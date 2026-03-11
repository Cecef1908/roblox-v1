--[[
	Gold Rush Legacy - PlayerData.server.lua
	Gère : économie, inventaire, progression, outils, sauvegarde DataStore
]]

print("[PlayerData] Script starting...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
print("[PlayerData] Config loaded OK")

-- DataStore (pcall pour fonctionner en local/non-publié)
local dataStore = nil
local dsOk, dsErr = pcall(function()
	dataStore = DataStoreService:GetDataStore("GoldRushLegacy_v1")
end)
if not dsOk then
	warn("[PlayerData] DataStore unavailable (local mode): " .. tostring(dsErr))
end

-- ═══════════════════════════════════════════
-- REMOTE EVENTS
-- ═══════════════════════════════════════════
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function createRemote(name, className)
	local remote = Instance.new(className or "RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
	return remote
end

local MineGoldEvent = createRemote("MineGold")
local SellGoldEvent = createRemote("SellGold")
local BuyToolEvent = createRemote("BuyTool")
local NotifyEvent = createRemote("Notify")
local UpdateInventoryEvent = createRemote("UpdateInventory")
local UpdateXPEvent = createRemote("UpdateXP")
local MineResultEvent = createRemote("MineResult")
local SellResultEvent = createRemote("SellResult")

-- ═══════════════════════════════════════════
-- PLAYER DATA
-- ═══════════════════════════════════════════
local playerData = {}

local DEFAULT_DATA = {
	cash = Config.Economy.startCash,
	xp = 0,
	level = 1,
	currentTool = "batee",
	ownedTools = { "batee" },
	inventory = {
		paillettes = 0,
		pepite_small = 0,
		pepite_large = 0,
		or_pur = 0,
		pepite_legendaire = 0,
	},
	gems = {
		quartz = 0,
		amethyste = 0,
		topaze = 0,
		saphir = 0,
		rubis = 0,
		diamant = 0,
	},
	totalGoldMined = 0,
	totalCashEarned = 0,
	totalMiningActions = 0,
}

local function deepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

-- ═══════════════════════════════════════════
-- SAUVEGARDE / CHARGEMENT
-- ═══════════════════════════════════════════
local function loadPlayerData(player)
	local key = "player_" .. player.UserId
	local success, data = false, nil
	if dataStore then
		success, data = pcall(function()
			return dataStore:GetAsync(key)
		end)
	end

	if success and data then
		local merged = deepCopy(DEFAULT_DATA)
		for k, v in pairs(data) do
			if type(v) == "table" and type(merged[k]) == "table" then
				for k2, v2 in pairs(v) do
					merged[k][k2] = v2
				end
			else
				merged[k] = v
			end
		end
		playerData[player.UserId] = merged
	else
		playerData[player.UserId] = deepCopy(DEFAULT_DATA)
	end

	return playerData[player.UserId]
end

local function savePlayerData(player)
	local data = playerData[player.UserId]
	if not data or not dataStore then return end

	local key = "player_" .. player.UserId
	pcall(function()
		dataStore:UpdateAsync(key, function()
			return data
		end)
	end)
end

-- ═══════════════════════════════════════════
-- LEADERSTATS
-- ═══════════════════════════════════════════
local function setupLeaderstats(player, data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = data.cash
	cash.Parent = leaderstats

	local level = Instance.new("IntValue")
	level.Name = "Niveau"
	level.Value = data.level
	level.Parent = leaderstats

	local goldMined = Instance.new("IntValue")
	goldMined.Name = "Or"
	goldMined.Value = data.totalGoldMined
	goldMined.Parent = leaderstats
end

local function updateLeaderstats(player, data)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return end
	ls.Cash.Value = data.cash
	ls.Niveau.Value = data.level
	ls.Or.Value = data.totalGoldMined
end

-- ═══════════════════════════════════════════
-- PROGRESSION
-- ═══════════════════════════════════════════
local function getLevel(xp)
	local currentLevel = 1
	for _, levelData in ipairs(Config.Levels) do
		if xp >= levelData.xpRequired then
			currentLevel = levelData.level
		end
	end
	return currentLevel
end

local function addXP(player, amount)
	local data = playerData[player.UserId]
	if not data then return end

	local oldLevel = data.level
	data.xp = data.xp + amount
	data.level = getLevel(data.xp)

	if data.level > oldLevel then
		local levelInfo = Config.Levels[data.level]
		NotifyEvent:FireClient(player, {
			title = "LEVEL UP !",
			message = "Tu es maintenant " .. levelInfo.title .. " !",
			type = "levelup",
		})
	end

	UpdateXPEvent:FireClient(player, {
		xp = data.xp,
		level = data.level,
		nextLevelXP = Config.Levels[math.min(data.level + 1, #Config.Levels)].xpRequired,
		currentTool = data.currentTool,
		ownedTools = data.ownedTools,
	})

	updateLeaderstats(player, data)
end

-- ═══════════════════════════════════════════
-- DEBOUNCE (anti double-click)
-- ═══════════════════════════════════════════
local actionCooldowns = {} -- { [userId] = { [action] = lastTime } }

local function canDoAction(player, action, cooldown)
	local userId = player.UserId
	if not actionCooldowns[userId] then
		actionCooldowns[userId] = {}
	end
	local now = tick()
	local last = actionCooldowns[userId][action] or 0
	if now - last < cooldown then
		return false
	end
	actionCooldowns[userId][action] = now
	return true
end

-- ═══════════════════════════════════════════
-- MINING LOGIC
-- ═══════════════════════════════════════════
local miningCooldowns = {}

local function rollLoot(zoneId, toolId, precisionMultiplier)
	local zone = Config.ZonesById[zoneId]
	local tool = Config.ToolsById[toolId]
	if not zone or not tool then return nil end

	-- Clamp precision (anti-cheat basique)
	precisionMultiplier = math.clamp(precisionMultiplier or 1, 1, 2)

	local loot = {}

	-- Roll pour l'or (precision haute = meilleure chance de rare)
	local totalWeight = 0
	for _, goldType in ipairs(Config.GoldTypes) do
		totalWeight = totalWeight + goldType.dropWeight
	end

	-- Si PERFECT, réduire le poids des items communs → plus de chances de rares
	local adjustedWeights = {}
	for _, goldType in ipairs(Config.GoldTypes) do
		local w = goldType.dropWeight
		if precisionMultiplier >= 2.0 and goldType.dropWeight > 20 then
			w = w * 0.5 -- divise par 2 le poids des communs sur PERFECT
		end
		table.insert(adjustedWeights, { type = goldType, weight = w })
	end

	local adjustedTotal = 0
	for _, entry in ipairs(adjustedWeights) do
		adjustedTotal = adjustedTotal + entry.weight
	end

	local roll = math.random() * adjustedTotal
	local cumulative = 0
	local selectedGold = Config.GoldTypes[1]

	for _, entry in ipairs(adjustedWeights) do
		cumulative = cumulative + entry.weight
		if roll <= cumulative then
			selectedGold = entry.type
			break
		end
	end

	-- Quantité basée sur zone + outil + precision
	local quantity = math.random(1, 3)
	quantity = math.floor(quantity * zone.goldMultiplier * tool.yieldMultiplier * precisionMultiplier)
	quantity = math.max(1, quantity)

	loot.gold = {
		id = selectedGold.id,
		name = selectedGold.name,
		quantity = quantity,
		value = selectedGold.baseValue * quantity,
		rarity = selectedGold.rarity,
	}

	loot.precision = precisionMultiplier

	-- Roll pour les gemmes (precision booste la chance)
	local gemChance = zone.gemChance * (1 + (precisionMultiplier - 1) * 0.5)
	if math.random() < gemChance then
		local gemTotalWeight = 0
		for _, gem in ipairs(Config.Gems) do
			gemTotalWeight = gemTotalWeight + gem.dropWeight
		end

		local gemRoll = math.random() * gemTotalWeight
		local gemCumulative = 0
		local selectedGem = Config.Gems[1]

		for _, gem in ipairs(Config.Gems) do
			gemCumulative = gemCumulative + gem.dropWeight
			if gemRoll <= gemCumulative then
				selectedGem = gem
				break
			end
		end

		loot.gem = {
			id = selectedGem.id,
			name = selectedGem.name,
			quantity = 1,
			value = selectedGem.baseValue,
			rarity = selectedGem.rarity,
		}
	end

	return loot
end

MineGoldEvent.OnServerEvent:Connect(function(player, spotData)
	local data = playerData[player.UserId]
	if not data then return end

	-- Input validation
	if type(spotData) ~= "table" then return end
	if spotData.spotName ~= nil and type(spotData.spotName) ~= "string" then return end
	if spotData.zoneId ~= nil and type(spotData.zoneId) ~= "string" then return end

	-- Cooldown
	local now = tick()
	local lastMine = miningCooldowns[player.UserId] or 0
	local tool = Config.ToolsById[data.currentTool]
	local cooldown = Config.Economy.miningCooldown / (tool and tool.miningSpeed or 1)

	if now - lastMine < cooldown then
		NotifyEvent:FireClient(player, {
			title = "Trop rapide",
			message = "Attends un peu avant de miner a nouveau !",
			type = "warning",
		})
		return
	end
	miningCooldowns[player.UserId] = now

	-- Zone check
	local zoneId = spotData and spotData.zoneId or "riviere_tranquille"
	local zone = Config.ZonesById[zoneId]
	if zone and data.level < zone.levelRequired then
		NotifyEvent:FireClient(player, {
			title = "Zone verrouillée",
			message = "Il faut être niveau " .. zone.levelRequired .. " pour miner ici !",
			type = "error",
		})
		return
	end

	-- Roll loot (avec precision du mini-jeu)
	local precision = spotData and spotData.precision or 1
	local loot = rollLoot(zoneId, data.currentTool, precision)
	if not loot then return end

	-- Ajouter à l'inventaire
	if loot.gold then
		local goldId = loot.gold.id
		data.inventory[goldId] = (data.inventory[goldId] or 0) + loot.gold.quantity
		data.totalGoldMined = data.totalGoldMined + loot.gold.quantity
		data.totalMiningActions = data.totalMiningActions + 1
	end

	if loot.gem then
		local gemId = loot.gem.id
		data.gems[gemId] = (data.gems[gemId] or 0) + loot.gem.quantity
	end

	-- XP
	local xpGain = Config.XP.perMine
	if loot.gold and (loot.gold.rarity == "Rare" or loot.gold.rarity == "Très rare" or loot.gold.rarity == "Légendaire") then
		xpGain = xpGain + Config.XP.perRareFind
	end
	if loot.gem then
		xpGain = xpGain + Config.XP.perGemFind
	end
	addXP(player, xpGain)

	-- Résultat au client
	MineResultEvent:FireClient(player, {
		loot = loot,
		xpGain = xpGain,
	})

	UpdateInventoryEvent:FireClient(player, {
		inventory = data.inventory,
		gems = data.gems,
		cash = data.cash,
	})

	updateLeaderstats(player, data)

	-- Respawn le spot miné via BindableEvent (Fix 4)
	if spotData and spotData.spotName then
		task.spawn(function()
			local ServerScriptService = game:GetService("ServerScriptService")
			local respawnEvent = ServerScriptService:WaitForChild("RespawnMiningSpotEvent", 10)
			if respawnEvent then
				respawnEvent:Fire(spotData.spotName)
			end
		end)
	end
end)

-- ═══════════════════════════════════════════
-- SELL LOGIC
-- ═══════════════════════════════════════════
SellGoldEvent.OnServerEvent:Connect(function(player, sellData)
	if not canDoAction(player, "sell", 1) then
		NotifyEvent:FireClient(player, {
			title = "Patiente",
			message = "Tu viens deja de vendre, attends un instant !",
			type = "warning",
		})
		return
	end

	local data = playerData[player.UserId]
	if not data then return end

	if type(sellData) ~= "table" then return end
	local merchantId = type(sellData.merchantId) == "string" and sellData.merchantId or "marchand_local"
	local merchant = nil
	for _, m in ipairs(Config.Merchants) do
		if m.id == merchantId then
			merchant = m
			break
		end
	end
	if not merchant then return end

	if data.level < merchant.levelRequired then
		NotifyEvent:FireClient(player, {
			title = "Accès refusé",
			message = merchant.name .. " ne traite pas avec les débutants !",
			type = "error",
		})
		return
	end

	local totalEarnings = 0
	local itemsSold = {}

	-- Vendre tout l'or
	for goldId, quantity in pairs(data.inventory) do
		if quantity > 0 then
			local goldType = Config.GoldTypesById[goldId]
			if goldType then
				local value = math.floor(goldType.baseValue * quantity * merchant.priceMultiplier)
				totalEarnings = totalEarnings + value
				table.insert(itemsSold, { name = goldType.name, quantity = quantity, value = value })
				data.inventory[goldId] = 0
			end
		end
	end

	-- Vendre les gemmes
	for gemId, quantity in pairs(data.gems) do
		if quantity > 0 then
			local gem = Config.GemsById[gemId]
			if gem then
				local value = math.floor(gem.baseValue * quantity * merchant.priceMultiplier)
				totalEarnings = totalEarnings + value
				table.insert(itemsSold, { name = gem.name, quantity = quantity, value = value })
				data.gems[gemId] = 0
			end
		end
	end

	if totalEarnings == 0 then
		NotifyEvent:FireClient(player, {
			title = "Rien à vendre",
			message = "Tu n'as rien dans ton inventaire !",
			type = "warning",
		})
		return
	end

	data.cash = data.cash + totalEarnings
	data.totalCashEarned = data.totalCashEarned + totalEarnings
	addXP(player, Config.XP.perSell * #itemsSold)

	SellResultEvent:FireClient(player, {
		totalEarnings = totalEarnings,
		itemsSold = itemsSold,
		merchantName = merchant.name,
	})

	UpdateInventoryEvent:FireClient(player, {
		inventory = data.inventory,
		gems = data.gems,
		cash = data.cash,
	})

	updateLeaderstats(player, data)
end)

-- ═══════════════════════════════════════════
-- BUY TOOL
-- ═══════════════════════════════════════════
BuyToolEvent.OnServerEvent:Connect(function(player, toolId)
	if not canDoAction(player, "buy", 0.5) then
		NotifyEvent:FireClient(player, {
			title = "Patiente",
			message = "Attends un instant avant d'acheter a nouveau !",
			type = "warning",
		})
		return
	end

	local data = playerData[player.UserId]
	if not data then return end

	if type(toolId) ~= "string" then return end
	local tool = Config.ToolsById[toolId]
	if not tool then return end

	-- Déjà possédé → juste équiper
	for _, owned in ipairs(data.ownedTools) do
		if owned == toolId then
			data.currentTool = toolId
			NotifyEvent:FireClient(player, {
				title = "Outil équipé",
				message = tool.name .. " est maintenant ton outil actif !",
				type = "success",
			})
			UpdateXPEvent:FireClient(player, {
				xp = data.xp,
				level = data.level,
				nextLevelXP = Config.Levels[math.min(data.level + 1, #Config.Levels)].xpRequired,
				currentTool = data.currentTool,
				ownedTools = data.ownedTools,
			})
			return
		end
	end

	if data.level < tool.levelRequired then
		NotifyEvent:FireClient(player, {
			title = "Niveau insuffisant",
			message = "Il faut être niveau " .. tool.levelRequired .. " !",
			type = "error",
		})
		return
	end

	if data.cash < tool.price then
		NotifyEvent:FireClient(player, {
			title = "Pas assez d'argent",
			message = "Il te faut $" .. tool.price .. " !",
			type = "error",
		})
		return
	end

	data.cash = data.cash - tool.price
	table.insert(data.ownedTools, toolId)
	data.currentTool = toolId

	NotifyEvent:FireClient(player, {
		title = "Nouvel outil !",
		message = tool.name .. " acheté ! Rendement x" .. tool.yieldMultiplier,
		type = "success",
	})

	UpdateInventoryEvent:FireClient(player, {
		inventory = data.inventory,
		gems = data.gems,
		cash = data.cash,
	})

	UpdateXPEvent:FireClient(player, {
		xp = data.xp,
		level = data.level,
		nextLevelXP = Config.Levels[math.min(data.level + 1, #Config.Levels)].xpRequired,
		currentTool = data.currentTool,
		ownedTools = data.ownedTools,
	})

	updateLeaderstats(player, data)
end)

-- ═══════════════════════════════════════════
-- PLAYER JOIN / LEAVE
-- ═══════════════════════════════════════════
Players.PlayerAdded:Connect(function(player)
	local data = loadPlayerData(player)
	setupLeaderstats(player, data)

	task.wait(1)
	UpdateInventoryEvent:FireClient(player, {
		inventory = data.inventory,
		gems = data.gems,
		cash = data.cash,
	})
	UpdateXPEvent:FireClient(player, {
		xp = data.xp,
		level = data.level,
		nextLevelXP = Config.Levels[math.min(data.level + 1, #Config.Levels)].xpRequired,
		currentTool = data.currentTool,
		ownedTools = data.ownedTools,
	})
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
	playerData[player.UserId] = nil
	miningCooldowns[player.UserId] = nil
	actionCooldowns[player.UserId] = nil
end)

-- Auto-save toutes les 60s
task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayerData(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayerData(player)
	end
end)

print("[Gold Rush Legacy] PlayerData system loaded")
