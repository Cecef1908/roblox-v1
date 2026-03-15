--[[
    DevTools.client.lua (LocalScript)
    ROLE : Outils de dev pour tester le jeu rapidement.
           Sprint (Shift), teleport via chat commands.
    NOTE : A retirer avant publication.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ═══════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════
local WALK_SPEED = 16
local SPRINT_SPEED = 50
local TURBO_SPEED = 160
local SPRINT_KEY = Enum.KeyCode.LeftShift
local TURBO_KEY = Enum.KeyCode.V
local FLY_KEY = Enum.KeyCode.G

-- Teleport destinations (Roblox coords X, Y, Z)
local TELEPORTS = {
	cratere = Vector3.new(484, 40, 485),
	cabane = Vector3.new(944, 50, 562),
	cascade = Vector3.new(890, 50, 648),
	tuto = Vector3.new(868, 50, 566),
	jed = Vector3.new(488, 40, 546),
	saloon = Vector3.new(417, 40, 501),
	forge = Vector3.new(538, 40, 447),
	sheriff = Vector3.new(456, 40, 433),
	pontnord = Vector3.new(754, 40, 511),
	pontsud = Vector3.new(774, 40, 262),
	meteorite = Vector3.new(484, 40, 485),
	berge = Vector3.new(916, 40, 429),
	courbe = Vector3.new(814, 40, 47),
	gatez2 = Vector3.new(148, 40, 73),
	spawn = Vector3.new(615, 40, 525),
}

-- ═══════════════════════════════════════════
-- SPRINT (Shift)
-- ═══════════════════════════════════════════
local sprinting = false
local turbo = false
local flying = false
local flyBodyVelocity = nil
local flyBodyGyro = nil

local function getSpeed()
	if turbo then return TURBO_SPEED end
	if sprinting then return SPRINT_SPEED end
	return WALK_SPEED
end

local function updateSpeed()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = getSpeed()
	end
end

-- ═══════════════════════════════════════════
-- FLY MODE (F)
-- ═══════════════════════════════════════════
local function startFly()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	flying = true
	humanoid.PlatformStand = true

	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.Velocity = Vector3.zero
	flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	flyBodyVelocity.Parent = hrp

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	flyBodyGyro.D = 200
	flyBodyGyro.P = 10000
	flyBodyGyro.Parent = hrp

	print("[DevTools] FLY ON")
end

local function stopFly()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end

	if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
	if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
	flying = false
	print("[DevTools] FLY OFF")
end

-- Update fly velocity every frame
RunService.Heartbeat:Connect(function()
	if not flying or not flyBodyVelocity then return end
	local camera = game.Workspace.CurrentCamera
	local character = player.Character
	if not character or not camera then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local speed = if turbo then TURBO_SPEED * 2 else 80
	local moveDir = Vector3.zero

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		moveDir = moveDir + camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveDir = moveDir - camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveDir = moveDir - camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveDir = moveDir + camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		moveDir = moveDir + Vector3.new(0, 1, 0)
	end
	if UserInputService:IsKeyDown(SPRINT_KEY) then
		moveDir = moveDir - Vector3.new(0, 1, 0)
	end

	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit * speed
	end

	flyBodyVelocity.Velocity = moveDir
	flyBodyGyro.CFrame = camera.CFrame
end)

-- ═══════════════════════════════════════════
-- INPUT
-- ═══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == SPRINT_KEY then
		sprinting = true
		updateSpeed()
	elseif input.KeyCode == TURBO_KEY then
		turbo = true
		updateSpeed()
	elseif input.KeyCode == FLY_KEY then
		if flying then
			stopFly()
		else
			startFly()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == SPRINT_KEY then
		sprinting = false
		updateSpeed()
	elseif input.KeyCode == TURBO_KEY then
		turbo = false
		updateSpeed()
	end
end)

-- Reset on respawn
player.CharacterAdded:Connect(function(character)
	flying = false
	flyBodyVelocity = nil
	flyBodyGyro = nil
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = WALK_SPEED
end)

-- ═══════════════════════════════════════════
-- TELEPORT (chat commands: /tp destination)
-- ═══════════════════════════════════════════
local function teleportTo(destination)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local target = TELEPORTS[destination:lower()]
	if target then
		hrp.CFrame = CFrame.new(target)
		print(`[DevTools] TP → {destination} ({target})`)
	else
		-- List available destinations
		local names = {}
		for name in pairs(TELEPORTS) do
			table.insert(names, name)
		end
		table.sort(names)
		print(`[DevTools] Destination inconnue: {destination}`)
		print(`[DevTools] Disponibles: {table.concat(names, ", ")}`)
	end
end

-- Dev commands via chat (both legacy + TextChatService)
local RS = game:GetService("ReplicatedStorage")

local function handleChat(message)
	local tpCmd = message:match("^/tp%s+(.+)")
	if tpCmd then
		teleportTo(tpCmd:match("^%s*(.-)%s*$"))
		return
	end
	-- Server commands: /give, /lvlup
	if message == "/give" or message == "/lvlup" then
		local devEvent = RS:WaitForChild("Events"):WaitForChild("RemoteEvents"):FindFirstChild("DevCommand")
		if devEvent then
			devEvent:FireServer(message)
			print("[DevTools] Commande envoyée au serveur: " .. message)
		end
	end
end

player.Chatted:Connect(handleChat)

local TextChatService = game:GetService("TextChatService")
TextChatService.MessageReceived:Connect(function(textChatMessage)
	if textChatMessage.TextSource and textChatMessage.TextSource.UserId == player.UserId then
		handleChat(textChatMessage.Text)
	end
end)

print("[DevTools] Initialisé ✓")
print("[DevTools] Shift=Sprint x3 | V=Turbo x10 | G=Fly | /tp [lieu]")
print("[DevTools] Lieux: cratere, cabane, cascade, jed, saloon, forge, sheriff, pontnord, pontsud, berge, spawn")
