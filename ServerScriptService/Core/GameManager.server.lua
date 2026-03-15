--[[
    GameManager.server.lua
    ROLE : Point d'entree serveur. Initialise tous les systemes,
           gere le cycle jour/nuit, coordonne les managers.
    DEPENDANCES : DataManager, EconomyManager, GoldSpawner, QuestManager,
                  CraftManager, BossManager, SaloonManager, LeaderboardManager
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- MapBuilder en premier (crée le monde, les events, les templates)
local MapBuilder = require(ServerScriptService.Systems.MapBuilder)

-- Modules (require les ModuleScripts)
local DataManager = require(ServerScriptService.Core.DataManager)
local EconomyManager = require(ServerScriptService.Core.EconomyManager)
local GoldSpawner = require(ServerScriptService.Systems.GoldSpawner)
local MiningSystem = require(ServerScriptService.Systems.MiningSystem)
local CraftManager = require(ServerScriptService.Systems.CraftManager)
local QuestManager = require(ServerScriptService.Systems.QuestManager)
local BossManager = require(ServerScriptService.Systems.BossManager)
local SaloonManager = require(ServerScriptService.Systems.SaloonManager)
local LeaderboardManager = require(ServerScriptService.Systems.LeaderboardManager)
local StoryManager = require(ServerScriptService.Systems.StoryManager)
local GameConfig = require(ReplicatedStorage.Modules.Config.GameConfig)

-- État global serveur
local GameState = {
    TimeOfDay = "Day",
    CycleTimer = 0,
    ServerStartTime = os.time(),
    ActivePlayers = {},
}

-- ==========================================
-- INITIALISATION
-- ==========================================
function Initialize()
    print("[GameManager] Initialisation du serveur...")

    -- 0. Construire le monde (remote events, templates, map, NPCs)
    MapBuilder:Init()

    -- 0.5. DevCommand RemoteEvent (après MapBuilder qui crée Events/)
    devEvent = Instance.new("RemoteEvent")
    devEvent.Name = "DevCommand"
    devEvent.Parent = ReplicatedStorage.Events.RemoteEvents
    devEvent.OnServerEvent:Connect(function(player, cmd)
        HandleDevCommand(player, cmd)
    end)

    -- 1. Initialiser le DataManager (ProfileStore)
    DataManager:Init()

    -- 2. Initialiser les systèmes
    EconomyManager:Init()
    GoldSpawner:Init()
    MiningSystem:Init()
    CraftManager:Init()
    QuestManager:Init()
    BossManager:Init()
    SaloonManager:Init()
    LeaderboardManager:Init()
    StoryManager:Init()

    -- 3. Connecter les événements joueurs
    Players.PlayerAdded:Connect(OnPlayerAdded)
    Players.PlayerRemoving:Connect(OnPlayerRemoving)

    -- 4. Gérer les joueurs déjà présents (en cas de script reload)
    for _, player in Players:GetPlayers() do
        task.spawn(OnPlayerAdded, player)
    end

    -- 5. Lancer le cycle jour/nuit
    -- RunService.Heartbeat:Connect(UpdateDayNightCycle) -- DÉSACTIVÉ temporairement

    print("[GameManager] Serveur initialisé ✓")
end

-- ==========================================
-- DEV COMMANDS — A RETIRER AVANT PUBLICATION
-- ==========================================
local function HandleDevCommand(player: Player, msg: string)
    if msg == "/give" then
        local data = DataManager:GetData(player)
        if not data then return end
        data.Inventory.Paillettes = (data.Inventory.Paillettes or 0) + 50
        data.Inventory.Pepites = (data.Inventory.Pepites or 0) + 20
        data.Inventory.MineraiOr = (data.Inventory.MineraiOr or 0) + 15
        data.Inventory.Quartz = (data.Inventory.Quartz or 0) + 5
        data.Inventory.Amethyste = (data.Inventory.Amethyste or 0) + 3
        data.Inventory.Topaze = (data.Inventory.Topaze or 0) + 1
        data.Cash = (data.Cash or 0) + 500
        data.XP = (data.XP or 0) + 200
        ReplicatedStorage.Events.RemoteEvents.PlayerDataUpdated:FireClient(player, data)
        print("[DevCmd] /give — inventaire rempli pour " .. player.Name)
    elseif msg == "/lvlup" then
        DataManager:AddXP(player, 500)
        local data = DataManager:GetData(player)
        if data then
            ReplicatedStorage.Events.RemoteEvents.PlayerDataUpdated:FireClient(player, data)
        end
        print("[DevCmd] /lvlup — +500 XP pour " .. player.Name)
    end
end

local function SetupDevCommands(player: Player)
    -- Legacy chat
    player.Chatted:Connect(function(msg)
        HandleDevCommand(player, msg)
    end)
end

-- DevCommand RemoteEvent — créé dans Initialize() après MapBuilder:Init()
local devEvent = nil

-- ==========================================
-- JOUEUR REJOINT
-- ==========================================
function OnPlayerAdded(player: Player)
    print("[GameManager] Joueur rejoint :", player.Name)

    -- Dev commands
    SetupDevCommands(player)

    -- 1. Charger / créer le profil
    local profile = DataManager:LoadProfile(player)
    if not profile then
        player:Kick("Erreur de chargement des données. Réessaie.")
        return
    end

    -- 2. Mettre à jour LastLogin
    profile.Data.LastLogin = os.time()
    if profile.Data.FirstJoin == 0 then
        profile.Data.FirstJoin = os.time()
    end

    -- 3. Initialiser la zone du joueur
    GameState.ActivePlayers[player.UserId] = true

    -- 4. Vérifier reset quotidien des quêtes
    QuestManager:CheckDailyReset(player)

    -- 5. Donner les outils à chaque spawn/respawn du character
    local lastEquippedChar = nil
    local function OnCharacterAdded(character)
        if lastEquippedChar == character then return end
        character:WaitForChild("Humanoid")
        task.wait(0.5) -- Attendre que Roblox finisse de vider/remplir le Backpack
        if lastEquippedChar == character then return end
        lastEquippedChar = character
        MiningSystem:EquipOwnedTools(player)
    end
    player.CharacterAdded:Connect(OnCharacterAdded)
    -- Si le character existe déjà (script reload)
    if player.Character then
        task.spawn(OnCharacterAdded, player.Character)
    end

    -- 6. Envoyer les données initiales au client
    local initEvent = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("InitPlayerData")
    if initEvent then
        initEvent:FireClient(player, profile.Data)
    end

    -- 7. Story quest chain
    task.delay(3, function()
        StoryManager:StartForPlayer(player)
    end)

    -- 8. Mettre à jour le leaderboard
    LeaderboardManager:UpdatePlayer(player)
end

-- ==========================================
-- JOUEUR QUITTE
-- ==========================================
function OnPlayerRemoving(player: Player)
    print("[GameManager] Joueur quitte :", player.Name)

    -- 1. Sauvegarder le profil
    DataManager:SaveAndReleaseProfile(player)

    -- 2. Nettoyer
    GameState.ActivePlayers[player.UserId] = nil
    LeaderboardManager:RemovePlayer(player)
end

-- ==========================================
-- CYCLE JOUR/NUIT
-- ==========================================
function UpdateDayNightCycle(deltaTime: number)
    local config = GameConfig.Saloon.DayNight
    GameState.CycleTimer = GameState.CycleTimer + deltaTime

    if GameState.CycleTimer >= config.CycleDuration then
        GameState.CycleTimer = 0
    end

    local dayDuration = config.CycleDuration * config.DayRatio
    local newTimeOfDay = (GameState.CycleTimer <= dayDuration) and "Day" or "Night"

    if newTimeOfDay ~= GameState.TimeOfDay then
        GameState.TimeOfDay = newTimeOfDay
        -- Notifier tous les clients
        local event = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("TimeOfDayChanged")
        if event then
            event:FireAllClients(newTimeOfDay)
        end

        -- Notifier le SaloonManager
        SaloonManager:OnTimeOfDayChanged(newTimeOfDay)

        print("[GameManager] Changement :", newTimeOfDay)
    end
end

-- ==========================================
-- GAME CLOSE — Sauvegarde d'urgence
-- ==========================================
game:BindToClose(function()
    print("[GameManager] Serveur en fermeture — sauvegarde d'urgence")
    DataManager:SaveAllProfiles()
    task.wait(3)
end)

-- Lancer !
Initialize()
