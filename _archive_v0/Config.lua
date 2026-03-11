-- Gold Rush Legacy - Configuration partagée
-- Module accessible depuis client ET server

local Config = {}

-- ═══════════════════════════════════════════
-- OUTILS
-- ═══════════════════════════════════════════
Config.Tools = {
	{
		id = "batee",
		name = "Batée",
		description = "L'outil de base pour orpailler",
		price = 0, -- gratuit au départ
		miningSpeed = 1.0, -- multiplicateur de vitesse
		yieldMultiplier = 1.0,
		levelRequired = 1,
		color = Color3.fromRGB(139, 90, 43),
	},
	{
		id = "batee_pro",
		name = "Batée Pro",
		description = "Batée améliorée, meilleur rendement",
		price = 500,
		miningSpeed = 1.3,
		yieldMultiplier = 1.5,
		levelRequired = 2,
		color = Color3.fromRGB(180, 120, 60),
	},
	{
		id = "tapis",
		name = "Tapis d'orpaillage",
		description = "Extraction semi-automatique",
		price = 2000,
		miningSpeed = 1.8,
		yieldMultiplier = 2.0,
		levelRequired = 3,
		color = Color3.fromRGB(60, 120, 60),
	},
	{
		id = "detecteur",
		name = "Détecteur d'or",
		description = "Trouve les meilleurs filons",
		price = 8000,
		miningSpeed = 2.5,
		yieldMultiplier = 3.0,
		levelRequired = 4,
		color = Color3.fromRGB(200, 200, 50),
	},
	{
		id = "foreuse",
		name = "Foreuse industrielle",
		description = "Extraction massive",
		price = 25000,
		miningSpeed = 4.0,
		yieldMultiplier = 5.0,
		levelRequired = 5,
		color = Color3.fromRGB(150, 150, 150),
	},
}

-- Index rapide par id
Config.ToolsById = {}
for _, tool in ipairs(Config.Tools) do
	Config.ToolsById[tool.id] = tool
end

-- ═══════════════════════════════════════════
-- TYPES D'OR
-- ═══════════════════════════════════════════
Config.GoldTypes = {
	{
		id = "paillettes",
		name = "Paillettes d'or",
		baseValue = 10,
		color = Color3.fromRGB(255, 215, 0),
		rarity = "Commun",
		dropWeight = 60,
	},
	{
		id = "pepite_small",
		name = "Petite pépite",
		baseValue = 50,
		color = Color3.fromRGB(255, 200, 0),
		rarity = "Peu commun",
		dropWeight = 25,
	},
	{
		id = "pepite_large",
		name = "Grosse pépite",
		baseValue = 200,
		color = Color3.fromRGB(218, 165, 32),
		rarity = "Rare",
		dropWeight = 10,
	},
	{
		id = "or_pur",
		name = "Or pur",
		baseValue = 500,
		color = Color3.fromRGB(255, 180, 0),
		rarity = "Très rare",
		dropWeight = 4,
	},
	{
		id = "pepite_legendaire",
		name = "Pépite légendaire",
		baseValue = 2000,
		color = Color3.fromRGB(255, 150, 50),
		rarity = "Légendaire",
		dropWeight = 1,
	},
}

-- Index rapide
Config.GoldTypesById = {}
for _, gold in ipairs(Config.GoldTypes) do
	Config.GoldTypesById[gold.id] = gold
end

-- ═══════════════════════════════════════════
-- GEMMES
-- ═══════════════════════════════════════════
Config.Gems = {
	{ id = "quartz",    name = "Quartz",    baseValue = 25,   color = Color3.fromRGB(200, 200, 220), rarity = "Commun",     dropWeight = 40 },
	{ id = "amethyste", name = "Améthyste", baseValue = 100,  color = Color3.fromRGB(153, 50, 204),  rarity = "Peu commun", dropWeight = 25 },
	{ id = "topaze",    name = "Topaze",    baseValue = 400,  color = Color3.fromRGB(255, 200, 50),  rarity = "Rare",       dropWeight = 15 },
	{ id = "saphir",    name = "Saphir",    baseValue = 1000, color = Color3.fromRGB(15, 82, 186),   rarity = "Très rare",  dropWeight = 10 },
	{ id = "rubis",     name = "Rubis",     baseValue = 3000, color = Color3.fromRGB(224, 17, 95),   rarity = "Ultra rare", dropWeight = 7 },
	{ id = "diamant",   name = "Diamant",   baseValue = 8000, color = Color3.fromRGB(185, 242, 255), rarity = "Légendaire", dropWeight = 3 },
}

Config.GemsById = {}
for _, gem in ipairs(Config.Gems) do
	Config.GemsById[gem.id] = gem
end

-- ═══════════════════════════════════════════
-- ZONES
-- ═══════════════════════════════════════════
Config.Zones = {
	{
		id = "riviere_tranquille",
		name = "Rivière Tranquille",
		levelRequired = 1,
		goldMultiplier = 1.0,
		gemChance = 0.05, -- 5% chance de gemme
		maxSpots = 15,
		respawnTime = 15, -- secondes
		color = Color3.fromRGB(34, 139, 34),
		position = Vector3.new(150, 0, 0),
		size = Vector3.new(200, 10, 150),
	},
	{
		id = "ruisseau_dore",
		name = "Ruisseau Doré",
		levelRequired = 2,
		goldMultiplier = 1.8,
		gemChance = 0.10,
		maxSpots = 12,
		respawnTime = 20,
		color = Color3.fromRGB(184, 134, 11),
		position = Vector3.new(400, 5, 0),
		size = Vector3.new(180, 10, 130),
	},
	{
		id = "collines_ambrees",
		name = "Collines Ambrées",
		levelRequired = 3,
		goldMultiplier = 3.0,
		gemChance = 0.20,
		maxSpots = 10,
		respawnTime = 30,
		color = Color3.fromRGB(160, 82, 45),
		position = Vector3.new(650, 15, 50),
		size = Vector3.new(200, 30, 200),
	},
	{
		id = "grottes_cristallines",
		name = "Grottes Cristallines",
		levelRequired = 4,
		goldMultiplier = 5.0,
		gemChance = 0.40,
		maxSpots = 8,
		respawnTime = 45,
		color = Color3.fromRGB(72, 61, 139),
		position = Vector3.new(900, -10, 0),
		size = Vector3.new(150, 40, 150),
	},
}

Config.ZonesById = {}
for _, zone in ipairs(Config.Zones) do
	Config.ZonesById[zone.id] = zone
end

-- ═══════════════════════════════════════════
-- PROGRESSION
-- ═══════════════════════════════════════════
Config.Levels = {
	{ level = 1, name = "Amateur",      xpRequired = 0,     title = "🥉 Amateur" },
	{ level = 2, name = "Orpailleur",   xpRequired = 500,   title = "🥈 Orpailleur" },
	{ level = 3, name = "Prospecteur",  xpRequired = 2000,  title = "🥇 Prospecteur" },
	{ level = 4, name = "Exploitant",   xpRequired = 8000,  title = "💎 Exploitant" },
	{ level = 5, name = "Industriel",   xpRequired = 25000, title = "👑 Industriel" },
}

-- XP rewards
Config.XP = {
	perMine = 10,       -- XP par extraction
	perSell = 5,        -- XP par vente
	perRareFind = 50,   -- bonus pour trouvaille rare
	perGemFind = 100,   -- bonus pour gemme
}

-- ═══════════════════════════════════════════
-- ÉCONOMIE
-- ═══════════════════════════════════════════
Config.Economy = {
	startCash = 100,
	miningCooldown = 3.0,    -- secondes entre chaque minage (base)
	miningDuration = 4.0,    -- durée du minage en secondes (base)
	sellMultiplier = 1.0,    -- multiplicateur de prix de vente
	spotRespawnTime = 15,    -- secondes avant respawn d'un spot
}

-- ═══════════════════════════════════════════
-- MARCHANDS
-- ═══════════════════════════════════════════
Config.Merchants = {
	{
		id = "marchand_local",
		name = "Marcel le Marchand",
		description = "Achète tout, prix bas",
		priceMultiplier = 0.7,
		levelRequired = 1,
	},
	{
		id = "negociant",
		name = "Hugo le Négociant",
		description = "Meilleurs prix, veut de la quantité",
		priceMultiplier = 1.0,
		levelRequired = 2,
	},
	{
		id = "joaillier",
		name = "Sophie la Joaillière",
		description = "Prix premium pour les gemmes",
		priceMultiplier = 1.5,
		levelRequired = 3,
	},
}

return Config
