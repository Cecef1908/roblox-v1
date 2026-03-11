--[[
	QuestManager.lua (ModuleScript)
	ROLE : Gere les quetes quotidiennes — attribution, suivi de progression,
	       completion, recompenses, reset quotidien.
	DEPENDANCES : DataManager, QuestConfig, GemConfig
]]

local QuestManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)
local QuestConfig = require(ReplicatedStorage.Modules.Config.QuestConfig)
local GemConfig = require(ReplicatedStorage.Modules.Config.GemConfig)

-- Set de noms de gemmes pour détection rapide
local GEM_NAMES = {}
for gemName in pairs(GemConfig.Gems) do
	GEM_NAMES[gemName] = true
end

-- ==========================================
-- INIT
-- ==========================================
function QuestManager:Init()
	local events = ReplicatedStorage.Events.RemoteEvents

	events.RequestQuestData.OnServerEvent:Connect(function(player)
		self:SendQuestData(player)
	end)

	print("[QuestManager] Initialisé ✓")
end

-- ==========================================
-- DAILY RESET — Vérifie et assigne les quêtes
-- ==========================================
function QuestManager:CheckDailyReset(player: Player)
	local data = DataManager:GetData(player)
	if not data then return end

	local now = os.time()
	local lastReset = data.Quests.DailyReset or 0

	-- Calcul du dernier reset UTC 00:00
	local resetHour = QuestConfig.QUEST_RESET_HOUR_UTC or 0
	local todayReset = math.floor(now / 86400) * 86400 + resetHour * 3600
	if todayReset > now then
		todayReset = todayReset - 86400
	end

	if lastReset < todayReset then
		self:AssignDailyQuests(player, data)
		data.Quests.DailyReset = now
		data.Quests.Completed = {}
		print(`[QuestManager] Quêtes quotidiennes assignées pour {player.Name}`)
	end
end

-- ==========================================
-- ASSIGNER LES QUÊTES QUOTIDIENNES
-- ==========================================
function QuestManager:AssignDailyQuests(player: Player, data)
	local level = data.Level or 1
	local count = QuestConfig.DAILY_QUEST_COUNT

	-- Filtrer les quêtes éligibles pour le niveau du joueur
	local eligible = {}
	for _, quest in ipairs(QuestConfig.DailyQuestPool) do
		if level >= quest.MinLevel then
			table.insert(eligible, quest)
		end
	end

	-- Mélanger (Fisher-Yates)
	for i = #eligible, 2, -1 do
		local j = math.random(1, i)
		eligible[i], eligible[j] = eligible[j], eligible[i]
	end

	-- Prendre les N premières
	data.Quests.Active = {}
	for i = 1, math.min(count, #eligible) do
		table.insert(data.Quests.Active, {
			Id = eligible[i].Id,
			Progress = 0,
		})
	end
end

-- ==========================================
-- PROGRESSION — MINAGE
-- ==========================================
function QuestManager:OnMineGold(player: Player, itemName: string, quantity: number)
	local data = DataManager:GetData(player)
	if not data then return end

	for _, activeQuest in ipairs(data.Quests.Active) do
		-- Skip already completed
		if not self:IsCompleted(data, activeQuest.Id) then
			local questDef = self:GetQuestDef(activeQuest.Id)
			if questDef and questDef.Type == "Collect" then
				local match = false
				if questDef.Target == itemName then
					match = true
				elseif questDef.Target == "AnyGem" and GEM_NAMES[itemName] then
					match = true
				end

				if match then
					activeQuest.Progress = activeQuest.Progress + quantity
					self:CheckCompletion(player, data, activeQuest, questDef)
				end
			end
		end
	end
end

-- ==========================================
-- PROGRESSION — VENTE
-- ==========================================
function QuestManager:OnSellTransaction(player: Player, itemName: string, quantity: number, totalCash: number)
	local data = DataManager:GetData(player)
	if not data then return end

	for _, activeQuest in ipairs(data.Quests.Active) do
		if not self:IsCompleted(data, activeQuest.Id) then
			local questDef = self:GetQuestDef(activeQuest.Id)
			if questDef then
				if questDef.Type == "Sell" and questDef.Target == "AnyTransaction" then
					activeQuest.Progress = activeQuest.Progress + 1
					self:CheckCompletion(player, data, activeQuest, questDef)
				elseif questDef.Type == "Earn" and questDef.Target == "Cash" then
					activeQuest.Progress = activeQuest.Progress + totalCash
					self:CheckCompletion(player, data, activeQuest, questDef)
				end
			end
		end
	end
end

-- ==========================================
-- PROGRESSION — CRAFT
-- ==========================================
function QuestManager:OnCraft(player: Player, outputItem: string, quantity: number)
	local data = DataManager:GetData(player)
	if not data then return end

	for _, activeQuest in ipairs(data.Quests.Active) do
		if not self:IsCompleted(data, activeQuest.Id) then
			local questDef = self:GetQuestDef(activeQuest.Id)
			if questDef and questDef.Type == "Craft" and questDef.Target == outputItem then
				activeQuest.Progress = activeQuest.Progress + quantity
				self:CheckCompletion(player, data, activeQuest, questDef)
			end
		end
	end
end

-- ==========================================
-- VÉRIFIER COMPLÉTION D'UNE QUÊTE
-- ==========================================
function QuestManager:CheckCompletion(player: Player, data, activeQuest, questDef)
	if activeQuest.Progress < questDef.Goal then return end

	-- Cap la progression au goal
	activeQuest.Progress = questDef.Goal
	table.insert(data.Quests.Completed, activeQuest.Id)

	-- Donner les récompenses
	if questDef.Reward.Cash and questDef.Reward.Cash > 0 then
		DataManager:AddCash(player, questDef.Reward.Cash)
	end
	if questDef.Reward.XP and questDef.Reward.XP > 0 then
		DataManager:AddXP(player, questDef.Reward.XP)
	end

	-- Notifier le client — completion
	local events = ReplicatedStorage.Events.RemoteEvents
	local questCompleteEvent = events:FindFirstChild("QuestCompleted")
	if questCompleteEvent then
		questCompleteEvent:FireClient(player, questDef.Title, questDef.Reward)
	end

	-- Mettre à jour les données client
	local updateEvent = events:FindFirstChild("PlayerDataUpdated")
	if updateEvent then
		local updatedData = DataManager:GetData(player)
		if updatedData then
			updateEvent:FireClient(player, updatedData)
		end
	end

	print(`[QuestManager] {player.Name} a complété: {questDef.Title} (+{questDef.Reward.Cash}$ +{questDef.Reward.XP}XP)`)
end

-- ==========================================
-- ENVOYER LES DONNÉES AU CLIENT
-- ==========================================
function QuestManager:SendQuestData(player: Player)
	local data = DataManager:GetData(player)
	if not data then return end

	local questsInfo = {}
	for _, activeQuest in ipairs(data.Quests.Active) do
		local questDef = self:GetQuestDef(activeQuest.Id)
		if questDef then
			table.insert(questsInfo, {
				Id = activeQuest.Id,
				Title = questDef.Title,
				Description = questDef.Description,
				Progress = activeQuest.Progress,
				Goal = questDef.Goal,
				Reward = questDef.Reward,
				Completed = self:IsCompleted(data, activeQuest.Id),
			})
		end
	end

	local event = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("QuestDataResponse")
	if event then
		event:FireClient(player, questsInfo)
	end
end

-- ==========================================
-- HELPERS
-- ==========================================
function QuestManager:GetQuestDef(questId: string)
	for _, quest in ipairs(QuestConfig.DailyQuestPool) do
		if quest.Id == questId then
			return quest
		end
	end
	return nil
end

function QuestManager:IsCompleted(data, questId: string): boolean
	for _, completedId in ipairs(data.Quests.Completed) do
		if completedId == questId then
			return true
		end
	end
	return false
end

return QuestManager
