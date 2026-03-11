--[[
    DataManager.lua (ModuleScript)
    ROLE : Gere le chargement, la sauvegarde et la liberation des profils joueurs.
    UTILISE : ProfileStore (wrapper simplifie dans Lib)
    DONNEES : Voir DEFAULT_DATA ci-dessous
]]

local DataManager = {}

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileStore = require(ServerScriptService.Lib.ProfileStore)

-- CONSTANTES
local DATASTORE_NAME = "GoldRush_PlayerData_V1"
local SAVE_INTERVAL = 60

-- État
local ProfileStoreInstance = nil
local Profiles = {} -- { [player] = Profile }

-- ==========================================
-- DEFAULT DATA (nouveau joueur)
-- ==========================================
local DEFAULT_DATA = {
    Version = 1,
    FirstJoin = 0,
    LastLogin = 0,
    TotalPlayTime = 0,
    Cash = 50,
    TotalCashEarned = 0,
    XP = 0,
    Level = 1,
    Inventory = {
        Paillettes = 0, OrPur = 0, Lingots = 0,
        Pepites = 0, MineraiOr = 0,
        Quartz = 0, Amethyste = 0, Topaze = 0,
    },
    Tools = {
        Batee = { Owned = true, Level = 1 },
        Tapis = { Owned = false, Level = 0 },
        Pioche = { Owned = false, Level = 0 },
    },
    Quests = { DailyReset = 0, Active = {}, Completed = {} },
    Zones = { Zone1_Unlocked = true, Zone2_Unlocked = false, Zone3_Unlocked = false },
    Saloon = { LastDrinkTime = 0, DrinksToday = 0, BuffActive = nil, BuffExpiry = 0 },
    Boss = { GardienDefeated = 0, LastBossAttempt = 0 },
    Tutorial = { Completed = false, Step = 1 },
}

-- ==========================================
-- INIT
-- ==========================================
function DataManager:Init()
    ProfileStoreInstance = ProfileStore.New(DATASTORE_NAME, DEFAULT_DATA)
    print("[DataManager] ProfileStore initialisé")
end

-- ==========================================
-- CHARGER UN PROFIL
-- ==========================================
function DataManager:LoadProfile(player: Player)
    local profileKey = "Player_" .. player.UserId

    local profile = ProfileStoreInstance:LoadProfileAsync(profileKey, "ForceLoad")

    if not profile then
        warn("[DataManager] Échec chargement profil pour", player.Name)
        return nil
    end

    -- Si le joueur a quitté pendant le chargement
    if not player:IsDescendantOf(Players) then
        profile:Release()
        return nil
    end

    -- Setup du profil
    profile:AddUserId(player.UserId)
    profile:Reconcile()
    profile:ListenToRelease(function()
        Profiles[player] = nil
        if player:IsDescendantOf(Players) then
            player:Kick("Profil relâché — reconnecte-toi.")
        end
    end)

    Profiles[player] = profile

    -- Auto-save périodique
    task.spawn(function()
        while Profiles[player] do
            task.wait(SAVE_INTERVAL)
            if Profiles[player] and profile:IsActive() then
                -- ProfileStore wrapper handles save on Release
                -- For periodic save, we force a save
                pcall(function()
                    if profile._dataStore then
                        profile._dataStore:SetAsync(profileKey, profile.Data, profile._userIds)
                    end
                end)
            end
        end
    end)

    print("[DataManager] Profil chargé pour", player.Name)
    return profile
end

-- ==========================================
-- OBTENIR LE PROFIL D'UN JOUEUR
-- ==========================================
function DataManager:GetProfile(player: Player)
    return Profiles[player]
end

function DataManager:GetData(player: Player)
    local profile = Profiles[player]
    if profile then
        return profile.Data
    end
    return nil
end

-- ==========================================
-- SAUVEGARDER ET RELÂCHER
-- ==========================================
function DataManager:SaveAndReleaseProfile(player: Player)
    local profile = Profiles[player]
    if profile then
        profile:Release()
        Profiles[player] = nil
        print("[DataManager] Profil sauvé et relâché pour", player.Name)
    end
end

-- ==========================================
-- SAUVEGARDE D'URGENCE (tous les joueurs)
-- ==========================================
function DataManager:SaveAllProfiles()
    for player, profile in pairs(Profiles) do
        if profile then
            profile:Release()
        end
    end
    Profiles = {}
    print("[DataManager] Tous les profils sauvés et relâchés")
end

-- ==========================================
-- UTILITAIRES DE MODIFICATION
-- ==========================================
function DataManager:UpdateData(player: Player, key: string, value: any)
    local data = self:GetData(player)
    if data then
        data[key] = value
    end
end

function DataManager:AddToInventory(player: Player, itemName: string, quantity: number)
    local data = self:GetData(player)
    if data and data.Inventory[itemName] ~= nil then
        data.Inventory[itemName] = data.Inventory[itemName] + quantity
        return true
    end
    return false
end

function DataManager:RemoveFromInventory(player: Player, itemName: string, quantity: number): boolean
    local data = self:GetData(player)
    if data and data.Inventory[itemName] and data.Inventory[itemName] >= quantity then
        data.Inventory[itemName] = data.Inventory[itemName] - quantity
        return true
    end
    return false
end

function DataManager:AddCash(player: Player, amount: number)
    local data = self:GetData(player)
    if data then
        data.Cash = data.Cash + amount
        data.TotalCashEarned = data.TotalCashEarned + amount
    end
end

function DataManager:RemoveCash(player: Player, amount: number): boolean
    local data = self:GetData(player)
    if data and data.Cash >= amount then
        data.Cash = data.Cash - amount
        return true
    end
    return false
end

function DataManager:AddXP(player: Player, amount: number)
    local data = self:GetData(player)
    if data then
        data.XP = data.XP + amount
        -- Vérifier level up
        local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
        for level, threshold in pairs(EconomyConfig.LevelThresholds) do
            if data.XP >= threshold.MinXP and level > data.Level then
                data.Level = level
                -- Débloquer zones
                if level == 2 then data.Zones.Zone2_Unlocked = true end
                if level == 3 then data.Zones.Zone3_Unlocked = true end
                -- Notifier le client
                local event = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("LevelUp")
                if event then
                    event:FireClient(player, level, threshold.Name)
                end
                print("[DataManager] Level up!", player.Name, "→", threshold.Name)
            end
        end
    end
end

return DataManager
