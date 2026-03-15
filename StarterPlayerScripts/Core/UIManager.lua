--[[
	UIManager.lua (ModuleScript)
	Western Ink — HUD premium RPG, desktop-first, 18+ audience.
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
-- RESPONSIVE — PreferredInput + UIScale
-- ═══════════════════════════════════════════
local BASE_HEIGHT = 1080

local function detectPlatform(): string
	local ok, preferred = pcall(function()
		return UserInputService.PreferredInput
	end)
	if ok and preferred == Enum.PreferredInput.Touch then
		return "mobile"
	elseif ok and preferred == Enum.PreferredInput.Gamepad then
		return "console"
	end
	-- Fallback for older clients
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "mobile"
	end
	return "desktop"
end

local platform = detectPlatform()
local isMobile = (platform == "mobile")
local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)

local function updateScreenInfo()
	local cam = workspace.CurrentCamera
	if cam then
		screenSize = cam.ViewportSize
	end
	platform = detectPlatform()
	isMobile = (platform == "mobile")
end

-- S() scales sizes for mobile. Desktop uses raw values; UIScale handles viewport adaptation.
local function S(baseSize)
	if isMobile then
		local scale = math.clamp(screenSize.X / 1200, 0.6, 0.9)
		return math.max(math.floor(baseSize * scale), 8)
	end
	return baseSize
end

-- Update UIScale on the main HUD based on viewport
local function updateUIScale(screenGui)
	local scaleObj = screenGui:FindFirstChild("ResponsiveScale")
	if not scaleObj then return end
	local viewportY = screenSize.Y
	scaleObj.Scale = math.clamp(viewportY / BASE_HEIGHT, 0.65, 1.4)
end

-- ═══════════════════════════════════════════
-- STYLE — Western Ink
-- ═══════════════════════════════════════════
local COLORS = {
	BgDark = Color3.fromRGB(18, 15, 12),
	BgPanel = Color3.fromRGB(28, 23, 18),
	BgRow = Color3.fromRGB(38, 32, 25),
	BgRowHover = Color3.fromRGB(48, 40, 32),
	BgButton = Color3.fromRGB(45, 38, 28),
	BgButtonHover = Color3.fromRGB(58, 48, 35),

	Gold = Color3.fromRGB(195, 165, 85),
	GoldDark = Color3.fromRGB(145, 120, 60),
	GoldMuted = Color3.fromRGB(160, 138, 75),

	TextWhite = Color3.fromRGB(215, 208, 195),
	TextGray = Color3.fromRGB(140, 132, 118),
	TextDim = Color3.fromRGB(95, 88, 75),

	Success = Color3.fromRGB(75, 165, 75),
	Error = Color3.fromRGB(185, 60, 55),
	Info = Color3.fromRGB(85, 145, 200),
	LevelUp = Color3.fromRGB(210, 170, 60),

	RarityCommon = Color3.fromRGB(150, 142, 130),
	RarityUncommon = Color3.fromRGB(85, 170, 85),
	RarityRare = Color3.fromRGB(70, 130, 215),
	RarityEpic = Color3.fromRGB(155, 70, 215),
	RarityLegendary = Color3.fromRGB(210, 155, 30),
}

local FONTS = {
	Title = Enum.Font.Antique,
	Header = Enum.Font.SourceSansBold,
	Body = Enum.Font.SourceSans,
	Number = Enum.Font.SourceSansBold,
	Small = Enum.Font.SourceSansLight,
}

local ITEM_RARITY = {
	Paillettes = "Common", Pepites = "Uncommon", MineraiOr = "Uncommon",
	OrPur = "Rare", Lingots = "Epic", Quartz = "Common",
	Amethyste = "Rare", Topaze = "Epic", Diamant = "Legendary",
}

local ITEM_ICONS = {
	Paillettes = "✦", Pepites = "◆", MineraiOr = "⬡", OrPur = "●",
	Lingots = "▬", Quartz = "◇", Amethyste = "♦", Topaze = "★", Diamant = "◈",
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
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or COLORS.GoldDark
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.3
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
-- HAPTIC FEEDBACK (mobile only)
-- ═══════════════════════════════════════════
local HapticService = pcall(game.GetService, game, "HapticService") and game:GetService("HapticService") or nil

local function haptic(_intensity)
	-- Haptic feedback for mobile — silently fails if unsupported
	if not isMobile or not HapticService then return end
	pcall(function()
		if HapticService:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small) then
			HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, _intensity or 0.3)
			task.delay(0.1, function()
				pcall(function()
					HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
				end)
			end)
		end
	end)
end

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
function UIManager:Init()
	updateScreenInfo()

	-- Disable default Roblox UI (we have our own HUD)
	local StarterGui = game:GetService("StarterGui")
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	-- React to input mode changes (tablet + keyboard, etc.)
	pcall(function()
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			local oldMobile = isMobile
			updateScreenInfo()
			if isMobile ~= oldMobile then
				self:CreateHUD()
				self:RefreshHUD()
			end
		end)
	end)

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
	self:SetupKeybinds()
	print("[UIManager] Initialisé")
end

-- ═══════════════════════════════════════════
-- KEYBINDS
-- ═══════════════════════════════════════════
local inventoryOpen = not (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)

function UIManager:SetupKeybinds()
	-- Desktop: Tab or I to toggle inventory
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.I then
			self:ToggleInventory()
		end
	end)

	-- Mobile: swipe right to open inventory, swipe left to close
	if isMobile then
		UserInputService.TouchSwipe:Connect(function(direction, _, processed)
			if processed then return end
			if direction == Enum.SwipeDirection.Right and not inventoryOpen then
				self:ToggleInventory()
			elseif direction == Enum.SwipeDirection.Left and inventoryOpen then
				self:ToggleInventory()
			end
		end)
	end
end

function UIManager:ToggleInventory()
	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end
	local invFrame = mainHUD:FindFirstChild("InventoryFrame")
	if not invFrame then return end

	inventoryOpen = not inventoryOpen
	if isMobile then
		-- Mobile: show/hide fullscreen overlay
		if inventoryOpen then
			self:RefreshInventory(mainHUD)
			invFrame.Visible = true
			invFrame.BackgroundTransparency = 1
			tweenProperty(invFrame, {BackgroundTransparency = 0.05}, 0.2)
		else
			tweenProperty(invFrame, {BackgroundTransparency = 1}, 0.2)
			task.delay(0.2, function()
				if not inventoryOpen then invFrame.Visible = false end
			end)
		end
	else
		-- Desktop: slide from left
		local offX = -(invFrame.Size.X.Offset + 20)
		if inventoryOpen then
			self:RefreshInventory(mainHUD)
			invFrame.Visible = true
			invFrame.Position = UDim2.new(0, offX, 0.5, -(invFrame.Size.Y.Offset / 2))
			tweenProperty(invFrame, {
				Position = UDim2.new(0, 12, 0.5, -(invFrame.Size.Y.Offset / 2)),
			}, 0.25, Enum.EasingStyle.Quad)
		else
			tweenProperty(invFrame, {
				Position = UDim2.new(0, offX, 0.5, -(invFrame.Size.Y.Offset / 2)),
			}, 0.2, Enum.EasingStyle.Quad)
			task.delay(0.2, function()
				if not inventoryOpen then invFrame.Visible = false end
			end)
		end
	end
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
	pcall(function() mainHUD.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
	mainHUD.Parent = playerGui

	-- UIScale adapts all children to viewport resolution
	local uiScale = Instance.new("UIScale")
	uiScale.Name = "ResponsiveScale"
	uiScale.Parent = mainHUD
	updateUIScale(mainHUD)

	-- Listen for viewport resize
	local cam = workspace.CurrentCamera
	if cam then
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			updateScreenInfo()
			updateUIScale(mainHUD)
		end)
	end

	self:CreateTopBar(mainHUD)
	self:CreateInventoryPanel(mainHUD)
	self:CreateToolBar(mainHUD)
	self:CreateNotificationContainer(mainHUD)
	-- self:CreateMinimap(mainHUD) -- désactivée pour l'instant
end

-- ═══════════════════════════════════════════
-- TOP BAR — Cash display (top-right, minimal)
-- ═══════════════════════════════════════════
function UIManager:CreateTopBar(parent)
	local tbW = isMobile and 130 or S(160)
	local tbH = isMobile and 44 or S(38)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(0, tbW, 0, tbH)
	topBar.Position = UDim2.new(1, -(tbW + 12), 0, 10)
	topBar.BackgroundColor3 = COLORS.BgDark
	topBar.BackgroundTransparency = 0.15
	topBar.Parent = parent
	addCorner(topBar, 6)
	addStroke(topBar, COLORS.GoldDark, 1, 0.5)

	local coinSize = S(18)
	local cashIcon = Instance.new("TextLabel")
	cashIcon.Name = "CashIcon"
	cashIcon.Size = UDim2.new(0, coinSize, 0, coinSize)
	cashIcon.Position = UDim2.new(0, 8, 0.5, -coinSize/2)
	cashIcon.BackgroundColor3 = COLORS.Gold
	cashIcon.TextColor3 = Color3.fromRGB(80, 60, 20)
	cashIcon.Font = FONTS.Number
	cashIcon.TextSize = isMobile and 14 or S(11)
	cashIcon.Text = "$"
	cashIcon.Parent = topBar
	addCorner(cashIcon, coinSize / 2)

	local cashLabel = Instance.new("TextLabel")
	cashLabel.Name = "CashLabel"
	cashLabel.Size = UDim2.new(1, -(coinSize + 20), 0, coinSize)
	cashLabel.Position = UDim2.new(0, coinSize + 12, 0.5, -coinSize/2)
	cashLabel.BackgroundTransparency = 1
	cashLabel.TextColor3 = COLORS.Gold
	cashLabel.Font = FONTS.Number
	cashLabel.TextSize = isMobile and 18 or S(18)
	cashLabel.TextXAlignment = Enum.TextXAlignment.Left
	cashLabel.Text = "50"
	cashLabel.Parent = topBar

	local cashDelta = Instance.new("TextLabel")
	cashDelta.Name = "CashDelta"
	cashDelta.Size = UDim2.new(0, 60, 0, 16)
	cashDelta.Position = UDim2.new(0, coinSize + 12, 0, -6)
	cashDelta.BackgroundTransparency = 1
	cashDelta.TextColor3 = COLORS.Success
	cashDelta.Font = FONTS.Number
	cashDelta.TextSize = isMobile and 14 or S(11)
	cashDelta.TextTransparency = 1
	cashDelta.TextXAlignment = Enum.TextXAlignment.Left
	cashDelta.Text = ""
	cashDelta.Parent = topBar
end

-- ═══════════════════════════════════════════
-- INVENTORY — Grid, toggle with Tab
-- ═══════════════════════════════════════════
function UIManager:CreateInventoryPanel(parent)
	local padding = 14
	local headerH = S(40)

	local invFrame = Instance.new("Frame")
	invFrame.Name = "InventoryFrame"
	invFrame.BackgroundColor3 = COLORS.BgDark
	invFrame.ClipsDescendants = true
	invFrame.Parent = parent

	if isMobile then
		-- Mobile: fullscreen overlay when open
		invFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
		invFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		invFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		invFrame.BackgroundTransparency = 0.05
		invFrame.Visible = false
		addCorner(invFrame, 12)
		addStroke(invFrame, COLORS.GoldDark, 1.5, 0.2)
	else
		-- Desktop: sidebar left, always visible
		local invW = S(260)
		local invH = S(380)
		invFrame.Size = UDim2.new(0, invW, 0, invH)
		invFrame.Position = UDim2.new(0, 12, 0.5, -(invH / 2))
		invFrame.BackgroundTransparency = 0.08
		invFrame.Visible = inventoryOpen
		addCorner(invFrame, 8)
		addStroke(invFrame, COLORS.GoldDark, 1, 0.4)
	end
	addCorner(invFrame, 8)
	addStroke(invFrame, COLORS.GoldDark, 1, 0.4)

	-- Header
	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, headerH)
	header.BackgroundTransparency = 1
	header.TextColor3 = COLORS.GoldMuted
	header.Font = FONTS.Title
	header.TextSize = S(20)
	header.Text = "INVENTAIRE"
	header.Parent = invFrame

	-- Keybind hint (desktop only)
	if not isMobile then
		local hint = Instance.new("TextLabel")
		hint.Size = UDim2.new(0, 40, 0, 16)
		hint.Position = UDim2.new(1, -46, 0, 9)
		hint.BackgroundTransparency = 1
		hint.TextColor3 = COLORS.TextDim
		hint.Font = FONTS.Small
		hint.TextSize = S(10)
		hint.Text = "[TAB]"
		hint.Parent = invFrame
	end

	local sep = Instance.new("Frame")
	sep.Size = UDim2.new(0.85, 0, 0, 1)
	sep.Position = UDim2.new(0.075, 0, 0, headerH)
	sep.BackgroundColor3 = COLORS.GoldDark
	sep.BackgroundTransparency = 0.6
	sep.BorderSizePixel = 0
	sep.Parent = invFrame

	-- Item list (scrollable)
	local listFrame = Instance.new("ScrollingFrame")
	listFrame.Name = "ItemList"
	listFrame.Size = UDim2.new(1, -(padding * 2), 1, -(headerH + 10))
	listFrame.Position = UDim2.new(0, padding, 0, headerH + 8)
	listFrame.BackgroundTransparency = 1
	listFrame.ScrollBarThickness = 3
	listFrame.ScrollBarImageColor3 = COLORS.GoldDark
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.BorderSizePixel = 0
	listFrame.Parent = invFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, S(5))
	listLayout.Parent = listFrame

	if isMobile then
		-- Toggle button (top-left, visible when inventory closed)
		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Name = "InvToggle"
		toggleBtn.Size = UDim2.new(0, 52, 0, 52)
		toggleBtn.Position = UDim2.new(0, 8, 0, 8)
		toggleBtn.BackgroundColor3 = COLORS.BgDark
		toggleBtn.BackgroundTransparency = 0.12
		toggleBtn.TextColor3 = COLORS.GoldMuted
		toggleBtn.Font = FONTS.Title
		toggleBtn.TextSize = 20
		toggleBtn.Text = "SAC"
		toggleBtn.AutoButtonColor = false
		toggleBtn.Parent = parent
		addCorner(toggleBtn, 10)
		addStroke(toggleBtn, COLORS.GoldDark, 1, 0.3)

		toggleBtn.MouseButton1Click:Connect(function()
			self:ToggleInventory()
		end)

		-- Close button inside the inventory panel
		local closeBtn = Instance.new("TextButton")
		closeBtn.Name = "CloseBtn"
		closeBtn.Size = UDim2.new(0, 48, 0, 48)
		closeBtn.Position = UDim2.new(1, -54, 0, 4)
		closeBtn.BackgroundColor3 = Color3.fromRGB(65, 28, 25)
		closeBtn.TextColor3 = COLORS.TextWhite
		closeBtn.Font = FONTS.Header
		closeBtn.TextSize = 22
		closeBtn.Text = "X"
		closeBtn.AutoButtonColor = false
		closeBtn.Parent = invFrame
		addCorner(closeBtn, 22)

		closeBtn.MouseButton1Click:Connect(function()
			self:ToggleInventory()
		end)
	end
end

-- ═══════════════════════════════════════════
-- ACTION BAR — RPG Soulslike (bottom center)
-- ═══════════════════════════════════════════
local TOOL_ORDER = {"Batee", "Tapis", "Pioche"}
local TOOL_ICONS = {Batee = "◎", Tapis = "▤", Pioche = "⚒"}
local TOOL_KEYBINDS = {"1", "2", "3"}

function UIManager:CreateToolBar(parent)
	local slotSize, slotGap, infoW
	if isMobile then
		slotSize = 50 -- raw px, no S() — guaranteed touch target
		slotGap = 6
		infoW = 0
	else
		slotSize = S(64)
		slotGap = S(8)
		infoW = S(200)
	end
	local slotsW = 3 * slotSize + 2 * slotGap
	local barW = isMobile and (slotsW + S(16)) or (slotsW + slotGap + infoW + S(20))
	local barH = isMobile and (slotSize + S(12)) or (slotSize + S(16))

	local toolBar = Instance.new("Frame")
	toolBar.Name = "ToolBar"
	toolBar.Size = UDim2.new(0, barW, 0, barH)
	if isMobile then
		-- Mobile: top-right, below cash (cash is ~44px + 12 margin)
		toolBar.AnchorPoint = Vector2.new(1, 0)
		toolBar.Position = UDim2.new(1, -10, 0, 60)
	else
		-- Desktop: bottom-center, wide with info panel
		toolBar.AnchorPoint = Vector2.new(0.5, 1)
		toolBar.Position = UDim2.new(0.5, 0, 1, -12)
	end
	toolBar.BackgroundColor3 = COLORS.BgDark
	toolBar.BackgroundTransparency = 0.12
	toolBar.Parent = parent
	addCorner(toolBar, 8)
	addStroke(toolBar, COLORS.GoldDark, 1, 0.35)

	-- 3 Tool Slots (left side)
	local slotsY = S(8)
	for i, toolName in ipairs(TOOL_ORDER) do
		local slotX = S(10) + (i - 1) * (slotSize + slotGap)

		local slot = Instance.new("TextButton")
		slot.Name = `Slot_{toolName}`
		slot.Size = UDim2.new(0, slotSize, 0, slotSize)
		slot.Position = UDim2.new(0, slotX, 0, slotsY)
		slot.BackgroundColor3 = COLORS.BgRow
		slot.BackgroundTransparency = 0.3
		slot.Text = ""
		slot.AutoButtonColor = false
		slot.Parent = toolBar
		addCorner(slot, 6)
		addStroke(slot, COLORS.GoldDark, 1, 0.5)

		-- Tool icon
		local icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(1, 0, 0.65, 0)
		icon.Position = UDim2.new(0, 0, 0, 0)
		icon.BackgroundTransparency = 1
		icon.TextColor3 = COLORS.TextDim
		icon.Font = FONTS.Header
		icon.TextSize = isMobile and 22 or S(26)
		icon.Text = TOOL_ICONS[toolName] or "?"
		icon.Parent = slot

		-- Keybind label (desktop only)
		if not isMobile then
			local kb = Instance.new("TextLabel")
			kb.Name = "Keybind"
			kb.Size = UDim2.new(0, 14, 0, 14)
			kb.Position = UDim2.new(0, 3, 0, 3)
			kb.BackgroundColor3 = COLORS.BgDark
			kb.BackgroundTransparency = 0.3
			kb.TextColor3 = COLORS.TextDim
			kb.Font = FONTS.Small
			kb.TextSize = 10
			kb.Text = TOOL_KEYBINDS[i]
			kb.ZIndex = 3
			kb.Parent = slot
			addCorner(kb, 3)
		end

		-- Lock icon (shown for unowned tools)
		local lock = Instance.new("TextLabel")
		lock.Name = "Lock"
		lock.Size = UDim2.new(1, 0, 0.35, 0)
		lock.Position = UDim2.new(0, 0, 0.65, 0)
		lock.BackgroundTransparency = 1
		lock.TextColor3 = COLORS.TextDim
		lock.Font = FONTS.Small
		lock.TextSize = isMobile and 13 or S(9)
		lock.Text = "🔒"
		lock.Visible = false
		lock.Parent = slot

		-- Level text (shown for owned tools)
		local lvl = Instance.new("TextLabel")
		lvl.Name = "Level"
		lvl.Size = UDim2.new(1, 0, 0.3, 0)
		lvl.Position = UDim2.new(0, 0, 0.7, 0)
		lvl.BackgroundTransparency = 1
		lvl.TextColor3 = COLORS.TextGray
		lvl.Font = FONTS.Small
		lvl.TextSize = isMobile and 12 or S(9)
		lvl.Text = ""
		lvl.Parent = slot

		-- Click to equip
		slot.MouseButton1Click:Connect(function()
			local data = PlayerData
			if not data or not data.Tools then return end
			local toolInfo = data.Tools[toolName]
			if toolInfo and toolInfo.Owned then
				-- Equip this tool
				local character = player.Character
				if not character then return end
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if not humanoid then return end
				local backpack = player.Backpack
				local tool = backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
				if tool and tool:IsA("Tool") then
					humanoid:EquipTool(tool)
					haptic(0.2)
				end
			end
		end)
	end

	-- Right side: Level + XP bar + Buff (desktop only)
	if not isMobile then
		local infoX = slotsW + slotGap + S(16)

		local levelLabel = Instance.new("TextLabel")
		levelLabel.Name = "LevelLabel"
		levelLabel.Size = UDim2.new(0, infoW, 0, S(18))
		levelLabel.Position = UDim2.new(0, infoX, 0, slotsY)
		levelLabel.BackgroundTransparency = 1
		levelLabel.TextColor3 = COLORS.TextWhite
		levelLabel.Font = FONTS.Header
		levelLabel.TextSize = S(17)
		levelLabel.TextXAlignment = Enum.TextXAlignment.Left
		levelLabel.Text = "Niv. 1 — Amateur"
		levelLabel.TextTruncate = Enum.TextTruncate.AtEnd
		levelLabel.Parent = toolBar

		local xpBarY = slotsY + S(20)
		local xpBarBg = Instance.new("Frame")
		xpBarBg.Name = "XPBarBg"
		xpBarBg.Size = UDim2.new(0, infoW, 0, S(6))
		xpBarBg.Position = UDim2.new(0, infoX, 0, xpBarY)
		xpBarBg.BackgroundColor3 = Color3.fromRGB(12, 10, 8)
		xpBarBg.Parent = toolBar
		addCorner(xpBarBg, 3)

		local xpBarFill = Instance.new("Frame")
		xpBarFill.Name = "XPBarFill"
		xpBarFill.Size = UDim2.new(0, 0, 1, 0)
		xpBarFill.BackgroundColor3 = COLORS.GoldDark
		xpBarFill.Parent = xpBarBg
		addCorner(xpBarFill, 3)

		local xpText = Instance.new("TextLabel")
		xpText.Name = "XPText"
		xpText.Size = UDim2.new(0, infoW, 0, S(12))
		xpText.Position = UDim2.new(0, infoX, 0, xpBarY + S(8))
		xpText.BackgroundTransparency = 1
		xpText.TextColor3 = COLORS.TextDim
		xpText.Font = FONTS.Small
		xpText.TextSize = S(10)
		xpText.TextXAlignment = Enum.TextXAlignment.Left
		xpText.Text = "0 / 500 XP"
		xpText.Parent = toolBar

		local buffLabel = Instance.new("TextLabel")
		buffLabel.Name = "BuffLabel"
		buffLabel.Size = UDim2.new(0, infoW, 0, S(14))
		buffLabel.Position = UDim2.new(0, infoX, 0, xpBarY + S(22))
		buffLabel.BackgroundTransparency = 1
		buffLabel.TextColor3 = COLORS.Gold
		buffLabel.Font = FONTS.Small
		buffLabel.TextSize = S(11)
		buffLabel.TextXAlignment = Enum.TextXAlignment.Left
		buffLabel.Text = ""
		buffLabel.Visible = false
		buffLabel.Parent = toolBar
	end

	-- Keybinds 1-2-3 to equip tools (desktop)
	if not isMobile then
		UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			local idx = nil
			if input.KeyCode == Enum.KeyCode.One then idx = 1
			elseif input.KeyCode == Enum.KeyCode.Two then idx = 2
			elseif input.KeyCode == Enum.KeyCode.Three then idx = 3
			end
			if not idx then return end

			local toolName = TOOL_ORDER[idx]
			if not PlayerData or not PlayerData.Tools then return end
			local toolInfo = PlayerData.Tools[toolName]
			if not toolInfo or not toolInfo.Owned then return end

			local character = player.Character
			if not character then return end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then return end
			local tool = player.Backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
			if tool and tool:IsA("Tool") then
				humanoid:EquipTool(tool)
				haptic(0.2)
			end
		end)
	end
end

-- ═══════════════════════════════════════════
-- NOTIFICATION CONTAINER
-- ═══════════════════════════════════════════
function UIManager:CreateNotificationContainer(parent)
	local notifW = isMobile and S(360) or S(450)

	local container = Instance.new("Frame")
	container.Name = "NotifContainer"
	container.Size = UDim2.new(0, notifW, 0, 200)
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.Position = UDim2.new(0.5, 0, 0, isMobile and 130 or 10)
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
-- MINIMAP — Circular, western-styled
-- ═══════════════════════════════════════════
local MINIMAP_LOCATIONS = {
	{name = "Dusthaven", x = 0, z = -200, color = Color3.fromRGB(195, 165, 85), size = 7, label = true},
	{name = "Cabane", x = -450, z = -450, color = Color3.fromRGB(160, 140, 100), size = 5, label = true},
	{name = "Z1", x = -100, z = -50, color = Color3.fromRGB(85, 170, 85), size = 6, label = true},
	{name = "Z2", x = -350, z = 200, color = Color3.fromRGB(70, 130, 215), size = 6, label = true},
	{name = "Z3", x = 300, z = 150, color = Color3.fromRGB(155, 70, 215), size = 6, label = true},
	{name = "Pont", x = -190, z = -380, color = Color3.fromRGB(120, 100, 70), size = 4, label = false},
}

function UIManager:CreateMinimap(parent)
	local RunService = game:GetService("RunService")
	local mapSize = isMobile and 110 or 150
	local mapRadius = mapSize / 2
	local worldStud = 1200
	local worldPx = mapSize * 1.6
	local pxPerStud = worldPx / worldStud

	-- Outer ring (decorative)
	local outerRing = Instance.new("Frame")
	outerRing.Name = "MinimapOuter"
	outerRing.Size = UDim2.new(0, mapSize + 8, 0, mapSize + 8)
	outerRing.Position = UDim2.new(0, 8, 0, 8)
	outerRing.BackgroundTransparency = 1
	outerRing.Parent = parent
	addCorner(outerRing, (mapSize + 8) / 2)
	addStroke(outerRing, COLORS.GoldDark, 1.5, 0.3)

	-- Main container (circular, clips content)
	local container = Instance.new("Frame")
	container.Name = "Minimap"
	container.Size = UDim2.new(0, mapSize, 0, mapSize)
	container.Position = UDim2.new(0, 12, 0, 12)
	container.BackgroundColor3 = Color3.fromRGB(12, 10, 8)
	container.BackgroundTransparency = 0.1
	container.ClipsDescendants = true
	container.Parent = parent
	addCorner(container, mapSize / 2)
	addStroke(container, COLORS.Gold, 2, 0.15)

	-- Subtle vignette (inner shadow ring)
	local vignette = Instance.new("Frame")
	vignette.Name = "Vignette"
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.BackgroundColor3 = Color3.new(0, 0, 0)
	vignette.BackgroundTransparency = 0.85
	vignette.ZIndex = 4
	vignette.Parent = container
	addCorner(vignette, mapSize / 2)

	-- World frame (moves to track player)
	local worldFrame = Instance.new("Frame")
	worldFrame.Name = "World"
	worldFrame.Size = UDim2.new(0, worldPx, 0, worldPx)
	worldFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	worldFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	worldFrame.BackgroundTransparency = 1
	worldFrame.Parent = container

	-- Grid lines (subtle cross at center of world)
	for i = 1, 2 do
		local line = Instance.new("Frame")
		line.Size = if i == 1
			then UDim2.new(1, 0, 0, 1)
			else UDim2.new(0, 1, 1, 0)
		line.Position = UDim2.new(0.5, 0, 0.5, 0)
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.BackgroundColor3 = COLORS.TextDim
		line.BackgroundTransparency = 0.85
		line.BorderSizePixel = 0
		line.Parent = worldFrame
	end

	-- Location markers
	for _, loc in ipairs(MINIMAP_LOCATIONS) do
		local markerX = (loc.x + 600) / worldStud
		local markerZ = (loc.z + 600) / worldStud

		local marker = Instance.new("Frame")
		marker.Name = `Marker_{loc.name}`
		marker.Size = UDim2.new(0, loc.size, 0, loc.size)
		marker.AnchorPoint = Vector2.new(0.5, 0.5)
		marker.Position = UDim2.new(markerX, 0, markerZ, 0)
		marker.BackgroundColor3 = loc.color
		marker.BorderSizePixel = 0
		marker.ZIndex = 3
		marker.Parent = worldFrame
		addCorner(marker, loc.size / 2)

		if loc.label then
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0, 50, 0, 10)
			label.Position = UDim2.new(0.5, 0, 1, 2)
			label.AnchorPoint = Vector2.new(0.5, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = loc.color
			label.Font = FONTS.Small
			label.TextSize = isMobile and 7 or 8
			label.Text = loc.name
			label.ZIndex = 3
			label.Parent = marker
		end
	end

	-- Player indicator (gold diamond, always at center)
	local playerDot = Instance.new("Frame")
	playerDot.Name = "PlayerDot"
	playerDot.Size = UDim2.new(0, 8, 0, 8)
	playerDot.AnchorPoint = Vector2.new(0.5, 0.5)
	playerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
	playerDot.BackgroundColor3 = COLORS.Gold
	playerDot.Rotation = 45
	playerDot.BorderSizePixel = 0
	playerDot.ZIndex = 5
	playerDot.Parent = container

	-- Player glow
	local playerGlow = Instance.new("Frame")
	playerGlow.Size = UDim2.new(0, 14, 0, 14)
	playerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	playerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	playerGlow.BackgroundColor3 = COLORS.Gold
	playerGlow.BackgroundTransparency = 0.7
	playerGlow.Rotation = 45
	playerGlow.BorderSizePixel = 0
	playerGlow.ZIndex = 4
	playerGlow.Parent = container

	-- Compass N
	local compass = Instance.new("TextLabel")
	compass.Name = "Compass"
	compass.Size = UDim2.new(0, 16, 0, 12)
	compass.Position = UDim2.new(0.5, -8, 0, 3)
	compass.BackgroundTransparency = 1
	compass.TextColor3 = COLORS.Gold
	compass.Font = FONTS.Header
	compass.TextSize = isMobile and 9 or 10
	compass.Text = "N"
	compass.ZIndex = 6
	compass.Parent = container

	-- Zone name display (below minimap)
	local zoneName = Instance.new("TextLabel")
	zoneName.Name = "ZoneName"
	zoneName.Size = UDim2.new(0, mapSize + 8, 0, 16)
	zoneName.Position = UDim2.new(0, 8, 0, mapSize + 22)
	zoneName.BackgroundTransparency = 1
	zoneName.TextColor3 = COLORS.TextGray
	zoneName.Font = FONTS.Small
	zoneName.TextSize = isMobile and 10 or 11
	zoneName.TextXAlignment = Enum.TextXAlignment.Center
	zoneName.Text = ""
	zoneName.Parent = parent

	-- Update loop
	local frameCount = 0
	RunService.Heartbeat:Connect(function()
		frameCount += 1
		if frameCount % 2 ~= 0 then return end -- update every other frame

		local character = player.Character
		if not character then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local px = hrp.Position.X
		local pz = hrp.Position.Z

		-- Move world frame so player appears at center
		local playerScaleX = (px + 600) / worldStud
		local playerScaleZ = (pz + 600) / worldStud
		worldFrame.Position = UDim2.new(
			0.5 - playerScaleX + 0.5, 0,
			0.5 - playerScaleZ + 0.5, 0
		)

		-- Rotate player dot to face camera direction
		local cam = workspace.CurrentCamera
		if cam then
			local lookVector = cam.CFrame.LookVector
			local angle = math.deg(math.atan2(lookVector.X, -lookVector.Z))
			playerDot.Rotation = angle + 45
		end

		-- Update zone name (every ~30 frames)
		if frameCount % 30 == 0 then
			local closest = nil
			local closestDist = 999999
			for _, loc in ipairs(MINIMAP_LOCATIONS) do
				local dist = math.sqrt((px - loc.x)^2 + (pz - loc.z)^2)
				if dist < closestDist then
					closestDist = dist
					closest = loc
				end
			end
			if closest and closestDist < 300 then
				zoneName.Text = closest.name
			else
				zoneName.Text = ""
			end
		end
	end)
end

-- ═══════════════════════════════════════════
-- REFRESH HUD
-- ═══════════════════════════════════════════
function UIManager:RefreshHUD()
	if not PlayerData then return end

	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end

	-- Cash (TopBar)
	local topBar = mainHUD:FindFirstChild("TopBar")
	if topBar then
		local cashLabel = topBar:FindFirstChild("CashLabel")
		if cashLabel then
			local cash = PlayerData.Cash or 0
			local formatted = tostring(cash)
			if cash >= 1000000 then
				formatted = string.format("%d,%03d,%03d", math.floor(cash / 1000000), math.floor(cash / 1000) % 1000, cash % 1000)
			elseif cash >= 1000 then
				formatted = string.format("%d,%03d", math.floor(cash / 1000), cash % 1000)
			end
			cashLabel.Text = formatted
		end
	end

	if inventoryOpen then
		self:RefreshInventory(mainHUD)
	end
	self:RefreshToolBar(mainHUD)
end

-- ═══════════════════════════════════════════
-- REFRESH INVENTORY — Grid
-- ═══════════════════════════════════════════
function UIManager:RefreshInventory(mainHUD)
	if not PlayerData or not PlayerData.Inventory then return end

	local invFrame = mainHUD:FindFirstChild("InventoryFrame")
	if not invFrame then return end

	local listFrame = invFrame:FindFirstChild("ItemList")
	if not listFrame then return end

	for _, child in listFrame:GetChildren() do
		if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
	end

	local order = {"Paillettes", "Pepites", "OrPur", "MineraiOr", "Lingots", "Quartz", "Amethyste", "Topaze", "Diamant"}
	local layoutOrder = 0
	local rowH = isMobile and 48 or S(36)

	for _, key in ipairs(order) do
		local qty = PlayerData.Inventory[key] or 0
		if qty > 0 then
			layoutOrder += 1

			local row = Instance.new("Frame")
			row.Name = key
			row.Size = UDim2.new(1, -4, 0, rowH)
			row.BackgroundColor3 = COLORS.BgRow
			row.BackgroundTransparency = 0.3
			row.LayoutOrder = layoutOrder
			row.Parent = listFrame
			addCorner(row, 5)

			-- Rarity accent bar (left)
			local accent = Instance.new("Frame")
			accent.Size = UDim2.new(0, 3, 0.65, 0)
			accent.Position = UDim2.new(0, 3, 0.175, 0)
			accent.BackgroundColor3 = getRarityColor(key)
			accent.BorderSizePixel = 0
			accent.Parent = row
			addCorner(accent, 2)

			-- Item name
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.65, -14, 1, 0)
			nameLabel.Position = UDim2.new(0, 12, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.TextColor3 = COLORS.TextWhite
			nameLabel.Font = FONTS.Body
			nameLabel.TextSize = isMobile and 16 or S(15)
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.Text = ITEM_DISPLAY[key] or key
			nameLabel.Parent = row

			-- Quantity (right)
			local qtyLabel = Instance.new("TextLabel")
			qtyLabel.Size = UDim2.new(0.35, -8, 1, 0)
			qtyLabel.Position = UDim2.new(0.65, 0, 0, 0)
			qtyLabel.BackgroundTransparency = 1
			qtyLabel.TextColor3 = getRarityColor(key)
			qtyLabel.Font = FONTS.Number
			qtyLabel.TextSize = isMobile and 16 or S(15)
			qtyLabel.TextXAlignment = Enum.TextXAlignment.Right
			qtyLabel.Text = `x{qty}`
			qtyLabel.Parent = row
			addPadding(qtyLabel, 0, 8, 0, 0)

			-- Hover
			row.MouseEnter:Connect(function()
				tweenProperty(row, {BackgroundTransparency = 0.1}, 0.1)
			end)
			row.MouseLeave:Connect(function()
				tweenProperty(row, {BackgroundTransparency = 0.3}, 0.1)
			end)

			-- Right-click context menu (desktop)
			if not isMobile then
				local rowBtn = Instance.new("TextButton")
				rowBtn.Size = UDim2.new(1, 0, 1, 0)
				rowBtn.BackgroundTransparency = 1
				rowBtn.Text = ""
				rowBtn.AutoButtonColor = false
				rowBtn.ZIndex = 3
				rowBtn.Parent = row

				rowBtn.MouseButton2Click:Connect(function()
					self:ShowItemContextMenu(invFrame, row, key, qty)
				end)
			end
		end
	end
end

-- ═══════════════════════════════════════════
-- ITEM CONTEXT MENU (right-click, desktop)
-- ═══════════════════════════════════════════
local activeContextMenu = nil

function UIManager:ShowItemContextMenu(invFrame, cell, itemKey, qty)
	-- Destroy any existing context menu
	if activeContextMenu and activeContextMenu.Parent then
		activeContextMenu:Destroy()
	end

	local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
	local prices = EconomyConfig.SellPrices.MarchandLocal
	local price = prices[itemKey]

	local menuW = 140
	local menuH = price and 70 or 36
	local menu = Instance.new("Frame")
	menu.Name = "ContextMenu"
	menu.Size = UDim2.new(0, menuW, 0, menuH)
	menu.BackgroundColor3 = COLORS.BgPanel
	menu.BackgroundTransparency = 0.05
	menu.ZIndex = 20
	menu.Parent = invFrame
	addCorner(menu, 6)
	addStroke(menu, COLORS.GoldDark, 1, 0.2)
	activeContextMenu = menu

	-- Position relative to cell
	local relX = cell.AbsolutePosition.X - invFrame.AbsolutePosition.X + cell.AbsoluteSize.X + 4
	local relY = cell.AbsolutePosition.Y - invFrame.AbsolutePosition.Y
	menu.Position = UDim2.new(0, relX, 0, relY)

	-- Item info row
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -8, 0, 30)
	infoLabel.Position = UDim2.new(0, 4, 0, 2)
	infoLabel.BackgroundTransparency = 1
	infoLabel.TextColor3 = getRarityColor(itemKey)
	infoLabel.Font = FONTS.Header
	infoLabel.TextSize = 14
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.Text = `{ITEM_ICONS[itemKey] or "·"} {ITEM_DISPLAY[itemKey] or itemKey} x{qty}`
	infoLabel.ZIndex = 21
	infoLabel.Parent = menu

	-- Sell button (if sellable)
	if price then
		local sellBtn = Instance.new("TextButton")
		sellBtn.Size = UDim2.new(1, -8, 0, 28)
		sellBtn.Position = UDim2.new(0, 4, 0, 34)
		sellBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 50)
		sellBtn.TextColor3 = COLORS.TextWhite
		sellBtn.Font = FONTS.Header
		sellBtn.TextSize = 13
		sellBtn.Text = `Vendre tout ({qty * price}$)`
		sellBtn.AutoButtonColor = false
		sellBtn.ZIndex = 21
		sellBtn.Parent = menu
		addCorner(sellBtn, 5)

		sellBtn.MouseEnter:Connect(function()
			tweenProperty(sellBtn, {BackgroundColor3 = Color3.fromRGB(65, 140, 65)}, 0.1)
		end)
		sellBtn.MouseLeave:Connect(function()
			tweenProperty(sellBtn, {BackgroundColor3 = Color3.fromRGB(50, 110, 50)}, 0.1)
		end)
		sellBtn.MouseButton1Click:Connect(function()
			Events.RequestSell:FireServer("MarchandLocal", itemKey, qty)
			if activeContextMenu then activeContextMenu:Destroy() end
		end)
	end

	-- Close on click outside (next frame)
	task.defer(function()
		local conn
		conn = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2 then
				task.defer(function()
					if activeContextMenu and activeContextMenu.Parent then
						activeContextMenu:Destroy()
						activeContextMenu = nil
					end
					if conn then conn:Disconnect() end
				end)
			end
		end)
	end)
end

-- ═══════════════════════════════════════════
-- REFRESH TOOLBAR
-- ═══════════════════════════════════════════
function UIManager:RefreshToolBar(mainHUD)
	if not PlayerData then return end

	local toolBar = mainHUD:FindFirstChild("ToolBar")
	if not toolBar then return end

	local ToolConfig = require(ReplicatedStorage.Modules.Config.ToolConfig)

	-- Find currently equipped tool
	local equippedTool = nil
	local character = player.Character
	if character then
		local tool = character:FindFirstChildOfClass("Tool")
		if tool then equippedTool = tool.Name end
	end

	-- Update each slot
	for _, toolName in ipairs(TOOL_ORDER) do
		local slot = toolBar:FindFirstChild(`Slot_{toolName}`)
		if not slot then continue end

		local toolInfo = PlayerData.Tools and PlayerData.Tools[toolName]
		local owned = toolInfo and toolInfo.Owned
		local level = toolInfo and toolInfo.Level or 0
		local toolData = ToolConfig.Tools[toolName]
		local maxLevel = toolData and #toolData.Levels or 3

		local icon = slot:FindFirstChild("Icon")
		local lock = slot:FindFirstChild("Lock")
		local lvl = slot:FindFirstChild("Level")
		local stroke = slot:FindFirstChildOfClass("UIStroke")

		if owned then
			-- Owned: show icon in color, level text
			if icon then icon.TextColor3 = COLORS.TextWhite end
			if lock then lock.Visible = false end
			if lvl then
				lvl.Text = `Niv.{level}/{maxLevel}`
				lvl.Visible = true
			end
			-- Active highlight
			if equippedTool == toolName then
				if stroke then
					stroke.Color = COLORS.Gold
					stroke.Transparency = 0
				end
				slot.BackgroundTransparency = 0.1
			else
				if stroke then
					stroke.Color = COLORS.GoldDark
					stroke.Transparency = 0.5
				end
				slot.BackgroundTransparency = 0.3
			end
		else
			-- Not owned: greyed out + lock
			if icon then icon.TextColor3 = COLORS.TextDim end
			if lock then lock.Visible = true end
			if lvl then lvl.Visible = false end
			if stroke then
				stroke.Color = COLORS.TextDim
				stroke.Transparency = 0.7
			end
			slot.BackgroundTransparency = 0.5
		end
	end

	-- Update level + XP
	local level = PlayerData.Level or 1
	local xp = PlayerData.XP or 0
	local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
	local levelInfo = EconomyConfig.LevelThresholds[level]
	local levelName = levelInfo and levelInfo.Name or "Amateur"
	local maxXP = levelInfo and levelInfo.MaxXP or 500
	local minXP = levelInfo and levelInfo.MinXP or 0

	local levelLabel = toolBar:FindFirstChild("LevelLabel")
	if levelLabel then levelLabel.Text = `Niv. {level} — {levelName}` end

	local xpBarBg = toolBar:FindFirstChild("XPBarBg")
	if xpBarBg then
		local xpBarFill = xpBarBg:FindFirstChild("XPBarFill")
		local xpInLevel = xp - minXP
		local xpNeeded = math.max(maxXP - minXP, 1)
		local ratio = math.clamp(xpInLevel / xpNeeded, 0, 1)
		if xpBarFill then
			tweenProperty(xpBarFill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.5)
		end
	end

	local xpText = toolBar:FindFirstChild("XPText")
	if xpText then xpText.Text = `{xp} / {maxXP} XP` end

	-- Update buff display
	local buffLabel = toolBar:FindFirstChild("BuffLabel")
	if buffLabel and PlayerData.Saloon then
		if PlayerData.Saloon.BuffActive and os.time() < (PlayerData.Saloon.BuffExpiry or 0) then
			local remaining = PlayerData.Saloon.BuffExpiry - os.time()
			local mins = math.floor(remaining / 60)
			local secs = remaining % 60
			local buffName = PlayerData.Saloon.BuffActive == "SpeedBoost" and "Vitesse" or "Chance"
			buffLabel.Text = `⚡ {buffName} {mins}:{string.format("%02d", secs)}`
			buffLabel.Visible = true
		else
			buffLabel.Visible = false
		end
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
	local cashDelta = topBar:FindFirstChild("CashDelta")
	if not cashDelta then return end

	local sign = delta > 0 and "+" or ""
	cashDelta.Text = `{sign}{delta}$`
	cashDelta.TextColor3 = delta > 0 and COLORS.Success or COLORS.Error
	cashDelta.TextTransparency = 0

	local startX = cashDelta.Position.X.Offset
	cashDelta.Position = UDim2.new(0, startX, 0, -4)

	tweenProperty(cashDelta, {
		Position = UDim2.new(0, startX, 0, -18),
		TextTransparency = 1,
	}, 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end

-- ═══════════════════════════════════════════
-- NOTIFICATION
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
	local accentColor = colorMap[notifType] or COLORS.Info

	local notifH = isMobile and S(56) or S(46)
	local notif = Instance.new("Frame")
	notif.Name = "Notification"
	notif.Size = UDim2.new(1, 0, 0, notifH)
	notif.BackgroundColor3 = COLORS.BgDark
	notif.BackgroundTransparency = 0.05
	notif.LayoutOrder = os.clock() * 1000
	notif.Parent = container
	addCorner(notif, 8)
	addStroke(notif, accentColor, 1, 0.4)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 4, 0.6, 0)
	accent.Position = UDim2.new(0, 5, 0.2, 0)
	accent.BackgroundColor3 = accentColor
	accent.BorderSizePixel = 0
	accent.Parent = notif
	addCorner(accent, 2)

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -24, 1, 0)
	msgLabel.Position = UDim2.new(0, 18, 0, 0)
	msgLabel.BackgroundTransparency = 1
	msgLabel.TextColor3 = COLORS.TextWhite
	msgLabel.Font = FONTS.Header
	msgLabel.TextSize = isMobile and S(17) or S(19)
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.TextTruncate = Enum.TextTruncate.AtEnd
	msgLabel.Text = message
	msgLabel.Parent = notif

	notif.Position = UDim2.new(0, 20, 0, 0)
	notif.BackgroundTransparency = 1
	tweenProperty(notif, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.08}, 0.25)

	task.spawn(function()
		task.wait(3.5)
		tweenProperty(notif, {BackgroundTransparency = 1, Position = UDim2.new(0, -15, 0, 0)}, 0.4)
		tweenProperty(msgLabel, {TextTransparency = 1}, 0.4)
		task.wait(0.5)
		notif:Destroy()
	end)
end

-- ═══════════════════════════════════════════
-- LEVEL UP — Subtle edge glow + notification
-- ═══════════════════════════════════════════
function UIManager:ShowLevelUp(level, levelName)
	haptic(0.8)
	self:ShowNotification(`Niveau {level} — {levelName}`, "LevelUp")

	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end

	local glow = Instance.new("Frame")
	glow.Name = "LevelGlow"
	glow.Size = UDim2.new(1, 0, 1, 0)
	glow.BackgroundColor3 = COLORS.Gold
	glow.BackgroundTransparency = 0.7
	glow.ZIndex = 10
	glow.Parent = mainHUD

	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.12, 1),
		NumberSequenceKeypoint.new(0.88, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	gradient.Parent = glow

	tweenProperty(glow, {BackgroundTransparency = 1}, 2, Enum.EasingStyle.Sine)
	task.delay(2.2, function() glow:Destroy() end)
end

-- ═══════════════════════════════════════════
-- FLOATING TEXT
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
	label.Font = FONTS.Number
	label.TextSize = 14
	label.TextStrokeColor3 = Color3.fromRGB(20, 15, 8)
	label.TextStrokeTransparency = 0.3
	label.Text = text
	label.Parent = billboardGui

	tweenProperty(label, {TextSize = isMobile and 18 or 20}, 0.15, Enum.EasingStyle.Quad)

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
-- LOOT FEED
-- ═══════════════════════════════════════════
function UIManager:ShowLootFeed(drops, xpGained)
	haptic(0.4)
	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end

	-- WoW-style: each item floats up from center and fades out
	local order = 0
	local centerY = 0.35

	if type(drops) == "table" then
		for itemName, qty in pairs(drops) do
			order += 1
			local label = Instance.new("TextLabel")
			label.Name = "LootItem"
			label.Size = isMobile and UDim2.new(0.85, 0, 0, 40) or UDim2.new(0, 500, 0, 46)
			label.AnchorPoint = Vector2.new(0.5, 0.5)
			label.Position = UDim2.new(0.5, 0, centerY, 0)
			label.BackgroundColor3 = Color3.new(0, 0, 0)
			label.BackgroundTransparency = 0.55
			label.TextColor3 = getRarityColor(itemName)
			label.Font = FONTS.Title
			label.TextSize = isMobile and 24 or 36
			label.TextStrokeColor3 = Color3.new(0, 0, 0)
			label.TextStrokeTransparency = 0.1
			label.Text = `+{qty} {ITEM_DISPLAY[itemName] or itemName}`
			label.TextTransparency = 1
			label.ZIndex = 8
			label.Parent = mainHUD
			addCorner(label, 8)

			-- Stagger each item
			task.delay((order - 1) * 0.25, function()
				if not label.Parent then return end
				-- Pop in
				tweenProperty(label, {TextTransparency = 0, BackgroundTransparency = 0.55}, 0.15)
				-- Float up and fade over 2s
				task.wait(1)
				if not label.Parent then return end
				tweenProperty(label, {
					Position = UDim2.new(0.5, 0, centerY - 0.08, 0),
					TextTransparency = 1,
					TextStrokeTransparency = 1,
					BackgroundTransparency = 1,
				}, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				task.wait(1.3)
				if label.Parent then label:Destroy() end
			end)
		end
	end

	if xpGained and xpGained > 0 then
		order += 1
		local xpLabel = Instance.new("TextLabel")
		xpLabel.Name = "LootXP"
		xpLabel.Size = isMobile and UDim2.new(0.7, 0, 0, 32) or UDim2.new(0, 400, 0, 36)
		xpLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		xpLabel.Position = UDim2.new(0.5, 0, centerY + 0.03, 0)
		xpLabel.BackgroundTransparency = 1
		xpLabel.TextColor3 = COLORS.Gold
		xpLabel.Font = FONTS.Title
		xpLabel.TextSize = isMobile and 26 or 30
		xpLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		xpLabel.TextStrokeTransparency = 0.1
		xpLabel.Text = `+{xpGained} XP`
		xpLabel.TextTransparency = 1
		xpLabel.ZIndex = 8
		xpLabel.Parent = mainHUD

		task.delay(order * 0.25, function()
			if not xpLabel.Parent then return end
			tweenProperty(xpLabel, {TextTransparency = 0}, 0.15)
			task.wait(1)
			if not xpLabel.Parent then return end
			tweenProperty(xpLabel, {
				Position = UDim2.new(0.5, 0, centerY - 0.05, 0),
				TextTransparency = 1,
				TextStrokeTransparency = 1,
			}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.wait(1.1)
			if xpLabel.Parent then xpLabel:Destroy() end
		end)
	end
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
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.Speed = NumberRange.new(4, 8)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Rate = 0
	emitter.Parent = part
	emitter:Emit(15)

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
-- NPC DIALOGUE BUBBLE
-- ═══════════════════════════════════════════
local activeBubbles = {}

function UIManager:ShowNPCBubble(npcModel, text, duration)
	duration = duration or 3

	if activeBubbles[npcModel] then
		activeBubbles[npcModel]:Destroy()
		activeBubbles[npcModel] = nil
	end

	local head = npcModel:FindFirstChild("Head")
	if not head then return end

	local bubbleH = if #text > 40 then 78 else 62

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DialogueBubble"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 240, 0, bubbleH)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 40
	billboard.Parent = playerGui
	activeBubbles[npcModel] = billboard

	local bg = Instance.new("Frame")
	bg.Name = "BubbleBG"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = COLORS.BgDark
	bg.BackgroundTransparency = 0.08
	bg.Parent = billboard
	addCorner(bg, 8)
	addStroke(bg, COLORS.GoldDark, 1, 0.3)

	local tail = Instance.new("Frame")
	tail.Size = UDim2.new(0, 10, 0, 7)
	tail.Position = UDim2.new(0.5, -5, 1, -1)
	tail.Rotation = 45
	tail.BackgroundColor3 = COLORS.BgDark
	tail.BackgroundTransparency = 0.08
	tail.BorderSizePixel = 0
	tail.Parent = bg

	local npcName = npcModel:FindFirstChild("HumanoidRootPart")
		and npcModel.HumanoidRootPart:GetAttribute("NPCName") or npcModel.Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -14, 0, 15)
	nameLabel.Position = UDim2.new(0, 7, 0, 4)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = COLORS.Gold
	nameLabel.Font = FONTS.Header
	nameLabel.TextSize = 11
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = npcName
	nameLabel.Parent = bg

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -14, 1, -20)
	textLabel.Position = UDim2.new(0, 7, 0, 19)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = COLORS.TextWhite
	textLabel.Font = FONTS.Body
	textLabel.TextSize = 12
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.TextWrapped = true
	textLabel.Text = ""
	textLabel.Parent = bg

	task.spawn(function()
		for i = 1, #text do
			if not billboard.Parent then return end
			textLabel.Text = string.sub(text, 1, i)
			task.wait(0.025)
		end
	end)

	local targetSize = UDim2.new(0, 240, 0, bubbleH)
	billboard.Size = UDim2.new(0, 20, 0, 10)
	TweenService:Create(billboard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = targetSize,
	}):Play()

	task.delay(duration, function()
		if billboard and billboard.Parent then
			TweenService:Create(billboard, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 20, 0, 10),
			}):Play()
			task.delay(0.2, function()
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
-- EXPORTS
-- ═══════════════════════════════════════════
UIManager.COLORS = COLORS
UIManager.FONTS = FONTS
UIManager.ITEM_DISPLAY = ITEM_DISPLAY
UIManager.ITEM_ICONS = ITEM_ICONS
UIManager.ITEM_RARITY = ITEM_RARITY
UIManager.addCorner = addCorner
UIManager.addStroke = addStroke
UIManager.addGradient = addGradient
UIManager.addPadding = addPadding
UIManager.tweenProperty = tweenProperty
UIManager.getRarityColor = getRarityColor
UIManager.haptic = haptic

-- ═══════════════════════════════════════════
-- QUEST TRACKER PERMANENT (style WoW)
-- ═══════════════════════════════════════════
local questTrackerFrame = nil
local questTrackerEntries = {}

function UIManager:CreateQuestTracker()
	local mainHUD = playerGui:FindFirstChild("MainHUD")
	if not mainHUD then return end
	if questTrackerFrame then questTrackerFrame:Destroy() end

	questTrackerFrame = Instance.new("Frame")
	questTrackerFrame.Name = "QuestTracker"
	questTrackerFrame.Size = UDim2.new(0, isMobile and 180 or S(260), 0, isMobile and 160 or S(200))
	questTrackerFrame.AnchorPoint = Vector2.new(1, 0)
	questTrackerFrame.Position = UDim2.new(1, -10, 0, isMobile and 200 or S(80))
	questTrackerFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 5)
	questTrackerFrame.BackgroundTransparency = 0.3
	questTrackerFrame.BorderSizePixel = 0
	questTrackerFrame.Parent = mainHUD
	addCorner(questTrackerFrame, 6)
	addStroke(questTrackerFrame, Color3.fromRGB(100, 70, 30), 1)

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, S(24))
	title.BackgroundTransparency = 1
	title.Text = "QUETES"
	title.TextColor3 = Color3.fromRGB(232, 198, 90)
	title.Font = FONTS.Header
	title.TextSize = isMobile and 14 or S(13)
	title.Parent = questTrackerFrame

	-- Container for quest entries
	local container = Instance.new("Frame")
	container.Name = "Entries"
	container.Size = UDim2.new(1, -10, 1, -S(28))
	container.Position = UDim2.new(0, 5, 0, S(26))
	container.BackgroundTransparency = 1
	container.Parent = questTrackerFrame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.Parent = container

	-- Request quest data from server
	Events.RequestQuestData:FireServer()
end

function UIManager:UpdateQuestTracker(quests)
	if not questTrackerFrame then return end
	local container = questTrackerFrame:FindFirstChild("Entries")
	if not container then return end

	-- Clear old entries
	for _, child in container:GetChildren() do
		if child:IsA("Frame") then child:Destroy() end
	end

	if not quests or #quests == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, S(20))
		empty.BackgroundTransparency = 1
		empty.Text = "Aucune quete active"
		empty.TextColor3 = Color3.fromRGB(150, 130, 100)
		empty.Font = FONTS.Body
		empty.TextSize = isMobile and 14 or S(11)
		empty.Parent = container
		return
	end

	for i, quest in ipairs(quests) do
		local entry = Instance.new("Frame")
		entry.Name = "Quest_" .. i
		entry.Size = UDim2.new(1, 0, 0, S(40))
		entry.BackgroundTransparency = 1
		entry.LayoutOrder = i
		entry.Parent = container

		-- Quest title
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, 0, 0, S(16))
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = quest.Title or "Quete"
		titleLabel.TextColor3 = quest.Completed and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(220, 200, 160)
		titleLabel.Font = FONTS.Header
		titleLabel.TextSize = isMobile and 14 or S(11)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = entry

		-- Progress bar
		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.new(1, 0, 0, S(8))
		barBg.Position = UDim2.new(0, 0, 0, S(17))
		barBg.BackgroundColor3 = Color3.fromRGB(40, 30, 20)
		barBg.Parent = entry
		addCorner(barBg, 3)

		local progress = (quest.Progress or 0) / math.max(quest.Goal or 1, 1)
		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.new(math.min(progress, 1), 0, 1, 0)
		barFill.BackgroundColor3 = quest.Completed and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(232, 198, 90)
		barFill.Parent = barBg
		addCorner(barFill, 3)

		-- Progress text
		local progText = Instance.new("TextLabel")
		progText.Size = UDim2.new(1, 0, 0, S(12))
		progText.Position = UDim2.new(0, 0, 0, S(26))
		progText.BackgroundTransparency = 1
		progText.Text = quest.Completed and "Terminee !" or `{quest.Progress or 0}/{quest.Goal or "?"}`
		progText.TextColor3 = Color3.fromRGB(150, 130, 100)
		progText.Font = FONTS.Body
		progText.TextSize = isMobile and 13 or S(10)
		progText.TextXAlignment = Enum.TextXAlignment.Left
		progText.Parent = entry
	end
end

-- Connect quest events to tracker
Events.QuestDataResponse.OnClientEvent:Connect(function(quests)
	UIManager:UpdateQuestTracker(quests)
end)

Events.QuestCompleted.OnClientEvent:Connect(function()
	-- Refresh tracker
	Events.RequestQuestData:FireServer()
end)

Events.PlayerDataUpdated.OnClientEvent:Connect(function()
	-- Refresh quests on any data change (mining, selling, crafting)
	task.delay(0.5, function()
		Events.RequestQuestData:FireServer()
	end)
end)

-- ═══════════════════════════════════════════
-- STORY QUEST (main quest objective)
-- ═══════════════════════════════════════════
local currentStoryStep = nil

Events.StartTutorial.OnClientEvent:Connect(function(stepData)
	if type(stepData) == "table" then
		currentStoryStep = stepData
		if stepData.message then
			UIManager:ShowNotification(stepData.message, "Info")
		end
		UIManager:UpdateStoryInTracker()
	end
end)

function UIManager:UpdateStoryInTracker()
	if not questTrackerFrame then return end
	local container = questTrackerFrame:FindFirstChild("Entries")
	if not container then return end

	local oldStory = container:FindFirstChild("StoryQuest")
	if oldStory then oldStory:Destroy() end

	if not currentStoryStep or currentStoryStep.isFinal then return end

	local entry = Instance.new("Frame")
	entry.Name = "StoryQuest"
	entry.Size = UDim2.new(1, 0, 0, S(32))
	entry.BackgroundColor3 = Color3.fromRGB(40, 25, 10)
	entry.BackgroundTransparency = 0.3
	entry.LayoutOrder = -1
	entry.Parent = container
	addCorner(entry, 4)

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, S(20), 1, 0)
	icon.BackgroundTransparency = 1
	icon.Text = ">"
	icon.TextColor3 = Color3.fromRGB(255, 200, 50)
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = S(14)
	icon.Parent = entry

	local objective = Instance.new("TextLabel")
	objective.Size = UDim2.new(1, -S(24), 1, 0)
	objective.Position = UDim2.new(0, S(20), 0, 0)
	objective.BackgroundTransparency = 1
	objective.Text = currentStoryStep.objective or ""
	objective.TextColor3 = Color3.fromRGB(255, 220, 100)
	objective.Font = Enum.Font.GothamBold
	objective.TextSize = S(11)
	objective.TextXAlignment = Enum.TextXAlignment.Left
	objective.TextWrapped = true
	objective.Parent = entry
end

-- Create tracker after HUD is built
task.delay(2, function()
	UIManager:CreateQuestTracker()
end)

return UIManager
