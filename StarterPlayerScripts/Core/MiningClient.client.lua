--[[
    MiningClient.client.lua (LocalScript)
    ROLE : Gère les interactions de minage côté client.
           Détecte les ProximityPrompt, joue l'animation de minage,
           envoie les requêtes au serveur, affiche les résultats.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvents")

-- Charger les modules
local UIManager = require(script.Parent.UIManager)
UIManager:Init()

local ToolAnimator = require(script.Parent.Parent.Lib.ToolAnimator)
ToolAnimator:Init()

-- ═══════════════════════════════════════════
-- ÉTAT
-- ═══════════════════════════════════════════
local ActiveGoldDeposits = workspace:WaitForChild("ActiveGoldDeposits")
local isMining = false

-- Reset l'état de minage quand le personnage meurt/respawn
player.CharacterAdded:Connect(function()
	isMining = false
end)

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════

-- Remonte de prompt.Parent au dépôt (enfant direct de ActiveGoldDeposits)
local function GetDeposit(prompt)
	local current = prompt.Parent
	while current and current.Parent ~= ActiveGoldDeposits do
		current = current.Parent
	end
	return current
end

local function GetDepositPosition(deposit)
	if deposit:IsA("Model") and deposit.PrimaryPart then
		return deposit.PrimaryPart.Position
	elseif deposit:IsA("BasePart") then
		return deposit.Position
	end
	return Vector3.zero
end

-- Auto-équipe un outil du Backpack si aucun n'est tenu (préfère Pioche)
local function AutoEquipTool(character, humanoid)
	local currentTool = character:FindFirstChildOfClass("Tool")
	if currentTool then return currentTool end

	-- Priorité : Pioche > Tapis > Batee
	local priority = { Pioche = 1, Tapis = 2, Batee = 3 }
	local bestTool = nil
	local bestPrio = 999

	for _, item in player.Backpack:GetChildren() do
		if item:IsA("Tool") then
			local prio = priority[item.Name] or 50
			if prio < bestPrio then
				bestPrio = prio
				bestTool = item
			end
		end
	end

	if bestTool then
		humanoid:EquipTool(bestTool)
		task.wait(0.1)
		return character:FindFirstChildOfClass("Tool")
	end
	return nil
end

-- ═══════════════════════════════════════════
-- ANIMATION DE TAMISAGE — GOLD PANNING MOTION
-- Mouvement : plonger → tourner/remuer → inspecter → retour
-- ═══════════════════════════════════════════
local function PlayPanningAnimation(character)
	local tool = character:FindFirstChildOfClass("Tool")
	if not tool then
		print("[MiningClient] Pas d'outil pour l'animation")
		return 0
	end

	local original = tool.Grip
	local sine = TweenInfo.new(0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	local function tweenGrip(grip, duration, style)
		local info = TweenInfo.new(duration, (style or Enum.EasingStyle.Sine), Enum.EasingDirection.InOut)
		local tween = TweenService:Create(tool, info, { Grip = grip })
		tween:Play()
		tween.Completed:Wait()
	end

	-- Phase 1 : Plonger la batée dans l'eau (forward + down + tilt)
	tweenGrip(original * CFrame.new(0, 0.3, -0.3) * CFrame.Angles(math.rad(-25), 0, 0), 0.3)

	-- Phase 2 : Remuer — basculer gauche
	tweenGrip(original * CFrame.new(0, 0.2, -0.25) * CFrame.Angles(math.rad(-15), 0, math.rad(22)), 0.2)

	-- Phase 3 : Remuer — basculer droite
	tweenGrip(original * CFrame.new(0, 0.2, -0.25) * CFrame.Angles(math.rad(-15), 0, math.rad(-22)), 0.2)

	-- Phase 4 : Remuer — basculer gauche (plus petit)
	tweenGrip(original * CFrame.new(0, 0.15, -0.2) * CFrame.Angles(math.rad(-10), 0, math.rad(14)), 0.2)

	-- Phase 5 : Lever et inspecter (bring up, tilt back)
	tweenGrip(original * CFrame.new(0, -0.15, 0.1) * CFrame.Angles(math.rad(12), 0, 0), 0.3, Enum.EasingStyle.Quad)

	-- Phase 6 : Retour au repos
	tweenGrip(original, 0.25)

	return 1.45
end

-- ═══════════════════════════════════════════
-- EFFETS VISUELS
-- ═══════════════════════════════════════════

-- Éclaboussures d'eau + paillettes dorées (gold panning)
local function PlayWaterSplashEffect(position)
	local splashPart = Instance.new("Part")
	splashPart.Size = Vector3.new(0.5, 0.5, 0.5)
	splashPart.Position = position + Vector3.new(0, 0.5, 0)
	splashPart.Anchored = true
	splashPart.CanCollide = false
	splashPart.Transparency = 1
	splashPart.Parent = workspace

	-- Gouttelettes d'eau
	local drops = Instance.new("ParticleEmitter")
	drops.Color = ColorSequence.new(
		Color3.fromRGB(120, 180, 220),
		Color3.fromRGB(200, 230, 255)
	)
	drops.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.15),
		NumberSequenceKeypoint.new(1, 0),
	})
	drops.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	drops.Lifetime = NumberRange.new(0.3, 0.8)
	drops.Speed = NumberRange.new(3, 8)
	drops.SpreadAngle = Vector2.new(60, 60)
	drops.Rate = 0
	drops.Parent = splashPart
	drops:Emit(15)

	-- Paillettes dorées qui s'envolent
	local goldFlakes = Instance.new("ParticleEmitter")
	goldFlakes.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
	goldFlakes.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(1, 0),
	})
	goldFlakes.Lifetime = NumberRange.new(0.5, 1.2)
	goldFlakes.Speed = NumberRange.new(1, 4)
	goldFlakes.SpreadAngle = Vector2.new(90, 40)
	goldFlakes.LightEmission = 0.6
	goldFlakes.Rate = 0
	goldFlakes.Parent = splashPart
	goldFlakes:Emit(8)

	-- Lueur dorée douce
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(255, 220, 100)
	glow.Brightness = 1.5
	glow.Range = 8
	glow.Parent = splashPart

	TweenService:Create(glow, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 0,
	}):Play()

	task.delay(2, function()
		splashPart:Destroy()
	end)
end

-- Son d'eau désactivé
local function PlayWaterSound()
	-- supprimé
end

-- ═══════════════════════════════════════════
-- CONNEXION DES PROXIMITYPROMPTS
-- ═══════════════════════════════════════════
local function ConnectPrompt(prompt)
	prompt.Triggered:Connect(function()
		if isMining then return end

		local deposit = GetDeposit(prompt)
		if not deposit then
			print("[MiningClient] Deposit introuvable pour ce prompt")
			return
		end

		local character = player.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not hrp then return end

		isMining = true
		prompt.Enabled = false

		-- Position du dépôt
		local depositPos = GetDepositPosition(deposit)

		-- Orienter le personnage face au dépôt (avec sécurité distance)
		local dx = depositPos.X - hrp.Position.X
		local dz = depositPos.Z - hrp.Position.Z
		if math.abs(dx) > 0.5 or math.abs(dz) > 0.5 then
			local lookTarget = Vector3.new(depositPos.X, hrp.Position.Y, depositPos.Z)
			hrp.CFrame = CFrame.lookAt(hrp.Position, lookTarget)
		end

		-- Auto-équiper un outil
		local tool = AutoEquipTool(character, humanoid)
		print("[MiningClient] Outil équipé:", tool and tool.Name or "AUCUN")

		-- Jouer l'animation de minage
		local animDuration = 0
		if ToolAnimator:HasMineAnimation() then
			-- Animation track (configurée dans AnimationConfig)
			animDuration = ToolAnimator:PlayMineAnimation()
		else
			-- Fallback : animation procédurale Grip tween
			animDuration = PlayPanningAnimation(character) or 1.0
		end

		-- Éclaboussures d'eau + paillettes pendant le swirl
		task.delay(math.min(0.35, animDuration * 0.25), function()
			PlayWaterSplashEffect(depositPos)
			PlayWaterSound()
		end)

		-- Attendre la fin de l'animation
		task.wait(animDuration)

		-- Envoyer la requête au serveur
		Events.RequestMine:FireServer(deposit.Name)
		print("[MiningClient] RequestMine envoyé pour:", deposit.Name)

		-- Réactiver après un court délai
		task.delay(0.5, function()
			if prompt and prompt.Parent then
				prompt.Enabled = true
			end
			isMining = false
		end)
	end)
end

-- Écouter les nouveaux gisements
ActiveGoldDeposits.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("ProximityPrompt") then
		ConnectPrompt(descendant)
	end
end)

-- Connecter les prompts déjà présents
for _, deposit in ActiveGoldDeposits:GetChildren() do
	local prompt = deposit:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		ConnectPrompt(prompt)
	end
end

-- ═══════════════════════════════════════════
-- RÉSULTAT DE MINAGE
-- ═══════════════════════════════════════════
Events.MineResult.OnClientEvent:Connect(function(success, drops, xpGained)
	if success then
		-- Loot feed screen-space (items + XP)
		UIManager:ShowLootFeed(drops, xpGained)

		-- Particules dorées autour du perso
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			UIManager:PlayMineEffect(character.HumanoidRootPart.Position)
		end

		UIManager:RefreshHUD()
	else
		UIManager:ShowNotification(tostring(drops), "Error")
	end
end)

print("[MiningClient] Initialisé ✓")
