--[[
	StoryManager.lua (ModuleScript)
	ROLE : Gère la quête principale (story quest chain).
	       8 étapes du spawn à la cabane jusqu'au free roam.
	NOTE : Utilise Tutorial.Step et Tutorial.Completed dans PlayerData.
]]

local StoryManager = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)

-- ═══════════════════════════════════════════
-- STORY STEPS
-- ═══════════════════════════════════════════
local STEPS = {
	{
		id = 1,
		name = "L'Héritage",
		objective = "Prends la batée au mur de la cabane",
		message = "La cabane de ton grand-père Eli... Il a laissé sa batée accrochée au mur. Prends-la.",
		autoComplete = 5, -- complete après 5 secondes (batée déjà donnée)
	},
	{
		id = 2,
		name = "Premier Or",
		objective = "Va au ruisseau et mine ton premier gisement (E)",
		message = "Le ruisseau coule en contrebas. Trouve un gisement doré et utilise ta batée.",
		completionType = "mine", -- complete quand le joueur mine
	},
	{
		id = 3,
		name = "La Lettre",
		objective = "Retourne à la cabane d'Eli",
		message = "Bien joué ! Retourne à la cabane... quelque chose t'y attend.",
		completionType = "proximity",
		targetPos = Vector3.new(944, 40, 562), -- cabane
		targetRadius = 30,
	},
	{
		id = 4,
		name = "Fragment #1",
		objective = "Lis la lettre d'Eli",
		message = "\"Mon cher petit-fils... j'ai trouvé quelque chose... les ombres s'allongent... Ne cherche pas la richesse. Cherche la...\"",
		autoComplete = 8, -- temps de lecture
	},
	{
		id = 5,
		name = "Le Coyote",
		objective = "Suis le Coyote vers la ville",
		message = "Un coyote t'observe depuis un rocher. Il s'éloigne vers le sud... Suis-le.",
		completionType = "proximity",
		targetPos = Vector3.new(484, 40, 485), -- cratère Dusthaven
		targetRadius = 60,
	},
	{
		id = 6,
		name = "Dusthaven",
		objective = "Parle à Marcel le Marchand et vends ton or (E)",
		message = "DUSTHAVEN — Le village des chercheurs d'or. Trouve Marcel le Marchand pour vendre tes trouvailles.",
		completionType = "sell", -- complete quand le joueur vend
	},
	{
		id = 7,
		name = "S'Équiper",
		objective = "Achète un outil chez Jacques l'Outilleur (E)",
		message = "Bien ! Maintenant améliore ton équipement chez Jacques l'Outilleur.",
		completionType = "buyTool", -- complete quand le joueur achète
	},
	{
		id = 8,
		name = "Libre",
		objective = "Explore Dusthaven et ses secrets...",
		message = "Tu es prêt ! Explore, mine, et découvre les secrets de Dusthaven. Les quêtes quotidiennes t'attendent.",
		autoComplete = 5,
		isFinal = true,
	},
}

-- État par joueur
local PlayerStory = {} -- { [userId] = { step, proximityConn } }

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
function StoryManager:Init()
	print("[StoryManager] Initialisé ✓")
end

-- ═══════════════════════════════════════════
-- START / RESUME story pour un joueur
-- ═══════════════════════════════════════════
function StoryManager:StartForPlayer(player: Player)
	local data = DataManager:GetData(player)
	if not data then return end

	-- Déjà terminé
	if data.Tutorial.Completed then return end

	local step = data.Tutorial.Step or 1
	print(`[StoryManager] Démarrage story pour {player.Name} — Step {step}`)

	PlayerStory[player.UserId] = { step = step }
	self:ActivateStep(player, step)
end

-- ═══════════════════════════════════════════
-- ACTIVER UN STEP
-- ═══════════════════════════════════════════
function StoryManager:ActivateStep(player: Player, stepNum: number)
	local stepDef = STEPS[stepNum]
	if not stepDef then return end

	local events = ReplicatedStorage.Events.RemoteEvents

	-- Envoyer l'objectif au client
	events.StartTutorial:FireClient(player, {
		step = stepNum,
		name = stepDef.name,
		objective = stepDef.objective,
		message = stepDef.message,
		isFinal = stepDef.isFinal,
	})

	print(`[StoryManager] Step {stepNum}: {stepDef.name} — {stepDef.objective}`)

	-- Auto-complete (timer)
	if stepDef.autoComplete then
		task.delay(stepDef.autoComplete, function()
			if PlayerStory[player.UserId] and PlayerStory[player.UserId].step == stepNum then
				self:CompleteStep(player, stepNum)
			end
		end)
	end

	-- Proximity check
	if stepDef.completionType == "proximity" then
		task.spawn(function()
			while PlayerStory[player.UserId] and PlayerStory[player.UserId].step == stepNum do
				local character = player.Character
				if character then
					local hrp = character:FindFirstChild("HumanoidRootPart")
					if hrp then
						local dist = (hrp.Position - stepDef.targetPos).Magnitude
						if dist <= stepDef.targetRadius then
							self:CompleteStep(player, stepNum)
							return
						end
					end
				end
				task.wait(1)
			end
		end)
	end
end

-- ═══════════════════════════════════════════
-- COMPLETE UN STEP
-- ═══════════════════════════════════════════
function StoryManager:CompleteStep(player: Player, stepNum: number)
	local state = PlayerStory[player.UserId]
	if not state or state.step ~= stepNum then return end

	local data = DataManager:GetData(player)
	if not data then return end

	local stepDef = STEPS[stepNum]
	print(`[StoryManager] Step {stepNum} COMPLETE pour {player.Name}: {stepDef.name}`)

	-- Marquer la progression
	if stepDef.isFinal then
		data.Tutorial.Completed = true
		data.Tutorial.Step = stepNum
		PlayerStory[player.UserId] = nil

		-- Notification finale
		local events = ReplicatedStorage.Events.RemoteEvents
		events.NotifyPlayer:FireClient(player, "Tutoriel terminé ! Les quêtes quotidiennes t'attendent.")
		events.PlayerDataUpdated:FireClient(player, data)
		print(`[StoryManager] Story TERMINEE pour {player.Name}`)
	else
		-- Passer au step suivant
		local nextStep = stepNum + 1
		data.Tutorial.Step = nextStep
		state.step = nextStep

		events = ReplicatedStorage.Events.RemoteEvents
		events.PlayerDataUpdated:FireClient(player, data)

		-- Petit délai avant le prochain step
		task.delay(2, function()
			self:ActivateStep(player, nextStep)
		end)
	end
end

-- ═══════════════════════════════════════════
-- CALLBACKS (appelés par les autres systèmes)
-- ═══════════════════════════════════════════
function StoryManager:OnMineGold(player: Player)
	local state = PlayerStory[player.UserId]
	if state and state.step == 2 then
		self:CompleteStep(player, 2)
	end
end

function StoryManager:OnSell(player: Player)
	local state = PlayerStory[player.UserId]
	if state and state.step == 6 then
		self:CompleteStep(player, 6)
	end
end

function StoryManager:OnBuyTool(player: Player)
	local state = PlayerStory[player.UserId]
	if state and state.step == 7 then
		self:CompleteStep(player, 7)
	end
end

-- Cleanup quand le joueur quitte
function StoryManager:OnPlayerRemoving(player: Player)
	PlayerStory[player.UserId] = nil
end

return StoryManager
