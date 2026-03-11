--[[
    MiningSystem.lua (ModuleScript)
    ROLE : Gere la logique de minage cote serveur.
           Recoit les requetes du client, valide, calcule les drops, distribue.
]]

local MiningSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local DataManager = require(ServerScriptService.Core.DataManager)
local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
local ToolConfig = require(ReplicatedStorage.Modules.Config.ToolConfig)

-- Cooldowns anti-spam
local MiningCooldowns = {} -- { [userId] = lastMineTime }
local MIN_MINE_INTERVAL = 2

-- ==========================================
-- INIT
-- ==========================================
function MiningSystem:Init()
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestMine.OnServerEvent:Connect(function(player, depositId)
        self:HandleMineRequest(player, depositId)
    end)

    events.BateeMinigameResult.OnServerEvent:Connect(function(player, depositId, score)
        self:HandleBateeResult(player, depositId, score)
    end)

    print("[MiningSystem] Initialisé ✓")
end

-- ==========================================
-- TRAITER UNE REQUÊTE DE MINAGE
-- ==========================================
function MiningSystem:HandleMineRequest(player: Player, depositId: string)
    print("[MiningSystem] RequestMine de", player.Name, "pour", depositId)

    -- Anti-spam
    local now = os.clock()
    if MiningCooldowns[player.UserId] and (now - MiningCooldowns[player.UserId]) < MIN_MINE_INTERVAL then
        print("[MiningSystem] Anti-spam bloque", player.Name)
        return
    end
    MiningCooldowns[player.UserId] = now

    -- Trouver le gisement
    local deposit = game.Workspace.ActiveGoldDeposits:FindFirstChild(depositId)
    if not deposit then
        warn("[MiningSystem] Deposit introuvable:", depositId)
        return
    end
    if not deposit:GetAttribute("IsActive") then
        warn("[MiningSystem] Deposit inactif:", depositId)
        return
    end

    -- Vérifier la distance (anti-exploit)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        warn("[MiningSystem] Pas de character pour", player.Name)
        return
    end
    local distance = (character.HumanoidRootPart.Position - self:GetDepositPosition(deposit)).Magnitude
    if distance > 15 then
        warn("[MiningSystem] Distance exploit:", player.Name, distance)
        return
    end

    -- Vérifier la zone et le niveau requis
    local zoneId = deposit:GetAttribute("ZoneId")
    local data = DataManager:GetData(player)
    if not data then
        warn("[MiningSystem] Pas de data pour", player.Name)
        return
    end

    local ZoneConfig = require(ReplicatedStorage.Modules.Config.ZoneConfig)
    local zoneData = ZoneConfig.Zones[zoneId]
    if data.Level < zoneData.RequiredLevel then
        print("[MiningSystem] Niveau insuffisant:", player.Name, "level", data.Level, "requis", zoneData.RequiredLevel)
        ReplicatedStorage.Events.RemoteEvents.MineResult:FireClient(
            player, false, "Niveau insuffisant pour cette zone !"
        )
        return
    end

    -- Vérifier que le joueur a un outil adapté
    local hasTool = self:HasValidTool(player, zoneId)
    if not hasTool then
        print("[MiningSystem] Pas d'outil valide pour", player.Name, "zone", zoneId)
        ReplicatedStorage.Events.RemoteEvents.MineResult:FireClient(
            player, false, "Tu n'as pas l'outil requis !"
        )
        return
    end

    -- Zone 1 : déclencher le mini-jeu de batée côté client
    if zoneId == "Zone1" then
        deposit:SetAttribute("IsActive", false)
        print("[MiningSystem] StartBateeMinigame envoyé à", player.Name, "deposit:", depositId)
        ReplicatedStorage.Events.RemoteEvents.StartBateeMinigame:FireClient(player, depositId)
        return
    end

    -- Zones 2 et 3 : minage direct
    print("[MiningSystem] Minage direct pour", player.Name, "zone:", zoneId)
    self:ProcessMining(player, deposit, zoneId, 1.0)
end

-- ==========================================
-- RÉSULTAT DU MINI-JEU DE BATÉE
-- ==========================================
function MiningSystem:HandleBateeResult(player: Player, depositId: string, score: number)
    print("[MiningSystem] BateeResult de", player.Name, "deposit:", depositId, "score:", score)

    if type(score) ~= "number" then
        warn("[MiningSystem] Score invalide (pas un nombre)")
        return
    end
    score = math.clamp(score, 0, 1)

    local deposit = game.Workspace.ActiveGoldDeposits:FindFirstChild(depositId)
    if not deposit then
        warn("[MiningSystem] Deposit introuvable pour BateeResult:", depositId)
        return
    end

    local zoneId = deposit:GetAttribute("ZoneId")
    print("[MiningSystem] ProcessMining avec score:", score, "zone:", zoneId)
    self:ProcessMining(player, deposit, zoneId, score)
end

-- ==========================================
-- TRAITEMENT DU MINAGE (calcul des drops)
-- ==========================================
function MiningSystem:ProcessMining(player: Player, deposit: Instance, zoneId: string, score: number)
    local data = DataManager:GetData(player)
    if not data then return end

    -- Déterminer la table de drops
    local dropTable = self:GetDropTable(zoneId, deposit)
    if not dropTable then return end

    -- Déterminer le bonus d'outil
    local toolLevel = self:GetBestToolLevel(player, zoneId)
    local qtyMultiplier = EconomyConfig.ToolBonuses.QuantityMultiplier[toolLevel] or 1.0

    -- Vérifier buff Saloon
    if data.Saloon.BuffActive == "LuckBoost" and os.time() < data.Saloon.BuffExpiry then
        qtyMultiplier = qtyMultiplier * 1.15
    end

    -- Appliquer le score du mini-jeu
    qtyMultiplier = qtyMultiplier * math.max(0.3, score)

    -- Calculer les drops + XP total
    local drops = {}
    local totalXP = 0
    for itemName, dropData in pairs(dropTable) do
        local roll = math.random(1, 100)
        if roll <= dropData.Chance then
            local baseQty = math.random(dropData.MinQty, dropData.MaxQty)
            local finalQty = math.max(1, math.floor(baseQty * qtyMultiplier))
            drops[itemName] = finalQty

            DataManager:AddToInventory(player, itemName, finalQty)

            local xpKey = "Mine" .. itemName
            local xp = EconomyConfig.XPRewards[xpKey] or 5
            totalXP = totalXP + xp
            DataManager:AddXP(player, xp)
        end
    end

    -- Si aucun drop, donner au moins 1 paillette
    if next(drops) == nil then
        drops["Paillettes"] = 1
        DataManager:AddToInventory(player, "Paillettes", 1)
        local xp = EconomyConfig.XPRewards.MinePaillette or 5
        totalXP = totalXP + xp
        DataManager:AddXP(player, xp)
    end

    -- Notifier le QuestManager
    local QuestManager = require(ServerScriptService.Systems.QuestManager)
    for itemName, qty in pairs(drops) do
        QuestManager:OnMineGold(player, itemName, qty)
    end

    -- Envoyer le résultat au client (drops + XP)
    print("[MiningSystem] Drops pour", player.Name, ":", drops, "XP:", totalXP)
    ReplicatedStorage.Events.RemoteEvents.MineResult:FireClient(player, true, drops, totalXP)

    -- Mettre à jour les données client
    local updatedData = DataManager:GetData(player)
    if updatedData then
        local updateEvent = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("PlayerDataUpdated")
        if updateEvent then
            updateEvent:FireClient(player, updatedData)
        end
    end

    -- Détruire le gisement
    local GoldSpawner = require(ServerScriptService.Systems.GoldSpawner)
    GoldSpawner:DestroyDeposit(deposit)
end

-- ==========================================
-- HELPERS
-- ==========================================
function MiningSystem:GetDropTable(zoneId: string, deposit: Instance)
    if zoneId == "Zone1" then
        return EconomyConfig.DropRates.Zone1
    elseif zoneId == "Zone2" then
        if deposit.Name:match("Filon") then
            return EconomyConfig.DropRates.Zone2_Filon
        end
        return EconomyConfig.DropRates.Zone2_Detecteur
    elseif zoneId == "Zone3" then
        return EconomyConfig.DropRates.Zone3
    end
    return nil
end

function MiningSystem:HasValidTool(player: Player, zoneId: string): boolean
    local data = DataManager:GetData(player)
    if not data then return false end

    local ZoneConfig = require(ReplicatedStorage.Modules.Config.ZoneConfig)
    local zoneData = ZoneConfig.Zones[zoneId]

    for _, toolName in ipairs(zoneData.AllowedTools) do
        if data.Tools[toolName] and data.Tools[toolName].Owned then
            return true
        end
    end
    return false
end

function MiningSystem:GetBestToolLevel(player: Player, zoneId: string): number
    local data = DataManager:GetData(player)
    if not data then return 1 end

    local ZoneConfig = require(ReplicatedStorage.Modules.Config.ZoneConfig)
    local zoneData = ZoneConfig.Zones[zoneId]
    local bestLevel = 1

    for _, toolName in ipairs(zoneData.AllowedTools) do
        if data.Tools[toolName] and data.Tools[toolName].Owned then
            bestLevel = math.max(bestLevel, data.Tools[toolName].Level)
        end
    end
    return bestLevel
end

function MiningSystem:GetDepositPosition(deposit: Instance): Vector3
    if deposit:IsA("Model") and deposit.PrimaryPart then
        return deposit.PrimaryPart.Position
    elseif deposit:IsA("BasePart") then
        return deposit.Position
    end
    return Vector3.zero
end

function MiningSystem:EquipOwnedTools(player: Player)
    local data = DataManager:GetData(player)
    if not data then
        warn("[MiningSystem] Pas de data pour", player.Name)
        return
    end

    for toolName, toolData in pairs(data.Tools) do
        if toolData.Owned then
            self:GiveTool(player, toolName)
        end
    end
end

function MiningSystem:GiveTool(player: Player, toolName: string)
    local itemModels = ServerStorage:FindFirstChild("ItemModels")
    if not itemModels then
        warn("[MiningSystem] ItemModels introuvable dans ServerStorage!")
        return
    end

    local template = itemModels:FindFirstChild("Tool_" .. toolName)
    if not template then
        warn("[MiningSystem] Template introuvable: Tool_" .. toolName)
        return
    end

    -- Ne pas donner en doublon
    if player.Backpack:FindFirstChild(toolName) then return end
    local character = player.Character
    if character and character:FindFirstChild(toolName) then return end

    local tool = template:Clone()
    tool.Name = toolName
    tool.Parent = player.Backpack
    print("[MiningSystem] Tool donné:", toolName, "à", player.Name)
end

return MiningSystem
