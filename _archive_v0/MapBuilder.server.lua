--[[
	Gold Rush Legacy - MapBuilder.server.lua
	Génère le monde : terrain, ville (hub), rivière, zones de minage, NPCs marchands
]]

print("[MapBuilder] Script starting...")

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
print("[MapBuilder] Config loaded OK")

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

local function addBillboard(parent, text, color, offset)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 250, 0, 50)
	gui.StudsOffset = offset or Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui

	return gui
end

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
-- TERRAIN PRINCIPAL
-- ═══════════════════════════════════════════

local worldFolder = Instance.new("Folder")
worldFolder.Name = "World"
worldFolder.Parent = Workspace

-- Sol principal déjà dans project.json (Baseplate statique)
-- On update juste ses propriétés visuelles si besoin
local existingGround = Workspace:FindFirstChild("Baseplate")
if existingGround then
	existingGround.Name = "Ground"
	existingGround.Parent = worldFolder
end

-- Chemin de terre (ville → rivière)
makePart({
	Name = "DirtPath",
	Size = Vector3.new(250, 0.1, 12),
	Position = Vector3.new(75, 0.05, 0),
	Color = C.dirt,
	Material = Enum.Material.Ground,
	Parent = worldFolder,
})

-- ═══════════════════════════════════════════
-- RIVIÈRE (zone de minage principale)
-- ═══════════════════════════════════════════

local riverFolder = Instance.new("Folder")
riverFolder.Name = "River"
riverFolder.Parent = worldFolder

-- Lit de rivière (eau)
for i = 1, 8 do
	local zOff = (i - 4.5) * 25
	local xWobble = math.sin(i * 0.8) * 8
	makePart({
		Name = "RiverWater_" .. i,
		Size = Vector3.new(20 + math.random(-3, 3), 1, 28),
		Position = Vector3.new(150 + xWobble, -0.8, zOff),
		Color = C.water,
		Material = Enum.Material.Glass,
		Transparency = 0.3,
		Parent = riverFolder,
	})
end

-- Berges (sable)
for i = 1, 8 do
	local zOff = (i - 4.5) * 25
	local xWobble = math.sin(i * 0.8) * 8
	-- Berge gauche
	makePart({
		Name = "BankLeft_" .. i,
		Size = Vector3.new(8, 0.5, 28),
		Position = Vector3.new(138 + xWobble, -0.2, zOff),
		Color = C.sand,
		Material = Enum.Material.Sand,
		Parent = riverFolder,
	})
	-- Berge droite
	makePart({
		Name = "BankRight_" .. i,
		Size = Vector3.new(8, 0.5, 28),
		Position = Vector3.new(162 + xWobble, -0.2, zOff),
		Color = C.sand,
		Material = Enum.Material.Sand,
		Parent = riverFolder,
	})
end

-- Rochers décoratifs dans la rivière
for i = 1, 6 do
	makePart({
		Name = "Rock_" .. i,
		Size = Vector3.new(
			math.random(2, 5),
			math.random(1, 3),
			math.random(2, 5)
		),
		Position = Vector3.new(
			148 + math.random(-5, 5),
			math.random(0, 1),
			-80 + math.random(0, 160)
		),
		Color = C.stoneDark,
		Material = Enum.Material.Slate,
		Parent = riverFolder,
	})
end

-- ═══════════════════════════════════════════
-- ZONE MARQUEURS (invisibles, pour le système de minage)
-- ═══════════════════════════════════════════

local zonesFolder = Instance.new("Folder")
zonesFolder.Name = "MiningZones"
zonesFolder.Parent = Workspace

for _, zoneConfig in ipairs(Config.Zones) do
	local zoneMarker = makePart({
		Name = zoneConfig.id,
		Size = zoneConfig.size,
		Position = zoneConfig.position,
		Transparency = 1, -- invisible
		CanCollide = false,
		Parent = zonesFolder,
	})
	zoneMarker:SetAttribute("ZoneId", zoneConfig.id)
	zoneMarker:SetAttribute("ZoneName", zoneConfig.name)
	zoneMarker:SetAttribute("LevelRequired", zoneConfig.levelRequired)

	-- Panneau indicateur de zone
	local signPost = makePart({
		Name = zoneConfig.id .. "_Sign",
		Size = Vector3.new(0.5, 6, 0.5),
		Position = zoneConfig.position + Vector3.new(-zoneConfig.size.X/2 + 2, 3, -zoneConfig.size.Z/2 + 2),
		Color = C.woodDark,
		Material = Enum.Material.Wood,
		Parent = zonesFolder,
	})
	local signBoard = makePart({
		Name = zoneConfig.id .. "_Board",
		Size = Vector3.new(8, 3, 0.5),
		Position = zoneConfig.position + Vector3.new(-zoneConfig.size.X/2 + 2, 7, -zoneConfig.size.Z/2 + 2),
		Color = C.sign,
		Material = Enum.Material.Wood,
		Parent = zonesFolder,
	})
	local levelText = zoneConfig.levelRequired > 1 and " (Niv." .. zoneConfig.levelRequired .. ")" or ""
	addBillboard(signBoard, zoneConfig.name .. levelText, C.gold, Vector3.new(0, 2, 0))
end

-- ═══════════════════════════════════════════
-- SPOTS DE MINAGE (brillants, interactifs)
-- ═══════════════════════════════════════════

local spotsFolder = Instance.new("Folder")
spotsFolder.Name = "MiningSpots"
spotsFolder.Parent = Workspace

local function createMiningSpot(zoneConfig, index)
	local zonePos = zoneConfig.position
	local zoneSize = zoneConfig.size

	local x = zonePos.X + math.random(-math.floor(zoneSize.X/2) + 5, math.floor(zoneSize.X/2) - 5)
	local z = zonePos.Z + math.random(-math.floor(zoneSize.Z/2) + 5, math.floor(zoneSize.Z/2) - 5)

	local spot = makePart({
		Name = "MiningSpot_" .. zoneConfig.id .. "_" .. index,
		Size = Vector3.new(5, 0.3, 5),
		Position = Vector3.new(x, 0.15, z),
		Color = C.gold,
		Material = Enum.Material.Neon,
		Transparency = 0.3,
		Shape = Enum.PartType.Block,
		CanCollide = false,
		Parent = spotsFolder,
	})

	-- Pilier lumineux au-dessus du spot pour le repérer de loin
	local beacon = Instance.new("Part")
	beacon.Name = "Beacon"
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.Size = Vector3.new(0.5, 15, 0.5)
	beacon.Position = Vector3.new(x, 8, z)
	beacon.Color = C.gold
	beacon.Material = Enum.Material.Neon
	beacon.Transparency = 0.5
	beacon.Parent = spot

	spot:SetAttribute("ZoneId", zoneConfig.id)
	spot:SetAttribute("SpotActive", true)
	spot:SetAttribute("SpotIndex", index)

	-- ProximityPrompt pour miner
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "Or"
	prompt.ActionText = "Miner"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.RequiresLineOfSight = false
	prompt.Parent = spot

	-- Particules dorées
	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(C.gold)
	particles.Size = NumberSequence.new(0.2, 0)
	particles.Lifetime = NumberRange.new(0.5, 1.5)
	particles.Rate = 5
	particles.Speed = NumberRange.new(1, 3)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Parent = spot

	return spot
end

-- Spawn initial des spots pour chaque zone
local totalSpots = 0
for _, zoneConfig in ipairs(Config.Zones) do
	for i = 1, zoneConfig.maxSpots do
		createMiningSpot(zoneConfig, i)
		totalSpots = totalSpots + 1
	end
end
print("[MapBuilder] Created " .. totalSpots .. " mining spots across " .. #Config.Zones .. " zones")

-- Respawn des spots après minage
local function respawnSpot(spot, zoneConfig)
	spot:SetAttribute("SpotActive", false)
	spot.Transparency = 1
	local prompt = spot:FindFirstChildOfClass("ProximityPrompt")
	if prompt then prompt.Enabled = false end
	local particles = spot:FindFirstChildOfClass("ParticleEmitter")
	if particles then particles.Enabled = false end

	task.delay(zoneConfig.respawnTime, function()
		if spot and spot.Parent then
			-- Repositionner aléatoirement
			local zonePos = zoneConfig.position
			local zoneSize = zoneConfig.size
			local x = zonePos.X + math.random(-math.floor(zoneSize.X/2) + 5, math.floor(zoneSize.X/2) - 5)
			local z = zonePos.Z + math.random(-math.floor(zoneSize.Z/2) + 5, math.floor(zoneSize.Z/2) - 5)
			spot.Position = Vector3.new(x, 0.15, z)

			-- Fix 9: Repositionner le beacon avec le spot
			local beacon = spot:FindFirstChild("Beacon")
			if beacon then
				beacon.Position = Vector3.new(x, 8, z)
			end

			spot:SetAttribute("SpotActive", true)
			spot.Transparency = 0.3
			if prompt then prompt.Enabled = true end
			if particles then particles.Enabled = true end
		end
	end)
end

-- BindableEvent pour le respawn (Fix 4 : remplace _G)
local ServerScriptService = game:GetService("ServerScriptService")
local respawnEvent = Instance.new("BindableEvent")
respawnEvent.Name = "RespawnMiningSpotEvent"
respawnEvent.Parent = ServerScriptService

respawnEvent.Event:Connect(function(spotName)
	local spot = spotsFolder:FindFirstChild(spotName)
	if not spot then return end
	local zoneId = spot:GetAttribute("ZoneId")
	local zoneConfig = Config.ZonesById[zoneId]
	if zoneConfig then
		respawnSpot(spot, zoneConfig)
	end
end)

-- ═══════════════════════════════════════════
-- VILLE (HUB CENTRAL)
-- ═══════════════════════════════════════════

local townFolder = Instance.new("Folder")
townFolder.Name = "Town"
townFolder.Parent = worldFolder

local TOWN_CENTER = Vector3.new(-30, 0, 0)

-- Place centrale (plancher bois)
makePart({
	Name = "TownSquare",
	Size = Vector3.new(60, 0.3, 60),
	Position = TOWN_CENTER + Vector3.new(0, 0.15, 0),
	Color = C.wood,
	Material = Enum.Material.Wood,
	Parent = townFolder,
})

-- ── MAGASIN D'OUTILS ──

local shopFolder = Instance.new("Folder")
shopFolder.Name = "ToolShop"
shopFolder.Parent = townFolder

local SHOP_POS = TOWN_CENTER + Vector3.new(-20, 0, -15)
local SW, SD, SH = 16, 12, 8

-- Sol
makePart({ Name = "ShopFloor", Size = Vector3.new(SW, 0.5, SD), Position = SHOP_POS + Vector3.new(0, 0.25, 0), Color = C.wood, Material = Enum.Material.Wood, Parent = shopFolder })
-- Murs
makeWall("ShopWallBack", Vector3.new(SW, SH, 0.5), SHOP_POS + Vector3.new(0, SH/2, -SD/2), C.woodDark, shopFolder)
makeWall("ShopWallLeft", Vector3.new(0.5, SH, SD), SHOP_POS + Vector3.new(-SW/2, SH/2, 0), C.woodDark, shopFolder)
makeWall("ShopWallRight", Vector3.new(0.5, SH, SD), SHOP_POS + Vector3.new(SW/2, SH/2, 0), C.woodDark, shopFolder)
-- Mur avant avec porte
makeWall("ShopFrontL", Vector3.new(5, SH, 0.5), SHOP_POS + Vector3.new(-5.5, SH/2, SD/2), C.woodDark, shopFolder)
makeWall("ShopFrontR", Vector3.new(5, SH, 0.5), SHOP_POS + Vector3.new(5.5, SH/2, SD/2), C.woodDark, shopFolder)
makeWall("ShopLintel", Vector3.new(6, 2, 0.5), SHOP_POS + Vector3.new(0, SH - 1, SD/2), C.woodDark, shopFolder)
-- Toit
makePart({ Name = "ShopRoof", Size = Vector3.new(SW + 2, 0.5, SD + 2), Position = SHOP_POS + Vector3.new(0, SH + 0.25, 0), Color = C.roof, Material = Enum.Material.Wood, Parent = shopFolder })
-- Enseigne
local shopSign = makePart({ Name = "ShopSign", Size = Vector3.new(10, 2.5, 0.5), Position = SHOP_POS + Vector3.new(0, SH + 2, SD/2 + 1), Color = C.sign, Material = Enum.Material.Wood, Parent = shopFolder })

local shopSignGui = Instance.new("SurfaceGui")
shopSignGui.Face = Enum.NormalId.Front
shopSignGui.Parent = shopSign
local shopSignLabel = Instance.new("TextLabel")
shopSignLabel.Size = UDim2.new(1, 0, 1, 0)
shopSignLabel.BackgroundTransparency = 1
shopSignLabel.Text = "OUTILS & ÉQUIPEMENT"
shopSignLabel.TextColor3 = Color3.fromRGB(50, 30, 10)
shopSignLabel.TextScaled = true
shopSignLabel.Font = Enum.Font.GothamBold
shopSignLabel.Parent = shopSignGui

-- Comptoir du shop
local shopCounter = makePart({
	Name = "ShopCounter",
	Size = Vector3.new(10, 3, 2),
	Position = SHOP_POS + Vector3.new(0, 1.5 + 0.5, -2),
	Color = C.woodDark,
	Material = Enum.Material.Wood,
	Parent = shopFolder,
})

-- NPC Vendeur d'outils
local shopNPC = Instance.new("Model")
shopNPC.Name = "ToolVendor"
shopNPC.Parent = shopFolder

local VENDOR_Y = 0.5 -- hauteur du sol du shop
local vendorTorso = Instance.new("Part")
vendorTorso.Name = "HumanoidRootPart"
vendorTorso.Anchored = true
vendorTorso.Size = Vector3.new(2, 3, 1)
vendorTorso.Position = SHOP_POS + Vector3.new(0, VENDOR_Y + 3, -3)
vendorTorso.Color = Color3.fromRGB(139, 90, 43)
vendorTorso.Material = Enum.Material.SmoothPlastic
vendorTorso.Parent = shopNPC

local vendorHead = Instance.new("Part")
vendorHead.Name = "Head"
vendorHead.Anchored = true
vendorHead.Shape = Enum.PartType.Ball
vendorHead.Size = Vector3.new(2, 2, 2)
vendorHead.Position = SHOP_POS + Vector3.new(0, VENDOR_Y + 5, -3)
vendorHead.Color = Color3.fromRGB(200, 160, 110)
vendorHead.Material = Enum.Material.SmoothPlastic
vendorHead.Parent = shopNPC

-- Chapeau de cowboy stylisé
local hat = Instance.new("Part")
hat.Name = "Hat"
hat.Anchored = true
hat.Size = Vector3.new(2.8, 0.3, 2.8)
hat.Position = SHOP_POS + Vector3.new(0, VENDOR_Y + 6.2, -3)
hat.Color = Color3.fromRGB(100, 65, 25)
hat.Material = Enum.Material.Leather
hat.Parent = shopNPC

-- Jambes vendeur
for i, offset in ipairs({-0.5, 0.5}) do
	local leg = Instance.new("Part")
	leg.Name = "Leg" .. i
	leg.Anchored = true
	leg.Size = Vector3.new(0.8, 2, 0.8)
	leg.Position = SHOP_POS + Vector3.new(offset, VENDOR_Y + 0.5, -3)
	leg.Color = Color3.fromRGB(70, 50, 30)
	leg.Material = Enum.Material.SmoothPlastic
	leg.Parent = shopNPC
end

shopNPC.PrimaryPart = vendorTorso
addBillboard(vendorHead, "Jake le Forgeron", Color3.fromRGB(255, 200, 80), Vector3.new(0, 3, 0))

-- ProximityPrompt sur le vendeur
local shopPrompt = Instance.new("ProximityPrompt")
shopPrompt.ObjectText = "Jake le Forgeron"
shopPrompt.ActionText = "Acheter des outils"
shopPrompt.HoldDuration = 0
shopPrompt.MaxActivationDistance = 10
shopPrompt.KeyboardKeyCode = Enum.KeyCode.E
shopPrompt.RequiresLineOfSight = false
shopPrompt.Parent = vendorTorso

vendorTorso:SetAttribute("NPCType", "ToolShop")
vendorTorso:SetAttribute("NPCName", "Jake le Forgeron")

-- ── BUREAU D'ACHAT D'OR (Marchand) ──

local merchantFolder = Instance.new("Folder")
merchantFolder.Name = "GoldMerchant"
merchantFolder.Parent = townFolder

local MERCH_POS = TOWN_CENTER + Vector3.new(20, 0, -15)

-- Comptoir du marchand (stand ouvert)
makePart({ Name = "MerchCounter", Size = Vector3.new(10, 3, 2), Position = MERCH_POS + Vector3.new(0, 1.5, 0), Color = C.woodDark, Material = Enum.Material.Wood, Parent = merchantFolder })
-- Auvent
makePart({ Name = "MerchAwning", Size = Vector3.new(14, 0.3, 8), Position = MERCH_POS + Vector3.new(0, 7, -1), Color = C.tent, Material = Enum.Material.Fabric, Parent = merchantFolder })
-- Poteaux
for _, xOff in ipairs({-6, 6}) do
	makePart({ Name = "MerchPole", Size = Vector3.new(0.5, 7, 0.5), Position = MERCH_POS + Vector3.new(xOff, 3.5, -4), Color = C.wood, Material = Enum.Material.Wood, Parent = merchantFolder })
end

-- NPC Marchand
local merchNPC = Instance.new("Model")
merchNPC.Name = "Marcel"
merchNPC.Parent = merchantFolder

local MERCH_Y = 0.3 -- hauteur du sol ville
local merchTorso = Instance.new("Part")
merchTorso.Name = "HumanoidRootPart"
merchTorso.Anchored = true
merchTorso.Size = Vector3.new(2, 3, 1)
merchTorso.Position = MERCH_POS + Vector3.new(0, MERCH_Y + 3, -2)
merchTorso.Color = Color3.fromRGB(50, 100, 50)
merchTorso.Material = Enum.Material.SmoothPlastic
merchTorso.Parent = merchNPC

local merchHead = Instance.new("Part")
merchHead.Name = "Head"
merchHead.Anchored = true
merchHead.Shape = Enum.PartType.Ball
merchHead.Size = Vector3.new(2, 2, 2)
merchHead.Position = MERCH_POS + Vector3.new(0, MERCH_Y + 5, -2)
merchHead.Color = Color3.fromRGB(185, 145, 100)
merchHead.Material = Enum.Material.SmoothPlastic
merchHead.Parent = merchNPC

for i, offset in ipairs({-0.5, 0.5}) do
	local leg = Instance.new("Part")
	leg.Name = "Leg" .. i
	leg.Anchored = true
	leg.Size = Vector3.new(0.8, 2, 0.8)
	leg.Position = MERCH_POS + Vector3.new(offset, MERCH_Y + 0.5, -2)
	leg.Color = Color3.fromRGB(60, 60, 70)
	leg.Material = Enum.Material.SmoothPlastic
	leg.Parent = merchNPC
end

-- Balance dorée sur le comptoir
local balance = makePart({
	Name = "GoldBalance",
	Size = Vector3.new(2, 1.5, 1),
	Position = MERCH_POS + Vector3.new(-3, 3.7, 0),
	Color = C.gold,
	Material = Enum.Material.Metal,
	Parent = merchantFolder,
})

merchNPC.PrimaryPart = merchTorso
addBillboard(merchHead, "Marcel le Marchand", Color3.fromRGB(255, 215, 0), Vector3.new(0, 3, 0))

-- ProximityPrompt
local merchPrompt = Instance.new("ProximityPrompt")
merchPrompt.ObjectText = "Marcel le Marchand"
merchPrompt.ActionText = "Vendre de l'or"
merchPrompt.HoldDuration = 0
merchPrompt.MaxActivationDistance = 10
merchPrompt.KeyboardKeyCode = Enum.KeyCode.E
merchPrompt.RequiresLineOfSight = false
merchPrompt.Parent = merchTorso

merchTorso:SetAttribute("NPCType", "Merchant")
merchTorso:SetAttribute("NPCName", "Marcel le Marchand")
merchTorso:SetAttribute("MerchantId", "marchand_local")

-- ── PANNEAU DE LEADERBOARD ──

local leaderboardSign = makePart({
	Name = "LeaderboardSign",
	Size = Vector3.new(8, 10, 1),
	Position = TOWN_CENTER + Vector3.new(0, 5, -28),
	Color = C.woodDark,
	Material = Enum.Material.Wood,
	Parent = townFolder,
})
addBillboard(leaderboardSign, "CLASSEMENT DES PROSPECTEURS", C.gold, Vector3.new(0, 6, 0))

-- ── DÉCORATION VILLE ──

-- Lampadaires
for _, pos in ipairs({
	TOWN_CENTER + Vector3.new(-25, 0, 25),
	TOWN_CENTER + Vector3.new(25, 0, 25),
	TOWN_CENTER + Vector3.new(-25, 0, -25),
	TOWN_CENTER + Vector3.new(25, 0, -25),
}) do
	makePart({ Name = "LampPost", Size = Vector3.new(0.5, 10, 0.5), Position = pos + Vector3.new(0, 5, 0), Color = C.stoneDark, Material = Enum.Material.Metal, Parent = townFolder })
	makePart({ Name = "LampLight", Size = Vector3.new(2, 1, 2), Position = pos + Vector3.new(0, 10.5, 0), Color = Color3.fromRGB(255, 230, 150), Material = Enum.Material.Neon, Parent = townFolder })
end

-- Tonneaux décoratifs
for i = 1, 4 do
	makePart({
		Name = "Barrel_" .. i,
		Size = Vector3.new(2, 3, 2),
		Position = TOWN_CENTER + Vector3.new(-28 + i * 5, 1.5, 20),
		Color = C.woodDark,
		Material = Enum.Material.Wood,
		Shape = Enum.PartType.Cylinder,
		Parent = townFolder,
	})
end

-- Caisse de dynamite (déco)
makePart({
	Name = "DynamiteCrate",
	Size = Vector3.new(3, 2, 2),
	Position = SHOP_POS + Vector3.new(9, 1, 4),
	Color = Color3.fromRGB(180, 50, 30),
	Material = Enum.Material.Wood,
	Parent = townFolder,
})

-- ═══════════════════════════════════════════
-- ZONE 2 : RUISSEAU DORÉ (niveau 2)
-- ═══════════════════════════════════════════

local creek2Folder = Instance.new("Folder")
creek2Folder.Name = "RuisseauDore"
creek2Folder.Parent = worldFolder

-- Terrain surélevé
makePart({
	Name = "CreekGround",
	Size = Vector3.new(180, 3, 130),
	Position = Vector3.new(400, 1.5, 0),
	Color = Color3.fromRGB(100, 80, 45),
	Material = Enum.Material.Ground,
	Parent = creek2Folder,
})

-- Eau du ruisseau
for i = 1, 5 do
	makePart({
		Name = "CreekWater_" .. i,
		Size = Vector3.new(12, 0.5, 25),
		Position = Vector3.new(400 + math.sin(i) * 15, 2.8, -50 + i * 20),
		Color = C.waterDeep,
		Material = Enum.Material.Glass,
		Transparency = 0.25,
		Parent = creek2Folder,
	})
end

-- ═══════════════════════════════════════════
-- ZONE 3 : COLLINES AMBRÉES (niveau 3)
-- ═══════════════════════════════════════════

local hillsFolder = Instance.new("Folder")
hillsFolder.Name = "CollinesAmbrees"
hillsFolder.Parent = worldFolder

-- Collines (bosses de terrain)
for i = 1, 5 do
	local hillSize = Vector3.new(
		30 + math.random(0, 20),
		10 + math.random(0, 15),
		30 + math.random(0, 20)
	)
	makePart({
		Name = "Hill_" .. i,
		Size = hillSize,
		Position = Vector3.new(
			650 + math.random(-60, 60),
			hillSize.Y / 2,
			50 + math.random(-60, 60)
		),
		Color = Color3.fromRGB(
			140 + math.random(-20, 20),
			100 + math.random(-20, 20),
			50 + math.random(-10, 10)
		),
		Material = Enum.Material.Rock,
		Parent = hillsFolder,
	})
end

-- ═══════════════════════════════════════════
-- ZONE 4 : GROTTES CRISTALLINES (niveau 4)
-- ═══════════════════════════════════════════

local cavesFolder = Instance.new("Folder")
cavesFolder.Name = "GrottesCristallines"
cavesFolder.Parent = worldFolder

-- Entrée de grotte
makePart({
	Name = "CaveEntrance",
	Size = Vector3.new(15, 12, 3),
	Position = Vector3.new(900, 0, -10),
	Color = C.stoneDark,
	Material = Enum.Material.Slate,
	Parent = cavesFolder,
})
-- Arch
makePart({
	Name = "CaveArch",
	Size = Vector3.new(8, 2, 3),
	Position = Vector3.new(900, 10, -10),
	Color = C.stone,
	Material = Enum.Material.Slate,
	Parent = cavesFolder,
})
-- Sol de grotte (en dessous)
makePart({
	Name = "CaveFloor",
	Size = Vector3.new(150, 1, 150),
	Position = Vector3.new(900, -12, 0),
	Color = Color3.fromRGB(60, 55, 50),
	Material = Enum.Material.Slate,
	Parent = cavesFolder,
})
-- Cristaux décoratifs
for i = 1, 8 do
	makePart({
		Name = "Crystal_" .. i,
		Size = Vector3.new(1, math.random(3, 8), 1),
		Position = Vector3.new(
			900 + math.random(-50, 50),
			-12 + math.random(1, 4),
			math.random(-50, 50)
		),
		Color = Color3.fromRGB(
			math.random(100, 200),
			math.random(50, 150),
			math.random(150, 255)
		),
		Material = Enum.Material.Neon,
		Transparency = 0.3,
		Parent = cavesFolder,
	})
end

-- ═══════════════════════════════════════════
-- SPAWN POINT (sur la place de la ville)
-- ═══════════════════════════════════════════

-- SpawnLocation déjà dans project.json (statique, disponible dès le chargement)

print("[Gold Rush Legacy] Map built! " .. #Config.Zones .. " zones, town, river, merchants")
