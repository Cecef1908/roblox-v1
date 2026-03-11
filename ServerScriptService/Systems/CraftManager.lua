--[[
    CraftManager.lua (ModuleScript)
    ROLE : Gere le crafting (raffinage, forge).
    VALIDATION : Toutes les verifications sont serveur-side.
    RECETTES : Definies dans CraftConfig.
]]

local CraftManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)
local CraftConfig = require(ReplicatedStorage.Modules.Config.CraftConfig)

-- Cooldowns anti-spam
local CraftCooldowns = {}
local MIN_CRAFT_INTERVAL = 1

-- ==========================================
-- INIT
-- ==========================================
function CraftManager:Init()
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestCraft.OnServerEvent:Connect(function(player, recipeId)
        self:HandleCraft(player, recipeId)
    end)

    print("[CraftManager] Initialisé ✓")
end

-- ==========================================
-- TRAITER UNE REQUÊTE DE CRAFT
-- ==========================================
function CraftManager:HandleCraft(player: Player, recipeId: string)
    -- Anti-spam
    local now = os.clock()
    if CraftCooldowns[player.UserId] and (now - CraftCooldowns[player.UserId]) < MIN_CRAFT_INTERVAL then
        return
    end
    CraftCooldowns[player.UserId] = now

    -- Trouver la recette
    local recipe = nil
    for _, r in ipairs(CraftConfig.Recipes) do
        if r.Id == recipeId then
            recipe = r
            break
        end
    end

    if not recipe then
        warn("[CraftManager] Recette inconnue:", recipeId)
        return
    end

    local data = DataManager:GetData(player)
    if not data then return end

    -- Vérifier le niveau requis
    if data.Level < recipe.RequiredLevel then
        ReplicatedStorage.Events.RemoteEvents.CraftResult:FireClient(
            player, false, "Niveau insuffisant ! (requis: " .. recipe.RequiredLevel .. ")"
        )
        return
    end

    -- Vérifier les matériaux
    local displayNames = {
        Paillettes = "Paillettes", OrPur = "Or Pur", Lingots = "Lingots",
        Pepites = "Pépites", MineraiOr = "Minerai d'Or",
    }

    for _, input in ipairs(recipe.Inputs) do
        local qty = data.Inventory[input.Item] or 0
        if qty < input.Quantity then
            ReplicatedStorage.Events.RemoteEvents.CraftResult:FireClient(
                player, false, string.format(
                    "Il te manque %s (besoin: %d, tu as: %d)",
                    displayNames[input.Item] or input.Item, input.Quantity, qty
                )
            )
            return
        end
    end

    -- Retirer les matériaux
    for _, input in ipairs(recipe.Inputs) do
        DataManager:RemoveFromInventory(player, input.Item, input.Quantity)
    end

    -- Donner l'output
    DataManager:AddToInventory(player, recipe.Output.Item, recipe.Output.Quantity)

    -- XP
    DataManager:AddXP(player, recipe.XPReward or 10)

    -- Résultat au client
    local outputName = displayNames[recipe.Output.Item] or recipe.Output.Item
    ReplicatedStorage.Events.RemoteEvents.CraftResult:FireClient(
        player, true, string.format("%dx %s forgé !", recipe.Output.Quantity, outputName)
    )

    -- Mettre à jour les données client
    local updatedData = DataManager:GetData(player)
    if updatedData then
        local updateEvent = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("PlayerDataUpdated")
        if updateEvent then
            updateEvent:FireClient(player, updatedData)
        end
    end

    -- Notifier le QuestManager
    local QuestManager = require(ServerScriptService.Systems.QuestManager)
    QuestManager:OnCraft(player, recipe.Output.Item, recipe.Output.Quantity)

    print("[CraftManager]", player.Name, "a crafté", recipe.Id, "→", recipe.Output.Quantity, recipe.Output.Item)
end

return CraftManager
