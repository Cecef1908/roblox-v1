--[[
    GoldSpawner.lua (ModuleScript)
    ROLE : Gere le spawn/respawn de gisements d'or et de gemmes dans les 3 zones.
    MECANIQUE : Chaque zone a des SpawnPoints. Le spawner cree des instances
                a partir de templates (ServerStorage) sur ces points.
]]

local GoldSpawner = {}

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
local ZoneConfig = require(ReplicatedStorage.Modules.Config.ZoneConfig)

-- État
local ActiveDeposits = {} -- { [zone] = { [spawnPointName] = depositInstance } }

-- ==========================================
-- INIT
-- ==========================================
function GoldSpawner:Init()
    for zoneId, zoneData in pairs(ZoneConfig.Zones) do
        ActiveDeposits[zoneId] = {}
        self:StartZoneSpawner(zoneId, zoneData)
    end

    print("[GoldSpawner] Initialisé ✓")
end

-- ==========================================
-- SPAWNER PAR ZONE
-- ==========================================
function GoldSpawner:StartZoneSpawner(zoneId: string, zoneData)
    task.spawn(function()
        while true do
            local zoneFolder = self:GetZoneFolder(zoneId)
            if zoneFolder then
                local spawnPoints = self:GetSpawnPoints(zoneFolder)
                local activeCount = self:CountActiveDeposits(zoneId)

                if activeCount < zoneData.MaxActiveDeposits then
                    for _, spawnPoint in ipairs(spawnPoints) do
                        if not ActiveDeposits[zoneId][spawnPoint.Name] then
                            self:SpawnDeposit(zoneId, spawnPoint)
                            break
                        end
                    end
                end
            end

            task.wait(zoneData.SpawnInterval)
        end
    end)
end

-- ==========================================
-- SPAWN UN GISEMENT
-- ==========================================
function GoldSpawner:SpawnDeposit(zoneId: string, spawnPoint: BasePart)
    local template = self:PickTemplate(zoneId)
    if not template then return end

    local deposit = template:Clone()
    deposit.Name = zoneId .. "_Deposit_" .. spawnPoint.Name
    deposit:SetAttribute("ZoneId", zoneId)
    deposit:SetAttribute("SpawnPointName", spawnPoint.Name)
    deposit:SetAttribute("IsActive", true)
    deposit:SetAttribute("SpawnTime", os.time())

    -- Déterminer le DisplayName depuis le template name
    local displayNames = {
        GoldDeposit_Paillette = "Paillettes d'Or",
        GoldDeposit_Pepite = "Pépite d'Or",
        GoldDeposit_Filon = "Filon d'Or",
        Gem_Quartz = "Quartz",
        Gem_Amethyste = "Améthyste",
        Gem_Topaze = "Topaze",
    }
    deposit:SetAttribute("DisplayName", displayNames[template.Name] or "Gisement")

    deposit.Parent = Workspace.ActiveGoldDeposits

    -- DEBUG: log position
    print(string.format("[GoldSpawner] Spawned %s at position (%d, %d, %d)", deposit.Name, spawnPoint.Position.X, spawnPoint.Position.Y, spawnPoint.Position.Z))

    -- Positionner avec rotation aléatoire pour varier le visuel
    local randomAngle = math.random() * math.pi * 2
    local spawnCFrame = spawnPoint.CFrame * CFrame.Angles(0, randomAngle, 0)
    if deposit:IsA("Model") then
        deposit:PivotTo(spawnCFrame)
    else
        deposit.CFrame = spawnCFrame
    end

    -- Ajouter ProximityPrompt
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Miner"
    prompt.ObjectText = deposit:GetAttribute("DisplayName") or "Gisement"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.RequiresLineOfSight = false
    prompt.Parent = deposit:IsA("Model") and deposit.PrimaryPart or deposit

    ActiveDeposits[zoneId][spawnPoint.Name] = deposit
    print("[GoldSpawner] Spawned", deposit.Name, "in", zoneId)
end

-- ==========================================
-- CHOISIR UN TEMPLATE
-- ==========================================
function GoldSpawner:PickTemplate(zoneId: string): Instance?
    local templates = ServerStorage.Templates
    if zoneId == "Zone1" then
        return templates.GoldDeposit_Paillette
    elseif zoneId == "Zone2" then
        return math.random() < 0.7
            and templates.GoldDeposit_Pepite
            or templates.GoldDeposit_Filon
    elseif zoneId == "Zone3" then
        local roll = math.random()
        if roll < 0.6 then
            return templates.GoldDeposit_Filon
        elseif roll < 0.9 then
            return templates.GoldDeposit_Pepite
        else
            local gems = {"Gem_Quartz", "Gem_Amethyste", "Gem_Topaze"}
            return templates[gems[math.random(#gems)]]
        end
    end
    return nil
end

-- ==========================================
-- DÉTRUIRE UN GISEMENT (après minage)
-- ==========================================
function GoldSpawner:DestroyDeposit(deposit: Instance)
    local zoneId = deposit:GetAttribute("ZoneId")
    local spawnPointName = deposit:GetAttribute("SpawnPointName")

    if zoneId and spawnPointName then
        ActiveDeposits[zoneId][spawnPointName] = nil
    end

    deposit:Destroy()
end

-- ==========================================
-- HELPERS
-- ==========================================
function GoldSpawner:GetZoneFolder(zoneId: string): Folder?
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return nil end
    local names = {
        Zone1 = "Zone1_RiviereTransquille",
        Zone2 = "Zone2_CollinesAmbrees",
        Zone3 = "Zone3_MineCrowCreek",
    }
    return mapFolder:FindFirstChild(names[zoneId] or "")
end

function GoldSpawner:GetSpawnPoints(zoneFolder: Folder): { BasePart }
    local points = {}
    for _, subfolder in zoneFolder:GetChildren() do
        if subfolder.Name:match("Spawn") or subfolder.Name:match("Filon")
            or subfolder.Name:match("Ore") or subfolder.Name:match("Gem") then
            for _, point in subfolder:GetChildren() do
                if point:IsA("BasePart") then
                    table.insert(points, point)
                end
            end
        end
    end
    return points
end

function GoldSpawner:CountActiveDeposits(zoneId: string): number
    local count = 0
    for _ in pairs(ActiveDeposits[zoneId] or {}) do
        count = count + 1
    end
    return count
end

return GoldSpawner
