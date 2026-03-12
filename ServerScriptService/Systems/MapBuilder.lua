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
-- MONDE — Western Town Square (v2 clean)
-- ═══════════════════════════════════════════
function MapBuilder:CreateWorld()
    local worldFolder = Instance.new("Folder")
    worldFolder.Name = "World"
    worldFolder.Parent = Workspace

    -- Nettoyer (sauf le Terrain importé)
    for _, child in Workspace:GetChildren() do
        if child:IsA("SpawnLocation") then child:Destroy() end
        if child.Name == "Baseplate" then child:Destroy() end
    end
    -- PAS de Terrain:Clear() — le terrain DusthavenTerrain est importé manuellement
    -- PAS de CreateTerrain() — idem

    -- Spawn (position à ajuster selon le terrain importé)
    local spawnLoc = Instance.new("SpawnLocation")
    spawnLoc.Name = "SpawnLocation"
    spawnLoc.Size = Vector3.new(10, 1, 10)
    spawnLoc.Position = Vector3.new(0, 155, 0)
    spawnLoc.Anchored = true
    spawnLoc.Transparency = 1
    spawnLoc.CanCollide = false
    spawnLoc.Parent = worldFolder

    -- ═══ STEPS SUIVANTS (désactivés pour validation) ═══
    -- self:CreateRiver()
    -- self:CreateBridge(worldFolder)
    -- self:CreateCollines()
    -- self:CreateDusthavenArea(worldFolder)
    -- self:CreateTrails(worldFolder)
    -- self:CreateDecor(worldFolder)
    -- self:CreateMiningZone(worldFolder)
    self:SetupSkybox()
    -- self:CreateTownNPCs(worldFolder)
end

-- ═══════════════════════════════════════════
-- TERRAIN — Désert plat 1200×1200
-- ═══════════════════════════════════════════
function MapBuilder:CreateTerrain()
    local region = Region3.new(
        Vector3.new(-600, -8, -600),
        Vector3.new(600, 0, 600)
    )
    Workspace.Terrain:FillRegion(region:ExpandToGrid(4), 4, Enum.Material.Sand)
    print("[MapBuilder] Terrain sable 1200×1200 créé")
end

-- ═══════════════════════════════════════════
-- RIVIÈRE — S-curves descendant du nord au sud
-- Côté gauche de la map, exactement comme le plan
-- ═══════════════════════════════════════════
function MapBuilder:CreateRiver()
    -- Rivière S-curves, descend du nord-ouest vers le sud
    -- Technique : FillBlock ORIENTÉ le long du courant → courbes lisses
    -- Étape 1 : creuser le lit (Air) / Étape 2 : remplir d'eau
    local waypoints = {
        { x = -350, z = -550, w = 16 },
        { x = -280, z = -470, w = 18 },
        { x = -190, z = -380, w = 20 }, -- pic EST (futur pont)
        { x = -220, z = -300, w = 18 },
        { x = -320, z = -200, w = 20 },
        { x = -380, z = -100, w = 18 },
        { x = -330, z =    0, w = 20 },
        { x = -250, z =  100, w = 20 },
        { x = -330, z =  200, w = 18 },
        { x = -380, z =  320, w = 20 },
    }

    local terrain = Workspace.Terrain
    local steps = 40 -- beaucoup de points → courbes très lisses

    -- Interpoler tous les points
    local points = {}
    for i = 1, #waypoints - 1 do
        local a = waypoints[i]
        local b = waypoints[i + 1]
        for s = 0, steps - 1 do
            local t = s / steps
            table.insert(points, {
                x = a.x + (b.x - a.x) * t,
                z = a.z + (b.z - a.z) * t,
                w = a.w + (b.w - a.w) * t,
            })
        end
    end
    table.insert(points, waypoints[#waypoints])

    -- Pour chaque paire de points consécutifs, créer un bloc orienté
    for i = 1, #points - 1 do
        local a = points[i]
        local b = points[i + 1]
        local mx = (a.x + b.x) / 2
        local mz = (a.z + b.z) / 2
        local w = (a.w + b.w) / 2
        local dx = b.x - a.x
        local dz = b.z - a.z
        local segLen = math.sqrt(dx * dx + dz * dz) + 2 -- +2 overlap
        local angle = math.atan2(dx, dz)

        -- Orientation : le bloc suit la direction du courant
        local cf = CFrame.new(mx, -4, mz) * CFrame.Angles(0, angle, 0)

        -- 1) Creuser le lit (enlever le sable) — de Y=-8 à Y=0
        terrain:FillBlock(cf, Vector3.new(w, 8, segLen), Enum.Material.Air)

        -- 2) Remplir d'eau — de Y=-8 à Y=-1 (eau 7 studs sous la surface)
        local cfWater = CFrame.new(mx, -4.5, mz) * CFrame.Angles(0, angle, 0)
        terrain:FillBlock(cfWater, Vector3.new(w, 7, segLen), Enum.Material.Water)
    end

    print("[MapBuilder] Rivière créée (FillBlock orienté, " .. #points .. " points) ✓")
end

-- ═══════════════════════════════════════════
-- PONT — enjambe la rivière au pic est (waypoint 3)
-- Connecte la Cabane (rive ouest) à Dusthaven (rive est)
-- ═══════════════════════════════════════════
function MapBuilder:CreateBridge(parent)
    local bridgeFolder = Instance.new("Folder")
    bridgeFolder.Name = "Bridge"
    bridgeFolder.Parent = parent

    -- Le pont enjambe la rivière au pic est (waypoint 3 à x=-190)
    local bx, bz = -190, -380
    local bAngle = math.rad(15) -- léger angle
    local bridgeY = 3 -- au-dessus de l'eau (eau à Y=-2)
    local bridgeLen = 28
    local bridgeW = 6

    -- Plancher principal — surélevé
    makePart({
        Name = "BridgeFloor",
        Size = Vector3.new(bridgeLen, 0.5, bridgeW),
        CFrame = CFrame.new(bx, bridgeY, bz) * CFrame.Angles(0, bAngle, 0),
        Color = C.wood,
        Material = Enum.Material.WoodPlanks,
        Parent = bridgeFolder,
    })

    -- Planches transversales (détail visuel)
    for i = -6, 6 do
        makePart({
            Name = "Plank_" .. (i + 7),
            Size = Vector3.new(0.3, 0.08, bridgeW),
            CFrame = CFrame.new(bx, bridgeY + 0.28, bz) * CFrame.Angles(0, bAngle, 0) * CFrame.new(i * 1.9, 0, 0),
            Color = Color3.fromRGB(115 + math.random(-15, 15), 80, 40),
            Material = Enum.Material.WoodPlanks,
            Parent = bridgeFolder,
        })
    end

    -- Piliers de support (dans l'eau, jusqu'au plancher)
    for _, dx in ipairs({-10, -3, 3, 10}) do
        makePart({
            Name = "BridgePillar",
            Size = Vector3.new(1.2, 8, 1.2),
            CFrame = CFrame.new(bx, bridgeY - 4, bz) * CFrame.Angles(0, bAngle, 0) * CFrame.new(dx, 0, 0),
            Color = C.woodDark,
            Material = Enum.Material.Wood,
            Parent = bridgeFolder,
        })
    end

    -- Rambardes
    for _, side in ipairs({-1, 1}) do
        local offset = side * (bridgeW / 2 - 0.2)
        for _, dx in ipairs({-10, -5, 0, 5, 10}) do
            makePart({
                Name = "RailPost",
                Size = Vector3.new(0.4, 2.5, 0.4),
                CFrame = CFrame.new(bx, bridgeY + 1.5, bz) * CFrame.Angles(0, bAngle, 0) * CFrame.new(dx, 0, offset),
                Color = C.woodDark,
                Material = Enum.Material.Wood,
                Parent = bridgeFolder,
            })
        end
        makePart({
            Name = "Rail_" .. side,
            Size = Vector3.new(bridgeLen, 0.3, 0.3),
            CFrame = CFrame.new(bx, bridgeY + 2.8, bz) * CFrame.Angles(0, bAngle, 0) * CFrame.new(0, 0, offset),
            Color = C.wood,
            Material = Enum.Material.Wood,
            Parent = bridgeFolder,
        })
    end

    -- Rampes d'accès (montées de chaque côté)
    for _, side in ipairs({-1, 1}) do
        local rampOffset = side * (bridgeLen / 2 + 4)
        makePart({
            Name = "Ramp_" .. side,
            Size = Vector3.new(8, 0.5, bridgeW),
            CFrame = CFrame.new(bx, bridgeY / 2, bz) * CFrame.Angles(0, bAngle, 0)
                * CFrame.new(rampOffset, 0, 0) * CFrame.Angles(0, 0, side * math.rad(20)),
            Color = C.wood,
            Material = Enum.Material.WoodPlanks,
            Parent = bridgeFolder,
        })
    end

    print("[MapBuilder] Pont créé à (" .. bx .. ", " .. bz .. ") — surélevé Y=" .. bridgeY .. " ✓")
end

-- ═══════════════════════════════════════════
-- COLLINES — 2 collines formant un passage vers Dusthaven
-- Le joueur passe ENTRE les deux pour accéder au village
-- ═══════════════════════════════════════════
function MapBuilder:CreateCollines()
    local terrain = Workspace.Terrain

    -- Colline NORD (au nord du passage)
    -- Centre à (-20, 0, -420), hauteur ~30 studs
    terrain:FillBall(Vector3.new(-20, -15, -420), 50, Enum.Material.Sand)
    terrain:FillBall(Vector3.new(-20,   0, -420), 42, Enum.Material.Sand)
    terrain:FillBall(Vector3.new(-20,  10, -420), 30, Enum.Material.Ground)
    terrain:FillBall(Vector3.new(-20,  18, -425), 18, Enum.Material.Rock)
    -- Extension ouest de la colline nord (allonge la barrière)
    terrain:FillBall(Vector3.new(-60, -10, -430), 35, Enum.Material.Sand)
    terrain:FillBall(Vector3.new(-60,   2, -430), 25, Enum.Material.Ground)

    -- Colline SUD (au sud du passage)
    -- Centre à (-20, 0, -240), hauteur ~30 studs
    terrain:FillBall(Vector3.new(-20, -15, -240), 50, Enum.Material.Sand)
    terrain:FillBall(Vector3.new(-20,   0, -240), 42, Enum.Material.Sand)
    terrain:FillBall(Vector3.new(-20,  10, -240), 30, Enum.Material.Ground)
    terrain:FillBall(Vector3.new(-20,  18, -235), 18, Enum.Material.Rock)
    -- Extension ouest de la colline sud
    terrain:FillBall(Vector3.new(-60, -10, -230), 35, Enum.Material.Sand)
    terrain:FillBall(Vector3.new(-60,   2, -230), 25, Enum.Material.Ground)

    -- Le GAP entre les deux : Z de ~-380 à ~-280 = ~100 studs d'ouverture
    -- Le chemin passe par le centre du gap à Z ≈ -330

    print("[MapBuilder] Collines créées (passage vers Dusthaven) ✓")
end

-- ═══════════════════════════════════════════
-- DUSTHAVEN — zone plate réservée, VIDE (pas de bâtiments)
-- Juste un marqueur au sol + panneau
-- ═══════════════════════════════════════════
function MapBuilder:CreateDusthavenArea(parent)
    -- Zone plate en terre battue — espace réservé pour les futurs bâtiments
    makePart({
        Name = "DusthavenGround",
        Size = Vector3.new(150, 0.15, 120),
        Position = Vector3.new(120, 0.08, -330),
        Color = Color3.fromRGB(150, 120, 75),
        Material = Enum.Material.Ground,
        Parent = parent,
    })

    -- Panneau DUSTHAVEN à l'entrée (côté ouest, face au passage)
    local signPost = makePart({
        Name = "DusthavenSignPost",
        Size = Vector3.new(0.6, 6, 0.6),
        Position = Vector3.new(50, 3, -330),
        Color = C.woodDark,
        Material = Enum.Material.Wood,
        Parent = parent,
    })
    local signBoard = makePart({
        Name = "DusthavenSign",
        Size = Vector3.new(14, 3, 0.4),
        Position = Vector3.new(50, 7, -330),
        Color = C.sign,
        Material = Enum.Material.Wood,
        Parent = parent,
    })
    addZoneSign(signBoard, "DUSTHAVEN", Color3.fromRGB(50, 30, 10))

    print("[MapBuilder] Zone Dusthaven réservée (150×120, VIDE) ✓")
end

-- ═══════════════════════════════════════════
-- SENTIERS — chemins en terre battue
-- ═══════════════════════════════════════════
function MapBuilder:CreateTrails(parent)
    local trailFolder = Instance.new("Folder")
    trailFolder.Name = "Trails"
    trailFolder.Parent = parent

    local trailColor = Color3.fromRGB(130, 105, 65)
    local trailMat = Enum.Material.Ground
    local trailY = 0.06

    local function trail(name, x1, z1, x2, z2, w)
        local dx = x2 - x1
        local dz = z2 - z1
        local len = math.sqrt(dx * dx + dz * dz)
        local angle = math.atan2(dx, dz)
        makePart({
            Name = name,
            Size = Vector3.new(w, 0.12, len),
            CFrame = CFrame.new((x1+x2)/2, trailY, (z1+z2)/2) * CFrame.Angles(0, angle, 0),
            Color = trailColor,
            Material = trailMat,
            Parent = trailFolder,
        })
    end

    -- Cabane → Rivière (vers l'ouest, court)
    trail("CabaneToRiver", -250, -300, -290, -320, 5)

    -- Cabane → Pont (vers l'est, le pont est à (-190, -380))
    trail("CabaneToPont_1", -250, -300, -220, -340, 6)
    trail("CabaneToPont_2", -220, -340, -205, -370, 6)

    -- Pont → passage entre collines → Dusthaven
    trail("PontToPass_1", -175, -380, -100, -360, 6)
    trail("PontToPass_2", -100, -360, -30, -340, 6)
    trail("PassToDust", 0, -330, 50, -330, 6)

    -- Sentier principal le long de la rivière (rive ouest, descend vers le sud)
    trail("RiverTrail_1", -290, -320, -300, -400, 5)
    trail("RiverTrail_2", -300, -400, -280, -470, 5)
    trail("RiverTrail_3", -280, -470, -330, -350, 5)
    trail("RiverTrail_4", -330, -350, -370, -200, 5)
    trail("RiverTrail_5", -370, -200, -380, -100, 5)
    trail("RiverTrail_6", -380, -100, -340, 0, 5)
    trail("RiverTrail_7", -340, 0, -280, 100, 5)

    print("[MapBuilder] Sentiers créés ✓")
end

-- ═══════════════════════════════════════════
-- DÉCOR — cactus, rochers, ambiance désertique
-- ═══════════════════════════════════════════
function MapBuilder:CreateDecor(parent)
    local decorFolder = Instance.new("Folder")
    decorFolder.Name = "Decor"
    decorFolder.Parent = parent

    -- Cactus dispersés dans la zone
    local cactusPositions = {
        Vector3.new(-450, 0, -450),
        Vector3.new(-150, 0, -500),
        Vector3.new(-480, 0, -200),
        Vector3.new(-100, 0, -150),
        Vector3.new(-400, 0, 50),
        Vector3.new(-180, 0, 200),
        Vector3.new(200, 0, -450),
        Vector3.new(300, 0, -200),
    }
    for i, pos in ipairs(cactusPositions) do
        local h = 4 + math.random() * 4
        makePart({
            Name = "Cactus_" .. i,
            Size = Vector3.new(1.2, h, 1.2),
            Position = pos + Vector3.new(0, h / 2, 0),
            Color = Color3.fromRGB(60, 120, 50),
            Material = Enum.Material.SmoothPlastic,
            Parent = decorFolder,
        })
        if math.random() > 0.3 then
            makePart({
                Name = "CactusArm_" .. i,
                Size = Vector3.new(1, h * 0.4, 1),
                Position = pos + Vector3.new(-1.5, h * 0.6, 0),
                Color = Color3.fromRGB(55, 115, 45),
                Material = Enum.Material.SmoothPlastic,
                Parent = decorFolder,
            })
        end
    end

    -- Rochers le long de la rivière
    local rockData = {
        { pos = Vector3.new(-320, 1.5, -480), size = Vector3.new(5, 3, 4) },
        { pos = Vector3.new(-230, 2, -350), size = Vector3.new(6, 4, 5) },
        { pos = Vector3.new(-360, 1.5, -180), size = Vector3.new(7, 4, 5) },
        { pos = Vector3.new(-300, 1, -50), size = Vector3.new(4, 2, 3) },
        { pos = Vector3.new(-280, 2, 80), size = Vector3.new(6, 3, 5) },
        { pos = Vector3.new(-370, 1.5, 250), size = Vector3.new(5, 3, 4) },
    }
    for i, rd in ipairs(rockData) do
        local rock = makePart({
            Name = "Rock_" .. i,
            Size = rd.size,
            Position = rd.pos,
            Color = Color3.fromRGB(140 + math.random(-20, 20), 125 + math.random(-15, 15), 100),
            Material = Enum.Material.Rock,
            Parent = decorFolder,
        })
        local rm = Instance.new("SpecialMesh")
        rm.MeshType = Enum.MeshType.Sphere
        rm.Scale = Vector3.new(1, 0.6, 1)
        rm.Parent = rock
    end

    print("[MapBuilder] Décor placé ✓")
end

-- ═══════════════════════════════════════════
-- ZONE DE MINAGE — 3 batée stations le long de la rivière
-- ═══════════════════════════════════════════
function MapBuilder:CreateMiningZone(worldFolder)
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return end

    local z1 = Instance.new("Folder")
    z1.Name = "Zone1_RiviereTransquille"
    z1.Parent = mapFolder

    -- Panneau "Dead Man's Shallows"
    local signPost = makePart({
        Name = "ZoneSignPost",
        Size = Vector3.new(0.5, 5, 0.5),
        Position = Vector3.new(-300, 2.5, -500),
        Color = C.woodDark,
        Material = Enum.Material.Wood,
        Parent = z1,
    })
    local zoneSign = makePart({
        Name = "ZoneSign",
        Size = Vector3.new(10, 2.5, 0.4),
        Position = Vector3.new(-300, 5.5, -500),
        Color = C.sign,
        Material = Enum.Material.Wood,
        Parent = z1,
    })
    addZoneSign(zoneSign, "Dead Man's Shallows", Color3.fromRGB(255, 215, 0))

    -- 3 batée stations sur les BERGES (décalées de la rivière, sur terre ferme)
    -- La rivière passe par: (-280,-470), (-320,-200), (-250,100)
    -- On décale de ~30-40 studs vers la terre pour être sur la rive
    local stations = {
        { name = "Batee1", x = -240, z = -460 }, -- rive ouest du virage nord
        { name = "Batee2", x = -360, z = -150 }, -- rive ouest du virage milieu
        { name = "Batee3", x = -210, z =  100 }, -- rive est du virage sud
    }

    local spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "SpawnPoints"
    spawnFolder.Parent = z1

    local spawnIndex = 1

    for _, station in ipairs(stations) do
        local pontonFolder = Instance.new("Folder")
        pontonFolder.Name = station.name
        pontonFolder.Parent = z1

        -- Ponton
        makePart({
            Name = station.name .. "_Floor",
            Size = Vector3.new(8, 0.4, 8),
            Position = Vector3.new(station.x, 0.2, station.z),
            Color = C.wood,
            Material = Enum.Material.WoodPlanks,
            Parent = pontonFolder,
        })
        for _, corner in ipairs({{-3.5, -3.5}, {3.5, -3.5}, {-3.5, 3.5}, {3.5, 3.5}}) do
            makePart({
                Name = station.name .. "_Post",
                Size = Vector3.new(0.5, 2, 0.5),
                Position = Vector3.new(station.x + corner[1], -0.8, station.z + corner[2]),
                Color = C.woodDark,
                Material = Enum.Material.Wood,
                Parent = pontonFolder,
            })
        end

        -- Sol terre autour
        makePart({
            Name = station.name .. "_Ground",
            Size = Vector3.new(20, 0.12, 20),
            Position = Vector3.new(station.x, 0.06, station.z),
            Color = Color3.fromRGB(170, 145, 95),
            Material = Enum.Material.Ground,
            Parent = pontonFolder,
        })

        -- 4 spawn points par station
        for j = 1, 4 do
            local angle = (j / 4) * math.pi * 2 + math.random() * 0.4
            local radius = 6 + math.random() * 8
            local pt = makePart({
                Name = "SP_" .. spawnIndex,
                Size = Vector3.new(3, 0.1, 3),
                Position = Vector3.new(
                    station.x + math.cos(angle) * radius,
                    0.05,
                    station.z + math.sin(angle) * radius
                ),
                Transparency = 1,
                CanCollide = false,
                Anchored = true,
                Parent = spawnFolder,
            })
            pt:SetAttribute("ZoneId", "Zone1")
            spawnIndex = spawnIndex + 1
        end
    end

    print("[MapBuilder] Zone de minage créée — 3 stations, 12 spawn points ✓")
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
-- NPCs DE LA VILLE (R15 animés)
-- ═══════════════════════════════════════════
-- NPCs dans Dusthaven (zone plate à (120, -330))
-- Même sans bâtiments, ils attendent les joueurs en plein air
local NPC_DATA = {
    {
        -- Entrée de Dusthaven, accueille les arrivants du passage
        pos = Vector3.new(60, 0, -330), facing = 270,
        name = "Guide", displayName = "Tom le Guide",
        npcType = "Tutor", actionText = "Parler",
        skin = Color3.fromRGB(190, 150, 110),
        torso = Color3.fromRGB(80, 130, 80),
        legs = Color3.fromRGB(60, 50, 35),
        shirt = 2789617463, pants = 2789619169,
    },
    {
        -- Centre-ouest de Dusthaven
        pos = Vector3.new(100, 0, -310), facing = 220,
        name = "ToolVendor", displayName = "Jake l'Outilleur",
        npcType = "ToolShop", actionText = "Acheter des outils",
        skin = Color3.fromRGB(180, 140, 100),
        torso = Color3.fromRGB(139, 90, 43),
        legs = Color3.fromRGB(70, 50, 30),
        shirt = 2789617463, pants = 2789619169,
        hat = "425117435",
    },
    {
        -- Centre de Dusthaven
        pos = Vector3.new(130, 0, -340), facing = 180,
        name = "Marcel", displayName = "Marcel le Marchand",
        npcType = "Merchant", actionText = "Vendre de l'or",
        skin = Color3.fromRGB(210, 170, 130),
        torso = Color3.fromRGB(50, 100, 50),
        legs = Color3.fromRGB(50, 40, 30),
        shirt = 2789617463, pants = 2789619169,
        hat = "30385423",
    },
    {
        -- Nord-est de Dusthaven
        pos = Vector3.new(160, 0, -315), facing = 250,
        name = "Gustave", displayName = "Gustave le Forgeron",
        npcType = "Crafter", actionText = "Forger",
        skin = Color3.fromRGB(170, 130, 90),
        torso = Color3.fromRGB(160, 80, 40),
        legs = Color3.fromRGB(60, 45, 25),
        shirt = 2789617463, pants = 2789619169,
    },
    {
        -- Sud-est de Dusthaven
        pos = Vector3.new(150, 0, -350), facing = 300,
        name = "Bill", displayName = "Bill le Barman",
        npcType = "Saloon", actionText = "Boire un verre",
        skin = Color3.fromRGB(200, 160, 120),
        torso = Color3.fromRGB(180, 60, 60),
        legs = Color3.fromRGB(40, 35, 30),
        shirt = 2789617463, pants = 2789619169,
        hat = "425117435",
    },
}

function MapBuilder:CreateTownNPCs(worldFolder)
    local npcFolder = Instance.new("Folder")
    npcFolder.Name = "TownNPCs"
    npcFolder.Parent = worldFolder

    for _, data in ipairs(NPC_DATA) do
        self:CreateNPC(npcFolder, data)
    end

    print("[MapBuilder] " .. #NPC_DATA .. " NPCs créés")
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

return MapBuilder
