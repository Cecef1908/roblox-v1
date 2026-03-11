--[[
    LeaderboardManager.lua (ModuleScript)
    ROLE : Gere le leaderboard visible en jeu (SurfaceGui sur un panneau).
    MECANIQUE : Utilise les donnees en memoire (pas d'OrderedDataStore en test).
    Affiche les top joueurs par Cash sur un panneau dans la ville.
]]

local LeaderboardManager = {}

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)

-- Leaderboard stats (updated in real-time)
local LeaderboardData = {} -- { {Name, Cash, Level} }

-- ==========================================
-- INIT
-- ==========================================
function LeaderboardManager:Init()
    -- Mettre à jour le leaderboard toutes les 30 secondes
    task.spawn(function()
        while true do
            task.wait(30)
            self:RefreshLeaderboard()
        end
    end)

    print("[LeaderboardManager] Initialisé ✓")
end

-- ==========================================
-- METTRE À JOUR UN JOUEUR
-- ==========================================
function LeaderboardManager:UpdatePlayer(player: Player)
    local data = DataManager:GetData(player)
    if not data then return end

    -- Mettre à jour ou ajouter
    local found = false
    for i, entry in ipairs(LeaderboardData) do
        if entry.UserId == player.UserId then
            entry.Name = player.Name
            entry.Cash = data.Cash or 0
            entry.Level = data.Level or 1
            entry.TotalCashEarned = data.TotalCashEarned or 0
            found = true
            break
        end
    end

    if not found then
        table.insert(LeaderboardData, {
            UserId = player.UserId,
            Name = player.Name,
            Cash = data.Cash or 0,
            Level = data.Level or 1,
            TotalCashEarned = data.TotalCashEarned or 0,
        })
    end

    -- Trier par TotalCashEarned (desc)
    table.sort(LeaderboardData, function(a, b)
        return a.TotalCashEarned > b.TotalCashEarned
    end)

    self:UpdateLeaderboardDisplay()
end

-- ==========================================
-- REFRESH COMPLET
-- ==========================================
function LeaderboardManager:RefreshLeaderboard()
    for _, player in Players:GetPlayers() do
        self:UpdatePlayer(player)
    end
end

-- ==========================================
-- AFFICHAGE — Roblox Leaderboard natif (leaderstats)
-- ==========================================
function LeaderboardManager:UpdateLeaderboardDisplay()
    -- Utiliser les leaderstats natifs de Roblox
    for _, player in Players:GetPlayers() do
        local data = DataManager:GetData(player)
        if data then
            local ls = player:FindFirstChild("leaderstats")
            if not ls then
                ls = Instance.new("Folder")
                ls.Name = "leaderstats"
                ls.Parent = player
            end

            -- Cash
            local cashStat = ls:FindFirstChild("Cash")
            if not cashStat then
                cashStat = Instance.new("IntValue")
                cashStat.Name = "Cash"
                cashStat.Parent = ls
            end
            cashStat.Value = data.Cash or 0

            -- Level
            local levelStat = ls:FindFirstChild("Level")
            if not levelStat then
                levelStat = Instance.new("IntValue")
                levelStat.Name = "Level"
                levelStat.Parent = ls
            end
            levelStat.Value = data.Level or 1
        end
    end
end

-- ==========================================
-- CLEANUP
-- ==========================================
function LeaderboardManager:RemovePlayer(player: Player)
    for i, entry in ipairs(LeaderboardData) do
        if entry.UserId == player.UserId then
            table.remove(LeaderboardData, i)
            break
        end
    end
end

return LeaderboardManager
