--[[
    BateeMinigame.client.lua (LocalScript)
    ROLE : Mini-jeu de la batee (Zone 1).
    MECANIQUE :
      - Un cercle apparait avec un indicateur rotatif
      - Le joueur doit cliquer/appuyer quand l'indicateur est dans la zone doree
      - Plus le timing est bon, plus le score (0-1) est eleve
      - Le score est envoye au serveur pour calculer les drops

    NOTE TECHNIQUE :
      Roblox UI Rotation tourne autour du centre geometrique de l'element.
      Pour un effet "aiguille de montre", on utilise un Frame pivot de meme
      taille que le cercle, avec l'aiguille en enfant positionnee en haut.
      Quand on tourne le pivot, l'aiguille orbite autour du centre du cercle.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Events = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvents")

-- État
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local isPlaying = false
local currentDepositId = nil
local rotationSpeed = 200
local currentAngle = 0
local greenZoneCenter = 0
local greenZoneWidth = 60

-- Refs UI (set par CreateMinigameUI)
local indicatorPivot = nil
local greenPivot = nil

-- Reset si le personnage meurt pendant le minigame
player.CharacterAdded:Connect(function()
    if isPlaying then
        isPlaying = false
        local gui = playerGui:FindFirstChild("BateeMinigameUI")
        if gui then gui.Enabled = false end
    end
end)

-- ==========================================
-- CRÉER LE UI DU MINI-JEU
-- ==========================================
local function CreateMinigameUI()
    local gui = playerGui:FindFirstChild("BateeMinigameUI")
    if gui then return gui end

    gui = Instance.new("ScreenGui")
    gui.Name = "BateeMinigameUI"
    gui.Enabled = false
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    -- Overlay léger (on voit encore le jeu)
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.7
    overlay.Parent = gui

    -- Container compact, en bas à droite (dégage le personnage)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 180, 0, 180)
    container.AnchorPoint = Vector2.new(1, 1)
    container.Position = UDim2.new(1, -30, 1, -100)
    container.BackgroundTransparency = 1
    container.Parent = gui

    -- Cercle de fond — brun sombre western
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundColor3 = Color3.fromRGB(25, 20, 15)
    circle.Parent = container

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0.5, 0)
    circleCorner.Parent = circle

    -- Anneau doré
    local circleStroke = Instance.new("UIStroke")
    circleStroke.Color = Color3.fromRGB(200, 160, 50)
    circleStroke.Thickness = 3
    circleStroke.Parent = circle

    -- Anneau extérieur subtil
    local outerRing = Instance.new("Frame")
    outerRing.Name = "OuterRing"
    outerRing.Size = UDim2.new(1, 12, 1, 12)
    outerRing.AnchorPoint = Vector2.new(0.5, 0.5)
    outerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    outerRing.BackgroundTransparency = 1
    outerRing.Parent = container

    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(0.5, 0)
    outerCorner.Parent = outerRing

    local outerStroke = Instance.new("UIStroke")
    outerStroke.Color = Color3.fromRGB(120, 100, 40)
    outerStroke.Thickness = 2
    outerStroke.Transparency = 0.4
    outerStroke.Parent = outerRing

    -- ========================================
    -- ZONE DORÉE — pivot container
    -- ========================================
    greenPivot = Instance.new("Frame")
    greenPivot.Name = "GreenPivot"
    greenPivot.Size = UDim2.new(1, 0, 1, 0)
    greenPivot.BackgroundTransparency = 1
    greenPivot.Parent = container

    -- Barre centrale de la zone dorée
    local greenBar = Instance.new("Frame")
    greenBar.Name = "GreenBar"
    greenBar.Size = UDim2.new(0, 6, 0.42, 0)
    greenBar.AnchorPoint = Vector2.new(0.5, 0)
    greenBar.Position = UDim2.new(0.5, 0, 0.06, 0)
    greenBar.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    greenBar.BackgroundTransparency = 0.25
    greenBar.Parent = greenPivot

    -- Barres de bord
    local halfWidth = greenZoneWidth / 2

    local greenLeft = Instance.new("Frame")
    greenLeft.Name = "GreenEdgeLeft"
    greenLeft.Size = UDim2.new(1, 0, 1, 0)
    greenLeft.BackgroundTransparency = 1
    greenLeft.Rotation = -halfWidth
    greenLeft.Parent = greenPivot

    local leftBar = Instance.new("Frame")
    leftBar.Size = UDim2.new(0, 2, 0.42, 0)
    leftBar.AnchorPoint = Vector2.new(0.5, 0)
    leftBar.Position = UDim2.new(0.5, 0, 0.06, 0)
    leftBar.BackgroundColor3 = Color3.fromRGB(200, 160, 30)
    leftBar.BackgroundTransparency = 0.4
    leftBar.Parent = greenLeft

    local greenRight = Instance.new("Frame")
    greenRight.Name = "GreenEdgeRight"
    greenRight.Size = UDim2.new(1, 0, 1, 0)
    greenRight.BackgroundTransparency = 1
    greenRight.Rotation = halfWidth
    greenRight.Parent = greenPivot

    local rightBar = Instance.new("Frame")
    rightBar.Size = UDim2.new(0, 2, 0.42, 0)
    rightBar.AnchorPoint = Vector2.new(0.5, 0)
    rightBar.Position = UDim2.new(0.5, 0, 0.06, 0)
    rightBar.BackgroundColor3 = Color3.fromRGB(200, 160, 30)
    rightBar.BackgroundTransparency = 0.4
    rightBar.Parent = greenRight

    -- Arc doré (segments le long du bord)
    for deg = math.floor(-halfWidth), math.ceil(halfWidth), 3 do
        local arcPivot = Instance.new("Frame")
        arcPivot.Size = UDim2.new(1, 0, 1, 0)
        arcPivot.BackgroundTransparency = 1
        arcPivot.Rotation = deg
        arcPivot.Parent = greenPivot

        local arcBar = Instance.new("Frame")
        arcBar.Size = UDim2.new(0, 5, 0.06, 0)
        arcBar.AnchorPoint = Vector2.new(0.5, 0)
        arcBar.Position = UDim2.new(0.5, 0, 0.01, 0)
        arcBar.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        arcBar.BackgroundTransparency = 0.45
        arcBar.Parent = arcPivot
    end

    -- ========================================
    -- AIGUILLE — blanche lumineuse
    -- ========================================
    indicatorPivot = Instance.new("Frame")
    indicatorPivot.Name = "IndicatorPivot"
    indicatorPivot.Size = UDim2.new(1, 0, 1, 0)
    indicatorPivot.BackgroundTransparency = 1
    indicatorPivot.Parent = container

    local needle = Instance.new("Frame")
    needle.Name = "Needle"
    needle.Size = UDim2.new(0, 3, 0.43, 0)
    needle.AnchorPoint = Vector2.new(0.5, 0)
    needle.Position = UDim2.new(0.5, 0, 0.05, 0)
    needle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    needle.Parent = indicatorPivot

    -- Pointe de l'aiguille
    local tip = Instance.new("Frame")
    tip.Name = "Tip"
    tip.Size = UDim2.new(0, 8, 0, 8)
    tip.AnchorPoint = Vector2.new(0.5, 1)
    tip.Position = UDim2.new(0.5, 0, 0, 0)
    tip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tip.Rotation = 45
    tip.Parent = needle

    -- Point central doré
    local centerDot = Instance.new("Frame")
    centerDot.Name = "CenterDot"
    centerDot.Size = UDim2.new(0, 14, 0, 14)
    centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    centerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    centerDot.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    centerDot.ZIndex = 5
    centerDot.Parent = container

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0.5, 0)
    dotCorner.Parent = centerDot

    -- Texte instruction (au-dessus du cercle)
    local instruction = Instance.new("TextLabel")
    instruction.Name = "InstructionText"
    instruction.Size = UDim2.new(0, 250, 0, 30)
    instruction.AnchorPoint = Vector2.new(1, 1)
    instruction.Position = UDim2.new(1, -30, 1, -288)
    instruction.BackgroundTransparency = 1
    instruction.TextColor3 = Color3.fromRGB(255, 220, 130)
    instruction.Font = Enum.Font.GothamBold
    instruction.TextSize = 14
    instruction.Text = isMobile and "Touche l'écran dans la zone dorée !" or "Appuie sur F dans la zone dorée !"
    instruction.TextStrokeTransparency = 0.5
    instruction.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    instruction.Parent = gui

    -- Score text (encore au-dessus)
    local scoreText = Instance.new("TextLabel")
    scoreText.Name = "ScoreText"
    scoreText.Size = UDim2.new(0, 200, 0, 35)
    scoreText.AnchorPoint = Vector2.new(1, 1)
    scoreText.Position = UDim2.new(1, -30, 1, -320)
    scoreText.BackgroundTransparency = 1
    scoreText.TextColor3 = Color3.fromRGB(255, 215, 0)
    scoreText.Font = Enum.Font.GothamBold
    scoreText.TextSize = 22
    scoreText.Text = ""
    scoreText.TextStrokeTransparency = 0.5
    scoreText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    scoreText.Visible = false
    scoreText.Parent = gui

    return gui
end

-- ==========================================
-- DÉMARRER LE MINI-JEU
-- ==========================================
Events.StartBateeMinigame.OnClientEvent:Connect(function(depositId)
    if isPlaying then return end

    currentDepositId = depositId
    isPlaying = true

    local gui = CreateMinigameUI()

    -- Randomiser la zone dorée
    greenZoneCenter = math.random(0, 359)

    if greenPivot then
        greenPivot.Rotation = greenZoneCenter
    end

    -- Reset
    currentAngle = 0
    if indicatorPivot then
        indicatorPivot.Rotation = 0
    end
    gui:FindFirstChild("InstructionText").Text = isMobile and "Touche l'écran dans la zone dorée !" or "Appuie sur F dans la zone dorée !"
    gui:FindFirstChild("ScoreText").Visible = false
    gui.Enabled = true

    print("[BateeMinigame] Mini-jeu lance pour deposit:", depositId, "zone verte a", greenZoneCenter, "deg")

    -- Animation de rotation
    task.spawn(function()
        while isPlaying do
            local dt = task.wait()
            currentAngle = (currentAngle + rotationSpeed * dt) % 360
            if indicatorPivot then
                indicatorPivot.Rotation = currentAngle
            end
        end
    end)

    -- Timeout (10 secondes max)
    task.spawn(function()
        task.wait(10)
        if isPlaying and currentDepositId == depositId then
            print("[BateeMinigame] Timeout - score 0.1")
            isPlaying = false
            gui.Enabled = false
            Events.BateeMinigameResult:FireServer(depositId, 0.1)
        end
    end)
end)

-- ==========================================
-- INPUT — APPUYER POUR VALIDER
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not isPlaying then return end

    if input.KeyCode == Enum.KeyCode.F or input.UserInputType == Enum.UserInputType.Touch then
        local angleDiff = math.abs(currentAngle - greenZoneCenter)
        if angleDiff > 180 then
            angleDiff = 360 - angleDiff
        end

        local score = 0
        local halfWidth = greenZoneWidth / 2
        local resultText = ""
        local resultColor = Color3.fromRGB(255, 255, 255)

        if angleDiff <= halfWidth * 0.3 then
            score = 1.0
            resultText = "PARFAIT !"
            resultColor = Color3.fromRGB(255, 215, 0)
        elseif angleDiff <= halfWidth then
            score = 0.7
            resultText = "Bon !"
            resultColor = Color3.fromRGB(100, 220, 100)
        elseif angleDiff <= halfWidth * 1.5 then
            score = 0.4
            resultText = "Moyen..."
            resultColor = Color3.fromRGB(220, 180, 50)
        else
            score = 0.1
            resultText = "Raté !"
            resultColor = Color3.fromRGB(220, 80, 80)
        end

        isPlaying = false
        local savedDepositId = currentDepositId

        print("[BateeMinigame] Score:", score, resultText, "angleDiff:", angleDiff)

        -- Feedback visuel
        local gui = playerGui:FindFirstChild("BateeMinigameUI")
        if gui then
            local scoreLabel = gui:FindFirstChild("ScoreText")
            if scoreLabel then
                scoreLabel.Text = resultText
                scoreLabel.TextColor3 = resultColor
                scoreLabel.Visible = true
            end

            local instruction = gui:FindFirstChild("InstructionText")
            if instruction then
                instruction.Text = string.format("Score: %d%%", math.floor(score * 100))
            end
        end

        -- Attendre un moment pour le feedback, puis fermer et envoyer
        task.spawn(function()
            task.wait(1.2)
            if gui then
                gui.Enabled = false
            end

            Events.BateeMinigameResult:FireServer(savedDepositId, score)
            print("[BateeMinigame] Resultat envoye au serveur:", savedDepositId, score)
        end)
    end
end)

print("[BateeMinigame] Initialise")
