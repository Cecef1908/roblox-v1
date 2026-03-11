--[[
    EconomyManager.lua (ModuleScript)
    ROLE : Gere toutes les transactions d'achat/vente.
    VALIDATION : Toutes les verifications sont serveur-side.
]]

local EconomyManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)
local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
local ToolConfig = require(ReplicatedStorage.Modules.Config.ToolConfig)

-- ==========================================
-- INIT
-- ==========================================
function EconomyManager:Init()
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestSell.OnServerEvent:Connect(function(player, npcType, itemName, quantity)
        self:HandleSell(player, npcType, itemName, quantity)
    end)

    events.RequestBuyTool.OnServerEvent:Connect(function(player, toolName)
        self:HandleBuyTool(player, toolName)
    end)

    events.RequestUpgradeTool.OnServerEvent:Connect(function(player, toolName)
        self:HandleUpgradeTool(player, toolName)
    end)

    print("[EconomyManager] Initialisé ✓")
end

-- ==========================================
-- VENDRE DES ITEMS
-- ==========================================
function EconomyManager:HandleSell(player: Player, npcType: string, itemName: string, quantity: number)
    -- VALIDATION
    if type(quantity) ~= "number" or quantity <= 0 or quantity ~= math.floor(quantity) then
        warn("[EconomyManager] Quantité invalide de", player.Name)
        return
    end
    if quantity > 9999 then return end

    local priceTable = EconomyConfig.SellPrices[npcType]
    if not priceTable then return end

    local pricePerUnit = priceTable[itemName]
    if not pricePerUnit then
        ReplicatedStorage.Events.RemoteEvents.SellResult:FireClient(
            player, false, "Ce marchand n'achète pas cet item."
        )
        return
    end

    -- Vérifier que le joueur possède assez
    local data = DataManager:GetData(player)
    if not data or not data.Inventory[itemName] or data.Inventory[itemName] < quantity then
        ReplicatedStorage.Events.RemoteEvents.SellResult:FireClient(
            player, false, "Quantité insuffisante."
        )
        return
    end

    -- Effectuer la vente
    local totalCash = pricePerUnit * quantity
    DataManager:RemoveFromInventory(player, itemName, quantity)
    DataManager:AddCash(player, totalCash)
    DataManager:AddXP(player, EconomyConfig.XPRewards.SellTransaction)

    -- Notifier le QuestManager
    local QuestManager = require(ServerScriptService.Systems.QuestManager)
    QuestManager:OnSellTransaction(player, itemName, quantity, totalCash)

    -- Résultat au client
    ReplicatedStorage.Events.RemoteEvents.SellResult:FireClient(
        player, true, string.format("Vendu %dx %s pour %d$ !", quantity, itemName, totalCash)
    )

    -- Mettre à jour les données client (cash + inventaire changés)
    local updatedData = DataManager:GetData(player)
    if updatedData then
        local updateEvent = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("PlayerDataUpdated")
        if updateEvent then
            updateEvent:FireClient(player, updatedData)
        end
    end

    -- Mettre à jour le leaderboard
    local LeaderboardManager = require(ServerScriptService.Systems.LeaderboardManager)
    LeaderboardManager:UpdatePlayer(player)

    print("[EconomyManager]", player.Name, "a vendu", quantity, itemName, "pour", totalCash, "$")
end

-- ==========================================
-- ACHETER UN OUTIL
-- ==========================================
function EconomyManager:HandleBuyTool(player: Player, toolName: string)
    local toolData = ToolConfig.Tools[toolName]
    if not toolData then return end

    local data = DataManager:GetData(player)
    if not data then return end

    if data.Tools[toolName] and data.Tools[toolName].Owned then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Tu possèdes déjà cet outil !"
        )
        return
    end

    local price = toolData.Levels[1].BuyPrice
    if not price or price == 0 then return end

    if not DataManager:RemoveCash(player, price) then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Pas assez d'argent !"
        )
        return
    end

    data.Tools[toolName] = { Owned = true, Level = 1 }

    local MiningSystem = require(ServerScriptService.Systems.MiningSystem)
    MiningSystem:GiveTool(player, toolName)

    ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
        player, true, string.format("%s acheté pour %d$ !", toolData.DisplayName, price)
    )

    -- Mettre à jour les données client (cash + outils changés)
    local updatedData = DataManager:GetData(player)
    if updatedData then
        local updateEvent = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("PlayerDataUpdated")
        if updateEvent then
            updateEvent:FireClient(player, updatedData)
        end
    end
end

-- ==========================================
-- UPGRADE UN OUTIL
-- ==========================================
function EconomyManager:HandleUpgradeTool(player: Player, toolName: string)
    local toolData = ToolConfig.Tools[toolName]
    if not toolData then return end

    local data = DataManager:GetData(player)
    if not data then return end

    local currentTool = data.Tools[toolName]
    if not currentTool or not currentTool.Owned then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Tu ne possèdes pas cet outil !"
        )
        return
    end

    local nextLevel = currentTool.Level + 1
    local nextLevelData = toolData.Levels[nextLevel]
    if not nextLevelData then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Outil déjà au niveau maximum !"
        )
        return
    end

    local price = nextLevelData.UpgradePrice
    if not DataManager:RemoveCash(player, price) then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Pas assez d'argent !"
        )
        return
    end

    data.Tools[toolName].Level = nextLevel

    ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
        player, true, string.format(
            "%s amélioré au niveau %d pour %d$ !",
            toolData.DisplayName, nextLevel, price
        )
    )

    -- Mettre à jour les données client (cash + outils changés)
    local updatedData = DataManager:GetData(player)
    if updatedData then
        local updateEvent = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("PlayerDataUpdated")
        if updateEvent then
            updateEvent:FireClient(player, updatedData)
        end
    end
end

return EconomyManager
