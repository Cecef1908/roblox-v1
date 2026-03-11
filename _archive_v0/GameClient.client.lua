--[[
	Gold Rush Legacy - GameClient.client.lua
	Gère toute l'UI côté joueur :
	- HUD (cash, XP, niveau, outil)
	- Notifications & loot popup
	- Shop d'outils (NPC Jake)
	- Vente d'or (NPC Marcel)
	- Inventaire rapide
	- Barre de minage
	- Zone indicator
]]

print("[GameClient] Script starting...")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

-- ═══════════════════════════════════════════
-- ATTENDRE LES REMOTES
-- ═══════════════════════════════════════════

print("[GameClient] Waiting for Remotes...")
local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not remotes then
	warn("[GameClient] Remotes folder not found after 30s!")
	return
end
print("[GameClient] Remotes found, loading events...")
local MineGoldEvent = remotes:WaitForChild("MineGold", 10)
local SellGoldEvent = remotes:WaitForChild("SellGold", 10)
local BuyToolEvent = remotes:WaitForChild("BuyTool", 10)
local NotifyEvent = remotes:WaitForChild("Notify", 10)
local UpdateInventoryEvent = remotes:WaitForChild("UpdateInventory", 10)
local UpdateXPEvent = remotes:WaitForChild("UpdateXP", 10)
local MineResultEvent = remotes:WaitForChild("MineResult", 10)
local SellResultEvent = remotes:WaitForChild("SellResult", 10)
print("[GameClient] All events loaded:", MineGoldEvent ~= nil, SellGoldEvent ~= nil)

-- ═══════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════

local playerState = {
	cash = Config.Economy.startCash,
	xp = 0,
	level = 1,
	nextLevelXP = 500,
	currentTool = "batee",
	ownedTools = { "batee" },
	inventory = {},
	gems = {},
}

-- ═══════════════════════════════════════════
-- UTILS
-- ═══════════════════════════════════════════

local function formatCash(amount)
	local s = tostring(math.floor(amount))
	local formatted = ""
	local len = #s
	for i = 1, len do
		if i > 1 and (len - i + 1) % 3 == 0 then
			formatted = formatted .. ","
		end
		formatted = formatted .. s:sub(i, i)
	end
	return "$" .. formatted
end

local function createCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function createPadding(parent, padding)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, padding)
	p.PaddingRight = UDim.new(0, padding)
	p.PaddingTop = UDim.new(0, padding)
	p.PaddingBottom = UDim.new(0, padding)
	p.Parent = parent
	return p
end

-- Couleurs thème
local THEME = {
	bg = Color3.fromRGB(15, 12, 8),
	bgLight = Color3.fromRGB(30, 25, 18),
	bgPanel = Color3.fromRGB(25, 20, 14),
	gold = Color3.fromRGB(255, 215, 0),
	goldDark = Color3.fromRGB(180, 140, 30),
	green = Color3.fromRGB(80, 200, 80),
	red = Color3.fromRGB(220, 60, 60),
	blue = Color3.fromRGB(80, 150, 255),
	white = Color3.fromRGB(240, 235, 220),
	muted = Color3.fromRGB(160, 150, 130),
	accent = Color3.fromRGB(200, 160, 50),
}

-- ═══════════════════════════════════════════
-- SOUND SYSTEM
-- ═══════════════════════════════════════════

local sounds = {}

local function createSound(name, soundId, volume, pitch)
	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = "rbxassetid://" .. soundId
	s.Volume = volume or 0.5
	s.PlaybackSpeed = pitch or 1
	s.Parent = SoundService
	sounds[name] = s
	return s
end

-- Sons désactivés temporairement (IDs invalides en local)
-- TODO: Remplacer par des IDs valides depuis le Roblox Creator Store
--[[
createSound("mine_hit", "12221976", 0.6, 1.2)
createSound("mine_hit2", "12221976", 0.5, 0.9)
createSound("gold_found", "5765734830", 0.7, 1.0)
createSound("gem_found", "5765734830", 0.8, 1.4)
createSound("rare_found", "3308923997", 0.8, 1.0)
createSound("sell_cash", "5693412489", 0.5, 1.0)
createSound("buy_item", "5693412489", 0.5, 0.8)
createSound("level_up", "3308923997", 1.0, 1.2)
createSound("ui_click", "6895079853", 0.3, 1.0)
createSound("mining_start", "12221976", 0.4, 0.7)
--]]

local function playSound(name)
	local s = sounds[name]
	if s then
		s:Play()
	end
end

-- ═══════════════════════════════════════════
-- SCREEN EFFECTS (flash, shake)
-- ═══════════════════════════════════════════

local effectScreen = Instance.new("ScreenGui")
effectScreen.Name = "EffectsGui"
effectScreen.ResetOnSpawn = false
effectScreen.IgnoreGuiInset = true
effectScreen.DisplayOrder = 100
effectScreen.Parent = playerGui

-- Flash overlay (pour les rares)
local flashFrame = Instance.new("Frame")
flashFrame.Size = UDim2.new(1, 0, 1, 0)
flashFrame.BackgroundColor3 = THEME.gold
flashFrame.BackgroundTransparency = 1
flashFrame.BorderSizePixel = 0
flashFrame.ZIndex = 100
flashFrame.Parent = effectScreen

local function flashScreen(color, intensity, duration)
	flashFrame.BackgroundColor3 = color or THEME.gold
	flashFrame.BackgroundTransparency = 1 - (intensity or 0.3)
	TweenService:Create(flashFrame, TweenInfo.new(duration or 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
end

-- Camera shake
local function shakeCamera(intensity, duration)
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local originalCFrame = camera.CFrame
	local elapsed = 0
	local shakeConn
	shakeConn = RunService.RenderStepped:Connect(function(dt)
		elapsed = elapsed + dt
		if elapsed >= duration then
			shakeConn:Disconnect()
			return
		end
		local progress = 1 - (elapsed / duration)
		local shakeX = (math.random() - 0.5) * intensity * progress
		local shakeY = (math.random() - 0.5) * intensity * progress
		camera.CFrame = camera.CFrame * CFrame.new(shakeX, shakeY, 0)
	end)
end

-- ═══════════════════════════════════════════
-- HUD PRINCIPAL (bas de l'écran)
-- ═══════════════════════════════════════════

local hudScreen = Instance.new("ScreenGui")
hudScreen.Name = "GoldRushHUD"
hudScreen.ResetOnSpawn = false
hudScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hudScreen.Parent = playerGui

-- Cash display (bas gauche)
local cashFrame = Instance.new("Frame")
cashFrame.Name = "CashFrame"
cashFrame.Size = UDim2.new(0, 230, 0, 55)
cashFrame.Position = UDim2.new(0, 15, 1, -70)
cashFrame.BackgroundColor3 = THEME.bg
cashFrame.BackgroundTransparency = 0.15
cashFrame.BorderSizePixel = 0
cashFrame.Parent = hudScreen
createCorner(cashFrame, 12)

-- Gold accent bar
local cashAccent = Instance.new("Frame")
cashAccent.Size = UDim2.new(0, 4, 0.7, 0)
cashAccent.Position = UDim2.new(0, 6, 0.15, 0)
cashAccent.BackgroundColor3 = THEME.gold
cashAccent.BorderSizePixel = 0
cashAccent.Parent = cashFrame
createCorner(cashAccent, 2)

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "CashLabel"
cashLabel.Size = UDim2.new(1, -20, 1, 0)
cashLabel.Position = UDim2.new(0, 16, 0, 0)
cashLabel.BackgroundTransparency = 1
cashLabel.Text = formatCash(Config.Economy.startCash)
cashLabel.TextColor3 = THEME.gold
cashLabel.TextSize = 28
cashLabel.Font = Enum.Font.GothamBold
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.Parent = cashFrame

-- Level & XP (à droite du cash)
local levelFrame = Instance.new("Frame")
levelFrame.Name = "LevelFrame"
levelFrame.Size = UDim2.new(0, 200, 0, 55)
levelFrame.Position = UDim2.new(0, 255, 1, -70)
levelFrame.BackgroundColor3 = THEME.bg
levelFrame.BackgroundTransparency = 0.15
levelFrame.BorderSizePixel = 0
levelFrame.Parent = hudScreen
createCorner(levelFrame, 12)

local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "LevelLabel"
levelLabel.Size = UDim2.new(1, -15, 0, 22)
levelLabel.Position = UDim2.new(0, 10, 0, 5)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Niv. 1 - Amateur"
levelLabel.TextColor3 = THEME.white
levelLabel.TextSize = 14
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextXAlignment = Enum.TextXAlignment.Left
levelLabel.Parent = levelFrame

-- XP bar
local xpBarBg = Instance.new("Frame")
xpBarBg.Name = "XPBarBg"
xpBarBg.Size = UDim2.new(1, -20, 0, 12)
xpBarBg.Position = UDim2.new(0, 10, 0, 32)
xpBarBg.BackgroundColor3 = THEME.bgLight
xpBarBg.BorderSizePixel = 0
xpBarBg.Parent = levelFrame
createCorner(xpBarBg, 6)

local xpBarFill = Instance.new("Frame")
xpBarFill.Name = "XPBarFill"
xpBarFill.Size = UDim2.new(0, 0, 1, 0)
xpBarFill.BackgroundColor3 = THEME.accent
xpBarFill.BorderSizePixel = 0
xpBarFill.Parent = xpBarBg
createCorner(xpBarFill, 6)

-- Tool indicator (à droite du level)
local toolFrame = Instance.new("Frame")
toolFrame.Name = "ToolFrame"
toolFrame.Size = UDim2.new(0, 180, 0, 55)
toolFrame.Position = UDim2.new(0, 465, 1, -70)
toolFrame.BackgroundColor3 = THEME.bg
toolFrame.BackgroundTransparency = 0.15
toolFrame.BorderSizePixel = 0
toolFrame.Parent = hudScreen
createCorner(toolFrame, 12)

local toolIcon = Instance.new("TextLabel")
toolIcon.Size = UDim2.new(0, 35, 1, 0)
toolIcon.Position = UDim2.new(0, 5, 0, 0)
toolIcon.BackgroundTransparency = 1
toolIcon.Text = "⛏️"
toolIcon.TextSize = 24
toolIcon.Parent = toolFrame

local toolLabel = Instance.new("TextLabel")
toolLabel.Name = "ToolLabel"
toolLabel.Size = UDim2.new(1, -45, 1, 0)
toolLabel.Position = UDim2.new(0, 40, 0, 0)
toolLabel.BackgroundTransparency = 1
toolLabel.Text = "Batée"
toolLabel.TextColor3 = THEME.white
toolLabel.TextSize = 16
toolLabel.Font = Enum.Font.GothamMedium
toolLabel.TextXAlignment = Enum.TextXAlignment.Left
toolLabel.Parent = toolFrame

-- ═══════════════════════════════════════════
-- INVENTORY MINI-DISPLAY (haut droite)
-- ═══════════════════════════════════════════

local invFrame = Instance.new("Frame")
invFrame.Name = "InventoryMini"
invFrame.Size = UDim2.new(0, 240, 0, 220)
invFrame.Position = UDim2.new(1, -255, 0, 80)
invFrame.BackgroundColor3 = THEME.bg
invFrame.BackgroundTransparency = 0.05
invFrame.BorderSizePixel = 0
invFrame.Parent = hudScreen
createCorner(invFrame, 12)

-- Bordure dorée (Fix 6)
local invStroke = Instance.new("UIStroke")
invStroke.Color = THEME.gold
invStroke.Thickness = 1
invStroke.Transparency = 0.5
invStroke.Parent = invFrame

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, 0, 0, 28)
invTitle.Position = UDim2.new(0, 0, 0, 5)
invTitle.BackgroundTransparency = 1
invTitle.Text = "INVENTAIRE"
invTitle.TextColor3 = THEME.gold
invTitle.TextSize = 14
invTitle.Font = Enum.Font.GothamBold
invTitle.Parent = invFrame

local invList = Instance.new("Frame")
invList.Name = "InvList"
invList.Size = UDim2.new(1, -16, 1, -38)
invList.Position = UDim2.new(0, 8, 0, 33)
invList.BackgroundTransparency = 1
invList.Parent = invFrame

local invLayout = Instance.new("UIListLayout")
invLayout.SortOrder = Enum.SortOrder.LayoutOrder
invLayout.Padding = UDim.new(0, 2)
invLayout.Parent = invList

local function updateInventoryDisplay()
	-- Clear
	for _, child in ipairs(invList:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local order = 0
	local hasItems = false

	-- Or
	for _, goldType in ipairs(Config.GoldTypes) do
		local qty = playerState.inventory[goldType.id] or 0
		if qty > 0 then
			hasItems = true
			order = order + 1
			local row = Instance.new("TextLabel")
			row.Size = UDim2.new(1, 0, 0, 18)
			row.BackgroundTransparency = 1
			row.Text = goldType.name .. ": " .. qty
			row.TextColor3 = THEME.gold
			row.TextSize = 13
			row.Font = Enum.Font.GothamMedium
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.LayoutOrder = order
			row.Parent = invList
		end
	end

	-- Gemmes
	for _, gem in ipairs(Config.Gems) do
		local qty = playerState.gems[gem.id] or 0
		if qty > 0 then
			hasItems = true
			order = order + 1
			local row = Instance.new("TextLabel")
			row.Size = UDim2.new(1, 0, 0, 18)
			row.BackgroundTransparency = 1
			row.Text = gem.name .. ": " .. qty
			row.TextColor3 = gem.color
			row.TextSize = 13
			row.Font = Enum.Font.GothamMedium
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.LayoutOrder = order
			row.Parent = invList
		end
	end

	if not hasItems then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 18)
		empty.BackgroundTransparency = 1
		empty.Text = "Vide - va miner !"
		empty.TextColor3 = THEME.muted
		empty.TextSize = 13
		empty.Font = Enum.Font.Gotham
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.LayoutOrder = 1
		empty.Parent = invList
	end

	-- Pulse doré quand l'inventaire change (Fix 6)
	if hasItems then
		TweenService:Create(invStroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
		task.delay(0.2, function()
			TweenService:Create(invStroke, TweenInfo.new(0.5), { Transparency = 0.5 }):Play()
		end)
	end
end

updateInventoryDisplay()

-- ═══════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════

local notifScreen = Instance.new("ScreenGui")
notifScreen.Name = "NotifGui"
notifScreen.ResetOnSpawn = false
notifScreen.Parent = playerGui

local notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0, 380, 0.5, 0)
notifContainer.Position = UDim2.new(1, -400, 0.5, 0)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = notifScreen

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.Padding = UDim.new(0, 6)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Parent = notifContainer

local notifCount = 0

local function showNotification(data)
	notifCount = notifCount + 1
	local title = data.title or ""
	local message = data.message or ""
	local notifType = data.type or "info"

	local accentColor = THEME.gold
	if notifType == "error" then accentColor = THEME.red
	elseif notifType == "success" then accentColor = THEME.green
	elseif notifType == "levelup" then accentColor = Color3.fromRGB(200, 100, 255); playSound("level_up")
	elseif notifType == "warning" then accentColor = Color3.fromRGB(255, 180, 50)
	end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 55)
	frame.BackgroundColor3 = THEME.bg
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.LayoutOrder = notifCount
	frame.Parent = notifContainer
	createCorner(frame, 10)

	-- Accent bar
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 4, 0.8, 0)
	bar.Position = UDim2.new(0, 5, 0.1, 0)
	bar.BackgroundColor3 = accentColor
	bar.BorderSizePixel = 0
	bar.Parent = frame
	createCorner(bar, 2)

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 18)
	titleLabel.Position = UDim2.new(0, 15, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = accentColor
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = frame

	-- Message
	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -20, 0, 22)
	msgLabel.Position = UDim2.new(0, 15, 0, 25)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = message
	msgLabel.TextColor3 = THEME.white
	msgLabel.TextSize = 12
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.TextWrapped = true
	msgLabel.Parent = frame

	-- Fade out
	task.delay(3.5, function()
		local tween = TweenService:Create(frame, TweenInfo.new(0.5), { BackgroundTransparency = 1 })
		local tween2 = TweenService:Create(titleLabel, TweenInfo.new(0.5), { TextTransparency = 1 })
		local tween3 = TweenService:Create(msgLabel, TweenInfo.new(0.5), { TextTransparency = 1 })
		tween:Play()
		tween2:Play()
		tween3:Play()
		tween.Completed:Connect(function()
			frame:Destroy()
		end)
	end)
end

-- ═══════════════════════════════════════════
-- LOOT POPUP (centre de l'écran, gros et visible)
-- ═══════════════════════════════════════════

local lootScreen = Instance.new("ScreenGui")
lootScreen.Name = "LootGui"
lootScreen.ResetOnSpawn = false
lootScreen.Parent = playerGui

local function showLootPopup(lootData)
	local loot = lootData.loot
	if not loot then return end

	-- === SONS selon la rareté ===
	local isRare = false
	local isLegendary = false
	if loot.gold then
		if loot.gold.rarity == "Rare" or loot.gold.rarity == "Très rare" then
			isRare = true
		elseif loot.gold.rarity == "Légendaire" then
			isLegendary = true
		end
	end

	if isLegendary then
		playSound("rare_found")
		flashScreen(Color3.fromRGB(255, 50, 50), 0.5, 0.8)
		shakeCamera(0.8, 0.4)
	elseif isRare then
		playSound("rare_found")
		flashScreen(Color3.fromRGB(255, 165, 0), 0.3, 0.5)
		shakeCamera(0.3, 0.2)
	elseif loot.gem then
		playSound("gem_found")
		flashScreen(Color3.fromRGB(200, 100, 255), 0.25, 0.4)
	else
		playSound("gold_found")
	end

	-- === POPUP ===
	local popup = Instance.new("Frame")
	popup.Size = UDim2.new(0, 300, 0, 0)
	popup.Position = UDim2.new(0.5, -150, 0.3, 0)
	popup.BackgroundColor3 = THEME.bg
	popup.BackgroundTransparency = 0.05
	popup.BorderSizePixel = 0
	popup.Parent = lootScreen
	createCorner(popup, 14)

	-- Glow border pour les rares
	if isRare or isLegendary or loot.gem then
		local glowColor = THEME.gold
		if isLegendary then glowColor = Color3.fromRGB(255, 50, 50)
		elseif loot.gem then glowColor = Color3.fromRGB(200, 100, 255)
		end
		local stroke = Instance.new("UIStroke")
		stroke.Color = glowColor
		stroke.Thickness = 2
		stroke.Transparency = 0
		stroke.Parent = popup
		-- Pulse le glow
		task.spawn(function()
			for i = 1, 4 do
				TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 0.7 }):Play()
				task.wait(0.3)
				TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 0 }):Play()
				task.wait(0.3)
			end
		end)
	end

	local yOffset = 10
	local totalHeight = 10

	-- Gold found
	if loot.gold then
		local rarityColor = THEME.gold
		if loot.gold.rarity == "Rare" then rarityColor = Color3.fromRGB(255, 165, 0)
		elseif loot.gold.rarity == "Très rare" then rarityColor = Color3.fromRGB(255, 100, 50)
		elseif loot.gold.rarity == "Légendaire" then rarityColor = Color3.fromRGB(255, 50, 50)
		end

		local goldLabel = Instance.new("TextLabel")
		goldLabel.Size = UDim2.new(1, -20, 0, 28)
		goldLabel.Position = UDim2.new(0, 10, 0, yOffset)
		goldLabel.BackgroundTransparency = 1
		goldLabel.Text = "+" .. loot.gold.quantity .. " " .. loot.gold.name
		goldLabel.TextColor3 = rarityColor
		goldLabel.TextSize = isLegendary and 24 or (isRare and 20 or 18)
		goldLabel.Font = Enum.Font.GothamBold
		goldLabel.TextXAlignment = Enum.TextXAlignment.Center
		goldLabel.Parent = popup

		yOffset = yOffset + 32
		totalHeight = totalHeight + 32

		-- Rarity tag
		if loot.gold.rarity ~= "Commun" then
			local rarityLabel = Instance.new("TextLabel")
			rarityLabel.Size = UDim2.new(1, -20, 0, 16)
			rarityLabel.Position = UDim2.new(0, 10, 0, yOffset)
			rarityLabel.BackgroundTransparency = 1
			rarityLabel.Text = "[ " .. loot.gold.rarity .. " ]"
			rarityLabel.TextColor3 = rarityColor
			rarityLabel.TextSize = 12
			rarityLabel.Font = Enum.Font.GothamMedium
			rarityLabel.TextXAlignment = Enum.TextXAlignment.Center
			rarityLabel.Parent = popup

			yOffset = yOffset + 20
			totalHeight = totalHeight + 20
		end
	end

	-- Gem found
	if loot.gem then
		local gemLabel = Instance.new("TextLabel")
		gemLabel.Size = UDim2.new(1, -20, 0, 24)
		gemLabel.Position = UDim2.new(0, 10, 0, yOffset)
		gemLabel.BackgroundTransparency = 1
		gemLabel.Text = "GEMME ! +" .. loot.gem.quantity .. " " .. loot.gem.name
		gemLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
		gemLabel.TextSize = 16
		gemLabel.Font = Enum.Font.GothamBold
		gemLabel.TextXAlignment = Enum.TextXAlignment.Center
		gemLabel.Parent = popup

		yOffset = yOffset + 28
		totalHeight = totalHeight + 28
	end

	-- Precision bonus display
	if loot.precision and loot.precision > 1 then
		local precLabel = Instance.new("TextLabel")
		precLabel.Size = UDim2.new(1, -20, 0, 16)
		precLabel.Position = UDim2.new(0, 10, 0, yOffset)
		precLabel.BackgroundTransparency = 1
		local precText = loot.precision >= 2 and "PERFECT x2" or "GOOD x1.5"
		local precColor = loot.precision >= 2 and THEME.gold or Color3.fromRGB(200, 140, 30)
		precLabel.Text = precText
		precLabel.TextColor3 = precColor
		precLabel.TextSize = 13
		precLabel.Font = Enum.Font.GothamBold
		precLabel.TextXAlignment = Enum.TextXAlignment.Center
		precLabel.Parent = popup

		yOffset = yOffset + 20
		totalHeight = totalHeight + 20
	end

	-- XP
	local xpLabel = Instance.new("TextLabel")
	xpLabel.Size = UDim2.new(1, -20, 0, 16)
	xpLabel.Position = UDim2.new(0, 10, 0, yOffset)
	xpLabel.BackgroundTransparency = 1
	xpLabel.Text = "+" .. (lootData.xpGain or 10) .. " XP"
	xpLabel.TextColor3 = THEME.accent
	xpLabel.TextSize = 12
	xpLabel.Font = Enum.Font.GothamMedium
	xpLabel.TextXAlignment = Enum.TextXAlignment.Center
	xpLabel.Parent = popup

	totalHeight = totalHeight + 26

	popup.Size = UDim2.new(0, 300, 0, totalHeight)

	-- === ANIMATE IN (scale up + fade) ===
	popup.BackgroundTransparency = 1
	local origSize = popup.Size
	popup.Size = UDim2.new(0, 200, 0, totalHeight * 0.7)
	popup.Position = UDim2.new(0.5, -100, 0.32, 0)

	for _, child in ipairs(popup:GetDescendants()) do
		if child:IsA("TextLabel") then
			child.TextTransparency = 1
		end
	end

	TweenService:Create(popup, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.05,
		Size = origSize,
		Position = UDim2.new(0.5, -150, 0.3, 0),
	}):Play()

	for _, child in ipairs(popup:GetDescendants()) do
		if child:IsA("TextLabel") then
			TweenService:Create(child, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
		end
	end

	-- Float up + fade out
	local displayTime = (isLegendary or isRare) and 3 or 2
	task.delay(displayTime, function()
		TweenService:Create(popup, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, -150, 0.25, 0), -- float up
		}):Play()
		for _, child in ipairs(popup:GetDescendants()) do
			if child:IsA("TextLabel") then
				TweenService:Create(child, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
			end
		end
		task.delay(0.7, function()
			popup:Destroy()
		end)
	end)
end

-- ═══════════════════════════════════════════
-- SHOP UI (NPC Jake)
-- ═══════════════════════════════════════════

local shopScreen = Instance.new("ScreenGui")
shopScreen.Name = "ShopGui"
shopScreen.ResetOnSpawn = false
shopScreen.Enabled = false
shopScreen.Parent = playerGui

local shopBg = Instance.new("Frame")
shopBg.Size = UDim2.new(0, 500, 0, 420)
shopBg.Position = UDim2.new(0.5, -250, 0.5, -210)
shopBg.BackgroundColor3 = THEME.bg
shopBg.BackgroundTransparency = 0.05
shopBg.BorderSizePixel = 0
shopBg.Parent = shopScreen
createCorner(shopBg, 16)

-- Title bar
local shopTitleBar = Instance.new("Frame")
shopTitleBar.Size = UDim2.new(1, 0, 0, 50)
shopTitleBar.BackgroundColor3 = THEME.bgLight
shopTitleBar.BorderSizePixel = 0
shopTitleBar.Parent = shopBg
createCorner(shopTitleBar, 16)
-- Cover bottom corners
local shopTitleCover = Instance.new("Frame")
shopTitleCover.Size = UDim2.new(1, 0, 0, 16)
shopTitleCover.Position = UDim2.new(0, 0, 1, -16)
shopTitleCover.BackgroundColor3 = THEME.bgLight
shopTitleCover.BorderSizePixel = 0
shopTitleCover.Parent = shopTitleBar

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, -20, 1, 0)
shopTitle.Position = UDim2.new(0, 15, 0, 0)
shopTitle.BackgroundTransparency = 1
shopTitle.Text = "OUTILS & EQUIPEMENT - Jake le Forgeron"
shopTitle.TextColor3 = THEME.gold
shopTitle.TextSize = 18
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Parent = shopTitleBar

-- Close button
local shopClose = Instance.new("TextButton")
shopClose.Size = UDim2.new(0, 35, 0, 35)
shopClose.Position = UDim2.new(1, -42, 0, 7)
shopClose.BackgroundColor3 = THEME.red
shopClose.Text = "X"
shopClose.TextColor3 = THEME.white
shopClose.TextSize = 16
shopClose.Font = Enum.Font.GothamBold
shopClose.BorderSizePixel = 0
shopClose.Parent = shopTitleBar
createCorner(shopClose, 8)

shopClose.MouseButton1Click:Connect(function()
	shopScreen.Enabled = false
end)

-- Tool list
local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, -20, 1, -65)
shopScroll.Position = UDim2.new(0, 10, 0, 55)
shopScroll.BackgroundTransparency = 1
shopScroll.ScrollBarThickness = 4
shopScroll.ScrollBarImageColor3 = THEME.gold
shopScroll.BorderSizePixel = 0
shopScroll.CanvasSize = UDim2.new(0, 0, 0, #Config.Tools * 85)
shopScroll.Parent = shopBg

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 8)
shopLayout.Parent = shopScroll

local shopButtons = {}

for i, tool in ipairs(Config.Tools) do
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 75)
	card.BackgroundColor3 = THEME.bgPanel
	card.BorderSizePixel = 0
	card.LayoutOrder = i
	card.Parent = shopScroll
	createCorner(card, 10)

	-- Tool color indicator
	local colorBar = Instance.new("Frame")
	colorBar.Size = UDim2.new(0, 6, 0.7, 0)
	colorBar.Position = UDim2.new(0, 8, 0.15, 0)
	colorBar.BackgroundColor3 = tool.color
	colorBar.BorderSizePixel = 0
	colorBar.Parent = card
	createCorner(colorBar, 3)

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, -30, 0, 22)
	nameLabel.Position = UDim2.new(0, 22, 0, 8)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = tool.name
	nameLabel.TextColor3 = THEME.white
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.6, -30, 0, 16)
	descLabel.Position = UDim2.new(0, 22, 0, 30)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = "Rendement x" .. tool.yieldMultiplier .. " | Vitesse x" .. tool.miningSpeed
	descLabel.TextColor3 = THEME.muted
	descLabel.TextSize = 11
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = card

	-- Level req
	local levelReq = Instance.new("TextLabel")
	levelReq.Size = UDim2.new(0.5, -20, 0, 14)
	levelReq.Position = UDim2.new(0, 22, 0, 50)
	levelReq.BackgroundTransparency = 1
	levelReq.Text = "Niveau " .. tool.levelRequired .. " requis"
	levelReq.TextColor3 = THEME.muted
	levelReq.TextSize = 10
	levelReq.Font = Enum.Font.Gotham
	levelReq.TextXAlignment = Enum.TextXAlignment.Left
	levelReq.Parent = card

	-- Buy button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 120, 0, 35)
	buyBtn.Position = UDim2.new(1, -130, 0.5, -17)
	buyBtn.BackgroundColor3 = tool.price == 0 and THEME.green or THEME.accent
	buyBtn.Text = tool.price == 0 and "GRATUIT" or formatCash(tool.price)
	buyBtn.TextColor3 = THEME.bg
	buyBtn.TextSize = 14
	buyBtn.Font = Enum.Font.GothamBold
	buyBtn.BorderSizePixel = 0
	buyBtn.Parent = card
	createCorner(buyBtn, 8)

	shopButtons[tool.id] = { button = buyBtn, card = card, nameLabel = nameLabel }

	buyBtn.MouseButton1Click:Connect(function()
		playSound("ui_click")
		BuyToolEvent:FireServer(tool.id)
	end)
end

local function updateShopUI()
	for _, tool in ipairs(Config.Tools) do
		local btn = shopButtons[tool.id]
		if not btn then continue end

		local isOwned = false
		local isEquipped = playerState.currentTool == tool.id
		for _, owned in ipairs(playerState.ownedTools) do
			if owned == tool.id then
				isOwned = true
				break
			end
		end

		if isEquipped then
			btn.button.Text = "EQUIPE"
			btn.button.BackgroundColor3 = THEME.green
		elseif isOwned then
			btn.button.Text = "EQUIPER"
			btn.button.BackgroundColor3 = THEME.blue
		elseif playerState.level < tool.levelRequired then
			btn.button.Text = "VERROUILLE"
			btn.button.BackgroundColor3 = THEME.muted
		else
			btn.button.Text = formatCash(tool.price)
			btn.button.BackgroundColor3 = THEME.accent
		end
	end
end

-- ═══════════════════════════════════════════
-- SELL UI (NPC Marcel)
-- ═══════════════════════════════════════════

local sellScreen = Instance.new("ScreenGui")
sellScreen.Name = "SellGui"
sellScreen.ResetOnSpawn = false
sellScreen.Enabled = false
sellScreen.Parent = playerGui

local sellBg = Instance.new("Frame")
sellBg.Size = UDim2.new(0, 450, 0, 350)
sellBg.Position = UDim2.new(0.5, -225, 0.5, -175)
sellBg.BackgroundColor3 = THEME.bg
sellBg.BackgroundTransparency = 0.05
sellBg.BorderSizePixel = 0
sellBg.Parent = sellScreen
createCorner(sellBg, 16)

-- Title
local sellTitleBar = Instance.new("Frame")
sellTitleBar.Size = UDim2.new(1, 0, 0, 50)
sellTitleBar.BackgroundColor3 = THEME.bgLight
sellTitleBar.BorderSizePixel = 0
sellTitleBar.Parent = sellBg
createCorner(sellTitleBar, 16)
local sellTitleCover = Instance.new("Frame")
sellTitleCover.Size = UDim2.new(1, 0, 0, 16)
sellTitleCover.Position = UDim2.new(0, 0, 1, -16)
sellTitleCover.BackgroundColor3 = THEME.bgLight
sellTitleCover.BorderSizePixel = 0
sellTitleCover.Parent = sellTitleBar

local sellTitle = Instance.new("TextLabel")
sellTitle.Size = UDim2.new(1, -20, 1, 0)
sellTitle.Position = UDim2.new(0, 15, 0, 0)
sellTitle.BackgroundTransparency = 1
sellTitle.Text = "VENDRE - Marcel le Marchand"
sellTitle.TextColor3 = THEME.gold
sellTitle.TextSize = 18
sellTitle.Font = Enum.Font.GothamBold
sellTitle.TextXAlignment = Enum.TextXAlignment.Left
sellTitle.Parent = sellTitleBar

-- Close
local sellClose = Instance.new("TextButton")
sellClose.Size = UDim2.new(0, 35, 0, 35)
sellClose.Position = UDim2.new(1, -42, 0, 7)
sellClose.BackgroundColor3 = THEME.red
sellClose.Text = "X"
sellClose.TextColor3 = THEME.white
sellClose.TextSize = 16
sellClose.Font = Enum.Font.GothamBold
sellClose.BorderSizePixel = 0
sellClose.Parent = sellTitleBar
createCorner(sellClose, 8)

sellClose.MouseButton1Click:Connect(function()
	sellScreen.Enabled = false
end)

-- Inventory preview
local sellInvFrame = Instance.new("Frame")
sellInvFrame.Size = UDim2.new(1, -20, 0, 180)
sellInvFrame.Position = UDim2.new(0, 10, 0, 60)
sellInvFrame.BackgroundColor3 = THEME.bgPanel
sellInvFrame.BorderSizePixel = 0
sellInvFrame.Parent = sellBg
createCorner(sellInvFrame, 10)

local sellInvTitle = Instance.new("TextLabel")
sellInvTitle.Size = UDim2.new(1, -10, 0, 20)
sellInvTitle.Position = UDim2.new(0, 8, 0, 5)
sellInvTitle.BackgroundTransparency = 1
sellInvTitle.Text = "Ton inventaire :"
sellInvTitle.TextColor3 = THEME.muted
sellInvTitle.TextSize = 12
sellInvTitle.Font = Enum.Font.GothamMedium
sellInvTitle.TextXAlignment = Enum.TextXAlignment.Left
sellInvTitle.Parent = sellInvFrame

local sellInvList = Instance.new("Frame")
sellInvList.Size = UDim2.new(1, -16, 1, -30)
sellInvList.Position = UDim2.new(0, 8, 0, 28)
sellInvList.BackgroundTransparency = 1
sellInvList.Parent = sellInvFrame

local sellInvLayout = Instance.new("UIListLayout")
sellInvLayout.Padding = UDim.new(0, 2)
sellInvLayout.Parent = sellInvList

local currentMerchantId = "marchand_local"

local function getMerchantMultiplier()
	for _, m in ipairs(Config.Merchants) do
		if m.id == currentMerchantId then return m.priceMultiplier end
	end
	return 0.7
end

local function updateSellInventory()
	for _, child in ipairs(sellInvList:GetChildren()) do
		if child:IsA("TextLabel") then child:Destroy() end
	end

	local totalValue = 0
	local order = 0
	local mult = getMerchantMultiplier()

	for _, goldType in ipairs(Config.GoldTypes) do
		local qty = playerState.inventory[goldType.id] or 0
		if qty > 0 then
			local value = math.floor(goldType.baseValue * qty * mult)
			totalValue = totalValue + value
			order = order + 1
			local row = Instance.new("TextLabel")
			row.Size = UDim2.new(1, 0, 0, 16)
			row.BackgroundTransparency = 1
			row.Text = goldType.name .. " x" .. qty .. " → " .. formatCash(value)
			row.TextColor3 = THEME.gold
			row.TextSize = 12
			row.Font = Enum.Font.Gotham
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.LayoutOrder = order
			row.Parent = sellInvList
		end
	end

	for _, gem in ipairs(Config.Gems) do
		local qty = playerState.gems[gem.id] or 0
		if qty > 0 then
			local value = math.floor(gem.baseValue * qty * mult)
			totalValue = totalValue + value
			order = order + 1
			local row = Instance.new("TextLabel")
			row.Size = UDim2.new(1, 0, 0, 16)
			row.BackgroundTransparency = 1
			row.Text = gem.name .. " x" .. qty .. " → " .. formatCash(value)
			row.TextColor3 = gem.color
			row.TextSize = 12
			row.Font = Enum.Font.Gotham
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.LayoutOrder = order
			row.Parent = sellInvList
		end
	end

	return totalValue
end

-- Total & sell button
local sellTotalLabel = Instance.new("TextLabel")
sellTotalLabel.Name = "SellTotal"
sellTotalLabel.Size = UDim2.new(0.5, -15, 0, 40)
sellTotalLabel.Position = UDim2.new(0, 10, 1, -55)
sellTotalLabel.BackgroundTransparency = 1
sellTotalLabel.Text = "Total: $0"
sellTotalLabel.TextColor3 = THEME.gold
sellTotalLabel.TextSize = 20
sellTotalLabel.Font = Enum.Font.GothamBold
sellTotalLabel.TextXAlignment = Enum.TextXAlignment.Left
sellTotalLabel.Parent = sellBg

local sellBtn = Instance.new("TextButton")
sellBtn.Size = UDim2.new(0, 180, 0, 45)
sellBtn.Position = UDim2.new(1, -190, 1, -55)
sellBtn.BackgroundColor3 = THEME.green
sellBtn.Text = "TOUT VENDRE"
sellBtn.TextColor3 = THEME.bg
sellBtn.TextSize = 18
sellBtn.Font = Enum.Font.GothamBold
sellBtn.BorderSizePixel = 0
sellBtn.Parent = sellBg
createCorner(sellBtn, 10)

sellBtn.MouseButton1Click:Connect(function()
	playSound("ui_click")
	SellGoldEvent:FireServer({ merchantId = currentMerchantId })
end)

-- ═══════════════════════════════════════════
-- NPC INTERACTIONS (ProximityPrompts)
-- ═══════════════════════════════════════════

local function onPromptTriggered(prompt)
	local part = prompt.Parent
	local npcType = part:GetAttribute("NPCType")
	if not npcType then return end

	if npcType == "ToolShop" then
		updateShopUI()
		shopScreen.Enabled = true
	elseif npcType == "Merchant" then
		currentMerchantId = part:GetAttribute("MerchantId") or "marchand_local"
		local totalValue = updateSellInventory()
		sellTotalLabel.Text = "Total: " .. formatCash(totalValue)
		sellScreen.Enabled = true
	end
end

-- Connect NPC proximity prompts
local function connectNPCPrompt(desc)
	if desc:IsA("ProximityPrompt") then
		local part = desc.Parent
		if part and part:GetAttribute("NPCType") then
			desc.Triggered:Connect(function()
				onPromptTriggered(desc)
			end)
		end
	end
end

for _, desc in ipairs(Workspace:GetDescendants()) do
	connectNPCPrompt(desc)
end
Workspace.DescendantAdded:Connect(connectNPCPrompt)

-- ═══════════════════════════════════════════
-- MINI-JEU DE MINAGE (timing bar)
-- ═══════════════════════════════════════════

local isMining = false

-- Mining mini-game UI
local miningScreen = Instance.new("ScreenGui")
miningScreen.Name = "MiningGui"
miningScreen.ResetOnSpawn = false
miningScreen.Enabled = false
miningScreen.Parent = playerGui

-- Container centré
local miningContainer = Instance.new("Frame")
miningContainer.Size = UDim2.new(0, 400, 0, 120)
miningContainer.Position = UDim2.new(0.5, -200, 0.5, -60)
miningContainer.BackgroundColor3 = THEME.bg
miningContainer.BackgroundTransparency = 0.1
miningContainer.BorderSizePixel = 0
miningContainer.Parent = miningScreen
createCorner(miningContainer, 14)

-- Titre "MINAGE EN COURS"
local miningTitle = Instance.new("TextLabel")
miningTitle.Size = UDim2.new(1, 0, 0, 22)
miningTitle.Position = UDim2.new(0, 0, 0, 8)
miningTitle.BackgroundTransparency = 1
miningTitle.Text = "Clique au bon moment !"
miningTitle.TextColor3 = THEME.white
miningTitle.TextSize = 14
miningTitle.Font = Enum.Font.GothamBold
miningTitle.Parent = miningContainer

-- Barre de fond
local barBg = Instance.new("Frame")
barBg.Name = "BarBg"
barBg.Size = UDim2.new(0.9, 0, 0, 30)
barBg.Position = UDim2.new(0.05, 0, 0, 38)
barBg.BackgroundColor3 = Color3.fromRGB(40, 35, 25)
barBg.BorderSizePixel = 0
barBg.Parent = miningContainer
createCorner(barBg, 8)

-- Zone "OK" (grise, toute la barre)
local zoneOk = Instance.new("Frame")
zoneOk.Size = UDim2.new(1, 0, 1, 0)
zoneOk.BackgroundColor3 = Color3.fromRGB(60, 55, 40)
zoneOk.BorderSizePixel = 0
zoneOk.Parent = barBg
createCorner(zoneOk, 8)

-- Zone "GOOD" (orange, 30% au centre)
local zoneGood = Instance.new("Frame")
zoneGood.Size = UDim2.new(0.30, 0, 1, 0)
zoneGood.Position = UDim2.new(0.35, 0, 0, 0)
zoneGood.BackgroundColor3 = Color3.fromRGB(200, 140, 30)
zoneGood.BorderSizePixel = 0
zoneGood.Parent = barBg
createCorner(zoneGood, 6)

-- Zone "PERFECT" (dorée brillante, 10% au centre)
local zonePerfect = Instance.new("Frame")
zonePerfect.Size = UDim2.new(0.10, 0, 1, 0)
zonePerfect.Position = UDim2.new(0.45, 0, 0, 0)
zonePerfect.BackgroundColor3 = THEME.gold
zonePerfect.BorderSizePixel = 0
zonePerfect.Parent = barBg
createCorner(zonePerfect, 4)

-- Curseur (trait blanc qui bouge)
local cursor = Instance.new("Frame")
cursor.Name = "Cursor"
cursor.Size = UDim2.new(0, 4, 1, 6)
cursor.Position = UDim2.new(0, 0, 0, -3)
cursor.BackgroundColor3 = Color3.new(1, 1, 1)
cursor.BorderSizePixel = 0
cursor.ZIndex = 5
cursor.Parent = barBg
createCorner(cursor, 2)

-- Label de résultat
local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1, 0, 0, 25)
resultLabel.Position = UDim2.new(0, 0, 0, 75)
resultLabel.BackgroundTransparency = 1
resultLabel.Text = ""
resultLabel.TextColor3 = THEME.gold
resultLabel.TextSize = 18
resultLabel.Font = Enum.Font.GothamBold
resultLabel.Parent = miningContainer

-- Bouton de frappe (gros, sous la barre)
local strikeBtn = Instance.new("TextButton")
strikeBtn.Size = UDim2.new(0.5, 0, 0, 35)
strikeBtn.Position = UDim2.new(0.25, 0, 0, 75)
strikeBtn.BackgroundColor3 = THEME.accent
strikeBtn.Text = "FRAPPER !"
strikeBtn.TextColor3 = THEME.bg
strikeBtn.TextSize = 16
strikeBtn.Font = Enum.Font.GothamBold
strikeBtn.BorderSizePixel = 0
strikeBtn.Visible = true
strikeBtn.Parent = miningContainer
createCorner(strikeBtn, 8)

-- Mini-game state (déclaré AVANT les handlers pour éviter le hoisting bug)
local miningActive = false
local cursorPosition = 0 -- 0 à 1
local cursorSpeed = 1.5 -- va-et-vient par seconde
local cursorDirection = 1
local pendingSpotData = nil
local miningTimeoutThread = nil

-- Bouton annuler
local cancelBtn = Instance.new("TextButton")
cancelBtn.Size = UDim2.new(0, 30, 0, 30)
cancelBtn.Position = UDim2.new(1, -35, 0, 5)
cancelBtn.BackgroundColor3 = THEME.red
cancelBtn.Text = "X"
cancelBtn.TextColor3 = THEME.white
cancelBtn.TextSize = 14
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.BorderSizePixel = 0
cancelBtn.Parent = miningContainer
createCorner(cancelBtn, 15)

cancelBtn.MouseButton1Click:Connect(function()
	-- Fix 15: Restaurer le spot si on annule
	if pendingSpotData and pendingSpotData.spotName then
		local spot = Workspace:FindFirstChild("MiningSpots") and Workspace.MiningSpots:FindFirstChild(pendingSpotData.spotName)
		if spot and spot.Parent then
			spot.Transparency = 0.3
			local p = spot:FindFirstChildOfClass("ParticleEmitter")
			if p then p.Enabled = true end
		end
	end
	miningActive = false
	miningScreen.Enabled = false
	isMining = false
	pendingSpotData = nil
	if miningTimeoutThread then
		task.cancel(miningTimeoutThread)
		miningTimeoutThread = nil
	end
end)

-- Animation du curseur
RunService.RenderStepped:Connect(function(dt)
	if not miningActive then return end

	cursorPosition = cursorPosition + cursorDirection * cursorSpeed * dt

	-- Rebondir
	if cursorPosition >= 1 then
		cursorPosition = 1
		cursorDirection = -1
	elseif cursorPosition <= 0 then
		cursorPosition = 0
		cursorDirection = 1
	end

	cursor.Position = UDim2.new(cursorPosition, -2, 0, -3)
end)

-- Calculer la précision
local function getPrecision(pos)
	-- Perfect zone : 0.45 à 0.55
	if pos >= 0.45 and pos <= 0.55 then
		return "PERFECT", 2.0, THEME.gold
	-- Good zone : 0.35 à 0.65
	elseif pos >= 0.35 and pos <= 0.65 then
		return "GOOD", 1.5, Color3.fromRGB(200, 140, 30)
	-- OK : le reste
	else
		return "OK", 1.0, THEME.muted
	end
end

-- Variable tutoriel première mine
local isFirstMine = true

-- Lancer le mini-jeu
local function startMiningMinigame(zoneId, spotName)
	print("[GameClient] startMiningMinigame called: zone=" .. tostring(zoneId) .. " spot=" .. tostring(spotName))
	pendingSpotData = { zoneId = zoneId, spotName = spotName }
	cursorPosition = 0
	cursorDirection = 1
	resultLabel.Text = ""
	resultLabel.Visible = false
	strikeBtn.Visible = true
	strikeBtn.Text = "FRAPPER !"
	strikeBtn.BackgroundColor3 = THEME.accent

	-- Vitesse basée sur l'outil (meilleur outil = plus lent = plus facile)
	local tool = Config.ToolsById[playerState.currentTool]
	cursorSpeed = 2.0 / (tool and tool.miningSpeed or 1)

	-- Tutoriel première mine (Fix 10)
	if isFirstMine then
		miningTitle.Text = "Clique FRAPPER quand le curseur est dans la zone doree !"
		cursorSpeed = cursorSpeed * 0.6 -- plus lent pour le tuto
	else
		miningTitle.Text = "Clique au bon moment !"
	end

	miningActive = true
	miningScreen.Enabled = true
	print("[GameClient] Mining UI ENABLED, miningActive=" .. tostring(miningActive))
	playSound("mining_start")

	-- Fix 15: Feedback visuel sur le spot pendant le minage
	local spot = Workspace:FindFirstChild("MiningSpots") and Workspace.MiningSpots:FindFirstChild(spotName)
	if spot then
		spot.Transparency = 0.7
		local particles = spot:FindFirstChildOfClass("ParticleEmitter")
		if particles then particles.Enabled = false end
	end

	-- Timeout auto-cancel (Fix 3) : 8 secondes max
	if miningTimeoutThread then
		task.cancel(miningTimeoutThread)
	end
	miningTimeoutThread = task.delay(8, function()
		if miningActive then
			miningActive = false
			miningScreen.Enabled = false
			isMining = false
			pendingSpotData = nil
			-- Restaurer le spot
			if spot and spot.Parent then
				spot.Transparency = 0.3
				local p = spot:FindFirstChildOfClass("ParticleEmitter")
				if p then p.Enabled = true end
			end
			showNotification({
				title = "Temps ecoule",
				message = "Tu as mis trop de temps ! Reessaie.",
				type = "warning",
			})
		end
	end)
end

-- Quand le joueur clique FRAPPER
strikeBtn.MouseButton1Click:Connect(function()
	if not miningActive or not pendingSpotData then return end

	miningActive = false
	isMining = false -- Reset immédiat (Fix 3)

	-- Annuler le timeout
	if miningTimeoutThread then
		task.cancel(miningTimeoutThread)
		miningTimeoutThread = nil
	end

	playSound("mine_hit")
	local rating, multiplier, color = getPrecision(cursorPosition)

	-- Afficher le résultat
	strikeBtn.Visible = false
	resultLabel.Visible = true
	resultLabel.Text = rating .. " ! (x" .. multiplier .. ")"
	resultLabel.TextColor3 = color

	-- Envoyer au serveur avec le multiplicateur
	local spotName = pendingSpotData.spotName
	MineGoldEvent:FireServer({
		zoneId = pendingSpotData.zoneId,
		spotName = spotName,
		precision = multiplier,
	})

	-- Fix 15: Restaurer le spot après minage
	local spot = Workspace:FindFirstChild("MiningSpots") and Workspace.MiningSpots:FindFirstChild(spotName)
	if spot and spot.Parent then
		spot.Transparency = 0.3
		local particles = spot:FindFirstChildOfClass("ParticleEmitter")
		if particles then particles.Enabled = true end
	end

	-- Première mine réussie → désactiver le tuto (Fix 10)
	if isFirstMine then
		isFirstMine = false
	end

	-- Fermer après un court délai
	task.delay(1, function()
		miningScreen.Enabled = false
	end)
end)

-- ═══════════════════════════════════════════
-- MINING SPOT INTERACTION (client → server)
-- ═══════════════════════════════════════════

local function connectMiningPrompt(prompt)
	if not prompt:IsA("ProximityPrompt") then return end
	local spot = prompt.Parent
	if not spot or not spot:GetAttribute("ZoneId") then return end

	prompt.Triggered:Connect(function()
		print("[GameClient] PROMPT TRIGGERED on " .. spot.Name .. " | isMining=" .. tostring(isMining) .. " | SpotActive=" .. tostring(spot:GetAttribute("SpotActive")))
		if isMining then print("[GameClient] BLOCKED: isMining is true") return end

		-- Fix 8: Feedback spots inactifs
		if not spot:GetAttribute("SpotActive") then
			showNotification({
				title = "Spot epuise",
				message = "Ce spot est epuise, reviens dans quelques secondes !",
				type = "warning",
			})
			return
		end

		-- Fix 7: Check de niveau côté client AVANT le mini-jeu
		local zoneId = spot:GetAttribute("ZoneId") or "riviere_tranquille"
		local zone = Config.ZonesById[zoneId]
		if zone and playerState.level < zone.levelRequired then
			showNotification({
				title = "Zone verrouillee",
				message = "Il faut etre niveau " .. zone.levelRequired .. " pour miner ici !",
				type = "error",
			})
			return
		end

		isMining = true

		-- Envoyer directement au serveur (test sans mini-jeu)
		print("[GameClient] MINING! Sending to server zone=" .. zoneId .. " spot=" .. spot.Name)
		MineGoldEvent:FireServer({
			zoneId = zoneId,
			spotName = spot.Name,
			precision = 1.5,
		})

		task.delay(1.5, function()
			isMining = false
		end)
	end)
end

local spotsFolder = Workspace:WaitForChild("MiningSpots", 30)
if spotsFolder then
	local connected = 0
	for _, desc in ipairs(spotsFolder:GetDescendants()) do
		if desc:IsA("ProximityPrompt") then
			connectMiningPrompt(desc)
			connected = connected + 1
		end
	end
	print("[GameClient] Connected " .. connected .. " mining prompts")
	spotsFolder.DescendantAdded:Connect(connectMiningPrompt)
else
	warn("[GameClient] MiningSpots folder NOT FOUND!")
end

-- ═══════════════════════════════════════════
-- ZONE INDICATOR (haut centre)
-- ═══════════════════════════════════════════

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Name = "ZoneIndicator"
zoneLabel.Size = UDim2.new(0, 300, 0, 35)
zoneLabel.Position = UDim2.new(0.5, -150, 0, 10)
zoneLabel.BackgroundColor3 = THEME.bg
zoneLabel.BackgroundTransparency = 0.3
zoneLabel.Text = "La Ville"
zoneLabel.TextColor3 = THEME.white
zoneLabel.TextSize = 16
zoneLabel.Font = Enum.Font.GothamBold
zoneLabel.BorderSizePixel = 0
zoneLabel.Parent = hudScreen
createCorner(zoneLabel, 10)

-- Check zone based on position
local currentZone = ""
local zonesFolder = Workspace:WaitForChild("MiningZones", 30)

RunService.Heartbeat:Connect(function()
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local pos = root.Position
	local foundZone = "La Ville"

	local isLocked = false
	if zonesFolder then
		for _, zoneMarker in ipairs(zonesFolder:GetChildren()) do
			if zoneMarker:IsA("Part") then
				local zonePos = zoneMarker.Position
				local zoneSize = zoneMarker.Size
				if math.abs(pos.X - zonePos.X) < zoneSize.X/2
					and math.abs(pos.Z - zonePos.Z) < zoneSize.Z/2 then
					local levelReq = zoneMarker:GetAttribute("LevelRequired") or 1
					foundZone = zoneMarker:GetAttribute("ZoneName") or zoneMarker.Name
					if playerState.level < levelReq then
						isLocked = true
						foundZone = foundZone .. " [VERROUILLE Niv." .. levelReq .. "]"
					end
					break
				end
			end
		end
	end

	if foundZone ~= currentZone then
		currentZone = foundZone
		zoneLabel.Text = currentZone

		-- Tween la couleur
		if isLocked then
			TweenService:Create(zoneLabel, TweenInfo.new(0.3), { TextColor3 = THEME.red }):Play()
			flashScreen(THEME.red, 0.15, 0.3)
		elseif foundZone == "La Ville" then
			TweenService:Create(zoneLabel, TweenInfo.new(0.3), { TextColor3 = THEME.white }):Play()
		else
			TweenService:Create(zoneLabel, TweenInfo.new(0.3), { TextColor3 = THEME.gold }):Play()
		end
	end
end)

-- ═══════════════════════════════════════════
-- EVENT HANDLERS
-- ═══════════════════════════════════════════

-- Notifications from server (Fix 14: level-up celebration)
NotifyEvent.OnClientEvent:Connect(function(data)
	if data.type == "levelup" then
		flashScreen(Color3.fromRGB(200, 100, 255), 0.4, 0.6)
		shakeCamera(0.5, 0.3)
	end
	showNotification(data)
end)

-- Mine result (loot popup)
MineResultEvent.OnClientEvent:Connect(function(data)
	showLootPopup(data)
end)

-- Sell result (Fix 13: celebration)
SellResultEvent.OnClientEvent:Connect(function(data)
	playSound("sell_cash")
	flashScreen(THEME.green, 0.3, 0.5)
	showNotification({
		title = "Vente réussie !",
		message = data.merchantName .. " t'a payé " .. formatCash(data.totalEarnings),
		type = "success",
	})
	-- Floating $ symbols
	for i = 1, 6 do
		task.spawn(function()
			local dollar = Instance.new("TextLabel")
			dollar.Size = UDim2.new(0, 40, 0, 40)
			dollar.Position = UDim2.new(math.random(30, 70) / 100, 0, 0.3, 0)
			dollar.BackgroundTransparency = 1
			dollar.Text = "$"
			dollar.TextColor3 = THEME.green
			dollar.TextSize = 24 + math.random(0, 12)
			dollar.Font = Enum.Font.GothamBold
			dollar.Parent = effectScreen
			TweenService:Create(dollar, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(dollar.Position.X.Scale, 0, 0.7, 0),
				TextTransparency = 1,
			}):Play()
			task.delay(1.5, function() dollar:Destroy() end)
			task.wait(0.1)
		end)
	end
	-- Close sell UI
	task.delay(0.5, function()
		sellScreen.Enabled = false
	end)
end)

-- Inventory update
UpdateInventoryEvent.OnClientEvent:Connect(function(data)
	playerState.inventory = data.inventory or playerState.inventory
	playerState.gems = data.gems or playerState.gems
	playerState.cash = data.cash or playerState.cash

	cashLabel.Text = formatCash(playerState.cash)
	updateInventoryDisplay()
end)

-- XP / Level update
UpdateXPEvent.OnClientEvent:Connect(function(data)
	playerState.xp = data.xp or playerState.xp
	playerState.level = data.level or playerState.level
	playerState.nextLevelXP = data.nextLevelXP or playerState.nextLevelXP
	playerState.currentTool = data.currentTool or playerState.currentTool
	playerState.ownedTools = data.ownedTools or playerState.ownedTools

	-- Update level label
	local levelInfo = Config.Levels[playerState.level]
	if levelInfo then
		levelLabel.Text = "Niv. " .. playerState.level .. " - " .. levelInfo.name
	end

	-- Update XP bar
	local prevLevelXP = Config.Levels[playerState.level] and Config.Levels[playerState.level].xpRequired or 0
	local xpInLevel = playerState.xp - prevLevelXP
	local xpNeeded = playerState.nextLevelXP - prevLevelXP
	local fillPct = math.clamp(xpInLevel / math.max(xpNeeded, 1), 0, 1)
	TweenService:Create(xpBarFill, TweenInfo.new(0.3), {
		Size = UDim2.new(fillPct, 0, 1, 0)
	}):Play()

	-- Update tool label
	local tool = Config.ToolsById[playerState.currentTool]
	if tool then
		toolLabel.Text = tool.name
	end

	updateShopUI()
end)

-- ═══════════════════════════════════════════
-- LEADERSTATS LISTENER (for cash HUD)
-- ═══════════════════════════════════════════

local leaderstats = player:WaitForChild("leaderstats", 30)
if leaderstats then
	local cashValue = leaderstats:WaitForChild("Cash")
	cashValue.Changed:Connect(function()
		cashLabel.Text = formatCash(cashValue.Value)
	end)
end

-- ═══════════════════════════════════════════
-- MESSAGE D'ACCUEIL
-- ═══════════════════════════════════════════

task.delay(2, function()
	showNotification({
		title = "Bienvenue, prospecteur !",
		message = "Marche vers la DROITE pour rejoindre la riviere et miner de l'or !",
		type = "success",
	})
end)

task.delay(6, function()
	showNotification({
		title = "Comment miner",
		message = "Approche les spots dores et appuie [E], puis clique FRAPPER au bon moment !",
		type = "info",
	})
end)

task.delay(10, function()
	showNotification({
		title = "Vendre & Ameliorer",
		message = "En ville : Marcel (a droite) achete ton or, Jake (a gauche) vend des outils !",
		type = "info",
	})
end)

-- Fix 3: Reset isMining on respawn
player.CharacterAdded:Connect(function()
	isMining = false
	miningActive = false
	miningScreen.Enabled = false
	pendingSpotData = nil
	if miningTimeoutThread then
		task.cancel(miningTimeoutThread)
		miningTimeoutThread = nil
	end
end)

print("[Gold Rush Legacy] Client loaded!")
