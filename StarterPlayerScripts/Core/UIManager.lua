--[[
	UIManager.lua (ModuleScript)
	ROLE : Module partagé pour l'UI client — HUD premium western, responsive mobile.
]]

local UIManager = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Events = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvents")

local PlayerData = nil

-- ═══════════════════════════════════════════
-- RESPONSIVE — detect platform
-- ═══════════════════════════════════════════
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local guiInset = GuiService:GetGuiInset()

local function updateScreenInfo()
	local cam = workspace.CurrentCamera
	if cam then
		screenSize = cam.ViewportSize
	end
	isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Scale factor: desktop always returns baseSize, mobile scales down
local function S(baseSize)
	if isMobile then
		local scale = math.clamp(screenSize.X / 1200, 0.55, 0.85)
		return math.max(math.floor(baseSize * scale), 6)
	end
	-- Desktop: no scaling, just return the base size as-is
	return baseSize
end

-- ═══════════════════════════════════════════
-- STYLE CONSTANTS
-- ═══════════════════════════════════════════
local COLORS = {
	BgDark = Color3.fromRGB(22, 18, 14),
	BgPanel = Color3.fromRGB(35, 28, 22),
	BgRow = Color3.fromRGB(50, 40, 30),
	BgRowHover = Color3.fromRGB(65, 52, 38),
	BgButton = Color3.fromRGB(60, 45, 25),
	BgButtonHover = Color3.fromRGB(80, 60, 35),

	Gold = Color3.fromRGB(255, 215, 0),
	GoldDark = Color3.fromRGB(200, 160, 50),
	GoldMuted = Color3.fromRGB(180, 150, 60),

	TextWhite = Color3.fromRGB(240, 230, 210),
	TextGray = Color3.fromRGB(170, 160, 145),
	TextDim = Color3.fromRGB(120, 110, 95),

	Success = Color3.fromRGB(80, 200, 80),
	Error = Color3.fromRGB(220, 70, 70),
	Info = Color3.fromRGB(100, 170, 240),
	LevelUp = Color3.fromRGB(255, 180, 50),

	RarityCommon = Color3.fromRGB(180, 170, 155),
	RarityUncommon = Color3.fromRGB(100, 200, 100),
	RarityRare = Color3.fromRGB(80, 150, 255),
	RarityEpic = Color3.fromRGB(180, 80, 255),
	RarityLegendary = Color3.fromRGB(255, 180, 0),
}

local ITEM_RARITY = {
	Paillettes = "Common", Pepites = "Uncommon", MineraiOr = "Uncommon",
	OrPur = "Rare", Lingots = "Epic", Quartz = "Common",
	Amethyste = "Rare", Topaze = "Epic", Diamant = "Legendary",
}

local ITEM_ICONS = {
	Paillettes = "✦", Pepites = "◆", MineraiOr = "⬡", OrPur = "●",
	Lingots = "▬", Quartz = "◇", Amethyste = "♦", Topaze = "★", Diamant = "💎",
}

local ITEM_DISPLAY = {
	Paillettes = "Paillettes", OrPur = "Or Pur", Lingots = "Lingots",
	Pepites = "Pépites", MineraiOr = "Minerai", Quartz = "Quartz",
	Amethyste = "Améthyste", Topaze = "Topaze", Diamant = "Diamant",
}

local function getRarityColor(itemKey)
	local rarity = ITEM_RARITY[itemKey] or "Common"
	if rarity == "Uncommon" then return COLORS.RarityUncommon
	elseif rarity == "Rare" then return COLORS.RarityRare
	elseif rarity == "Epic" then return COLORS.RarityEpic
	elseif rarity == "Legendary" then return COLORS.RarityLegendary
	end
	return COLORS.RarityCommon
end

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════
local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or COLORS.GoldDark
	s.Thickness = thickness or 2
	s.Transparency = transparency or 0
	s.Parent = parent
	return s
end

local function addGradient(parent, top, bottom)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(top or COLORS.BgPanel, bottom or COLORS.BgDark)
	g.Rotation = 90
	g.Parent = parent
	return g
end

local function addPadding(parent, l, r, t, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, l or 8)
	p.PaddingRight = UDim.new(0, r or 8)
	p.PaddingTop = UDim.new(0, t or 6)
	p.PaddingBottom = UDim.new(0, b or 6)
	p.Parent = parent
	return p
end

local function tweenProperty(obj, props, duration, style, direction)
	local tween = TweenService:Create(obj, TweenInfo.new(
		duration or 0.3,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	), props)
	tween:Play()
	return tween
end

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
function UIManager:Init()
	updateScreenInfo()

	Events.InitPlayerData.OnClientEvent:Connect(function(data)
		PlayerData = data
		self:RefreshHUD()
		print("[UIManager] Données initiales reçues")
	end)

	Events.PlayerDataUpdated.OnClientEvent:Connect(function(data)
		local oldData = PlayerData
		PlayerData = data
		self:RefreshHUD()
		if oldData and data.Cash ~= oldData.Cash then
			self:AnimateCashChange(data.Cash - oldData.Cash)
		end
	end)

	local notifyEvent = Events:FindFirstChild("NotifyPlayer")
	if notifyEvent then
		notifyEvent.OnClientEvent:Connect(function(message, notifType)
			self:ShowNotification(message, notifType or "Info")
		end)
	end

	Events.LevelUp.OnClientEvent:Connect(function(level, levelName)
		self:ShowLevelUp(level, levelName)
	end)

	self:CreateHUD()
	print("[UIManager] Initialisé ✓")
end

-- ═══════════════════════════════════════════
-- HUD PRINCIPAL
-- ═══════════════════════════════════════════
function UIManager:CreateHUD()
	updateScreenInfo()

	local existing = playerGui:FindFirstChild("MainHUD")
	if existing then existing:Destroy() end

	local mainHUD = Instance.new("ScreenGui")
	mainHUD.Name = "MainHUD"
	mainHUD.ResetOnSpawn = false
	mainHUD.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mainHUD.IgnoreGuiInset = false
	mainHUD.Parent = playerGui

	self:CreateTopBar(mainHUD)
	self:CreateInventoryPanel(mainHUD)
	self:CreateToolBar(mainHUD)
	self:CreateNotificationContainer(mainHUD)
end

-- ═══════════════════════════════════════════
-- TOP BAR — Cash + Level + XP
-- ═══════════════════════════════════════════
function UIManager:CreateTopBar(parent)
	local w = isMobile and S(200) or S(240)
	local cashH = isMobile and S(34) or S(38)
	local levelH = isMobile and S(38) or S(44)
	local gap = 4
	local margin = isMobile and 6 or 10

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(0, w, 0, cashH + levelH + gap)
	topBar.Position = UDim2.new(1, -(w + margin), 0, margin)
	topBar.BackgroundTransparency = 1
	topBar.Parent = parent

	-- Cash frame
	local cashFrame = Instance.new("Frame")
	cashFrame.Name = "CashFrame"
	cashFrame.Size = UDim2.new(1, 0, 0, cashH)
	cashFrame.BackgroundColor3 = COLORS.BgDark
	cashFrame.BackgroundTransparency = 0.15
	cashFrame.Parent = topBar
	addCorner(cashFrame, S(10))
	addStroke(cashFrame, COLORS.GoldDark, isMobile and 1.5 or 2, 0.2)
	addGradient(cashFrame, Color3.fromRGB(45, 35, 20), Color3.fromRGB(25, 20, 12))

	local coinSize = isMobile and S(26) or S(30)
	local coinIcon = Instance.new("TextLabel")
	coinIcon.Name = "CoinIcon"
	coinIcon.Size = UDim2.new(0, coinSize, 0, coinSize)
	coinIcon.Position = UDim2.new(0, 4, 0.5, -coinSize/2)
	coinIcon.BackgroundColor3 = COLORS.Gold
	coinIcon.TextColor3 = Color3.fromRGB(120, 90, 0)
	coinIcon.Font = Enum.Font.GothamBold
	coinIcon.TextSize = S(16)
	coinIcon.Text = "$"
	coinIcon.Parent = cashFrame
	addCorner(coinIcon, coinSize/2)

	local cashLabel = Instance.new("TextLabel")
	cashLabel.Name = "CashLabel"
	cashLabel.Size = UDim2.new(1, -(coinSize + 8), 1, 0)
	cashLabel.Position = UDim2.new(0, coinSize + 6, 0, 0)
	cashLabel.BackgroundTransparency = 1
	cashLabel.TextColor3 = COLORS.Gold
	cashLabel.Font = Enum.Font.GothamBold
	cashLabel.TextSize = isMobile and S(18) or S(20)
	cashLabel.TextXAlignment = Enum.TextXAlignment.Right
	cashLabel.Text = "50"
	cashLabel.Parent = cashFrame
	addPadding(cashLabel, 0, 8, 0, 0)

	local cashDelta = Instance.new("TextLabel")
	cashDelta.Name = "CashDelta"
	cashDelta.Size = UDim2.new(0, 80, 0, 20)
	cashDelta.Position = UDim2.new(1, -90, 0, -2)
	cashDelta.BackgroundTransparency = 1
	cashDelta.TextColor3 = COLORS.Success
	cashDelta.Font = Enum.Font.GothamBold
	cashDelta.TextSize = S(13)
	cashDelta.TextTransparency = 1
	cashDelta.TextXAlignment = Enum.TextXAlignment.Right
	cashDelta.Text = ""
	cashDelta.Parent = cashFrame

	-- Level frame
	local levelFrame = Instance.new("Frame")
	levelFrame.Name = "LevelFrame"
	levelFrame.Size = UDim2.new(1, 0, 0, levelH)
	levelFrame.Position = UDim2.new(0, 0, 0, cashH + gap)
	levelFrame.BackgroundColor3 = COLORS.BgDark
	levelFrame.BackgroundTransparency = 0.15
	levelFrame.Parent = topBar
	addCorner(levelFrame, S(10))
	addStroke(levelFrame, COLORS.GoldDark, 1.5, 0.4)

	local levelIcon = Instance.new("TextLabel")
	levelIcon.Name = "LevelIcon"
	levelIcon.Size = UDim2.new(0, S(24), 0, S(24))
	levelIcon.Position = UDim2.new(0, 6, 0, 3)
	levelIcon.BackgroundTransparency = 1
	levelIcon.TextColor3 = COLORS.GoldMuted
	levelIcon.Font = Enum.Font.GothamBold
	levelIcon.TextSize = S(16)
	levelIcon.Text = "★"
	levelIcon.Parent = levelFrame

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Size = UDim2.new(1, -S(34), 0, S(16))
	levelLabel.Position = UDim2.new(0, S(32), 0, 2)
	levelLabel.BackgroundTransparency = 1
	levelLabel.TextColor3 = COLORS.TextWhite
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.TextSize = isMobile and S(11) or S(13)
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.Text = "Niv. 1 — Amateur"
	levelLabel.TextTruncate = Enum.TextTruncate.AtEnd
	levelLabel.Parent = levelFrame

	local barY = isMobile and S(20) or S(24)
	local xpBarBg = Instance.new("Frame")
	xpBarBg.Name = "XPBarBg"
	xpBarBg.Size = UDim2.new(1, -16, 0, S(10))
	xpBarBg.Position = UDim2.new(0, 8, 0, barY)
	xpBarBg.BackgroundColor3 = Color3.fromRGB(15, 12, 8)
	xpBarBg.Parent = levelFrame
	addCorner(xpBarBg, 5)

	local xpBarFill = Instance.new("Frame")
	xpBarFill.Name = "XPBarFill"
	xpBarFill.Size = UDim2.new(0, 0, 1, 0)
	xpBarFill.BackgroundColor3 = COLORS.Gold
	xpBarFill.Parent = xpBarBg
	addCorner(xpBarFill, 5)
	addGradient(xpBarFill, Color3.fromRGB(255, 220, 60), Color3.fromRGB(200, 150, 0))

	local xpText = Instance.new("TextLabel")
	xpText.Name = "XPText"
	xpText.Size = UDim2.new(1, 0, 1, 0)
	xpText.BackgroundTransparency = 1
	xpText.TextColor3 = COLORS.TextWhite
	xpText.Font = Enum.Font.GothamBold
	xpText.TextSize = isMobile and 7 or 8
	xpText.Text = "0 / 500 XP"
	xpText.ZIndex = 3
	xpText.Parent = xpBarBg
end

-- ═══════════════════════════════════════════
-- INVENTORY PANEL — collapsible on mobile
-- ═══════════════════════════════════════════
local inventoryOpen = not isMobile -- auto-open on desktop, closed on mobile

function UIManager:CreateInventoryPanel(parent)
	local invW = isMobile and S(180) or S(210)
	local invH = isMobile and S(220) or S(280)
	local margin = isMobile and 4 or 10

	-- Toggle button (always visible)
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "InvToggle"
	toggleBtn.Size = UDim2.new(0, isMobile and 40 or 36, 0, isMobile and 40 or 36)
	toggleBtn.Position = UDim2.new(0, margin, 0.5, -(invH/2) - (isMobile and 44 or 0))
	toggleBtn.BackgroundColor3 = COLORS.BgDark
	toggleBtn.BackgroundTransparency = 0.15
	toggleBtn.TextColor3 = COLORS.GoldMuted
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = isMobile and 18 or 16
	toggleBtn.Text = "📦"
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = parent
	addCorner(toggleBtn, isMobile and 20 or 8)
	addStroke(toggleBtn, COLORS.GoldDark, 1.5, 0.3)

	-- Inventory frame
	local invFrame = Instance.new("Frame")
	invFrame.Name = "InventoryFrame"
	invFrame.Size = UDim2.new(0, invW, 0, invH)
	invFrame.Position = UDim2.new(0, margin, 0.5, -(invH/2))
	invFrame.BackgroundColor3 = COLORS.BgDark
	invFrame.BackgroundTransparency = 0.1
	invFrame.Visible = inventoryOpen
	invFrame.Parent = parent
	addCorner(invFrame, S(10))
	addStroke(invFrame, COLORS.GoldDark, 1.5, 0.3)

	-- Toggle logic
	toggleBtn.MouseButton1Click:Connect(function()
		inventoryOpen = not inventoryOpen
		if inventoryOpen then
			invFrame.Visible = true
			invFrame.BackgroundTransparency = 1
			tweenProperty(invFrame, {BackgroundTransparency = 0.1}, 0.2)
		else
			tweenProperty(invFrame, {BackgroundTransparency = 1}, 0.2)
			task.delay(0.2, function()
				invFrame.Visible = false
			end)
		end
	end)

	-- Hide toggle on desktop if always visible
	if not isMobile then
		toggleBtn.Visible = false
	end

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, S(28))
	header.BackgroundColor3 = COLORS.BgPanel
	header.BackgroundTransparency = 0.3
	header.Parent = invFrame
	addCorner(header, S(10))

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 1, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = COLORS.GoldMuted
	title.Font = Enum.Font.GothamBold
	title.TextSize = isMobile and S(11) or S(13)
	title.Text = "INVENTAIRE"
	title.Parent = header

	-- Close button on mobile (inside panel)
	if isMobile then
		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.new(0, 28, 0, 28)
		closeBtn.Position = UDim2.new(1, -30, 0, 0)
		closeBtn.BackgroundTransparency = 1
		closeBtn.TextColor3 = COLORS.TextGray
		closeBtn.Font = Enum.Font.GothamBold
		closeBtn.TextSize = 14
		closeBtn.Text = "✕"
		closeBtn.Parent = header
		closeBtn.MouseButton1Click:Connect(function()
			inventoryOpen = false
			tweenProperty(invFrame, {BackgroundTransparency = 1}, 0.2)
			task.delay(0.2, function() invFrame.Visible = false end)
		end)
	end

	local sep = Instance.new("Frame")
	sep.Size = UDim2.new(0.85, 0, 0, 1)
	sep.Position = UDim2.new(0.075, 0, 0, S(30))
	sep.BackgroundColor3 = COLORS.GoldDark
	sep.BackgroundTransparency = 0.6
	sep.BorderSizePixel = 0
	sep.Parent = invFrame

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ItemList"
	scrollFrame.Size = UDim2.new(1, -10, 1, -S(36))
	scrollFrame.Position = UDim2.new(0, 5, 0, S(34))
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = isMobile and 4 or 3
	scrollFrame.ScrollBarImageColor3 = COLORS.GoldDark
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.BorderSizePixel = 0
	scrollFrame.Parent = invFrame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, isMobile and 4 or 3)
	layout.Parent = scrollFrame
end

-- ═══════════════════════════════════════════
-- TOOLBAR (bottom center)
-- ═══════════════════════════════════════════
function UIManager:CreateToolBar(parent)
	local tbW = isMobile and S(160) or S(180)
	local tbH = isMobile and S(44) or S(50)
	local bottomMargin = isMobile and 20 or 10

	local toolBar = Instance.new("Frame")
	toolBar.Name = "ToolBar"
	toolBar.Size = UDim2.new(0, tbW, 0, tbH)
	toolBar.AnchorPoint = Vector2.new(0.5, 1)
	toolBar.Position = UDim2.new(0.5, 0, 1, -bottomMargin)
	toolBar.BackgroundColor3 = COLORS.BgDark
	toolBar.BackgroundTransparency = 0.15
	toolBar.Parent = parent
	addCorner(toolBar, S(12))
	addStroke(toolBar, COLORS.GoldDark, 1.5, 0.3)

	local slotSize = isMobile and S(36) or S(40)
	local slot = Instance.new("Frame")
	slot.Name = "ToolSlot"
	slot.Size = UDim2.new(0, slotSize, 0, slotSize)
	slot.Position = UDim2.new(0, 5, 0.5, -slotSize/2)
	slot.BackgroundColor3 = COLORS.BgRow
	slot.Parent = toolBar
	addCorner(slot, 8)
	addStroke(slot, COLORS.GoldDark, 1, 0.5)

	local toolIcon = Instance.new("TextLabel")
	toolIcon.Name = "ToolIcon"
	toolIcon.Size = UDim2.new(1, 0, 1, 0)
	toolIcon.BackgroundTransparency = 1
	toolIcon.TextColor3 = COLORS.GoldMuted
	toolIcon.Font = Enum.Font.GothamBold
	toolIcon.TextSize = S(18)
	toolIcon.Text = "⛏"
	toolIcon.Parent = slot

	local labelX = slotSize + 10
	local toolLabel = Instance.new("TextLabel")
	toolLabel.Name = "ToolLabel"
	toolLabel.Size = UDim2.new(1, -(labelX + 4), 0, S(18))
	toolLabel.Position = UDim2.new(0, labelX, 0, isMobile and 4 or 5)
	toolLabel.BackgroundTransparency = 1
	toolLabel.TextColor3 = COLORS.TextWhite
	toolLabel.Font = Enum.Font.GothamBold
	toolLabel.TextSize = isMobile and S(11) or S(13)
	toolLabel.TextXAlignment = Enum.TextXAlignment.Left
	toolLabel.TextTruncate = Enum.TextTruncate.AtEnd
	toolLabel.Text = "Batée en Bois"
	toolLabel.Parent = toolBar

	local toolLevel = Instance.new("TextLabel")
	toolLevel.Name = "ToolLevel"
	toolLevel.Size = UDim2.new(1, -(labelX + 4), 0, S(12))
	toolLevel.Position = UDim2.new(0, labelX, 0, isMobile and S(20) or S(24))
	toolLevel.BackgroundTransparency = 1
	toolLevel.TextColor3 = COLORS.TextDim
	toolLevel.Font = Enum.Font.Gotham
	toolLevel.TextSize = isMobile and S(9) or S(11)
	toolLevel.TextXAlignment = Enum.TextXAlignment.Left
	toolLevel.Text = "Niveau 1"
	toolLevel.Parent = toolBar
end

-- ═══════════════════════════════════════════
-- NOTIFICATION CONTAINER
-- ═══════════════════════════════════════════
function UIManager:CreateNotificationContainer(parent)
	local notifW = isMobile and S(300) or S(360)

	local container = Instance.new("Frame")
	container.Name = "NotifContainer"
	container.Size = UDim2.new(0, notifW, 0, 200)
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.Position = UDim2.new(0.5, 0, 0, isMobile and 4 or 10)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.Parent = container
end

-- ═══════════════════════════════════════════
-- REFRESH HUD
-- ═══════════════════════════════════════════
function UIManager:RefreshHUD()
	if not PlayerData then return end

	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end

	local topBar = mainHUD:FindFirstChild("TopBar")
	if topBar then
		local cashLabel = topBar.CashFrame:FindFirstChild("CashLabel")
		if cashLabel then
			local cash = PlayerData.Cash or 0
			local formatted = tostring(cash)
			if cash >= 1000 then
				formatted = string.format("%d,%03d", math.floor(cash / 1000), cash % 1000)
			end
			cashLabel.Text = formatted
		end

		local levelFrame = topBar:FindFirstChild("LevelFrame")
		if levelFrame then
			local level = PlayerData.Level or 1
			local xp = PlayerData.XP or 0

			local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
			local levelInfo = EconomyConfig.LevelThresholds[level]
			local levelName = levelInfo and levelInfo.Name or "Amateur"
			local maxXP = levelInfo and levelInfo.MaxXP or 500
			local minXP = levelInfo and levelInfo.MinXP or 0

			local levelLabel = levelFrame:FindFirstChild("LevelLabel")
			if levelLabel then
				levelLabel.Text = `Niv. {level} — {levelName}`
			end

			local xpBarBg = levelFrame:FindFirstChild("XPBarBg")
			if xpBarBg then
				local xpBarFill = xpBarBg:FindFirstChild("XPBarFill")
				local xpText = xpBarBg:FindFirstChild("XPText")
				local xpInLevel = xp - minXP
				local xpNeeded = math.max(maxXP - minXP, 1)
				local ratio = math.clamp(xpInLevel / xpNeeded, 0, 1)
				if xpBarFill then
					tweenProperty(xpBarFill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.5)
				end
				if xpText then
					xpText.Text = `{xp} / {maxXP} XP`
				end
			end
		end
	end

	self:RefreshInventory(mainHUD)
	self:RefreshToolBar(mainHUD)
end

function UIManager:RefreshInventory(mainHUD)
	if not PlayerData or not PlayerData.Inventory then return end

	local invFrame = mainHUD:FindFirstChild("InventoryFrame")
	if not invFrame then return end

	local itemList = invFrame:FindFirstChild("ItemList")
	if not itemList then return end

	for _, child in itemList:GetChildren() do
		if child:IsA("Frame") then child:Destroy() end
	end

	local order = {"Paillettes", "Pepites", "OrPur", "MineraiOr", "Lingots", "Quartz", "Amethyste", "Topaze", "Diamant"}
	local layoutOrder = 0
	local rowH = isMobile and S(32) or S(28)

	for _, key in ipairs(order) do
		local qty = PlayerData.Inventory[key] or 0
		if qty > 0 then
			layoutOrder += 1
			local row = Instance.new("Frame")
			row.Name = key
			row.Size = UDim2.new(1, -4, 0, rowH)
			row.BackgroundColor3 = COLORS.BgRow
			row.BackgroundTransparency = 0.4
			row.LayoutOrder = layoutOrder
			row.Parent = itemList
			addCorner(row, 6)

			local accent = Instance.new("Frame")
			accent.Size = UDim2.new(0, 3, 0.7, 0)
			accent.Position = UDim2.new(0, 3, 0.15, 0)
			accent.BackgroundColor3 = getRarityColor(key)
			accent.BorderSizePixel = 0
			accent.Parent = row
			addCorner(accent, 2)

			local icon = Instance.new("TextLabel")
			icon.Size = UDim2.new(0, 22, 1, 0)
			icon.Position = UDim2.new(0, 10, 0, 0)
			icon.BackgroundTransparency = 1
			icon.TextColor3 = getRarityColor(key)
			icon.Font = Enum.Font.GothamBold
			icon.TextSize = isMobile and S(12) or S(13)
			icon.Text = ITEM_ICONS[key] or "•"
			icon.Parent = row

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.55, -30, 1, 0)
			nameLabel.Position = UDim2.new(0, 34, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.TextColor3 = COLORS.TextWhite
			nameLabel.Font = Enum.Font.Gotham
			nameLabel.TextSize = isMobile and S(11) or S(12)
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.Text = ITEM_DISPLAY[key] or key
			nameLabel.Parent = row

			local qtyLabel = Instance.new("TextLabel")
			qtyLabel.Size = UDim2.new(0.3, 0, 1, 0)
			qtyLabel.Position = UDim2.new(0.7, 0, 0, 0)
			qtyLabel.BackgroundTransparency = 1
			qtyLabel.TextColor3 = getRarityColor(key)
			qtyLabel.Font = Enum.Font.GothamBold
			qtyLabel.TextSize = isMobile and S(12) or S(13)
			qtyLabel.TextXAlignment = Enum.TextXAlignment.Right
			qtyLabel.Text = `x{qty}`
			qtyLabel.Parent = row
			addPadding(qtyLabel, 0, 6, 0, 0)
		end
	end
end

function UIManager:RefreshToolBar(mainHUD)
	if not PlayerData then return end

	local toolBar = mainHUD:FindFirstChild("ToolBar")
	if not toolBar then return end

	local ToolConfig = require(ReplicatedStorage.Modules.Config.ToolConfig)
	local bestTool = "Batee"
	local bestLevel = 1
	local toolIcons = { Batee = "🥘", Tapis = "🧹", Pioche = "⛏" }

	-- Pick highest-tier owned tool (Pioche > Tapis > Batee)
	local toolPriority = { Pioche = 3, Tapis = 2, Batee = 1 }
	local bestPrio = 0
	if PlayerData.Tools then
		for toolName, toolInfo in pairs(PlayerData.Tools) do
			if toolInfo.Owned then
				local prio = toolPriority[toolName] or 0
				if prio > bestPrio then
					bestPrio = prio
					bestTool = toolName
					bestLevel = toolInfo.Level or 1
				end
			end
		end
	end

	local toolData = ToolConfig.Tools[bestTool]
	local levelData = toolData and toolData.Levels[bestLevel]
	local displayName = levelData and levelData.Name or (toolData and toolData.DisplayName or bestTool)

	local toolLabel = toolBar:FindFirstChild("ToolLabel")
	if toolLabel then toolLabel.Text = displayName end

	local toolLevel = toolBar:FindFirstChild("ToolLevel")
	if toolLevel then toolLevel.Text = `Niveau {bestLevel}` end

	local slot = toolBar:FindFirstChild("ToolSlot")
	if slot then
		local toolIcon = slot:FindFirstChild("ToolIcon")
		if toolIcon then toolIcon.Text = toolIcons[bestTool] or "⛏" end
	end
end

-- ═══════════════════════════════════════════
-- CASH CHANGE ANIMATION
-- ═══════════════════════════════════════════
function UIManager:AnimateCashChange(delta)
	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end
	local topBar = mainHUD:FindFirstChild("TopBar")
	if not topBar then return end
	local cashDelta = topBar.CashFrame:FindFirstChild("CashDelta")
	if not cashDelta then return end

	local sign = delta > 0 and "+" or ""
	cashDelta.Text = `{sign}{delta}$`
	cashDelta.TextColor3 = delta > 0 and COLORS.Success or COLORS.Error
	cashDelta.TextTransparency = 0
	cashDelta.Position = UDim2.new(1, -90, 0, -2)

	tweenProperty(cashDelta, {
		Position = UDim2.new(1, -90, 0, -18),
		TextTransparency = 1,
	}, 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end

-- ═══════════════════════════════════════════
-- NOTIFICATION (toast)
-- ═══════════════════════════════════════════
function UIManager:ShowNotification(message: string, notifType: string)
	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end
	local container = mainHUD:FindFirstChild("NotifContainer")
	if not container then return end

	local colorMap = {
		Info = COLORS.Info, Error = COLORS.Error,
		Success = COLORS.Success, LevelUp = COLORS.LevelUp,
	}
	local iconMap = { Info = "ℹ", Error = "✗", Success = "✓", LevelUp = "★" }
	local accentColor = colorMap[notifType] or COLORS.Info
	local iconChar = iconMap[notifType] or "ℹ"

	local notifH = isMobile and S(36) or S(38)
	local notif = Instance.new("Frame")
	notif.Name = "Notification"
	notif.Size = UDim2.new(1, 0, 0, notifH)
	notif.BackgroundColor3 = COLORS.BgDark
	notif.BackgroundTransparency = 0.1
	notif.LayoutOrder = os.clock() * 1000
	notif.Parent = container
	addCorner(notif, 8)
	addStroke(notif, accentColor, 1.5, 0.3)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 3, 0.7, 0)
	accent.Position = UDim2.new(0, 4, 0.15, 0)
	accent.BackgroundColor3 = accentColor
	accent.BorderSizePixel = 0
	accent.Parent = notif
	addCorner(accent, 2)

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 24, 1, 0)
	iconLabel.Position = UDim2.new(0, 12, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.TextColor3 = accentColor
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = S(14)
	iconLabel.Text = iconChar
	iconLabel.Parent = notif

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -44, 1, 0)
	msgLabel.Position = UDim2.new(0, 38, 0, 0)
	msgLabel.BackgroundTransparency = 1
	msgLabel.TextColor3 = COLORS.TextWhite
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.TextSize = isMobile and S(11) or S(13)
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.TextTruncate = Enum.TextTruncate.AtEnd
	msgLabel.Text = message
	msgLabel.Parent = notif

	notif.Position = UDim2.new(0, 30, 0, 0)
	notif.BackgroundTransparency = 1
	tweenProperty(notif, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.1}, 0.3)

	task.spawn(function()
		task.wait(3.5)
		tweenProperty(notif, {BackgroundTransparency = 1, Position = UDim2.new(0, -20, 0, 0)}, 0.4)
		tweenProperty(msgLabel, {TextTransparency = 1}, 0.4)
		task.wait(0.5)
		notif:Destroy()
	end)
end

-- ═══════════════════════════════════════════
-- LEVEL UP CELEBRATION
-- ═══════════════════════════════════════════
function UIManager:ShowLevelUp(level, levelName)
	self:ShowNotification(`LEVEL UP ! Niveau {level} — {levelName}`, "LevelUp")

	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end

	local flash = Instance.new("Frame")
	flash.Name = "LevelFlash"
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = COLORS.Gold
	flash.BackgroundTransparency = 0.7
	flash.ZIndex = 10
	flash.Parent = mainHUD

	local bigText = Instance.new("TextLabel")
	bigText.Size = UDim2.new(1, 0, 0, 80)
	bigText.AnchorPoint = Vector2.new(0.5, 0.5)
	bigText.Position = UDim2.new(0.5, 0, 0.4, 0)
	bigText.BackgroundTransparency = 1
	bigText.TextColor3 = COLORS.Gold
	bigText.Font = Enum.Font.GothamBold
	bigText.TextSize = isMobile and S(32) or S(42)
	bigText.TextStrokeColor3 = Color3.fromRGB(80, 50, 0)
	bigText.TextStrokeTransparency = 0.3
	bigText.Text = `NIVEAU {level}`
	bigText.ZIndex = 11
	bigText.Parent = mainHUD

	local subText = Instance.new("TextLabel")
	subText.Size = UDim2.new(1, 0, 0, 30)
	subText.AnchorPoint = Vector2.new(0.5, 0.5)
	subText.Position = UDim2.new(0.5, 0, 0.4, isMobile and 35 or 45)
	subText.BackgroundTransparency = 1
	subText.TextColor3 = COLORS.TextWhite
	subText.Font = Enum.Font.GothamBold
	subText.TextSize = isMobile and S(16) or S(20)
	subText.TextStrokeTransparency = 0.5
	subText.Text = levelName or ""
	subText.ZIndex = 11
	subText.Parent = mainHUD

	bigText.TextTransparency = 1
	subText.TextTransparency = 1
	tweenProperty(bigText, {TextTransparency = 0}, 0.3)
	tweenProperty(subText, {TextTransparency = 0}, 0.4)

	task.spawn(function()
		task.wait(2)
		tweenProperty(flash, {BackgroundTransparency = 1}, 0.6)
		tweenProperty(bigText, {TextTransparency = 1, Position = UDim2.new(0.5, 0, 0.35, 0)}, 0.6)
		tweenProperty(subText, {TextTransparency = 1}, 0.5)
		task.wait(0.7)
		flash:Destroy()
		bigText:Destroy()
		subText:Destroy()
	end)
end

-- ═══════════════════════════════════════════
-- FLOATING TEXT (drops)
-- ═══════════════════════════════════════════
function UIManager:ShowFloatingText(worldPos: Vector3, text: string, color: Color3)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = playerGui

	local anchor = Instance.new("Part")
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.Position = worldPos
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Parent = workspace

	billboardGui.Adornee = anchor

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = color or COLORS.Gold
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextStrokeColor3 = Color3.fromRGB(30, 20, 0)
	label.TextStrokeTransparency = 0.3
	label.Text = text
	label.Parent = billboardGui

	tweenProperty(label, {TextSize = isMobile and 18 or 22}, 0.15, Enum.EasingStyle.Back)

	task.spawn(function()
		for i = 1, 40 do
			anchor.Position = anchor.Position + Vector3.new(0, 0.04, 0)
			if i > 25 then
				label.TextTransparency = (i - 25) / 15
				label.TextStrokeTransparency = 0.3 + ((i - 25) / 15) * 0.7
			end
			task.wait(0.025)
		end
		billboardGui:Destroy()
		anchor:Destroy()
	end)
end

-- ═══════════════════════════════════════════
-- EFFECTS
-- ═══════════════════════════════════════════
function UIManager:PlayMineEffect(position: Vector3)
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(COLORS.Gold)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.Speed = NumberRange.new(5, 10)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Rate = 0
	emitter.Parent = part
	emitter:Emit(20)

	task.delay(2, function() part:Destroy() end)
end

function UIManager:PlaySound(soundName: string)
	local soundIds = {
		MineSuccess = "rbxasset://sounds/impact_explosion_03.mp3",
	}
	local id = soundIds[soundName]
	if id then
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Volume = 0.5
		sound.Parent = player.PlayerGui
		sound:Play()
		sound.Ended:Connect(function() sound:Destroy() end)
	end
end

-- ═══════════════════════════════════════════
-- LOOT FEED
-- ═══════════════════════════════════════════
function UIManager:ShowLootFeed(drops, xpGained)
	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end

	local feedW = isMobile and S(160) or S(200)
	local feedFrame = Instance.new("Frame")
	feedFrame.Name = "LootFeed"
	feedFrame.Size = UDim2.new(0, feedW, 0, 200)
	feedFrame.AnchorPoint = Vector2.new(1, 0.5)
	feedFrame.Position = UDim2.new(1, isMobile and -4 or -10, 0.5, 0)
	feedFrame.BackgroundTransparency = 1
	feedFrame.Parent = mainHUD

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 3)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.Parent = feedFrame

	local order = 0
	local itemH = isMobile and S(22) or S(24)
	local fontSize = isMobile and S(12) or S(14)

	if type(drops) == "table" then
		for itemName, qty in pairs(drops) do
			order += 1
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0, feedW - 10, 0, itemH)
			label.BackgroundColor3 = COLORS.BgDark
			label.BackgroundTransparency = 0.3
			label.TextColor3 = getRarityColor(itemName)
			label.Font = Enum.Font.GothamBold
			label.TextSize = fontSize
			label.TextXAlignment = Enum.TextXAlignment.Right
			label.Text = `+{qty} {ITEM_DISPLAY[itemName] or itemName} {ITEM_ICONS[itemName] or ""}`
			label.LayoutOrder = order
			label.Parent = feedFrame
			addCorner(label, 6)
			addPadding(label, 6, 6, 0, 0)

			label.Position = UDim2.new(0, 30, 0, 0)
			label.TextTransparency = 1
			label.BackgroundTransparency = 1
			task.delay(order * 0.1, function()
				tweenProperty(label, {Position = UDim2.new(0, 0, 0, 0), TextTransparency = 0, BackgroundTransparency = 0.3}, 0.25, Enum.EasingStyle.Back)
			end)
		end
	end

	if xpGained and xpGained > 0 then
		order += 1
		local xpLabel = Instance.new("TextLabel")
		xpLabel.Size = UDim2.new(0, feedW - 10, 0, S(20))
		xpLabel.BackgroundTransparency = 1
		xpLabel.TextColor3 = COLORS.GoldMuted
		xpLabel.Font = Enum.Font.GothamBold
		xpLabel.TextSize = isMobile and S(11) or S(13)
		xpLabel.TextXAlignment = Enum.TextXAlignment.Right
		xpLabel.Text = `+{xpGained} XP`
		xpLabel.LayoutOrder = order
		xpLabel.Parent = feedFrame

		xpLabel.TextTransparency = 1
		task.delay(order * 0.1, function()
			tweenProperty(xpLabel, {TextTransparency = 0}, 0.25)
		end)
	end

	task.spawn(function()
		task.wait(2.5)
		for _, child in feedFrame:GetChildren() do
			if child:IsA("TextLabel") then
				tweenProperty(child, {TextTransparency = 1, BackgroundTransparency = 1}, 0.4)
			end
		end
		task.wait(0.5)
		feedFrame:Destroy()
	end)
end

-- ═══════════════════════════════════════════
-- PUBLIC API
-- ═══════════════════════════════════════════
function UIManager:GetPlayerData()
	return PlayerData
end

function UIManager:IsMobile()
	return isMobile
end

-- ═══════════════════════════════════════════
-- NPC DIALOGUE BUBBLE (speech bubble above head)
-- ═══════════════════════════════════════════
local activeBubbles = {} -- npcModel → billboard

function UIManager:ShowNPCBubble(npcModel, text, duration)
	duration = duration or 3

	-- Destroy existing bubble on this NPC
	if activeBubbles[npcModel] then
		activeBubbles[npcModel]:Destroy()
		activeBubbles[npcModel] = nil
	end

	local head = npcModel:FindFirstChild("Head")
	if not head then return end

	-- Size bubble based on text length
	local bubbleH = if #text > 40 then 85 else 70

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DialogueBubble"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 260, 0, bubbleH)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 40
	billboard.Parent = playerGui
	activeBubbles[npcModel] = billboard

	-- Bubble background
	local bg = Instance.new("Frame")
	bg.Name = "BubbleBG"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(30, 25, 18)
	bg.BackgroundTransparency = 0.15
	bg.Parent = billboard
	addCorner(bg, 10)
	addStroke(bg, Color3.fromRGB(180, 150, 80), 1.5, 0.3)

	-- Tail (small triangle at bottom)
	local tail = Instance.new("Frame")
	tail.Size = UDim2.new(0, 12, 0, 8)
	tail.Position = UDim2.new(0.5, -6, 1, -1)
	tail.Rotation = 45
	tail.BackgroundColor3 = Color3.fromRGB(30, 25, 18)
	tail.BackgroundTransparency = 0.15
	tail.BorderSizePixel = 0
	tail.Parent = bg

	-- NPC name
	local npcName = npcModel:FindFirstChild("HumanoidRootPart")
		and npcModel.HumanoidRootPart:GetAttribute("NPCName") or npcModel.Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -16, 0, 16)
	nameLabel.Position = UDim2.new(0, 8, 0, 4)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 210, 100)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 11
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = npcName
	nameLabel.Parent = bg

	-- Dialogue text (typewriter effect)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -16, 1, -22)
	textLabel.Position = UDim2.new(0, 8, 0, 20)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(240, 235, 220)
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextSize = 13
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.TextWrapped = true
	textLabel.Text = ""
	textLabel.Parent = bg

	-- Typewriter effect
	task.spawn(function()
		for i = 1, #text do
			if not billboard.Parent then return end
			textLabel.Text = string.sub(text, 1, i)
			task.wait(0.025)
		end
	end)

	-- Animate in (scale up)
	local targetSize = UDim2.new(0, 260, 0, bubbleH)
	billboard.Size = UDim2.new(0, 20, 0, 10)
	TweenService:Create(billboard, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = targetSize,
	}):Play()

	-- Auto-destroy after duration
	task.delay(duration, function()
		if billboard and billboard.Parent then
			TweenService:Create(billboard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 20, 0, 10),
			}):Play()
			task.delay(0.25, function()
				if billboard and billboard.Parent then
					billboard:Destroy()
				end
				if activeBubbles[npcModel] == billboard then
					activeBubbles[npcModel] = nil
				end
			end)
		end
	end)
end

function UIManager:DismissAllBubbles()
	for npcModel, billboard in pairs(activeBubbles) do
		if billboard and billboard.Parent then
			billboard:Destroy()
		end
		activeBubbles[npcModel] = nil
	end
end

UIManager.COLORS = COLORS
UIManager.ITEM_DISPLAY = ITEM_DISPLAY
UIManager.ITEM_ICONS = ITEM_ICONS
UIManager.ITEM_RARITY = ITEM_RARITY
UIManager.addCorner = addCorner
UIManager.addStroke = addStroke
UIManager.addGradient = addGradient
UIManager.addPadding = addPadding
UIManager.tweenProperty = tweenProperty
UIManager.getRarityColor = getRarityColor

return UIManager
