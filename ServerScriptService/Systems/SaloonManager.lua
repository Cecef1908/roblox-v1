--[[
    SaloonManager.lua (ModuleScript)
    ROLE : Gere le saloon, les boissons et les buffs temporaires.
    CONFIG : GameConfig.Saloon contient les boissons, prix et durees.
]]

local SaloonManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)
local GameConfig = require(ReplicatedStorage.Modules.Config.GameConfig)

-- État
local CurrentTimeOfDay = "Day"

-- ==========================================
-- INIT
-- ==========================================
function SaloonManager:Init()
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestDrink.OnServerEvent:Connect(function(player, drinkId)
        self:HandleDrink(player, drinkId)
    end)

    print("[SaloonManager] Initialisé ✓")
end

-- ==========================================
-- TRAITER UNE COMMANDE DE BOISSON
-- ==========================================
function SaloonManager:HandleDrink(player: Player, drinkId: string)
    -- Trouver la boisson
    local drink = nil
    for _, d in ipairs(GameConfig.Saloon.Drinks) do
        if d.Id == drinkId then
            drink = d
            break
        end
    end

    if not drink then
        warn("[SaloonManager] Boisson inconnue:", drinkId)
        return
    end

    local data = DataManager:GetData(player)
    if not data then return end

    -- Vérifier limite quotidienne
    local today = math.floor(os.time() / 86400)
    local lastDrinkDay = math.floor(data.Saloon.LastDrinkTime / 86400)
    if today ~= lastDrinkDay then
        data.Saloon.DrinksToday = 0
    end

    if data.Saloon.DrinksToday >= GameConfig.Saloon.MaxDrinksPerDay then
        ReplicatedStorage.Events.RemoteEvents.DrinkResult:FireClient(
            player, false, "T'as assez bu pour aujourd'hui, cow-boy !"
        )
        return
    end

    -- Vérifier si un buff est déjà actif
    if data.Saloon.BuffActive and os.time() < data.Saloon.BuffExpiry then
        ReplicatedStorage.Events.RemoteEvents.DrinkResult:FireClient(
            player, false, "Tu as déjà un boost actif ! Attends qu'il expire."
        )
        return
    end

    -- Calculer le prix (réduction la nuit)
    local cost = drink.Cost
    if CurrentTimeOfDay == "Night" then
        cost = math.floor(cost * (1 - GameConfig.Saloon.DayNight.NightDrinkDiscount))
    end

    -- Vérifier l'argent
    if not DataManager:RemoveCash(player, cost) then
        ReplicatedStorage.Events.RemoteEvents.DrinkResult:FireClient(
            player, false, string.format("Pas assez d'argent ! (il faut %d$)", cost)
        )
        return
    end

    -- Appliquer le buff
    data.Saloon.BuffActive = drink.BuffType
    data.Saloon.BuffExpiry = os.time() + drink.Duration
    data.Saloon.LastDrinkTime = os.time()
    data.Saloon.DrinksToday = data.Saloon.DrinksToday + 1

    -- Feedback
    local buffDesc = drink.BuffType == "SpeedBoost" and "plus rapide" or "plus chanceux"
    local minutes = math.floor(drink.Duration / 60)
    ReplicatedStorage.Events.RemoteEvents.DrinkResult:FireClient(
        player, true, string.format("Santé ! Tu te sens %s pendant %d min ! (%d$)", buffDesc, minutes, cost)
    )

    -- Mettre à jour les données client
    local updatedData = DataManager:GetData(player)
    if updatedData then
        local updateEvent = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("PlayerDataUpdated")
        if updateEvent then
            updateEvent:FireClient(player, updatedData)
        end
    end

    print("[SaloonManager]", player.Name, "a bu", drink.Name, "buff:", drink.BuffType, "pour", cost, "$")
end

-- ==========================================
-- CALLBACK JOUR/NUIT
-- ==========================================
function SaloonManager:OnTimeOfDayChanged(timeOfDay: string)
    CurrentTimeOfDay = timeOfDay
    print("[SaloonManager] Heure :", timeOfDay, timeOfDay == "Night" and "(réductions actives)" or "")
end

return SaloonManager
