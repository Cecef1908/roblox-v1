--[[
	ToolAnimator.lua (ModuleScript)
	ROLE : Gère les animations d'outils côté client.
	       Charge les tracks (idle, equip, mine) quand un outil est équipé.
	       Expose PlayMineAnimation() pour que MiningClient puisse déclencher l'anim.
]]

local ToolAnimator = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationConfig = require(ReplicatedStorage.Modules.Config.AnimationConfig)

local player = Players.LocalPlayer

-- État interne
local currentTracks = {} -- { idle: AnimationTrack?, equip: AnimationTrack?, mine: AnimationTrack? }
local currentToolName = nil
local isInitialized = false

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════
local function GetAnimator(character): Animator?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	-- Animator est un enfant du Humanoid
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	return animator
end

local function StopAllTracks()
	for _, track in pairs(currentTracks) do
		if track and track.IsPlaying then
			track:Stop(0.2)
		end
	end
	currentTracks = {}
	currentToolName = nil
end

local function LoadTrack(animator: Animator, animId: string): AnimationTrack?
	if not animId or animId == "" or animId == "rbxassetid://0" then
		return nil
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = animId

	local ok, track = pcall(function()
		return animator:LoadAnimation(anim)
	end)

	if ok and track then
		return track
	end

	warn("[ToolAnimator] Erreur chargement animation:", animId)
	return nil
end

-- ═══════════════════════════════════════════
-- EQUIP / UNEQUIP
-- ═══════════════════════════════════════════
local function OnToolEquipped(tool: Tool)
	local character = player.Character
	if not character then return end

	local animator = GetAnimator(character)
	if not animator then return end

	local toolName = tool.Name
	local animData = AnimationConfig.Tools[toolName]
	if not animData then
		print(`[ToolAnimator] Pas de config animation pour: {toolName}`)
		return
	end

	-- Stop les tracks précédents
	StopAllTracks()
	currentToolName = toolName

	-- Charger les tracks
	local settings = AnimationConfig.Settings
	currentTracks.idle = LoadTrack(animator, animData.Idle)
	currentTracks.equip = LoadTrack(animator, animData.Equip)
	currentTracks.mine = LoadTrack(animator, animData.Mine)

	-- Configurer les priorités
	if currentTracks.idle then
		currentTracks.idle.Priority = Enum.AnimationPriority.Idle
		currentTracks.idle.Looped = true
	end
	if currentTracks.equip then
		currentTracks.equip.Priority = Enum.AnimationPriority.Action
		currentTracks.equip.Looped = false
	end
	if currentTracks.mine then
		currentTracks.mine.Priority = Enum.AnimationPriority.Action2
		currentTracks.mine.Looped = false
	end

	-- Jouer equip → puis idle
	if currentTracks.equip then
		currentTracks.equip:Play(settings.EquipFadeTime)
		currentTracks.equip.Stopped:Once(function()
			if currentTracks.idle and currentToolName == toolName then
				currentTracks.idle:Play(settings.IdleFadeTime)
			end
		end)
	elseif currentTracks.idle then
		currentTracks.idle:Play(settings.IdleFadeTime)
	end

	print(`[ToolAnimator] Équipé: {toolName}`)
end

local function OnToolUnequipped()
	StopAllTracks()
	print("[ToolAnimator] Déséquipé")
end

-- ═══════════════════════════════════════════
-- API PUBLIQUE
-- ═══════════════════════════════════════════

--- Joue l'animation de minage. Retourne la durée de l'animation.
--- Si aucune animation configurée, retourne 0.
function ToolAnimator:PlayMineAnimation(): number
	local settings = AnimationConfig.Settings

	if currentTracks.mine then
		-- Pause idle
		if currentTracks.idle and currentTracks.idle.IsPlaying then
			currentTracks.idle:Stop(settings.MineFadeTime)
		end

		currentTracks.mine:Play(settings.MineFadeTime)

		-- Reprendre idle après le mine
		local savedTool = currentToolName
		currentTracks.mine.Stopped:Once(function()
			if currentTracks.idle and currentToolName == savedTool then
				currentTracks.idle:Play(settings.IdleResumeDelay)
			end
		end)

		return currentTracks.mine.Length
	end

	-- Pas d'animation configurée
	return 0
end

--- Vérifie si une animation de minage est chargée
function ToolAnimator:HasMineAnimation(): boolean
	return currentTracks.mine ~= nil
end

--- Retourne le nom de l'outil actuellement équipé
function ToolAnimator:GetCurrentToolName(): string?
	return currentToolName
end

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
function ToolAnimator:Init()
	if isInitialized then return end
	isInitialized = true

	local function SetupCharacter(character)
		-- Écouter equip/unequip
		character.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				OnToolEquipped(child)
			end
		end)
		character.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") then
				OnToolUnequipped()
			end
		end)

		-- Vérifier si un outil est déjà équipé
		local existingTool = character:FindFirstChildOfClass("Tool")
		if existingTool then
			OnToolEquipped(existingTool)
		end
	end

	if player.Character then
		SetupCharacter(player.Character)
	end
	player.CharacterAdded:Connect(SetupCharacter)

	print("[ToolAnimator] Initialisé ✓")
end

return ToolAnimator
