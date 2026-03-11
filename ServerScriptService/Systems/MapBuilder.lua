--[[
    MapBuilder.lua (ModuleScript)
    ROLE : Génère le monde au runtime : terrain, ville, zones de minage,
           NPCs marchands, templates de gisements, remote events.
    APPELÉ PAR : GameManager:Init() en tout premier.
]]

local MapBuilder = {}

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local ZoneConfig = require(ReplicatedStorage.Modules.Config.ZoneConfig)

-- ═══════════════════════════════════════════
-- COULEURS
-- ═══════════════════════════════════════════
local C = {
    grass      = Color3.fromRGB(76, 140, 53),
    dirt       = Color3.fromRGB(120, 85, 50),
    road       = Color3.fromRGB(75, 70, 60),
    water      = Color3.fromRGB(50, 120, 180),
    waterDeep  = Color3.fromRGB(30, 80, 140),
    sand       = Color3.fromRGB(210, 190, 140),
    wood       = Color3.fromRGB(130, 85, 45),
    woodDark   = Color3.fromRGB(90, 60, 30),
    stone      = Color3.fromRGB(140, 135, 125),
    stoneDark  = Color3.fromRGB(100, 95, 85),
    roof       = Color3.fromRGB(160, 80, 40),
    gold       = Color3.fromRGB(255, 215, 0),
    sign       = Color3.fromRGB(180, 140, 60),
    tent       = Color3.fromRGB(200, 180, 140),
}

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════
local function makePart(props)
    local p = Instance.new("Part")
    p.Anchored = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    for k, v in pairs(props) do
        if k ~= "Parent" then
            p[k] = v
        end
    end
    p.Parent = props.Parent or Workspace
    return p
end

local function makeWall(name, size, position, color, parent)
    return makePart({
        Name = name,
        Size = size,
        Position = position,
        Color = color,
        Material = Enum.Material.SmoothPlastic,
        Parent = parent,
    })
end

-- Raycast vers le bas pour trouver la hauteur du terrain
local function getTerrainHeight(x, z)
    local ray = Workspace:Raycast(
        Vector3.new(x, 500, z),
        Vector3.new(0, -1000, 0),
        RaycastParams.new()
    )
    return ray and ray.Position.Y or 5
end

-- SurfaceGui pour les panneaux de zone (remplace addBillboard)
local function addZoneSign(parent, text, textColor)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 50
    gui.Parent = parent

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0.05, 0)
    padding.PaddingRight = UDim.new(0.05, 0)
    padding.PaddingTop = UDim.new(0.1, 0)
    padding.PaddingBottom = UDim.new(0.1, 0)
    padding.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor or Color3.new(1, 1, 1)
    label.TextStrokeColor3 = Color3.fromRGB(30, 20, 10)
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.Antique
    label.Parent = gui

    -- Aussi sur la face arrière
    local gui2 = gui:Clone()
    gui2.Face = Enum.NormalId.Back
    gui2.Parent = parent
end

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
function MapBuilder:Init()
    print("[MapBuilder] Construction du monde...")
    self:CreateRemoteEvents()
    self:CreateFolders()
    self:SetupAtmosphere()
    self:CreateTemplates()
    self:CreateItemModels()
    self:CreateWorld()
    self:SetupAmbiance()
    -- self:StartDayNightCycle() -- DÉSACTIVÉ temporairement
    print("[MapBuilder] Monde construit ✓")
end

-- ═══════════════════════════════════════════
-- REMOTE EVENTS
-- ═══════════════════════════════════════════
function MapBuilder:CreateRemoteEvents()
    local eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "Events"

    local remoteEvents = Instance.new("Folder")
    remoteEvents.Name = "RemoteEvents"

    local eventNames = {
        -- Mining
        "RequestMine", "MineResult",
        "StartBateeMinigame", "BateeMinigameResult",
        -- Player data
        "InitPlayerData", "PlayerDataUpdated",
        -- Notifications
        "NotifyPlayer", "LevelUp",
        -- Day/Night
        "TimeOfDayChanged",
        -- Tutorial
        "StartTutorial",
        -- Economy
        "RequestSell", "SellResult",
        "RequestBuyTool", "RequestUpgradeTool", "ShopResult",
        -- Craft
        "RequestCraft", "CraftResult",
        -- Saloon
        "RequestDrink", "DrinkResult",
        -- Quests
        "RequestQuestData", "QuestDataResponse", "QuestCompleted",
    }

    -- Create all events BEFORE parenting folders (avoid client race condition)
    for _, name in ipairs(eventNames) do
        local event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = remoteEvents
    end

    remoteEvents.Parent = eventsFolder
    eventsFolder.Parent = ReplicatedStorage

    print("[MapBuilder] " .. #eventNames .. " RemoteEvents créés")
end

-- ═══════════════════════════════════════════
-- DOSSIERS WORKSPACE
-- ═══════════════════════════════════════════
function MapBuilder:CreateFolders()
    -- ActiveGoldDeposits — requis par MiningClient/GoldSpawner
    local deposits = Instance.new("Folder")
    deposits.Name = "ActiveGoldDeposits"
    deposits.Parent = Workspace

    -- Map — structure de zones (spawn points à ajouter plus tard)
    local map = Instance.new("Folder")
    map.Name = "Map"
    map.Parent = Workspace
end

function MapBuilder:CreateSpawnPoints(zoneId, parentFolder, zoneData)
    local center = zoneData.WorldPosition
    local count = zoneData.MaxActiveDeposits + 4 -- quelques extras

    for i = 1, count do
        local angle = (i / count) * math.pi * 2 + math.random() * 0.5
        local radius = 15 + math.random() * 25
        local x = center.X + math.cos(angle) * radius
        local z = center.Z + math.sin(angle) * radius

        local pt = makePart({
            Name = "SP_" .. i,
            Size = Vector3.new(3, 0.1, 3),
            Position = Vector3.new(x, 1.5, z),
            Transparency = 1,
            CanCollide = false,
            Anchored = true,
            Parent = parentFolder,
        })
        pt:SetAttribute("ZoneId", zoneId)
    end

    print("[MapBuilder] " .. count .. " spawn points dans " .. zoneId)
end

-- ═══════════════════════════════════════════
-- TEMPLATES (ServerStorage)
-- ═══════════════════════════════════════════
function MapBuilder:CreateTemplates()
    local templates = Instance.new("Folder")
    templates.Name = "Templates"
    templates.Parent = ServerStorage

    -- ═══ GoldDeposit_Paillette (Zone 1 — petites roches dans le sable) ═══
    local paillette = Instance.new("Model")
    paillette.Name = "GoldDeposit_Paillette"

    local pRoot = Instance.new("Part")
    pRoot.Name = "Root"
    -- Shape = Block (défaut) pour que SpecialMesh fonctionne correctement
    pRoot.Size = Vector3.new(2.5, 1.8, 3)
    pRoot.Color = Color3.fromRGB(140, 125, 100)
    pRoot.Material = Enum.Material.Sandstone
    pRoot.Anchored = true
    pRoot.CanCollide = false
    pRoot.CFrame = CFrame.new(0, 0.9, 0)
    pRoot.Parent = paillette

    local pMesh = Instance.new("SpecialMesh")
    pMesh.MeshType = Enum.MeshType.Sphere
    pMesh.Scale = Vector3.new(1.2, 0.7, 1.3)
    pMesh.Parent = pRoot

    local pRock2 = Instance.new("Part")
    pRock2.Name = "SmallRock"
    pRock2.Size = Vector3.new(1.5, 1.2, 1.8)
    pRock2.Color = Color3.fromRGB(130, 115, 90)
    pRock2.Material = Enum.Material.Rock
    pRock2.Anchored = true
    pRock2.CanCollide = false
    pRock2.CFrame = CFrame.new(1.5, 0.6, 0.5) * CFrame.Angles(0.2, 0.8, 0.1)
    pRock2.Parent = paillette

    -- Éclat doré subtil entre les roches
    local pGold = Instance.new("Part")
    pGold.Name = "GoldFleck"
    pGold.Size = Vector3.new(0.6, 0.15, 0.4)
    pGold.Color = Color3.fromRGB(200, 170, 40)
    pGold.Material = Enum.Material.SmoothPlastic
    pGold.Transparency = 0
    pGold.Anchored = true
    pGold.CanCollide = false
    pGold.CFrame = CFrame.new(0.3, 1.4, 0.2) * CFrame.Angles(0.1, 0.4, 0.2)
    pGold.Parent = paillette

    local pLight = Instance.new("PointLight")
    pLight.Color = C.gold
    pLight.Brightness = 0.3
    pLight.Range = 5
    pLight.Parent = pRoot

    self:AddGoldParticles(pRoot, 3, 0.15)

    paillette.PrimaryPart = pRoot
    paillette.Parent = templates

    -- ═══ GoldDeposit_Pepite (Zone 2 — rocher moyen avec veine dorée) ═══
    local pepite = Instance.new("Model")
    pepite.Name = "GoldDeposit_Pepite"

    local peRoot = Instance.new("Part")
    peRoot.Name = "Root"
    -- Shape = Block pour que SpecialMesh fonctionne
    peRoot.Size = Vector3.new(3.5, 2.5, 3)
    peRoot.Color = Color3.fromRGB(128, 120, 108)
    peRoot.Material = Enum.Material.Rock
    peRoot.Anchored = true
    peRoot.CanCollide = false
    peRoot.CFrame = CFrame.new(0, 1.25, 0)
    peRoot.Parent = pepite

    local peMesh = Instance.new("SpecialMesh")
    peMesh.MeshType = Enum.MeshType.Sphere
    peMesh.Scale = Vector3.new(1.1, 0.8, 1.2)
    peMesh.Parent = peRoot

    local peRock2 = Instance.new("Part")
    peRock2.Name = "Rock2"
    peRock2.Size = Vector3.new(2, 1.8, 2.5)
    peRock2.Color = Color3.fromRGB(115, 108, 95)
    peRock2.Material = Enum.Material.Rock
    peRock2.Anchored = true
    peRock2.CanCollide = false
    peRock2.CFrame = CFrame.new(-1.8, 0.9, 0.8) * CFrame.Angles(0.15, 1.2, 0.1)
    peRock2.Parent = pepite

    local peRock2Mesh = Instance.new("SpecialMesh")
    peRock2Mesh.MeshType = Enum.MeshType.Sphere
    peRock2Mesh.Scale = Vector3.new(1.3, 0.9, 1.1)
    peRock2Mesh.Parent = peRock2

    -- Veine dorée intégrée dans la roche (subtile, pas Neon)
    local peVein = Instance.new("Part")
    peVein.Name = "GoldVein"
    peVein.Size = Vector3.new(1.8, 0.15, 0.3)
    peVein.Color = Color3.fromRGB(200, 170, 40)
    peVein.Material = Enum.Material.SmoothPlastic
    peVein.Transparency = 0
    peVein.Anchored = true
    peVein.CanCollide = false
    peVein.CFrame = CFrame.new(0.2, 1.5, 0.9) * CFrame.Angles(0.1, 0.3, 0.2)
    peVein.Parent = pepite

    local peLight = Instance.new("PointLight")
    peLight.Color = C.gold
    peLight.Brightness = 0.4
    peLight.Range = 6
    peLight.Parent = peRoot

    self:AddGoldParticles(peRoot, 4, 0.2)

    pepite.PrimaryPart = peRoot
    pepite.Parent = templates

    -- ═══ GoldDeposit_Filon (Zone 2-3 — gros rocher avec veine épaisse) ═══
    local filon = Instance.new("Model")
    filon.Name = "GoldDeposit_Filon"

    local fRoot = Instance.new("Part")
    fRoot.Name = "Root"
    -- Shape = Block pour que SpecialMesh fonctionne
    fRoot.Size = Vector3.new(5, 3.5, 4)
    fRoot.Color = Color3.fromRGB(95, 90, 80)
    fRoot.Material = Enum.Material.Slate
    fRoot.Anchored = true
    fRoot.CanCollide = false
    fRoot.CFrame = CFrame.new(0, 1.75, 0)
    fRoot.Parent = filon

    local fMesh = Instance.new("SpecialMesh")
    fMesh.MeshType = Enum.MeshType.Sphere
    fMesh.Scale = Vector3.new(1.0, 0.85, 1.1)
    fMesh.Parent = fRoot

    local fRock2 = Instance.new("Part")
    fRock2.Name = "Rock2"
    fRock2.Size = Vector3.new(3, 2.5, 3.5)
    fRock2.Color = Color3.fromRGB(85, 80, 72)
    fRock2.Material = Enum.Material.Slate
    fRock2.Anchored = true
    fRock2.CanCollide = false
    fRock2.CFrame = CFrame.new(2.5, 1.2, 1) * CFrame.Angles(0.1, 0.7, 0.15)
    fRock2.Parent = filon

    local fRock2Mesh = Instance.new("SpecialMesh")
    fRock2Mesh.MeshType = Enum.MeshType.Sphere
    fRock2Mesh.Scale = Vector3.new(1.2, 0.75, 1.0)
    fRock2Mesh.Parent = fRock2

    -- Accent anguleux
    local fRock3 = Instance.new("WedgePart")
    fRock3.Name = "Rock3"
    fRock3.Size = Vector3.new(2, 1.8, 2.5)
    fRock3.Color = Color3.fromRGB(100, 95, 85)
    fRock3.Material = Enum.Material.Rock
    fRock3.Anchored = true
    fRock3.CanCollide = false
    fRock3.CFrame = CFrame.new(-2, 0.9, -0.5) * CFrame.Angles(0.05, 2.1, 0)
    fRock3.Parent = filon

    -- Veine dorée intégrée (subtile)
    local fVein = Instance.new("Part")
    fVein.Name = "GoldVein"
    fVein.Size = Vector3.new(2.5, 0.2, 0.4)
    fVein.Color = Color3.fromRGB(200, 170, 40)
    fVein.Material = Enum.Material.SmoothPlastic
    fVein.Transparency = 0
    fVein.Anchored = true
    fVein.CanCollide = false
    fVein.CFrame = CFrame.new(0, 2.0, 0.9) * CFrame.Angles(0.15, 0.2, 0.1)
    fVein.Parent = filon

    -- Veine secondaire
    local fVein2 = Instance.new("Part")
    fVein2.Name = "GoldVein2"
    fVein2.Size = Vector3.new(1.5, 0.15, 0.3)
    fVein2.Color = Color3.fromRGB(200, 170, 40)
    fVein2.Material = Enum.Material.SmoothPlastic
    fVein2.Transparency = 0
    fVein2.Anchored = true
    fVein2.CanCollide = false
    fVein2.CFrame = CFrame.new(1, 1.2, -0.6) * CFrame.Angles(0.3, -0.5, 0.1)
    fVein2.Parent = filon

    local fLight = Instance.new("PointLight")
    fLight.Color = C.gold
    fLight.Brightness = 0.5
    fLight.Range = 8
    fLight.Parent = fRoot

    self:AddGoldParticles(fRoot, 5, 0.25)

    filon.PrimaryPart = fRoot
    filon.Parent = templates

    -- ═══ GEMMES (Zone 3 — rocher sombre + cristal coloré) ═══
    local gemData = {
        { Name = "Gem_Quartz",    CrystalColor = Color3.fromRGB(240, 240, 255), LightColor = Color3.fromRGB(220, 220, 255) },
        { Name = "Gem_Amethyste", CrystalColor = Color3.fromRGB(150, 50, 200),  LightColor = Color3.fromRGB(180, 80, 255) },
        { Name = "Gem_Topaze",    CrystalColor = Color3.fromRGB(255, 180, 0),   LightColor = Color3.fromRGB(255, 200, 50) },
    }

    for _, gem in ipairs(gemData) do
        local gemModel = Instance.new("Model")
        gemModel.Name = gem.Name

        local gRoot = Instance.new("Part")
        gRoot.Name = "Root"
        -- Shape = Block pour que SpecialMesh fonctionne
        gRoot.Size = Vector3.new(3, 2.5, 3)
        gRoot.Color = Color3.fromRGB(70, 65, 60)
        gRoot.Material = Enum.Material.Basalt
        gRoot.Anchored = true
        gRoot.CanCollide = false
        gRoot.CFrame = CFrame.new(0, 1.25, 0)
        gRoot.Parent = gemModel

        local gMesh = Instance.new("SpecialMesh")
        gMesh.MeshType = Enum.MeshType.Sphere
        gMesh.Scale = Vector3.new(1.1, 0.85, 1.0)
        gMesh.Parent = gRoot

        -- Cristal principal
        local crystal1 = Instance.new("WedgePart")
        crystal1.Name = "Crystal1"
        crystal1.Size = Vector3.new(0.6, 1.8, 0.8)
        crystal1.Color = gem.CrystalColor
        crystal1.Material = Enum.Material.Glass
        crystal1.Transparency = 0.3
        crystal1.Anchored = true
        crystal1.CanCollide = false
        crystal1.CFrame = CFrame.new(0.3, 2.2, 0) * CFrame.Angles(0.15, 0.3, -0.2)
        crystal1.Parent = gemModel

        -- Cristal secondaire (plus petit)
        local crystal2 = Instance.new("WedgePart")
        crystal2.Name = "Crystal2"
        crystal2.Size = Vector3.new(0.4, 1.2, 0.5)
        crystal2.Color = gem.CrystalColor
        crystal2.Material = Enum.Material.Glass
        crystal2.Transparency = 0.35
        crystal2.Anchored = true
        crystal2.CanCollide = false
        crystal2.CFrame = CFrame.new(-0.5, 1.8, 0.3) * CFrame.Angles(-0.1, 0.8, 0.15)
        crystal2.Parent = gemModel

        local gLight = Instance.new("PointLight")
        gLight.Color = gem.LightColor
        gLight.Brightness = 0.6
        gLight.Range = 6
        gLight.Parent = crystal1

        -- Particules légères
        local gParticles = Instance.new("ParticleEmitter")
        gParticles.Color = ColorSequence.new(gem.CrystalColor)
        gParticles.Size = NumberSequence.new(0.2, 0)
        gParticles.Lifetime = NumberRange.new(0.5, 1.5)
        gParticles.Rate = 3
        gParticles.Speed = NumberRange.new(0.5, 1.5)
        gParticles.SpreadAngle = Vector2.new(180, 180)
        gParticles.Parent = crystal1

        gemModel.PrimaryPart = gRoot
        gemModel.Parent = templates
    end

    print("[MapBuilder] 6 templates créés")
end

function MapBuilder:AddGoldParticles(parent, rate, size)
    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(Color3.fromRGB(220, 190, 50))
    particles.Size = NumberSequence.new(size, 0)
    particles.Lifetime = NumberRange.new(1, 2.5)
    particles.Rate = rate
    particles.Speed = NumberRange.new(0.3, 1)
    particles.SpreadAngle = Vector2.new(120, 120)
    particles.LightEmission = 0.3
    particles.Parent = parent
end

-- ═══════════════════════════════════════════
-- ITEM MODELS (outils dans ServerStorage)
-- ═══════════════════════════════════════════
function MapBuilder:CreateItemModels()
    local models = Instance.new("Folder")
    models.Name = "ItemModels"
    models.Parent = ServerStorage

    -- ═══ BATÉE (disque plat en bois — cylindre fin) ═══
    local batee = Instance.new("Tool")
    batee.Name = "Tool_Batee"
    batee.CanBeDropped = false
    batee.Grip = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(-45), 0, 0)
    batee.Parent = models

    local bateeHandle = Instance.new("Part")
    bateeHandle.Name = "Handle"
    bateeHandle.Shape = Enum.PartType.Cylinder
    bateeHandle.Size = Vector3.new(0.4, 2, 2)
    bateeHandle.Color = Color3.fromRGB(160, 120, 60)
    bateeHandle.Material = Enum.Material.Wood
    bateeHandle.CanCollide = false
    bateeHandle.Parent = batee

    -- ═══ TAPIS (tissu plat) ═══
    local tapis = Instance.new("Tool")
    tapis.Name = "Tool_Tapis"
    tapis.CanBeDropped = false
    tapis.Grip = CFrame.new(0, -0.3, 0) * CFrame.Angles(math.rad(-20), 0, 0)
    tapis.Parent = models

    local tapisHandle = Instance.new("Part")
    tapisHandle.Name = "Handle"
    tapisHandle.Size = Vector3.new(2.5, 0.08, 1.5)
    tapisHandle.Color = Color3.fromRGB(180, 160, 120)
    tapisHandle.Material = Enum.Material.Fabric
    tapisHandle.CanCollide = false
    tapisHandle.Parent = tapis

    -- ═══ PIOCHE (manche block vertical + tête wedge + soudures) ═══
    local pioche = Instance.new("Tool")
    pioche.Name = "Tool_Pioche"
    pioche.CanBeDropped = false
    pioche.Grip = CFrame.new(0, -0.8, 0) -- Main saisit en bas du manche, tête en haut
    pioche.Parent = models

    -- Manche en bois (block vertical — aligne naturellement avec le bras)
    local piocheHandle = Instance.new("Part")
    piocheHandle.Name = "Handle"
    piocheHandle.Size = Vector3.new(0.35, 3.5, 0.35)
    piocheHandle.Color = Color3.fromRGB(139, 90, 43)
    piocheHandle.Material = Enum.Material.Wood
    piocheHandle.CanCollide = false
    piocheHandle.Parent = pioche

    -- Tête de pioche (pointe avant — WedgePart)
    local pickHead = Instance.new("WedgePart")
    pickHead.Name = "PickHead"
    pickHead.Size = Vector3.new(0.35, 0.6, 1.4)
    pickHead.Color = Color3.fromRGB(130, 130, 135)
    pickHead.Material = Enum.Material.Metal
    pickHead.CanCollide = false
    pickHead.CFrame = piocheHandle.CFrame * CFrame.new(0, 1.45, 0.75)
    pickHead.Parent = pioche

    local weld1 = Instance.new("WeldConstraint")
    weld1.Part0 = piocheHandle
    weld1.Part1 = pickHead
    weld1.Parent = piocheHandle

    -- Contre-pointe (arrière, plus courte)
    local pickBack = Instance.new("WedgePart")
    pickBack.Name = "PickBack"
    pickBack.Size = Vector3.new(0.35, 0.5, 0.8)
    pickBack.Color = Color3.fromRGB(130, 130, 135)
    pickBack.Material = Enum.Material.Metal
    pickBack.CanCollide = false
    pickBack.CFrame = piocheHandle.CFrame * CFrame.new(0, 1.4, -0.45) * CFrame.Angles(0, math.rad(180), 0)
    pickBack.Parent = pioche

    local weld2 = Instance.new("WeldConstraint")
    weld2.Part0 = piocheHandle
    weld2.Part1 = pickBack
    weld2.Parent = piocheHandle

    -- Raccord métal entre tête et manche
    local collar = Instance.new("Part")
    collar.Name = "Collar"
    collar.Size = Vector3.new(0.55, 0.55, 0.55)
    collar.Color = Color3.fromRGB(100, 100, 100)
    collar.Material = Enum.Material.Metal
    collar.CanCollide = false
    collar.CFrame = piocheHandle.CFrame * CFrame.new(0, 1.45, 0)
    collar.Parent = pioche

    local weld3 = Instance.new("WeldConstraint")
    weld3.Part0 = piocheHandle
    weld3.Part1 = collar
    weld3.Parent = piocheHandle

    print("[MapBuilder] 3 outils créés")
end

-- ═══════════════════════════════════════════
-- MONDE (terrain, NPCs, zones)
-- Les bâtiments de la ville sont placés en dur
-- dans le Workspace (via MCP create_build).
-- On ne génère ici que le sol, spawn, chemins,
-- NPCs et zones de minage.
-- ═══════════════════════════════════════════
-- ═══════════════════════════════════════════
-- ATMOSPHÈRE & POST-PROCESSING
-- ═══════════════════════════════════════════
function MapBuilder:SetupAtmosphere()
    local Lighting = game:GetService("Lighting")

    -- Atmosphere — brume western dorée
    local atmo = Instance.new("Atmosphere")
    atmo.Density = 0.3
    atmo.Offset = 0.25
    atmo.Color = Color3.fromRGB(200, 180, 140)
    atmo.Decay = Color3.fromRGB(180, 150, 100)
    atmo.Glare = 0.15
    atmo.Haze = 2.5
    atmo.Parent = Lighting

    -- Bloom doux
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.4
    bloom.Size = 30
    bloom.Threshold = 1.5
    bloom.Parent = Lighting

    -- Rayons de soleil
    local sunRays = Instance.new("SunRaysEffect")
    sunRays.Intensity = 0.08
    sunRays.Spread = 0.6
    sunRays.Parent = Lighting

    -- Teinte chaude dorée
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Brightness = 0.02
    cc.Contrast = 0.05
    cc.Saturation = 0.1
    cc.TintColor = Color3.fromRGB(255, 240, 210)
    cc.Parent = Lighting

    -- Depth of Field léger (lointain flou)
    local dof = Instance.new("DepthOfFieldEffect")
    dof.FarIntensity = 0.1
    dof.FocusDistance = 100
    dof.InFocusRadius = 80
    dof.NearIntensity = 0
    dof.Parent = Lighting

    print("[MapBuilder] Atmosphère western configurée ✓")
end

-- ═══════════════════════════════════════════
-- AMBIANCE (sons, fumée, poussière)
-- ═══════════════════════════════════════════
function MapBuilder:SetupAmbiance()
    -- TODO: Ajouter sons ambiants quand on aura uploadé les assets audio
    -- (Roblox restreint les IDs audio tiers)

    -- Fumée de cheminée — Forge
    local forge = Workspace:FindFirstChild("Forge")
    if forge then
        self:AddChimneySmoke(forge)
    end

    -- Fumée — Saloon
    local saloon = Workspace:FindFirstChild("Saloon")
    if saloon then
        self:AddChimneySmoke(saloon)
    end

    -- Poussière dans la rue
    local mainStreet = Workspace:FindFirstChild("MainStreet")
    if mainStreet then
        local road = mainStreet:FindFirstChild("Road")
        if road then
            local dust = Instance.new("ParticleEmitter")
            dust.Name = "StreetDust"
            dust.Color = ColorSequence.new(Color3.fromRGB(180, 160, 120))
            dust.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.3, 1.5),
                NumberSequenceKeypoint.new(1, 0),
            })
            dust.Lifetime = NumberRange.new(3, 6)
            dust.Rate = 2
            dust.Speed = NumberRange.new(0.5, 2)
            dust.SpreadAngle = Vector2.new(180, 20)
            dust.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.2, 0.7),
                NumberSequenceKeypoint.new(1, 1),
            })
            dust.RotSpeed = NumberRange.new(-30, 30)
            dust.Parent = road
        end
    end

    print("[MapBuilder] Ambiance configurée ✓")
end

function MapBuilder:AddChimneySmoke(building)
    -- Trouver le point le plus haut (toit)
    local highestY = 0
    local highestPart = nil
    for _, part in building:GetDescendants() do
        if part:IsA("BasePart") then
            local top = part.Position.Y + part.Size.Y / 2
            if top > highestY then
                highestY = top
                highestPart = part
            end
        end
    end

    if highestPart then
        local smokePos = Instance.new("Part")
        smokePos.Name = "SmokeEmitter"
        smokePos.Size = Vector3.new(1, 1, 1)
        smokePos.Position = Vector3.new(highestPart.Position.X + 3, highestY + 1, highestPart.Position.Z)
        smokePos.Anchored = true
        smokePos.CanCollide = false
        smokePos.Transparency = 1
        smokePos.Parent = building

        local smoke = Instance.new("ParticleEmitter")
        smoke.Name = "ChimneySmoke"
        smoke.Color = ColorSequence.new(Color3.fromRGB(120, 115, 110))
        smoke.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.5, 2.5),
            NumberSequenceKeypoint.new(1, 4),
        })
        smoke.Lifetime = NumberRange.new(4, 7)
        smoke.Rate = 3
        smoke.Speed = NumberRange.new(1, 3)
        smoke.SpreadAngle = Vector2.new(15, 15)
        smoke.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.5, 0.7),
            NumberSequenceKeypoint.new(1, 1),
        })
        smoke.RotSpeed = NumberRange.new(-20, 20)
        smoke.Acceleration = Vector3.new(2, 1, 0)
        smoke.Parent = smokePos
    end
end

-- ═══════════════════════════════════════════
-- MONDE (terrain, NPCs, zones)
-- ═══════════════════════════════════════════
function MapBuilder:CreateWorld()
    local worldFolder = Instance.new("Folder")
    worldFolder.Name = "World"
    worldFolder.Parent = Workspace

    -- Nettoyer les éléments par défaut
    for _, child in Workspace:GetChildren() do
        if child:IsA("SpawnLocation") then child:Destroy() end
        if child.Name == "Baseplate" then child:Destroy() end
    end

    -- Spawn location — au bord de la rivière, sur le terrain
    local spawnY = getTerrainHeight(0, -55) + 2
    local spawnLoc = Instance.new("SpawnLocation")
    spawnLoc.Name = "SpawnLocation"
    spawnLoc.Size = Vector3.new(12, 1, 12)
    spawnLoc.Position = Vector3.new(0, spawnY, -55)
    spawnLoc.Anchored = true
    spawnLoc.Transparency = 1
    spawnLoc.CanCollide = false
    spawnLoc.Parent = worldFolder

    -- Skybox
    self:SetupSkybox()

    -- NPCs au bord de la rivière (Y auto par raycast)
    self:CreateTownNPCs(worldFolder)
end

-- ═══════════════════════════════════════════
-- CHEMINS AVEC TRANSITION DE COULEUR
-- ═══════════════════════════════════════════
function MapBuilder:CreatePath(parent, cfg)
    local pathFolder = Instance.new("Folder")
    pathFolder.Name = cfg.name
    pathFolder.Parent = parent

    for i = 1, cfg.segments do
        local t = (i - 1) / (cfg.segments - 1) -- 0 → 1
        -- Lerp couleur
        local color = cfg.colorStart:Lerp(cfg.colorEnd, t)
        local mat = if t < 0.5 then cfg.matStart else cfg.matEnd
        -- Largeur qui varie légèrement
        local width = 12 + math.sin(i * 0.7) * 2

        local pos
        if cfg.dir == "z" then
            pos = cfg.startPos + Vector3.new(0, 0, cfg.sign * (i - 1) * cfg.segLen)
            makePart({
                Name = `Seg_{i}`,
                Size = Vector3.new(width, 0.15, cfg.segLen + 0.5),
                Position = pos,
                Color = color,
                Material = mat,
                Parent = pathFolder,
            })
        else
            pos = cfg.startPos + Vector3.new(cfg.sign * (i - 1) * cfg.segLen, 0, 0)
            makePart({
                Name = `Seg_{i}`,
                Size = Vector3.new(cfg.segLen + 0.5, 0.15, width),
                Position = pos,
                Color = color,
                Material = mat,
                Parent = pathFolder,
            })
        end

        -- Clôtures tous les 3 segments (côté alternant)
        if i % 3 == 0 and i < cfg.segments then
            local side = if i % 6 == 0 then 1 else -1
            local fencePos, fenceSize
            if cfg.dir == "z" then
                fencePos = pos + Vector3.new(side * (width / 2 + 0.5), 1, 0)
                fenceSize = Vector3.new(0.3, 2, cfg.segLen)
            else
                fencePos = pos + Vector3.new(0, 1, side * (width / 2 + 0.5))
                fenceSize = Vector3.new(cfg.segLen, 2, 0.3)
            end
            makePart({
                Name = `Fence_{i}`,
                Size = fenceSize,
                Position = fencePos,
                Color = C.woodDark,
                Material = Enum.Material.Wood,
                Parent = pathFolder,
            })
        end

        -- Rochers décoratifs le long du chemin (aléatoire)
        if math.random() > 0.6 then
            local side = if math.random() > 0.5 then 1 else -1
            local rockH = math.random(5, 12) / 10
            local rockPos
            if cfg.dir == "z" then
                rockPos = pos + Vector3.new(side * (width / 2 + 2 + math.random()), rockH / 2, math.random(-5, 5))
            else
                rockPos = pos + Vector3.new(math.random(-5, 5), rockH / 2, side * (width / 2 + 2 + math.random()))
            end
            local rock = makePart({
                Name = `PathRock_{i}`,
                Size = Vector3.new(rockH * 1.5, rockH, rockH * 1.2),
                Position = rockPos,
                Color = Color3.fromRGB(110 + math.random(-15, 15), 100 + math.random(-15, 15), 85),
                Material = Enum.Material.Rock,
                Parent = pathFolder,
            })
            local rMesh = Instance.new("SpecialMesh")
            rMesh.MeshType = Enum.MeshType.Sphere
            rMesh.Scale = Vector3.new(1, 0.6, 1)
            rMesh.Parent = rock
        end
    end
end

-- ═══════════════════════════════════════════
-- DÉCORATION CHEMIN VILLE → RIVIÈRE
-- ═══════════════════════════════════════════
function MapBuilder:DecoratePathToRiver(worldFolder)
    local pathFolder = worldFolder:FindFirstChild("PathToZone1")
    if not pathFolder then return end

    local startZ = -10
    local pathLen = 8 * 35 -- 280 studs

    -- ═══ LANTERNES (4 seulement) ═══
    for i = 1, 4 do
        local zPos = startZ - (i * pathLen / 5)
        local side = if i % 2 == 0 then 1 else -1
        local polePos = Vector3.new(side * 9, 0, zPos)

        makePart({
            Name = "LanternPole_" .. i,
            Size = Vector3.new(0.4, 4.5, 0.4),
            Position = polePos + Vector3.new(0, 2.25, 0),
            Color = C.woodDark,
            Material = Enum.Material.Wood,
            Parent = pathFolder,
        })
        local lantern = makePart({
            Name = "Lantern_" .. i,
            Size = Vector3.new(0.8, 0.8, 0.8),
            Position = polePos + Vector3.new(0, 4.8, 0),
            Color = Color3.fromRGB(255, 200, 80),
            Material = Enum.Material.Neon,
            Parent = pathFolder,
        })
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 190, 100)
        light.Brightness = 0.6
        light.Range = 14
        light.Parent = lantern
    end

    -- ═══ FLEURS (6 seulement) ═══
    local flowerColors = {
        Color3.fromRGB(255, 200, 80),
        Color3.fromRGB(220, 100, 140),
        Color3.fromRGB(180, 140, 255),
    }
    for i = 1, 6 do
        local zPos = startZ - math.random(20, math.floor(pathLen - 20))
        local side = if math.random() > 0.5 then 1 else -1
        local xPos = side * (7 + math.random() * 6)

        local flower = makePart({
            Name = "PathFlower_" .. i,
            Size = Vector3.new(0.6, 0.4, 0.6),
            Position = Vector3.new(xPos, 0.3, zPos),
            Color = flowerColors[math.random(1, #flowerColors)],
            Material = Enum.Material.SmoothPlastic,
            Parent = pathFolder,
        })
        local fm = Instance.new("SpecialMesh")
        fm.MeshType = Enum.MeshType.Sphere
        fm.Scale = Vector3.new(1, 0.5, 1)
        fm.Parent = flower
    end

    -- ═══ ARBUSTES (3 seulement) ═══
    for i = 1, 3 do
        local zPos = startZ - (i * pathLen / 4)
        local side = if i % 2 == 0 then 1 else -1
        local xPos = side * (10 + math.random() * 5)
        local bSize = 2 + math.random() * 1.5

        local bush = makePart({
            Name = "PathBush_" .. i,
            Size = Vector3.new(bSize, bSize * 0.7, bSize),
            Position = Vector3.new(xPos, bSize * 0.35, zPos),
            Color = Color3.fromRGB(45 + math.random(-10, 10), 95 + math.random(-15, 15), 30),
            Material = Enum.Material.Fabric,
            Parent = pathFolder,
        })
        local bm = Instance.new("SpecialMesh")
        bm.MeshType = Enum.MeshType.Sphere
        bm.Scale = Vector3.new(1, 0.8, 1)
        bm.Parent = bush
    end

    -- ═══ ARBRES (2 seulement) ═══
    for i = 1, 2 do
        local zPos = startZ - (i * pathLen / 3)
        local side = if i % 2 == 0 then 1 else -1
        local xPos = side * (14 + math.random() * 4)
        local trunkH = 5 + math.random() * 3

        makePart({
            Name = "PathTreeTrunk_" .. i,
            Size = Vector3.new(1, trunkH, 1),
            Position = Vector3.new(xPos, trunkH / 2, zPos),
            Color = Color3.fromRGB(80, 55, 30),
            Material = Enum.Material.Wood,
            Parent = pathFolder,
        })
        local canopySize = 5 + math.random() * 3
        local canopy = makePart({
            Name = "PathTreeCanopy_" .. i,
            Size = Vector3.new(canopySize, canopySize * 0.6, canopySize),
            Position = Vector3.new(xPos, trunkH + canopySize * 0.2, zPos),
            Color = Color3.fromRGB(40 + math.random(-8, 8), 90 + math.random(-15, 15), 28),
            Material = Enum.Material.Fabric,
            Parent = pathFolder,
        })
        local cm = Instance.new("SpecialMesh")
        cm.MeshType = Enum.MeshType.Sphere
        cm.Scale = Vector3.new(1, 0.7, 1)
        cm.Parent = canopy
    end

    -- ═══ PANNEAU DIRECTIONNEL ═══
    local signZ = startZ - 40
    makePart({
        Name = "DirSignPost",
        Size = Vector3.new(0.5, 4, 0.5),
        Position = Vector3.new(8, 2, signZ),
        Color = C.woodDark,
        Material = Enum.Material.Wood,
        Parent = pathFolder,
    })
    local dirSign = makePart({
        Name = "DirSign",
        Size = Vector3.new(6, 1.5, 0.3),
        Position = Vector3.new(8, 4.2, signZ),
        Color = C.sign,
        Material = Enum.Material.Wood,
        Parent = pathFolder,
    })
    addZoneSign(dirSign, "Riviere  →", Color3.fromRGB(60, 40, 20))
end

-- ═══════════════════════════════════════════
-- SKYBOX
-- ═══════════════════════════════════════════
function MapBuilder:SetupSkybox()
    local Lighting = game:GetService("Lighting")

    -- Supprimer skybox existante
    for _, child in Lighting:GetChildren() do
        if child:IsA("Sky") then child:Destroy() end
    end

    local sky = Instance.new("Sky")
    sky.CelestialBodiesShown = true
    sky.StarCount = 2000
    sky.MoonAngularSize = 11
    sky.SunAngularSize = 15
    -- Couleurs du ciel (pas de skybox texture — couleur ambiante suffit)
    sky.Parent = Lighting

    print("[MapBuilder] Skybox configurée ✓")
end

-- ═══════════════════════════════════════════
-- CYCLE JOUR/NUIT (serveur)
-- ═══════════════════════════════════════════
function MapBuilder:StartDayNightCycle()
    local Lighting = game:GetService("Lighting")
    local RunService = game:GetService("RunService")

    -- Config : 720s réelles = 24h in-game (12 min)
    local CYCLE_DURATION = 720
    local HOURS_PER_SEC = 24 / CYCLE_DURATION

    -- Démarrer à 16h30 (heure actuelle du Lighting)
    -- Le cycle avance naturellement

    local timeOfDayEvent = ReplicatedStorage:FindFirstChild("Events")
        and ReplicatedStorage.Events:FindFirstChild("RemoteEvents")
        and ReplicatedStorage.Events.RemoteEvents:FindFirstChild("TimeOfDayChanged")

    local lastBroadcastHour = math.floor(Lighting.ClockTime)

    RunService.Heartbeat:Connect(function(dt)
        -- Avancer l'horloge
        local newTime = Lighting.ClockTime + dt * HOURS_PER_SEC
        if newTime >= 24 then newTime = newTime - 24 end
        Lighting.ClockTime = newTime

        -- Ajuster l'ambiance selon l'heure
        local hour = newTime

        -- Ambient colors (transition douce)
        if hour >= 6 and hour < 8 then
            -- Lever de soleil (6h-8h)
            local t = (hour - 6) / 2
            Lighting.Ambient = Color3.fromRGB(80, 60, 40):Lerp(Color3.fromRGB(135, 120, 90), t)
            Lighting.OutdoorAmbient = Color3.fromRGB(90, 70, 50):Lerp(Color3.fromRGB(150, 140, 110), t)
            Lighting.Brightness = 1 + t * 1.5
        elseif hour >= 8 and hour < 17 then
            -- Journée (8h-17h)
            Lighting.Ambient = Color3.fromRGB(135, 120, 90)
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 140, 110)
            Lighting.Brightness = 2.5
        elseif hour >= 17 and hour < 20 then
            -- Coucher de soleil (17h-20h)
            local t = (hour - 17) / 3
            Lighting.Ambient = Color3.fromRGB(135, 120, 90):Lerp(Color3.fromRGB(50, 40, 60), t)
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 140, 110):Lerp(Color3.fromRGB(40, 35, 55), t)
            Lighting.Brightness = 2.5 - t * 1.8
        elseif hour >= 20 or hour < 5 then
            -- Nuit (20h-5h)
            Lighting.Ambient = Color3.fromRGB(50, 40, 60)
            Lighting.OutdoorAmbient = Color3.fromRGB(40, 35, 55)
            Lighting.Brightness = 0.7
        elseif hour >= 5 and hour < 6 then
            -- Aube (5h-6h)
            local t = hour - 5
            Lighting.Ambient = Color3.fromRGB(50, 40, 60):Lerp(Color3.fromRGB(80, 60, 40), t)
            Lighting.OutdoorAmbient = Color3.fromRGB(40, 35, 55):Lerp(Color3.fromRGB(90, 70, 50), t)
            Lighting.Brightness = 0.7 + t * 0.3
        end

        -- Brouillard (plus dense la nuit)
        if hour >= 20 or hour < 6 then
            Lighting.FogEnd = 800
            Lighting.FogStart = 100
            Lighting.FogColor = Color3.fromRGB(30, 25, 40)
        else
            Lighting.FogEnd = 2000
            Lighting.FogStart = 500
            Lighting.FogColor = Color3.fromRGB(180, 170, 150)
        end

        -- Broadcast aux clients quand l'heure change (chaque heure in-game)
        local currentHour = math.floor(hour)
        if currentHour ~= lastBroadcastHour and timeOfDayEvent then
            lastBroadcastHour = currentHour
            timeOfDayEvent:FireAllClients(hour)
        end
    end)

    print(`[MapBuilder] Cycle jour/nuit lancé (1 jour = {CYCLE_DURATION}s)`)
end

-- ═══════════════════════════════════════════
-- UPGRADE ARBRES WORKSPACE (cubes → sphères)
-- ═══════════════════════════════════════════
function MapBuilder:UpgradeTrees()
    local count = 0
    for _, obj in Workspace:GetChildren() do
        if obj:IsA("Model") and obj.Name:match("^Tree_") then
            -- Trouver les feuilles (la part verte en haut)
            for _, part in obj:GetChildren() do
                if part:IsA("BasePart") then
                    if part.Color.G > 0.3 and part.Color.R < 0.4 then
                        -- C'est une feuille verte → arrondir
                        if not part:FindFirstChildOfClass("SpecialMesh") then
                            local mesh = Instance.new("SpecialMesh")
                            mesh.MeshType = Enum.MeshType.Sphere
                            mesh.Scale = Vector3.new(1.2, 0.9, 1.2)
                            mesh.Parent = part
                        end
                        -- Varier légèrement la couleur
                        local r = part.Color.R + (math.random() - 0.5) * 0.05
                        local g = part.Color.G + (math.random() - 0.5) * 0.08
                        local b = part.Color.B + (math.random() - 0.5) * 0.03
                        part.Color = Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1))
                    end
                end
            end
            count += 1
        end
    end
    if count > 0 then
        print(`[MapBuilder] {count} arbres améliorés ✓`)
    end
end

-- ═══════════════════════════════════════════
-- NPCs DE LA VILLE (R15 animés)
-- ═══════════════════════════════════════════
-- Positions XZ près de la rivière — Y sera calculé par raycast
local NPC_DATA = {
    {
        pos = Vector3.new(-20, 0, -55), facing = 160,
        name = "ToolVendor", displayName = "Jake l'Outilleur",
        npcType = "ToolShop", actionText = "Acheter des outils",
        skin = Color3.fromRGB(180, 140, 100),
        torso = Color3.fromRGB(139, 90, 43),
        legs = Color3.fromRGB(70, 50, 30),
        shirt = 2789617463, pants = 2789619169,
        hat = "425117435",
    },
    {
        pos = Vector3.new(15, 0, -55), facing = -160,
        name = "Marcel", displayName = "Marcel le Marchand",
        npcType = "Merchant", actionText = "Vendre de l'or",
        skin = Color3.fromRGB(210, 170, 130),
        torso = Color3.fromRGB(50, 100, 50),
        legs = Color3.fromRGB(50, 40, 30),
        shirt = 2789617463, pants = 2789619169,
        hat = "30385423",
    },
    {
        pos = Vector3.new(-30, 0, -48), facing = 120,
        name = "Gustave", displayName = "Gustave le Forgeron",
        npcType = "Crafter", actionText = "Forger",
        skin = Color3.fromRGB(170, 130, 90),
        torso = Color3.fromRGB(160, 80, 40),
        legs = Color3.fromRGB(60, 45, 25),
        shirt = 2789617463, pants = 2789619169,
    },
    {
        pos = Vector3.new(25, 0, -48), facing = -120,
        name = "Bill", displayName = "Bill le Barman",
        npcType = "Saloon", actionText = "Boire un verre",
        skin = Color3.fromRGB(200, 160, 120),
        torso = Color3.fromRGB(180, 60, 60),
        legs = Color3.fromRGB(40, 35, 30),
        shirt = 2789617463, pants = 2789619169,
        hat = "425117435",
    },
    {
        pos = Vector3.new(0, 0, -60), facing = 180,
        name = "Guide", displayName = "Tom le Guide",
        npcType = "Tutor", actionText = "Parler",
        skin = Color3.fromRGB(190, 150, 110),
        torso = Color3.fromRGB(80, 130, 80),
        legs = Color3.fromRGB(70, 55, 35),
        shirt = 2789617463, pants = 2789619169,
        hat = "30385423",
    },
}

function MapBuilder:CreateTownNPCs(worldFolder)
    local npcFolder = Instance.new("Folder")
    npcFolder.Name = "TownNPCs"
    npcFolder.Parent = worldFolder

    for _, data in ipairs(NPC_DATA) do
        -- Calculer Y à partir du terrain
        local groundY = getTerrainHeight(data.pos.X, data.pos.Z)
        data.pos = Vector3.new(data.pos.X, groundY, data.pos.Z)
        self:CreateNPC(npcFolder, data)
    end

    print("[MapBuilder] " .. #NPC_DATA .. " NPCs créés dans la ville")
end

-- ═══════════════════════════════════════════
-- NPC — R15 animé (fallback R6)
-- ═══════════════════════════════════════════
function MapBuilder:CreateNPC(parent, data)
    local npc = nil
    local hrp = nil
    local humanoid = nil

    -- HumanoidDescription
    local desc = Instance.new("HumanoidDescription")
    desc.HeadColor = data.skin
    desc.TorsoColor = data.torso
    desc.LeftArmColor = data.skin
    desc.RightArmColor = data.skin
    desc.LeftLegColor = data.legs
    desc.RightLegColor = data.legs

    -- Proportions adultes
    desc.BodyTypeScale = 0.3
    desc.HeadScale = 1
    desc.HeightScale = 1.05
    desc.WidthScale = 1
    desc.ProportionScale = 0

    -- Vêtements (silent fail si asset invalide)
    pcall(function() desc.Shirt = data.shirt end)
    pcall(function() desc.Pants = data.pants end)
    if data.hat then
        pcall(function() desc.HatAccessory = data.hat end)
    end

    -- Créer le modèle R15
    local ok, result = pcall(function()
        return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
    end)

    if ok and result then
        npc = result
        npc.Name = data.name
        hrp = npc:FindFirstChild("HumanoidRootPart")

        -- AUCUNE part ancrée — on utilise des contraintes physiques
        -- Anchored=true empêche les Motor6D de bouger → pas d'animation visible
        for _, part in npc:GetDescendants() do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end

        -- Supprimer tout Animate script qui pourrait interférer
        for _, child in npc:GetDescendants() do
            if child.Name == "Animate" and (child:IsA("LocalScript") or child:IsA("Script")) then
                child:Destroy()
            end
        end

        -- Positionner + orienter vers la rue
        local yAngle = math.rad(data.facing or 0)
        local targetCF = CFrame.new(data.pos + Vector3.new(0, 3, 0)) * CFrame.Angles(0, yAngle, 0)
        npc:PivotTo(targetCF)

        -- Contraintes physiques pour maintenir le NPC en place (remplace Anchored)
        if hrp then
            -- Attachment nécessaire pour les contraintes
            local att = Instance.new("Attachment")
            att.Name = "RootAttachment"
            att.Parent = hrp

            -- Maintenir la position
            local alignPos = Instance.new("AlignPosition")
            alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
            alignPos.Attachment0 = att
            alignPos.Position = targetCF.Position
            alignPos.MaxForce = 100000
            alignPos.MaxVelocity = math.huge
            alignPos.Responsiveness = 200
            alignPos.Parent = hrp

            -- Maintenir l'orientation
            local alignOri = Instance.new("AlignOrientation")
            alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
            alignOri.Attachment0 = att
            alignOri.CFrame = targetCF
            alignOri.MaxTorque = 100000
            alignOri.Responsiveness = 200
            alignOri.Parent = hrp
        end

        -- Config Humanoid
        humanoid = npc:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayName = data.displayName
            humanoid.NameDisplayDistance = 20
            humanoid.HealthDisplayDistance = 0
        end

        print(`[MapBuilder] NPC R15 créé : {data.displayName}`)
    else
        -- Fallback R6
        warn("[MapBuilder] R15 échoué : " .. tostring(result) .. " → fallback R6 pour " .. data.name)
        npc, hrp = self:CreateNPCR6(data)
        humanoid = npc and npc:FindFirstChildOfClass("Humanoid")
    end

    -- ProximityPrompt
    if hrp then
        local prompt = Instance.new("ProximityPrompt")
        prompt.ObjectText = data.displayName
        prompt.ActionText = data.actionText
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 10
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.RequiresLineOfSight = false
        prompt.Parent = hrp

        hrp:SetAttribute("NPCType", data.npcType)
        hrp:SetAttribute("NPCName", data.displayName)
    end

    -- Parent dans le monde
    if npc then
        npc.Parent = parent
    end

    -- Animation idle gérée côté CLIENT (NPCAnimator.client.lua)
    -- Les animations serveur ne se répliquent pas visuellement aux clients
end

-- ═══════════════════════════════════════════
-- FALLBACK R6 (si R15 échoue)
-- ═══════════════════════════════════════════
function MapBuilder:CreateNPCR6(data)
    local SKIN = data.skin
    local pos = data.pos

    local npc = Instance.new("Model")
    npc.Name = data.name

    local hrp = Instance.new("Part")
    hrp.Name = "HumanoidRootPart"
    hrp.Size = Vector3.new(2, 2, 1)
    hrp.Anchored = true
    hrp.CanCollide = false
    hrp.Transparency = 1
    hrp.Position = pos + Vector3.new(0, 3, 0)
    hrp.Parent = npc

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Anchored = true
    head.Position = pos + Vector3.new(0, 4.5, 0)
    head.Color = SKIN
    head.Material = Enum.Material.SmoothPlastic
    head.Parent = npc

    local headMesh = Instance.new("SpecialMesh")
    headMesh.MeshType = Enum.MeshType.Head
    headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
    headMesh.Parent = head

    local face = Instance.new("Decal")
    face.Name = "face"
    face.Texture = "rbxasset://textures/face.png"
    face.Parent = head

    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.Anchored = true
    torso.Position = pos + Vector3.new(0, 3, 0)
    torso.Color = data.torso
    torso.Material = Enum.Material.SmoothPlastic
    torso.Parent = npc

    for _, info in ipairs({{-1.5, "Left Arm"}, {1.5, "Right Arm"}}) do
        local arm = Instance.new("Part")
        arm.Name = info[2]
        arm.Size = Vector3.new(1, 2, 1)
        arm.Anchored = true
        arm.Position = pos + Vector3.new(info[1], 3, 0)
        arm.Color = SKIN
        arm.Material = Enum.Material.SmoothPlastic
        arm.Parent = npc
    end

    for _, info in ipairs({{-0.5, "Left Leg"}, {0.5, "Right Leg"}}) do
        local leg = Instance.new("Part")
        leg.Name = info[2]
        leg.Size = Vector3.new(1, 2, 1)
        leg.Anchored = true
        leg.Position = pos + Vector3.new(info[1], 1, 0)
        leg.Color = data.legs
        leg.Material = Enum.Material.SmoothPlastic
        leg.Parent = npc
    end

    local humanoid = Instance.new("Humanoid")
    humanoid.DisplayName = data.displayName
    humanoid.NameDisplayDistance = 20
    humanoid.HealthDisplayDistance = 0
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = npc

    npc.PrimaryPart = hrp
    return npc, hrp
end

-- ═══════════════════════════════════════════
-- ZONE 1 — RIVIÈRE TRANQUILLE (Sud, z=-200)
-- ═══════════════════════════════════════════
function MapBuilder:CreateZone1(worldFolder)
    local z1 = Instance.new("Folder")
    z1.Name = "Zone1_Riviere"
    z1.Parent = worldFolder

    local center = ZoneConfig.Zones.Zone1.WorldPosition -- (0, 0, -200)

    -- ═══ SEGMENT DATA ═══
    -- Each segment: z offset, x wobble, width, depth category
    local segCount = 18
    local segLen = 16
    local segments = {}
    for i = 1, segCount do
        local t = (i - 1) / (segCount - 1)
        local zOff = -120 + t * 240
        local xW = math.sin(i * 0.4) * 22 + math.sin(i * 0.9) * 8

        -- Width: massive river — 50 to 90 studs
        local w
        if i <= 3 then w = 50 + i * 5
        elseif i <= 7 then w = 65 + (i - 3) * 6
        elseif i <= 12 then w = 85 + math.sin(i) * 8
        elseif i <= 15 then w = 70 + math.sin(i * 0.7) * 6
        else w = 75 + (i - 15) * 4
        end

        -- Depth: cascade > deep pool > meander > shallows (tuned for 18 segs)
        local d
        if i <= 3 then d = 3.0        -- cascade plunge zone
        elseif i <= 7 then d = 3.8    -- deep pool
        elseif i <= 12 then d = 2.5   -- wide meander
        elseif i <= 15 then d = 1.8   -- getting shallower
        else d = 1.2                   -- shallows at south end
        end

        segments[i] = { z = zOff, x = xW, width = w, depth = d }
    end

    -- ═══ TERRAIN SETUP ═══
    local terrain = Workspace.Terrain
    terrain.WaterColor = Color3.fromRGB(40, 120, 170)
    terrain.WaterTransparency = 0.3
    terrain.WaterWaveSize = 0.15
    terrain.WaterWaveSpeed = 8
    terrain.WaterReflectance = 0.1

    -- ═══ SOL TERRAIN (remplace le Part Ground dans cette zone) ═══
    -- D'abord poser un gros bloc de terrain Grass qui couvre toute la zone rivière
    -- Le Part Ground est à y=-0.5 (top = y=0), on pose le terrain AU-DESSUS à y=1
    local zoneWidth = 250  -- assez large pour couvrir le wobble + berges
    local zoneLen = 280    -- couvre les 18 segments (240 studs) + marge
    terrain:FillBlock(
        CFrame.new(center + Vector3.new(0, 1, 0)),
        Vector3.new(zoneWidth, 3, zoneLen),
        Enum.Material.Grass
    )

    -- ═══ CREUSER LA RIVIÈRE ═══
    -- Pour chaque segment : d'abord vider (Air), puis lit (Mud), puis eau (Water)
    for i, seg in ipairs(segments) do
        local pos = center + Vector3.new(seg.x, 0, seg.z)

        -- 1. Creuser le canal — remplacer le terrain par de l'Air
        terrain:FillBlock(
            CFrame.new(pos + Vector3.new(0, 0, 0)),
            Vector3.new(seg.width + 6, 4, segLen + 2),
            Enum.Material.Air
        )

        -- 2. Lit de la rivière au fond
        terrain:FillBlock(
            CFrame.new(pos + Vector3.new(0, -seg.depth, 0)),
            Vector3.new(seg.width + 8, 1, segLen + 2),
            Enum.Material.Mud
        )

        -- 3. Bande de sable sur les bords (transition douce)
        for _, side in ipairs({-1, 1}) do
            terrain:FillBlock(
                CFrame.new(pos + Vector3.new(side * (seg.width / 2 + 2), 0, 0)),
                Vector3.new(5, 2, segLen + 2),
                Enum.Material.Sand
            )
        end

        -- 4. Remplir d'eau
        terrain:FillBlock(
            CFrame.new(pos + Vector3.new(0, -seg.depth / 2 + 0.5, 0)),
            Vector3.new(seg.width, seg.depth + 1, segLen + 2),
            Enum.Material.Water
        )
    end

    -- ═══ CASCADE (nord) ═══
    local cascZ = center.Z + segments[1].z - 10
    local cascX = center.X + segments[1].x
    local cascW = segments[1].width

    -- Mur rocheux surélevé
    terrain:FillBlock(
        CFrame.new(Vector3.new(cascX, 4, cascZ)),
        Vector3.new(cascW + 20, 10, 8),
        Enum.Material.Rock
    )

    -- Chute d'eau devant le mur
    terrain:FillBlock(
        CFrame.new(Vector3.new(cascX, 1, cascZ + 5)),
        Vector3.new(cascW * 0.5, 6, 3),
        Enum.Material.Water
    )

    -- Bassin au pied
    terrain:FillBlock(
        CFrame.new(Vector3.new(cascX, -1, cascZ + 12)),
        Vector3.new(cascW + 10, 3, 12),
        Enum.Material.Water
    )

    -- ═══ QUELQUES ROCHERS DANS L'EAU (Parts) ═══
    for i = 1, 4 do
        local seg = segments[math.random(2, #segments - 1)]
        local xOff = math.random(-math.floor(seg.width / 4), math.floor(seg.width / 4))
        local rockH = 1 + math.random() * 1.5

        local rock = makePart({
            Name = "WaterRock_" .. i,
            Size = Vector3.new(2 + math.random() * 2, rockH, 2 + math.random() * 2),
            Position = center + Vector3.new(seg.x + xOff, rockH / 2 - 0.5, seg.z),
            Color = Color3.fromRGB(90 + math.random(-10, 10), 85 + math.random(-10, 10), 75),
            Material = Enum.Material.Rock,
            Parent = z1,
        })
        local rm = Instance.new("SpecialMesh")
        rm.MeshType = Enum.MeshType.Sphere
        rm.Scale = Vector3.new(1, 0.6, 1.1)
        rm.Parent = rock
    end

    -- ═══ SAULES (4 arbres sur les berges) ═══
    local willowSegs = { 3, 7, 12, 16 }
    local willowSides = { 1, -1, 1, -1 }
    for i = 1, 4 do
        local seg = segments[willowSegs[i]]
        local side = willowSides[i]
        local treePos = Vector3.new(
            center.X + seg.x + side * (seg.width / 2 + 18),
            2,
            center.Z + seg.z
        )

        local tree = Instance.new("Model")
        tree.Name = "Willow_" .. i

        makePart({
            Name = "Trunk",
            Size = Vector3.new(1.8, 8, 1.8),
            Position = treePos + Vector3.new(0, 4, 0),
            Color = Color3.fromRGB(75, 55, 30),
            Material = Enum.Material.Wood,
            Parent = tree,
        })
        local canopy = makePart({
            Name = "Canopy",
            Size = Vector3.new(12, 6, 12),
            Position = treePos + Vector3.new(0, 9, 0),
            Color = Color3.fromRGB(45, 95 + math.random(-10, 10), 30),
            Material = Enum.Material.Fabric,
            Parent = tree,
        })
        local cm = Instance.new("SpecialMesh")
        cm.MeshType = Enum.MeshType.Sphere
        cm.Scale = Vector3.new(1, 0.6, 1)
        cm.Parent = canopy

        tree.Parent = z1
    end

end

-- ═══════════════════════════════════════════
-- ZONE 2 — COLLINES AMBRÉES (Ouest, x=-200)
-- ═══════════════════════════════════════════
function MapBuilder:CreateZone2(worldFolder)
    local z2 = Instance.new("Folder")
    z2.Name = "Zone2_Collines"
    z2.Parent = worldFolder

    local center = ZoneConfig.Zones.Zone2.WorldPosition -- (-200, 0, 0)

    -- Terrain surélevé
    makePart({
        Name = "Ground",
        Size = Vector3.new(120, 2, 120),
        Position = center + Vector3.new(0, 1.1, 0),
        Color = Color3.fromRGB(100, 80, 45),
        Material = Enum.Material.Ground,
        Parent = z2,
    })

    -- Panneau sur poteau
    makePart({
        Name = "SignPost",
        Size = Vector3.new(1, 8, 1),
        Position = center + Vector3.new(54, 4, 0),
        Color = C.woodDark,
        Material = Enum.Material.Wood,
        Parent = z2,
    })
    local sign = makePart({
        Name = "ZoneSign",
        Size = Vector3.new(10, 3, 0.5),
        Position = center + Vector3.new(60, 7, 0),
        Color = C.sign,
        Material = Enum.Material.Wood,
        Parent = z2,
    })
    addZoneSign(sign, "Zone 2 — Collines Ambrées [Niv.2]", Color3.fromRGB(200, 180, 100))

    -- Collines arrondies (SpecialMesh sphère)
    for i = 1, 7 do
        local hillSize = Vector3.new(
            25 + math.random(0, 15), 8 + math.random(0, 12), 25 + math.random(0, 15)
        )
        local hill = makePart({
            Name = "Hill_" .. i,
            Size = hillSize,
            Position = center + Vector3.new(
                math.random(-45, 45), hillSize.Y / 2 + 2, math.random(-45, 45)
            ),
            Color = Color3.fromRGB(140 + math.random(-20, 20), 100 + math.random(-20, 20), 50),
            Material = Enum.Material.Rock,
            Parent = z2,
        })
        local hillMesh = Instance.new("SpecialMesh")
        hillMesh.MeshType = Enum.MeshType.Sphere
        hillMesh.Scale = Vector3.new(1, 0.5, 1)
        hillMesh.Parent = hill
    end

    -- Cactus / arbustes secs
    for i = 1, 8 do
        local cactusH = math.random(20, 45) / 10
        makePart({
            Name = "Cactus_" .. i,
            Size = Vector3.new(0.6, cactusH, 0.6),
            Position = center + Vector3.new(
                math.random(-50, 50), 2.1 + cactusH / 2, math.random(-50, 50)
            ),
            Color = Color3.fromRGB(60, 100 + math.random(-15, 15), 40),
            Material = Enum.Material.Fabric,
            Parent = z2,
        })
    end

    -- Torches le long du chemin
    for i = 1, 4 do
        local tPos = center + Vector3.new(60 - i * 12, 2, (i % 2 == 0) and 8 or -8)
        local torchPole = makePart({
            Name = "TorchPole_" .. i,
            Size = Vector3.new(0.4, 5, 0.4),
            Position = tPos + Vector3.new(0, 2.5, 0),
            Color = C.woodDark,
            Material = Enum.Material.Wood,
            Parent = z2,
        })
        local torchTop = makePart({
            Name = "TorchTop_" .. i,
            Size = Vector3.new(0.6, 0.6, 0.6),
            Position = tPos + Vector3.new(0, 5.3, 0),
            Color = Color3.fromRGB(255, 150, 30),
            Material = Enum.Material.Neon,
            Parent = z2,
        })
        local torchLight = Instance.new("PointLight")
        torchLight.Color = Color3.fromRGB(255, 180, 80)
        torchLight.Brightness = 0.8
        torchLight.Range = 15
        torchLight.Parent = torchTop

        -- Flamme
        local flame = Instance.new("ParticleEmitter")
        flame.Color = ColorSequence.new(Color3.fromRGB(255, 160, 30), Color3.fromRGB(255, 80, 10))
        flame.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.5, 0.6),
            NumberSequenceKeypoint.new(1, 0),
        })
        flame.Lifetime = NumberRange.new(0.3, 0.8)
        flame.Rate = 15
        flame.Speed = NumberRange.new(1, 3)
        flame.SpreadAngle = Vector2.new(15, 15)
        flame.LightEmission = 1
        flame.Parent = torchTop
    end
end

-- ═══════════════════════════════════════════
-- ZONE 3 — MINE DE CROW CREEK (Nord, z=200)
-- ═══════════════════════════════════════════
function MapBuilder:CreateZone3(worldFolder)
    local z3 = Instance.new("Folder")
    z3.Name = "Zone3_Mine"
    z3.Parent = worldFolder

    local center = ZoneConfig.Zones.Zone3.WorldPosition -- (0, 0, 200)

    -- Entrée de la mine (plus imposante)
    makePart({
        Name = "MineWallL",
        Size = Vector3.new(4, 14, 6),
        Position = center + Vector3.new(-6, 7, -40),
        Color = C.stoneDark,
        Material = Enum.Material.Slate,
        Parent = z3,
    })
    makePart({
        Name = "MineWallR",
        Size = Vector3.new(4, 14, 6),
        Position = center + Vector3.new(6, 7, -40),
        Color = C.stoneDark,
        Material = Enum.Material.Slate,
        Parent = z3,
    })
    makePart({
        Name = "MineArch",
        Size = Vector3.new(16, 3, 6),
        Position = center + Vector3.new(0, 12.5, -40),
        Color = C.stone,
        Material = Enum.Material.Slate,
        Parent = z3,
    })

    -- Poutres de soutènement à l'entrée
    makePart({
        Name = "BeamL",
        Size = Vector3.new(1, 12, 1),
        Position = center + Vector3.new(-3.5, 6, -40),
        Color = C.woodDark,
        Material = Enum.Material.Wood,
        Parent = z3,
    })
    makePart({
        Name = "BeamR",
        Size = Vector3.new(1, 12, 1),
        Position = center + Vector3.new(3.5, 6, -40),
        Color = C.woodDark,
        Material = Enum.Material.Wood,
        Parent = z3,
    })
    makePart({
        Name = "BeamTop",
        Size = Vector3.new(8, 1, 1),
        Position = center + Vector3.new(0, 11.5, -40),
        Color = C.woodDark,
        Material = Enum.Material.Wood,
        Parent = z3,
    })

    -- Panneau sur l'arche
    local sign = makePart({
        Name = "ZoneSign",
        Size = Vector3.new(8, 2.5, 0.5),
        Position = center + Vector3.new(0, 14.5, -40),
        Color = C.sign,
        Material = Enum.Material.Wood,
        Parent = z3,
    })
    addZoneSign(sign, "Mine de Crow Creek [Niv.3]", Color3.fromRGB(200, 100, 100))

    -- Sol mine
    makePart({
        Name = "MineFloor",
        Size = Vector3.new(100, 0.3, 100),
        Position = center + Vector3.new(0, 0.25, 0),
        Color = Color3.fromRGB(60, 55, 50),
        Material = Enum.Material.Slate,
        Parent = z3,
    })

    -- Rails avec traverses
    for i = 1, 3 do
        local railZ = -20 + i * 15
        -- Rail gauche + droit
        makePart({
            Name = "RailL_" .. i,
            Size = Vector3.new(70, 0.12, 0.3),
            Position = center + Vector3.new(0, 0.46, railZ - 1),
            Color = Color3.fromRGB(100, 90, 80),
            Material = Enum.Material.Metal,
            Parent = z3,
        })
        makePart({
            Name = "RailR_" .. i,
            Size = Vector3.new(70, 0.12, 0.3),
            Position = center + Vector3.new(0, 0.46, railZ + 1),
            Color = Color3.fromRGB(100, 90, 80),
            Material = Enum.Material.Metal,
            Parent = z3,
        })
        -- Traverses en bois
        for t = 1, 14 do
            makePart({
                Name = `Tie_{i}_{t}`,
                Size = Vector3.new(0.4, 0.1, 3),
                Position = center + Vector3.new(-30 + t * 4.5, 0.45, railZ),
                Color = C.woodDark,
                Material = Enum.Material.Wood,
                Parent = z3,
            })
        end
    end

    -- Wagonnets décoratifs
    for i = 1, 2 do
        local wagonX = math.random(-20, 20)
        local wagonZ = math.random(-10, 30)
        local wagon = Instance.new("Model")
        wagon.Name = "MineCart_" .. i

        makePart({
            Name = "CartBase",
            Size = Vector3.new(3, 1.5, 2),
            Position = center + Vector3.new(wagonX, 1.2, wagonZ),
            Color = Color3.fromRGB(90, 80, 70),
            Material = Enum.Material.Metal,
            Parent = wagon,
        })
        makePart({
            Name = "CartOre",
            Size = Vector3.new(2.5, 0.8, 1.5),
            Position = center + Vector3.new(wagonX, 2.2, wagonZ),
            Color = Color3.fromRGB(80, 70, 55),
            Material = Enum.Material.Rock,
            Parent = wagon,
        })

        wagon.Parent = z3
    end

    -- Lampes à huile le long des rails
    for i = 1, 6 do
        local lampPos = center + Vector3.new(-25 + i * 10, 0, math.random(-25, 35))
        makePart({
            Name = "LampPole_" .. i,
            Size = Vector3.new(0.3, 4, 0.3),
            Position = lampPos + Vector3.new(0, 2, 0),
            Color = C.woodDark,
            Material = Enum.Material.Wood,
            Parent = z3,
        })
        local lampTop = makePart({
            Name = "Lamp_" .. i,
            Size = Vector3.new(0.5, 0.5, 0.5),
            Position = lampPos + Vector3.new(0, 4.3, 0),
            Color = Color3.fromRGB(255, 200, 80),
            Material = Enum.Material.Neon,
            Transparency = 0.2,
            Parent = z3,
        })
        local lampLight = Instance.new("PointLight")
        lampLight.Color = Color3.fromRGB(255, 180, 60)
        lampLight.Brightness = 0.6
        lampLight.Range = 12
        lampLight.Parent = lampTop
    end

    -- Cristaux (Glass au lieu de Neon)
    for i = 1, 6 do
        local crystalH = math.random(20, 50) / 10
        local crystalColor = ({
            Color3.fromRGB(140, 80, 200),
            Color3.fromRGB(100, 180, 220),
            Color3.fromRGB(200, 100, 150),
        })[math.random(1, 3)]

        local crystal = makePart({
            Name = "Crystal_" .. i,
            Size = Vector3.new(0.8, crystalH, 0.8),
            Position = center + Vector3.new(
                math.random(-35, 35), 0.4 + crystalH / 2, math.random(-30, 30)
            ),
            Color = crystalColor,
            Material = Enum.Material.Glass,
            Transparency = 0.3,
            Parent = z3,
        })

        -- Lueur subtile sur certains cristaux
        if i % 2 == 0 then
            local cLight = Instance.new("PointLight")
            cLight.Color = crystalColor
            cLight.Brightness = 0.3
            cLight.Range = 5
            cLight.Parent = crystal
        end
    end

    -- Poutres de soutènement intérieures
    for i = 1, 4 do
        local beamZ = center.Z - 15 + i * 15
        makePart({
            Name = "SupportL_" .. i,
            Size = Vector3.new(0.8, 6, 0.8),
            Position = Vector3.new(center.X - 15, 3.4, beamZ),
            Color = C.woodDark,
            Material = Enum.Material.Wood,
            Parent = z3,
        })
        makePart({
            Name = "SupportR_" .. i,
            Size = Vector3.new(0.8, 6, 0.8),
            Position = Vector3.new(center.X + 15, 3.4, beamZ),
            Color = C.woodDark,
            Material = Enum.Material.Wood,
            Parent = z3,
        })
        makePart({
            Name = "SupportBeam_" .. i,
            Size = Vector3.new(31, 0.6, 0.6),
            Position = Vector3.new(center.X, 6.5, beamZ),
            Color = C.woodDark,
            Material = Enum.Material.Wood,
            Parent = z3,
        })
    end
end

return MapBuilder
