--[[
	AnimationConfig.lua (ModuleScript)
	ROLE : IDs d'animation pour chaque outil.
	       Créer les animations dans l'Animation Editor de Studio,
	       publier, puis remplacer les "rbxassetid://0" par les vrais IDs.
]]

local AnimationConfig = {}

-- ═══════════════════════════════════════════
-- ANIMATION IDS PAR OUTIL
-- Remplacer "rbxassetid://0" par tes IDs
-- ═══════════════════════════════════════════
AnimationConfig.Tools = {
	Batee = {
		Idle = "rbxassetid://0",    -- Pose idle avec batée en main
		Equip = "rbxassetid://0",   -- Sortir la batée
		Mine = "rbxassetid://0",    -- Mouvement de tamisage (secouer la batée)
	},
	Tapis = {
		Idle = "rbxassetid://0",    -- Pose idle avec tapis
		Equip = "rbxassetid://0",   -- Déployer le tapis
		Mine = "rbxassetid://0",    -- Poser et filtrer
	},
	Pioche = {
		Idle = "rbxassetid://0",    -- Pose idle pioche sur l'épaule
		Equip = "rbxassetid://0",   -- Sortir la pioche
		Mine = "rbxassetid://0",    -- Swing de pioche (lever + frapper)
	},
}

-- ═══════════════════════════════════════════
-- PARAMÈTRES
-- ═══════════════════════════════════════════
AnimationConfig.Settings = {
	IdleFadeTime = 0.3,
	EquipFadeTime = 0.2,
	MineFadeTime = 0.1,
	IdleResumeDelay = 0.3,
}

return AnimationConfig
