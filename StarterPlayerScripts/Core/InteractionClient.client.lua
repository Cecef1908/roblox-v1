--[[
	InteractionClient.client.lua (LocalScript)
	ROLE : Gère les interactions avec les NPCs (achat, vente, craft, saloon).
	Crée les UI menus quand le joueur interagit avec un NPC.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Events = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvents")

local UIManager = require(script.Parent.UIManager)

-- Shared style helpers from UIManager
local COLORS = UIManager.COLORS
local addCorner = UIManager.addCorner
local addStroke = UIManager.addStroke
local addGradient = UIManager.addGradient
local addPadding = UIManager.addPadding
local tweenProperty = UIManager.tweenProperty
local FONTS = UIManager.FONTS
local ITEM_DISPLAY = UIManager.ITEM_DISPLAY

-- ═══════════════════════════════════════════
-- HELPERS — Panel creation
-- ═══════════════════════════════════════════
local activeGui = nil

local mobile = UIManager:IsMobile()

local function CloseActiveMenu()
	if not activeGui then return end

	local guiToClose = activeGui
	activeGui = nil

	UIManager:DismissAllBubbles()

	local bg = guiToClose:FindFirstChild("Background")
	local overlay = guiToClose:FindFirstChild("Overlay")

	if mobile and bg then
		-- Mobile: slide down
		tweenProperty(bg, { Position = UDim2.new(0.5, 0, 1, bg.Size.Y.Offset) }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	elseif bg then
		-- Desktop: fade out
		tweenProperty(bg, { BackgroundTransparency = 1 }, 0.2)
	end
	if overlay then
		tweenProperty(overlay, { BackgroundTransparency = 1 }, 0.15)
	end

	task.delay(0.3, function()
		if guiToClose and guiToClose.Parent then
			guiToClose:Destroy()
		end
	end)
end

-- Close panel with Escape key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Escape and activeGui then
		CloseActiveMenu()
	end
end)

local function CreateMenuPanel(name, title, width, height, accentColor)
	CloseActiveMenu()

	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 5
	pcall(function() gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
	gui.Parent = playerGui
	activeGui = gui

	local overlay = Instance.new("TextButton")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.BorderSizePixel = 0
	overlay.Parent = gui
	overlay.MouseButton1Click:Connect(CloseActiveMenu)

	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.BackgroundColor3 = COLORS.BgDark
	bg.Parent = gui

	if mobile then
		-- BOTTOM SHEET — slides up from bottom, full width
		local screenH = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y or 700
		local sheetH = math.min(height + 40, screenH * 0.75, 560)
		bg.AnchorPoint = Vector2.new(0.5, 1)
		bg.Size = UDim2.new(1, 0, 0, sheetH)
		bg.Position = UDim2.new(0.5, 0, 1, 0)
		addCorner(bg, 16)
		-- Only round top corners: clip bottom with a child frame
		bg.ClipsDescendants = true

		-- Swipe down to close
		pcall(function()
			local swipeConn
			swipeConn = UserInputService.TouchSwipe:Connect(function(direction, _, processed)
				if not processed and direction == Enum.SwipeDirection.Down and activeGui == gui then
					CloseActiveMenu()
				end
				if swipeConn then swipeConn:Disconnect() end
			end)
		end)

		-- Drag handle (visual indicator)
		local handle = Instance.new("Frame")
		handle.Name = "Handle"
		handle.Size = UDim2.new(0, 40, 0, 4)
		handle.Position = UDim2.new(0.5, -20, 0, 8)
		handle.BackgroundColor3 = COLORS.TextDim
		handle.BorderSizePixel = 0
		handle.Parent = bg
		addCorner(handle, 2)
	else
		-- DESKTOP — centered modal
		bg.AnchorPoint = Vector2.new(0.5, 0.5)
		bg.Position = UDim2.new(0.5, 0, 0.5, 0)
		bg.Size = UDim2.new(0, width, 0, height)
		addCorner(bg, 12)
	end

	addStroke(bg, accentColor or COLORS.GoldDark, mobile and 1 or 2, 0.1)
	addGradient(bg, Color3.fromRGB(40, 32, 24), COLORS.BgDark)

	local headerH = mobile and 52 or 54
	local headerY = mobile and 16 or 0
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, headerH)
	header.Position = UDim2.new(0, 0, 0, headerY)
	header.BackgroundColor3 = COLORS.BgPanel
	header.BackgroundTransparency = 0.5
	header.Parent = bg
	addCorner(header, 12)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -54, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = accentColor or COLORS.Gold
	titleLabel.Font = FONTS.Title
	titleLabel.TextSize = mobile and 22 or 24
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.Text = title
	titleLabel.Parent = header

	-- Close button
	local closeBtnSize = mobile and 48 or 32
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, closeBtnSize, 0, closeBtnSize)
	closeBtn.Position = UDim2.new(1, -(closeBtnSize + 8), 0.5, -closeBtnSize/2)
	closeBtn.BackgroundColor3 = Color3.fromRGB(65, 28, 25)
	closeBtn.TextColor3 = COLORS.TextWhite
	closeBtn.Font = FONTS.Header
	closeBtn.TextSize = mobile and 22 or 18
	closeBtn.Text = "✕"
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	addCorner(closeBtn, closeBtnSize/2)

	closeBtn.MouseButton1Click:Connect(CloseActiveMenu)
	closeBtn.MouseEnter:Connect(function()
		tweenProperty(closeBtn, {BackgroundColor3 = Color3.fromRGB(130, 45, 40)}, 0.15)
	end)
	closeBtn.MouseLeave:Connect(function()
		tweenProperty(closeBtn, {BackgroundColor3 = Color3.fromRGB(65, 28, 25)}, 0.15)
	end)

	local sep = Instance.new("Frame")
	sep.Size = UDim2.new(0.9, 0, 0, 1)
	sep.Position = UDim2.new(0.05, 0, 0, headerY + headerH + 2)
	sep.BackgroundColor3 = accentColor or COLORS.GoldDark
	sep.BackgroundTransparency = 0.5
	sep.BorderSizePixel = 0
	sep.Parent = bg

	local content = Instance.new("ScrollingFrame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -16, 1, -(headerY + headerH + 14))
	content.Position = UDim2.new(0, 8, 0, headerY + headerH + 8)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = mobile and 5 or 3
	content.ScrollBarImageColor3 = COLORS.GoldDark
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.BorderSizePixel = 0
	content.Parent = bg

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, mobile and 10 or 6)
	layout.Parent = content

	-- Animate open
	if mobile then
		-- Slide up from bottom
		bg.Position = UDim2.new(0.5, 0, 1, bg.Size.Y.Offset)
		overlay.BackgroundTransparency = 1
		tweenProperty(bg, {Position = UDim2.new(0.5, 0, 1, 0)}, 0.3, Enum.EasingStyle.Quad)
		tweenProperty(overlay, {BackgroundTransparency = 0.5}, 0.2)
	else
		-- Scale up from center
		local targetSize = bg.Size
		bg.Size = UDim2.new(0, width - 30, 0, height - 30)
		bg.BackgroundTransparency = 0.5
		overlay.BackgroundTransparency = 1
		tweenProperty(bg, {Size = targetSize, BackgroundTransparency = 0}, 0.25, Enum.EasingStyle.Back)
		tweenProperty(overlay, {BackgroundTransparency = 0.5}, 0.2)
	end

	return gui, bg, content
end

local function CreateActionButton(parent, text, color, layoutOrder, callback)
	local btnW = mobile and 140 or 120
	local btnH = mobile and 56 or 36

	local btn = Instance.new("TextButton")
	btn.Name = "ActionBtn"
	btn.Size = UDim2.new(0, btnW, 0, btnH)
	btn.Position = UDim2.new(1, -(btnW + 8), 0.5, -btnH/2)
	btn.BackgroundColor3 = color
	btn.TextColor3 = COLORS.TextWhite
	btn.Font = FONTS.Header
	btn.TextSize = mobile and 18 or 16
	btn.Text = text
	btn.AutoButtonColor = false
	btn.LayoutOrder = layoutOrder or 0
	btn.Parent = parent
	addCorner(btn, 8)

	local hoverColor = Color3.new(
		math.min(color.R * 1.3, 1),
		math.min(color.G * 1.3, 1),
		math.min(color.B * 1.3, 1)
	)

	btn.MouseEnter:Connect(function()
		tweenProperty(btn, {BackgroundColor3 = hoverColor}, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		tweenProperty(btn, {BackgroundColor3 = color}, 0.15)
	end)

	if callback then
		btn.MouseButton1Click:Connect(callback)
	end

	return btn
end

local function CreateDisabledButton(parent, text, layoutOrder)
	local btnW = mobile and 140 or 120
	local btnH = mobile and 56 or 36

	local btn = Instance.new("TextButton")
	btn.Name = "DisabledBtn"
	btn.Size = UDim2.new(0, btnW, 0, btnH)
	btn.Position = UDim2.new(1, -(btnW + 8), 0.5, -btnH/2)
	btn.BackgroundColor3 = Color3.fromRGB(50, 42, 32)
	btn.TextColor3 = COLORS.TextDim
	btn.Font = FONTS.Header
	btn.TextSize = mobile and 15 or 16
	btn.Text = text
	btn.AutoButtonColor = false
	btn.Active = false
	btn.LayoutOrder = layoutOrder or 0
	btn.Parent = parent
	addCorner(btn, 8)
	return btn
end

-- ═══════════════════════════════════════════
-- NPC DIALOGUE CONFIG
-- ═══════════════════════════════════════════
local NPC_GREETINGS = {
	ToolShop = {
		"Bienvenue ! J'ai les meilleurs outils de la région !",
		"Hé cow-boy ! Tu veux du bon matos ?",
		"Mes pioches cassent la roche comme du beurre !",
		"Entre, entre ! J'ai des nouveautés !",
	},
	Merchant = {
		"Bonjour voyageur ! Tu as de l'or à vendre ?",
		"Montre-moi ce que tu as trouvé !",
		"Approche ! Les prix sont bons aujourd'hui !",
		"De l'or frais ? J'achète tout !",
	},
	Crafter = {
		"Apporte-moi du minerai, je te ferai de l'or pur !",
		"Ma forge est la plus chaude du comté !",
		"Tu veux transformer tes trouvailles ?",
		"Le feu est prêt, montre-moi tes matériaux !",
	},
	Saloon = {
		"Bienvenue au Saloon ! Un remontant ?",
		"Installe-toi, cow-boy ! Qu'est-ce que je te sers ?",
		"Un verre pour le courage ?",
		"Le meilleur whisky à l'ouest de la rivière !",
	},
	Tutor = {
		"Bienvenue, nouveau ! Je vais t'apprendre les ficelles.",
		"La rivière cache bien des trésors...",
		"Tu veux apprendre à chercher de l'or ?",
		"Approche, j'ai des conseils pour toi !",
	},
}

-- ═══════════════════════════════════════════
-- NPC IDENTITY
-- ═══════════════════════════════════════════
local NPC_COLORS = {
	ToolShop = Color3.fromRGB(70, 130, 180),
	Merchant = Color3.fromRGB(195, 165, 85),
	Crafter = Color3.fromRGB(200, 110, 40),
	Saloon = Color3.fromRGB(180, 140, 60),
	Tutor = Color3.fromRGB(90, 160, 100),
}

local NPC_NAMES = {
	ToolShop = "Jake l'Outilleur",
	Merchant = "Marcel le Marchand",
	Crafter = "Gustave le Forgeron",
	Saloon = "Bill le Barman",
	Tutor = "Tom le Guide",
}

local NPC_INITIALS = {
	ToolShop = "J", Merchant = "M", Crafter = "G", Saloon = "B", Tutor = "T",
}

local NPC_ACTION_LABELS = {
	ToolShop = "Voir les outils",
	Merchant = "Vendre mes trouvailles",
	Crafter = "Ouvrir la forge",
	Saloon = "Voir le menu",
	Tutor = "Demander conseil",
}

-- ═══════════════════════════════════════════
-- DIALOGUE BOX (bottom of screen, RPG-style)
-- ═══════════════════════════════════════════
local activeDialogue = nil

local function CloseDialogue()
	if activeDialogue and activeDialogue.Parent then
		local panel = activeDialogue:FindFirstChild("DialoguePanel")
		if panel then
			tweenProperty(panel, {Position = UDim2.new(0.5, 0, 1, 160)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
		task.delay(0.25, function()
			if activeDialogue and activeDialogue.Parent then
				activeDialogue:Destroy()
			end
		end)
		activeDialogue = nil
	end
end

local function ShowDialogueBox(npcType, text, callback)
	CloseDialogue()
	CloseActiveMenu()

	local accentColor = NPC_COLORS[npcType] or COLORS.Gold
	local npcName = NPC_NAMES[npcType] or "Inconnu"
	local initial = NPC_INITIALS[npcType] or "?"
	local actionLabel = NPC_ACTION_LABELS[npcType] or "Interagir"

	local gui = Instance.new("ScreenGui")
	gui.Name = "DialogueUI"
	gui.DisplayOrder = 8
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	activeDialogue = gui

	-- Panel at bottom
	local panelH = mobile and 130 or 150
	local panel = Instance.new("Frame")
	panel.Name = "DialoguePanel"
	panel.Size = UDim2.new(mobile and 0.95 or 0.65, 0, 0, panelH)
	panel.AnchorPoint = Vector2.new(0.5, 1)
	panel.Position = UDim2.new(0.5, 0, 1, -16)
	panel.BackgroundColor3 = COLORS.BgDark
	panel.BackgroundTransparency = 0.06
	panel.Parent = gui
	addCorner(panel, 10)
	addStroke(panel, accentColor, 1.5, 0.2)

	-- Portrait (colored square with initial)
	local portSize = mobile and 60 or 80
	local portrait = Instance.new("Frame")
	portrait.Size = UDim2.new(0, portSize, 0, portSize)
	portrait.Position = UDim2.new(0, 16, 0.5, -portSize / 2)
	portrait.BackgroundColor3 = accentColor
	portrait.BackgroundTransparency = 0.15
	portrait.Parent = panel
	addCorner(portrait, 10)
	addStroke(portrait, accentColor, 1, 0.1)

	local initialLabel = Instance.new("TextLabel")
	initialLabel.Size = UDim2.new(1, 0, 1, 0)
	initialLabel.BackgroundTransparency = 1
	initialLabel.TextColor3 = COLORS.TextWhite
	initialLabel.Font = FONTS.Title
	initialLabel.TextSize = mobile and 28 or 36
	initialLabel.Text = initial
	initialLabel.Parent = portrait

	-- NPC Name
	local textX = portSize + 30
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -(textX + 16), 0, 24)
	nameLabel.Position = UDim2.new(0, textX, 0, 12)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = accentColor
	nameLabel.Font = FONTS.Title
	nameLabel.TextSize = mobile and 18 or 22
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = npcName
	nameLabel.Parent = panel

	-- Accent line under name
	local nameLine = Instance.new("Frame")
	nameLine.Size = UDim2.new(0, 60, 0, 2)
	nameLine.Position = UDim2.new(0, textX, 0, 38)
	nameLine.BackgroundColor3 = accentColor
	nameLine.BackgroundTransparency = 0.5
	nameLine.BorderSizePixel = 0
	nameLine.Parent = panel

	-- Dialogue text (typewriter)
	local dialogueLabel = Instance.new("TextLabel")
	dialogueLabel.Name = "DialogueText"
	dialogueLabel.Size = UDim2.new(1, -(textX + 16), 0, 46)
	dialogueLabel.Position = UDim2.new(0, textX, 0, 44)
	dialogueLabel.BackgroundTransparency = 1
	dialogueLabel.TextColor3 = COLORS.TextWhite
	dialogueLabel.Font = FONTS.Body
	dialogueLabel.TextSize = mobile and 15 or 17
	dialogueLabel.TextXAlignment = Enum.TextXAlignment.Left
	dialogueLabel.TextYAlignment = Enum.TextYAlignment.Top
	dialogueLabel.TextWrapped = true
	dialogueLabel.Text = ""
	dialogueLabel.Parent = panel

	-- Response buttons container
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, -(textX + 16), 0, 36)
	btnContainer.Position = UDim2.new(0, textX, 1, -48)
	btnContainer.BackgroundTransparency = 1
	btnContainer.Parent = panel

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.Padding = UDim.new(0, 10)
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	btnLayout.Parent = btnContainer

	-- Action button
	local actionBtn = Instance.new("TextButton")
	actionBtn.Size = UDim2.new(0, mobile and 170 or 190, 0, mobile and 48 or 34)
	actionBtn.BackgroundColor3 = accentColor
	actionBtn.TextColor3 = COLORS.TextWhite
	actionBtn.Font = FONTS.Header
	actionBtn.TextSize = mobile and 14 or 16
	actionBtn.Text = actionLabel
	actionBtn.AutoButtonColor = false
	actionBtn.LayoutOrder = 1
	actionBtn.Parent = btnContainer
	addCorner(actionBtn, 6)

	actionBtn.MouseEnter:Connect(function()
		tweenProperty(actionBtn, {BackgroundTransparency = 0.2}, 0.1)
	end)
	actionBtn.MouseLeave:Connect(function()
		tweenProperty(actionBtn, {BackgroundTransparency = 0}, 0.1)
	end)

	-- Partir button
	local leaveBtn = Instance.new("TextButton")
	leaveBtn.Size = UDim2.new(0, mobile and 100 or 100, 0, mobile and 48 or 34)
	leaveBtn.BackgroundColor3 = COLORS.BgRow
	leaveBtn.TextColor3 = COLORS.TextGray
	leaveBtn.Font = FONTS.Body
	leaveBtn.TextSize = mobile and 14 or 16
	leaveBtn.Text = "Partir"
	leaveBtn.AutoButtonColor = false
	leaveBtn.LayoutOrder = 2
	leaveBtn.Parent = btnContainer
	addCorner(leaveBtn, 6)

	-- Slide up animation
	panel.Position = UDim2.new(0.5, 0, 1, panelH + 20)
	tweenProperty(panel, {Position = UDim2.new(0.5, 0, 1, -16)}, 0.3, Enum.EasingStyle.Quad)

	-- Typewriter effect
	task.spawn(function()
		for i = 1, #text do
			if not gui.Parent then return end
			dialogueLabel.Text = string.sub(text, 1, i)
			task.wait(0.02)
		end
	end)

	-- Button handlers
	actionBtn.MouseButton1Click:Connect(function()
		CloseDialogue()
		if callback then callback("action") end
	end)
	leaveBtn.MouseButton1Click:Connect(function()
		CloseDialogue()
		if callback then callback("leave") end
	end)
end

-- ═══════════════════════════════════════════
-- CONFIRM DIALOG (before purchase/sell/craft)
-- ═══════════════════════════════════════════
local function ShowConfirmDialog(title, cost, onConfirm)
	local data = UIManager:GetPlayerData()
	local cash = data and data.Cash or 0
	local canAfford = cash >= cost
	local balanceAfter = cash - cost

	local gui = Instance.new("ScreenGui")
	gui.Name = "ConfirmUI"
	gui.DisplayOrder = 15
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	-- Overlay
	local overlay = Instance.new("TextButton")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.6
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.Parent = gui
	overlay.MouseButton1Click:Connect(function() gui:Destroy() end)

	-- Panel
	local panelW = mobile and 300 or 340
	local panelH = 160
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, panelW, 0, panelH)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.BackgroundColor3 = COLORS.BgDark
	panel.Parent = gui
	addCorner(panel, 10)
	addStroke(panel, COLORS.GoldDark, 1.5, 0.2)
	addGradient(panel, Color3.fromRGB(38, 30, 22), COLORS.BgDark)

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 30)
	titleLabel.Position = UDim2.new(0, 10, 0, 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = COLORS.TextWhite
	titleLabel.Font = FONTS.Title
	titleLabel.TextSize = 20
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.Text = title
	titleLabel.Parent = panel

	-- Cost
	local costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.new(1, -20, 0, 22)
	costLabel.Position = UDim2.new(0, 10, 0, 48)
	costLabel.BackgroundTransparency = 1
	costLabel.TextColor3 = COLORS.Gold
	costLabel.Font = FONTS.Number
	costLabel.TextSize = 18
	costLabel.Text = `Prix : {cost}$`
	costLabel.Parent = panel

	-- Balance after
	local balLabel = Instance.new("TextLabel")
	balLabel.Size = UDim2.new(1, -20, 0, 20)
	balLabel.Position = UDim2.new(0, 10, 0, 72)
	balLabel.BackgroundTransparency = 1
	balLabel.TextColor3 = canAfford and COLORS.TextGray or COLORS.Error
	balLabel.Font = FONTS.Body
	balLabel.TextSize = 15
	balLabel.Text = canAfford and `Solde après : {balanceAfter}$` or "Fonds insuffisants !"
	balLabel.Parent = panel

	-- Buttons
	local btnY = panelH - 50
	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(0, mobile and 140 or 130, 0, mobile and 48 or 36)
	confirmBtn.Position = UDim2.new(0.5, -135, 0, btnY)
	confirmBtn.BackgroundColor3 = canAfford and Color3.fromRGB(50, 110, 50) or Color3.fromRGB(50, 42, 32)
	confirmBtn.TextColor3 = canAfford and COLORS.TextWhite or COLORS.TextDim
	confirmBtn.Font = FONTS.Header
	confirmBtn.TextSize = 16
	confirmBtn.Text = "Confirmer"
	confirmBtn.AutoButtonColor = false
	confirmBtn.Active = canAfford
	confirmBtn.Parent = panel
	addCorner(confirmBtn, 6)

	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0, mobile and 140 or 130, 0, mobile and 48 or 36)
	cancelBtn.Position = UDim2.new(0.5, 5, 0, btnY)
	cancelBtn.BackgroundColor3 = Color3.fromRGB(65, 28, 25)
	cancelBtn.TextColor3 = COLORS.TextWhite
	cancelBtn.Font = FONTS.Header
	cancelBtn.TextSize = 16
	cancelBtn.Text = "Annuler"
	cancelBtn.AutoButtonColor = false
	cancelBtn.Parent = panel
	addCorner(cancelBtn, 6)

	-- Scale in
	panel.Size = UDim2.new(0, panelW - 20, 0, panelH - 20)
	overlay.BackgroundTransparency = 1
	tweenProperty(panel, {Size = UDim2.new(0, panelW, 0, panelH)}, 0.2, Enum.EasingStyle.Back)
	tweenProperty(overlay, {BackgroundTransparency = 0.6}, 0.15)

	confirmBtn.MouseButton1Click:Connect(function()
		if not canAfford then return end
		gui:Destroy()
		UIManager.haptic(0.3)
		if onConfirm then onConfirm() end
	end)
	cancelBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)
end

-- ═══════════════════════════════════════════
-- NPC ProximityPrompts
-- ═══════════════════════════════════════════
local isInteracting = false

local function OnPromptTriggered(prompt)
	local part = prompt.Parent
	if not part then return end
	if isInteracting then return end

	local npcType = part:GetAttribute("NPCType")
	if not npcType then return end

	isInteracting = true

	-- Pick a random greeting
	local greetings = NPC_GREETINGS[npcType]
	local greetingLine = greetings and greetings[math.random(1, #greetings)] or "..."

	-- Show RPG dialogue box
	ShowDialogueBox(npcType, greetingLine, function(choice)
		isInteracting = false
		if choice ~= "action" then return end

		if npcType == "ToolShop" then
			ShowToolShop()
		elseif npcType == "Merchant" then
			ShowSellMenu()
		elseif npcType == "Crafter" then
			ShowCraftMenu()
		elseif npcType == "Saloon" then
			ShowSaloonMenu()
		elseif npcType == "Tutor" then
			ShowTutorPanel()
		end
	end)
end

local function ConnectPrompt(descendant)
	if descendant:IsA("ProximityPrompt") then
		-- Triggered checks NPCType at fire time (no race condition)
		descendant.Triggered:Connect(function()
			OnPromptTriggered(descendant)
		end)
	end
end

-- Scan existing + listen for new
workspace.DescendantAdded:Connect(ConnectPrompt)
for _, desc in workspace:GetDescendants() do
	ConnectPrompt(desc)
end

-- ═══════════════════════════════════════════
-- TOOL SHOP UI
-- ═══════════════════════════════════════════
function ShowToolShop()
	local data = UIManager:GetPlayerData()
	if not data then return end

	local gui, bg, content = CreateMenuPanel("ShopUI", mobile and "Outils" or "Jake l'Outilleur — Outils", 520, mobile and 400 or 460, NPC_COLORS.ToolShop)

	local ToolConfig = require(ReplicatedStorage.Modules.Config.ToolConfig)
	local order = {"Batee", "Tapis", "Pioche"}
	local rowH = mobile and 86 or 82

	for idx, toolName in ipairs(order) do
		local toolData = ToolConfig.Tools[toolName]
		if not toolData then continue end

		local owned = data.Tools[toolName] and data.Tools[toolName].Owned
		local level = owned and data.Tools[toolName].Level or 0

		local row = Instance.new("Frame")
		row.Name = toolName
		row.Size = UDim2.new(1, 0, 0, rowH)
		row.BackgroundColor3 = COLORS.BgRow
		row.BackgroundTransparency = 0.3
		row.LayoutOrder = idx
		row.Parent = content
		addCorner(row, 8)

		-- Tool name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.6, 0, 0, 22)
		nameLabel.Position = UDim2.new(0, 12, 0, 8)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = COLORS.TextWhite
		nameLabel.Font = FONTS.Header
		nameLabel.TextSize = 18
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = row

		if owned then
			local levelName = toolData.Levels[level] and toolData.Levels[level].Name or toolData.DisplayName
			nameLabel.Text = levelName
		else
			nameLabel.Text = toolData.DisplayName
		end

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(0.6, 0, 0, 16)
		descLabel.Position = UDim2.new(0, 12, 0, 30)
		descLabel.BackgroundTransparency = 1
		descLabel.TextColor3 = COLORS.TextGray
		descLabel.Font = FONTS.Body
		descLabel.TextSize = 15
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Text = toolData.Description
		descLabel.Parent = row

		-- Level dots
		if owned and level > 0 then
			for i = 1, 3 do
				local dot = Instance.new("Frame")
				dot.Size = UDim2.new(0, 8, 0, 8)
				dot.Position = UDim2.new(0, 12 + (i - 1) * 14, 0, 52)
				dot.BackgroundColor3 = i <= level and COLORS.Gold or Color3.fromRGB(60, 50, 40)
				dot.BorderSizePixel = 0
				dot.Parent = row
				addCorner(dot, 4)
			end
		end

		-- Action button
		if not owned then
			local price = toolData.Levels[1].BuyPrice
			if price and price > 0 then
				local displayName = toolData.DisplayName or toolName
				CreateActionButton(row, `Acheter {price}$`, Color3.fromRGB(50, 110, 50), idx, function()
					ShowConfirmDialog(`Acheter {displayName} ?`, price, function()
						Events.RequestBuyTool:FireServer(toolName)
						CloseActiveMenu()
					end)
				end)
			else
				CreateDisabledButton(row, "Gratuit", idx)
			end
		else
			local nextLevel = level + 1
			local nextData = toolData.Levels[nextLevel]
			if nextData then
				CreateActionButton(row, `Améliorer {nextData.UpgradePrice}$`, Color3.fromRGB(40, 80, 140), idx, function()
					ShowConfirmDialog(`Améliorer en {nextData.Name} ?`, nextData.UpgradePrice, function()
						Events.RequestUpgradeTool:FireServer(toolName)
						CloseActiveMenu()
					end)
				end)
			else
				CreateDisabledButton(row, "MAX", idx)
			end
		end
	end
end

-- ═══════════════════════════════════════════
-- SELL MENU UI
-- ═══════════════════════════════════════════
function ShowSellMenu()
	local data = UIManager:GetPlayerData()
	if not data then return end

	local gui, bg, content = CreateMenuPanel("SellUI", mobile and "Vendre" or "Marcel le Marchand — Vendre", 520, mobile and 420 or 480, NPC_COLORS.Merchant)

	local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
	local prices = EconomyConfig.SellPrices.MarchandLocal
	local order = {"Paillettes", "Pepites", "OrPur", "MineraiOr", "Lingots", "Quartz", "Amethyste", "Topaze"}
	local idx = 0
	local hasItems = false

	for _, itemName in ipairs(order) do
		local price = prices[itemName]
		if not price then continue end

		local qty = data.Inventory[itemName] or 0
		if qty <= 0 then continue end

		hasItems = true
		idx += 1

		local row = Instance.new("Frame")
		row.Name = itemName
		row.Size = UDim2.new(1, 0, 0, mobile and 68 or 62)
		row.BackgroundColor3 = COLORS.BgRow
		row.BackgroundTransparency = 0.3
		row.LayoutOrder = idx
		row.Parent = content
		addCorner(row, 8)

		-- Rarity accent
		local accent = Instance.new("Frame")
		accent.Size = UDim2.new(0, 3, 0.7, 0)
		accent.Position = UDim2.new(0, 4, 0.15, 0)
		accent.BackgroundColor3 = UIManager.getRarityColor(itemName)
		accent.BorderSizePixel = 0
		accent.Parent = row
		addCorner(accent, 2)

		-- Icon + name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
		nameLabel.Position = UDim2.new(0, 14, 0, 6)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = COLORS.TextWhite
		nameLabel.Font = FONTS.Header
		nameLabel.TextSize = 18
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = `{UIManager.ITEM_ICONS[itemName] or "•"} {ITEM_DISPLAY[itemName] or itemName}`
		nameLabel.Parent = row

		-- Quantity + unit price
		local detailLabel = Instance.new("TextLabel")
		detailLabel.Size = UDim2.new(0.5, 0, 0, 16)
		detailLabel.Position = UDim2.new(0, 14, 0, 28)
		detailLabel.BackgroundTransparency = 1
		detailLabel.TextColor3 = COLORS.TextGray
		detailLabel.Font = FONTS.Body
		detailLabel.TextSize = 15
		detailLabel.TextXAlignment = Enum.TextXAlignment.Left
		detailLabel.Text = `{qty} en stock — {price}$/unité`
		detailLabel.Parent = row

		-- Sell button with total
		local total = qty * price
		CreateActionButton(row, `Vendre tout ({total}$)`, Color3.fromRGB(50, 110, 50), idx, function()
			Events.RequestSell:FireServer("MarchandLocal", itemName, qty)
			CloseActiveMenu()
		end)
	end

	if not hasItems then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Size = UDim2.new(1, 0, 0, 60)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.TextColor3 = COLORS.TextGray
		emptyLabel.Font = FONTS.Body
		emptyLabel.TextSize = 18
		emptyLabel.Text = "Tu n'as rien à vendre pour le moment !"
		emptyLabel.Parent = content
	end
end

-- ═══════════════════════════════════════════
-- CRAFT MENU UI
-- ═══════════════════════════════════════════
function ShowCraftMenu()
	local data = UIManager:GetPlayerData()
	if not data then return end

	local gui, bg, content = CreateMenuPanel("CraftUI", mobile and "Forge" or "Gustave le Forgeron — Forge", 540, mobile and 420 or 480, NPC_COLORS.Crafter)

	local CraftConfig = require(ReplicatedStorage.Modules.Config.CraftConfig)

	for idx, recipe in ipairs(CraftConfig.Recipes) do
		local row = Instance.new("Frame")
		row.Name = recipe.Id or recipe.Name
		row.Size = UDim2.new(1, 0, 0, mobile and 96 or 90)
		row.BackgroundColor3 = COLORS.BgRow
		row.BackgroundTransparency = 0.3
		row.LayoutOrder = idx
		row.Parent = content
		addCorner(row, 8)

		-- Recipe name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.6, 0, 0, 22)
		nameLabel.Position = UDim2.new(0, 12, 0, 6)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		nameLabel.Font = FONTS.Header
		nameLabel.TextSize = 18
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = recipe.Name
		nameLabel.Parent = row

		-- Ingredients
		local parts = {}
		local canCraft = true
		for _, input in ipairs(recipe.Inputs) do
			local has = data.Inventory[input.Item] or 0
			local enough = has >= input.Quantity
			if not enough then canCraft = false end
			local mark = enough and "✓" or "✗"
			table.insert(parts, `{mark} {input.Quantity}x {ITEM_DISPLAY[input.Item] or input.Item} ({has})`)
		end
		if data.Level < recipe.RequiredLevel then canCraft = false end

		local ingredLabel = Instance.new("TextLabel")
		ingredLabel.Size = UDim2.new(0.62, 0, 0, 16)
		ingredLabel.Position = UDim2.new(0, 12, 0, 30)
		ingredLabel.BackgroundTransparency = 1
		ingredLabel.TextColor3 = COLORS.TextGray
		ingredLabel.Font = FONTS.Body
		ingredLabel.TextSize = 14
		ingredLabel.TextXAlignment = Enum.TextXAlignment.Left
		ingredLabel.Text = table.concat(parts, "  |  ")
		ingredLabel.Parent = row

		-- Output
		local outLabel = Instance.new("TextLabel")
		outLabel.Size = UDim2.new(0.62, 0, 0, 16)
		outLabel.Position = UDim2.new(0, 12, 0, 50)
		outLabel.BackgroundTransparency = 1
		outLabel.TextColor3 = COLORS.Gold
		outLabel.Font = FONTS.Body
		outLabel.TextSize = 14
		outLabel.TextXAlignment = Enum.TextXAlignment.Left
		outLabel.Text = `→ {recipe.Output.Quantity}x {ITEM_DISPLAY[recipe.Output.Item] or recipe.Output.Item} (+{recipe.XPReward or 0} XP)`
		outLabel.Parent = row

		-- Button
		if canCraft then
			CreateActionButton(row, "Forger", Color3.fromRGB(150, 80, 25), idx, function()
				ShowConfirmDialog(`Forger {recipe.Name} ?`, 0, function()
					Events.RequestCraft:FireServer(recipe.Id)
					CloseActiveMenu()
				end)
			end)
		else
			local reason = data.Level < recipe.RequiredLevel and `Niv.{recipe.RequiredLevel}` or "Manque"
			CreateDisabledButton(row, reason, idx)
		end
	end
end

-- ═══════════════════════════════════════════
-- SALOON MENU UI
-- ═══════════════════════════════════════════
function ShowSaloonMenu()
	local data = UIManager:GetPlayerData()
	if not data then return end

	local gui, bg, content = CreateMenuPanel("SaloonUI", mobile and "Saloon" or "Bill le Barman — Saloon", 520, mobile and 380 or 440, NPC_COLORS.Saloon)

	-- Buff status bar
	local statusFrame = Instance.new("Frame")
	statusFrame.Name = "Status"
	statusFrame.Size = UDim2.new(1, 0, 0, 28)
	statusFrame.BackgroundColor3 = COLORS.BgPanel
	statusFrame.BackgroundTransparency = 0.5
	statusFrame.LayoutOrder = 0
	statusFrame.Parent = content
	addCorner(statusFrame, 6)

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, -16, 1, 0)
	statusLabel.Position = UDim2.new(0, 8, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = FONTS.Body
	statusLabel.TextSize = 15
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = statusFrame

	if data.Saloon.BuffActive and os.time() < data.Saloon.BuffExpiry then
		local remaining = data.Saloon.BuffExpiry - os.time()
		local mins = math.ceil(remaining / 60)
		statusLabel.TextColor3 = COLORS.Success
		statusLabel.Text = `Buff actif: {data.Saloon.BuffActive} ({mins} min restantes)`
	else
		statusLabel.TextColor3 = COLORS.TextGray
		statusLabel.Text = `Consommations : {data.Saloon.DrinksToday or 0}/3 aujourd'hui`
	end

	-- Drinks
	local GameConfig = require(ReplicatedStorage.Modules.Config.GameConfig)
	for idx, drink in ipairs(GameConfig.Saloon.Drinks) do
		local row = Instance.new("Frame")
		row.Name = drink.Id
		row.Size = UDim2.new(1, 0, 0, mobile and 96 or 90)
		row.BackgroundColor3 = Color3.fromRGB(55, 35, 20)
		row.BackgroundTransparency = 0.3
		row.LayoutOrder = idx
		row.Parent = content
		addCorner(row, 8)

		-- Name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.6, 0, 0, 22)
		nameLabel.Position = UDim2.new(0, 12, 0, 8)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255, 220, 150)
		nameLabel.Font = FONTS.Header
		nameLabel.TextSize = 18
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = drink.Name
		nameLabel.Parent = row

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(0.6, 0, 0, 16)
		descLabel.Position = UDim2.new(0, 12, 0, 32)
		descLabel.BackgroundTransparency = 1
		descLabel.TextColor3 = COLORS.TextGray
		descLabel.Font = FONTS.Body
		descLabel.TextSize = 15
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Text = drink.Description
		descLabel.Parent = row

		-- Price
		local priceLabel = Instance.new("TextLabel")
		priceLabel.Size = UDim2.new(0.6, 0, 0, 16)
		priceLabel.Position = UDim2.new(0, 12, 0, 52)
		priceLabel.BackgroundTransparency = 1
		priceLabel.TextColor3 = COLORS.Gold
		priceLabel.Font = FONTS.Header
		priceLabel.TextSize = 16
		priceLabel.TextXAlignment = Enum.TextXAlignment.Left
		priceLabel.Text = `{drink.Cost}$`
		priceLabel.Parent = row

		CreateActionButton(row, "Commander", Color3.fromRGB(115, 65, 22), idx, function()
			ShowConfirmDialog(`Commander {drink.Name} ?`, drink.Cost, function()
				Events.RequestDrink:FireServer(drink.Id)
				CloseActiveMenu()
			end)
		end)
	end
end

-- ═══════════════════════════════════════════
-- TUTOR PANEL UI
-- ═══════════════════════════════════════════
function ShowTutorPanel()
	local data = UIManager:GetPlayerData()

	local gui, bg, content = CreateMenuPanel("TutorUI", mobile and "Guide" or "Tom le Guide — Conseils", 500, mobile and 400 or 440, NPC_COLORS.Tutor)

	local tips = {
		{ title = "Chercher de l'or", text = "Approche-toi des gisements dorés près de la rivière et appuie sur E pour miner." },
		{ title = "Vendre tes trouvailles", text = "Marcel le Marchand achète tout ce que tu trouves. Plus l'or est pur, plus il paie cher !" },
		{ title = "Améliorer tes outils", text = "Jake vend des outils. Meilleur outil = meilleur rendement. Investis !" },
		{ title = "La Forge", text = "Gustave peut transformer ton minerai brut en or pur et tes pépites en lingots." },
		{ title = "Le Saloon", text = "Bill propose des boissons qui boostent temporairement tes gains. Utile avant une session de minage !" },
	}

	for idx, tip in ipairs(tips) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, mobile and 66 or 60)
		row.BackgroundColor3 = COLORS.BgRow
		row.BackgroundTransparency = 0.3
		row.LayoutOrder = idx
		row.Parent = content
		addCorner(row, 8)

		local accent = Instance.new("Frame")
		accent.Size = UDim2.new(0, 3, 0.7, 0)
		accent.Position = UDim2.new(0, 4, 0.15, 0)
		accent.BackgroundColor3 = Color3.fromRGB(100, 200, 120)
		accent.BorderSizePixel = 0
		accent.Parent = row
		addCorner(accent, 2)

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -20, 0, 18)
		titleLabel.Position = UDim2.new(0, 14, 0, 4)
		titleLabel.BackgroundTransparency = 1
		titleLabel.TextColor3 = Color3.fromRGB(130, 220, 150)
		titleLabel.Font = FONTS.Header
		titleLabel.TextSize = 16
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Text = tip.title
		titleLabel.Parent = row

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, -20, 0, 24)
		textLabel.Position = UDim2.new(0, 14, 0, 22)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = COLORS.TextGray
		textLabel.Font = FONTS.Body
		textLabel.TextSize = 14
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextWrapped = true
		textLabel.Text = tip.text
		textLabel.Parent = row
	end

	-- Player level info
	if data then
		local lvlRow = Instance.new("Frame")
		lvlRow.Size = UDim2.new(1, 0, 0, 32)
		lvlRow.BackgroundColor3 = COLORS.BgPanel
		lvlRow.BackgroundTransparency = 0.4
		lvlRow.LayoutOrder = #tips + 1
		lvlRow.Parent = content
		addCorner(lvlRow, 6)

		local lvlLabel = Instance.new("TextLabel")
		lvlLabel.Size = UDim2.new(1, -16, 1, 0)
		lvlLabel.Position = UDim2.new(0, 8, 0, 0)
		lvlLabel.BackgroundTransparency = 1
		lvlLabel.TextColor3 = COLORS.GoldMuted
		lvlLabel.Font = FONTS.Header
		lvlLabel.TextSize = 15
		lvlLabel.TextXAlignment = Enum.TextXAlignment.Left
		lvlLabel.Text = `Ton niveau : {data.Level or 1} — Continue à miner !`
		lvlLabel.Parent = lvlRow
	end
end

-- ═══════════════════════════════════════════
-- QUEST HUD BUTTON + PANEL
-- ═══════════════════════════════════════════
local questData = {} -- cache du dernier QuestDataResponse
local wantsQuestPanel = false -- true quand le joueur clique sur le bouton

local function CreateQuestButton()
	local questGui = Instance.new("ScreenGui")
	questGui.Name = "QuestButtonGui"
	questGui.ResetOnSpawn = false
	questGui.DisplayOrder = 3
	pcall(function() questGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
	questGui.Parent = playerGui

	local btnSize = 48
	local btn = Instance.new("TextButton")
	btn.Name = "QuestBtn"
	btn.Size = UDim2.new(0, btnSize, 0, btnSize)
	btn.Position = UDim2.new(1, -(btnSize + (mobile and 8 or 12)), 0, mobile and 140 or 56)
	btn.BackgroundColor3 = COLORS.BgDark
	btn.BackgroundTransparency = 0.1
	btn.TextColor3 = COLORS.Gold
	btn.Font = FONTS.Header
	btn.TextSize = mobile and 20 or 22
	btn.Text = "!"
	btn.AutoButtonColor = false
	btn.Parent = questGui
	addCorner(btn, btnSize / 2)
	addStroke(btn, COLORS.GoldDark, 2, 0.2)

	-- Badge compteur de quêtes non complétées
	local badge = Instance.new("TextLabel")
	badge.Name = "Badge"
	badge.Size = UDim2.new(0, 18, 0, 18)
	badge.Position = UDim2.new(1, -6, 0, -4)
	badge.BackgroundColor3 = Color3.fromRGB(220, 60, 40)
	badge.TextColor3 = COLORS.TextWhite
	badge.Font = FONTS.Header
	badge.TextSize = 11
	badge.Text = "3"
	badge.Visible = false
	badge.Parent = btn
	addCorner(badge, 9)

	-- Hover
	btn.MouseEnter:Connect(function()
		tweenProperty(btn, {BackgroundColor3 = COLORS.BgPanel}, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		tweenProperty(btn, {BackgroundColor3 = COLORS.BgDark}, 0.15)
	end)

	btn.MouseButton1Click:Connect(function()
		-- Toggle : si le panneau de quêtes est ouvert, le fermer
		if activeGui and activeGui.Name == "QuestUI" then
			CloseActiveMenu()
			return
		end
		wantsQuestPanel = true
		Events.RequestQuestData:FireServer()
	end)

	return badge
end

local questBadge = CreateQuestButton()
questBadge.Visible = false -- Remplacé par le Quest Tracker permanent dans UIManager

-- Met à jour le badge (désactivé — remplacé par Quest Tracker permanent)
local function UpdateQuestBadge()
	-- Badge caché, le Quest Tracker dans UIManager gère l'affichage
end

function ShowQuestPanel()
	local gui, bg, content = CreateMenuPanel(
		"QuestUI",
		mobile and "Quêtes" or "Quêtes du jour",
		520,
		mobile and 400 or 460,
		Color3.fromRGB(210, 160, 50)
	)

	if #questData == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Size = UDim2.new(1, 0, 0, 60)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.TextColor3 = COLORS.TextGray
		emptyLabel.Font = FONTS.Body
		emptyLabel.TextSize = 18
		emptyLabel.Text = "Aucune quête disponible. Reviens demain !"
		emptyLabel.Parent = content
		return
	end

	for idx, quest in ipairs(questData) do
		local rowH = mobile and 90 or 84
		local row = Instance.new("Frame")
		row.Name = quest.Id
		row.Size = UDim2.new(1, 0, 0, rowH)
		row.BackgroundColor3 = quest.Completed and Color3.fromRGB(35, 50, 30) or COLORS.BgRow
		row.BackgroundTransparency = 0.3
		row.LayoutOrder = idx
		row.Parent = content
		addCorner(row, 8)

		-- Accent barre gauche
		local accent = Instance.new("Frame")
		accent.Size = UDim2.new(0, 3, 0.7, 0)
		accent.Position = UDim2.new(0, 4, 0.15, 0)
		accent.BackgroundColor3 = quest.Completed and COLORS.Success or COLORS.Gold
		accent.BorderSizePixel = 0
		accent.Parent = row
		addCorner(accent, 2)

		-- Titre
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(0.75, 0, 0, 20)
		titleLabel.Position = UDim2.new(0, 14, 0, 6)
		titleLabel.BackgroundTransparency = 1
		titleLabel.TextColor3 = quest.Completed and COLORS.Success or COLORS.TextWhite
		titleLabel.Font = FONTS.Header
		titleLabel.TextSize = 16
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Text = quest.Completed and `✓ {quest.Title}` or quest.Title
		titleLabel.Parent = row

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(0.75, 0, 0, 14)
		descLabel.Position = UDim2.new(0, 14, 0, 26)
		descLabel.BackgroundTransparency = 1
		descLabel.TextColor3 = COLORS.TextGray
		descLabel.Font = FONTS.Body
		descLabel.TextSize = 15
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Text = quest.Description
		descLabel.Parent = row

		-- Barre de progression
		local barBgH = 10
		local barBg = Instance.new("Frame")
		barBg.Name = "ProgressBg"
		barBg.Size = UDim2.new(0.72, 0, 0, barBgH)
		barBg.Position = UDim2.new(0, 14, 0, 46)
		barBg.BackgroundColor3 = Color3.fromRGB(30, 24, 18)
		barBg.BorderSizePixel = 0
		barBg.Parent = row
		addCorner(barBg, barBgH / 2)

		local progress = math.clamp(quest.Progress / quest.Goal, 0, 1)
		local barFill = Instance.new("Frame")
		barFill.Name = "Fill"
		barFill.Size = UDim2.new(math.max(0.02, progress), 0, 1, 0)
		barFill.BackgroundColor3 = quest.Completed and COLORS.Success or COLORS.Gold
		barFill.BorderSizePixel = 0
		barFill.Parent = barBg
		addCorner(barFill, barBgH / 2)

		-- Texte progression
		local progLabel = Instance.new("TextLabel")
		progLabel.Size = UDim2.new(0.28, 0, 0, barBgH)
		progLabel.Position = UDim2.new(0.72, 4, 0, 46)
		progLabel.BackgroundTransparency = 1
		progLabel.TextColor3 = quest.Completed and COLORS.Success or COLORS.TextGray
		progLabel.Font = FONTS.Header
		progLabel.TextSize = 14
		progLabel.TextXAlignment = Enum.TextXAlignment.Left
		progLabel.Text = `{math.min(quest.Progress, quest.Goal)}/{quest.Goal}`
		progLabel.Parent = row

		-- Récompense
		local rewardLabel = Instance.new("TextLabel")
		rewardLabel.Size = UDim2.new(1, -14, 0, 14)
		rewardLabel.Position = UDim2.new(0, 14, 0, 58)
		rewardLabel.BackgroundTransparency = 1
		rewardLabel.TextColor3 = COLORS.GoldMuted
		rewardLabel.Font = FONTS.Body
		rewardLabel.TextSize = mobile and 15 or 13
		rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
		rewardLabel.Text = `Récompense: {quest.Reward.Cash}$ + {quest.Reward.XP} XP`
		rewardLabel.Parent = row
	end
end

-- Réception des données de quêtes
Events.QuestDataResponse.OnClientEvent:Connect(function(quests)
	questData = quests or {}
	UpdateQuestBadge()

	-- N'ouvrir le panneau que si le joueur a cliqué
	if wantsQuestPanel then
		wantsQuestPanel = false
		ShowQuestPanel()
	end
end)

-- Quête complétée — notification célébration
Events.QuestCompleted.OnClientEvent:Connect(function(questTitle, reward)
	local msg = `Quête terminée : {questTitle} ! +{reward.Cash}$ +{reward.XP} XP`
	UIManager:ShowNotification(msg, "Success")

	-- Refresh badge
	for _, q in ipairs(questData) do
		if q.Title == questTitle then
			q.Completed = true
			q.Progress = q.Goal
			break
		end
	end
	UpdateQuestBadge()
end)

-- Demander les quêtes au démarrage (badge uniquement, pas de panel)
task.delay(2, function()
	Events.RequestQuestData:FireServer()
end)

-- ═══════════════════════════════════════════
-- SERVER RESULTS
-- ═══════════════════════════════════════════
Events.ShopResult.OnClientEvent:Connect(function(success, message)
	UIManager:ShowNotification(message, success and "Success" or "Error")
	if success then UIManager.haptic(0.5) end
end)

Events.SellResult.OnClientEvent:Connect(function(success, message)
	UIManager:ShowNotification(message, success and "Success" or "Error")
	if success then UIManager.haptic(0.4) end
end)

Events.CraftResult.OnClientEvent:Connect(function(success, message)
	UIManager:ShowNotification(message, success and "Success" or "Error")
	if success then UIManager.haptic(0.6) end
end)

Events.DrinkResult.OnClientEvent:Connect(function(success, message)
	UIManager:ShowNotification(message, success and "Success" or "Error")
	if success then UIManager.haptic(0.3) end
end)

print("[InteractionClient] Initialisé ✓")
