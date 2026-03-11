--[[ NPCAnimator — Client-side NPC idle animations + idle chatter ]]

local Workspace = game:GetService("Workspace")

local UIManager = require(script.Parent.Parent.Core.UIManager)

local IDLE_ANIM_ID = "rbxassetid://507766388"
local animatedNPCs = {}

-- ═══════════════════════════════════════════
-- IDLE PHRASES (random chatter)
-- ═══════════════════════════════════════════
local IDLE_PHRASES = {
	ToolVendor = {
		"Hé toi ! Tu veux un bon outil ?",
		"Mes outils sont les meilleurs du comté !",
		"Pioche flambant neuve, ça t'intéresse ?",
		"*astique une pioche*",
		"L'acier vient direct de la forge de Gustave !",
		"Un bon outil, c'est la moitié du travail !",
	},
	Marcel = {
		"Or frais ! Qui a de l'or frais ?",
		"Les prix sont bons aujourd'hui !",
		"*compte ses pièces*",
		"Approche, je fais de bons deals !",
		"Du bel or, c'est tout ce que je demande !",
		"*examine une pépite*",
	},
	Gustave = {
		"*martèle l'enclume*",
		"Le feu est bon aujourd'hui...",
		"Apporte-moi du minerai !",
		"*essuie la sueur de son front*",
		"Ma forge transforme le brut en or pur !",
		"*souffle sur les braises*",
	},
	Bill = {
		"Un p'tit whisky, cow-boy ?",
		"*essuie un verre*",
		"Le Saloon est ouvert !",
		"Mes boissons donnent du courage !",
		"*siffle un air de saloon*",
		"La tournée est pour moi... ou pas !",
	},
	Guide = {
		"La rivière cache bien des trésors...",
		"Nouveau par ici ?",
		"Les Collines sont dangereuses pour les débutants...",
		"Suivez le courant, l'or s'y dépose...",
		"*regarde la rivière au loin*",
		"Patience et batée, voilà le secret !",
	},
}

-- ═══════════════════════════════════════════
-- IDLE ANIMATION
-- ═══════════════════════════════════════════
local function animateNPC(npcModel)
	if animatedNPCs[npcModel] then return end
	animatedNPCs[npcModel] = true

	local humanoid = npcModel:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local idleAnim = Instance.new("Animation")
	idleAnim.AnimationId = IDLE_ANIM_ID

	local ok, track = pcall(function()
		return animator:LoadAnimation(idleAnim)
	end)

	if ok and track then
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Idle
		track:Play()
		print(`[NPCAnimator] Idle lancée pour {npcModel.Name}`)
	else
		warn(`[NPCAnimator] Échec pour {npcModel.Name}: {tostring(track)}`)
	end
end

-- ═══════════════════════════════════════════
-- IDLE CHATTER LOOP
-- ═══════════════════════════════════════════
local function startIdleChatter(npcModel)
	local phrases = IDLE_PHRASES[npcModel.Name]
	if not phrases then return end

	task.spawn(function()
		-- Random initial delay so all NPCs don't talk at once
		task.wait(math.random(5, 15))

		while npcModel and npcModel.Parent do
			local phrase = phrases[math.random(1, #phrases)]
			UIManager:ShowNPCBubble(npcModel, phrase, 4)

			-- Wait 12-25 seconds before next phrase
			task.wait(math.random(12, 25))
		end
	end)
end

-- ═══════════════════════════════════════════
-- SCAN FOR NPCs
-- ═══════════════════════════════════════════
local function setupNPC(npcModel)
	if npcModel:IsA("Model") and npcModel:FindFirstChildOfClass("Humanoid") then
		task.spawn(animateNPC, npcModel)
		startIdleChatter(npcModel)
	end
end

local function scanForNPCs()
	local world = Workspace:WaitForChild("World", 15)
	if not world then return end

	local npcFolder = world:WaitForChild("TownNPCs", 10)
	if not npcFolder then return end

	for _, child in npcFolder:GetChildren() do
		setupNPC(child)
	end

	npcFolder.ChildAdded:Connect(function(child)
		task.wait(1)
		setupNPC(child)
	end)
end

task.delay(3, scanForNPCs)
print("[NPCAnimator] Initialisé ✓")
