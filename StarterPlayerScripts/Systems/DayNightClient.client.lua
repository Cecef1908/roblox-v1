--[[ DayNightClient — Effets visuels jour/nuit côté client
	Écoute le ClockTime du Lighting et ajuste :
	- ColorCorrection (teinte chaude jour → bleutée nuit)
	- Lampes/torches (allumées la nuit, éteintes le jour)
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Trouver la ColorCorrection créée par MapBuilder
local cc = nil
for _, child in Lighting:GetChildren() do
	if child:IsA("ColorCorrectionEffect") then
		cc = child
		break
	end
end

local lastIsNight = false

local function isNightTime(hour)
	return hour >= 20 or hour < 6
end

local function isSunsetTime(hour)
	return hour >= 17 and hour < 20
end

local function updateVisuals()
	local hour = Lighting.ClockTime

	-- ColorCorrection — teinte chaude jour, bleutée nuit
	if cc then
		if isNightTime(hour) then
			cc.TintColor = Color3.fromRGB(180, 190, 230)
			cc.Brightness = -0.05
			cc.Contrast = 0.08
			cc.Saturation = -0.15
		elseif isSunsetTime(hour) then
			local t = (hour - 17) / 3
			cc.TintColor = Color3.fromRGB(255, 240, 210):Lerp(Color3.fromRGB(180, 190, 230), t)
			cc.Brightness = 0.02 - t * 0.07
			cc.Saturation = 0.1 - t * 0.25
		elseif hour >= 5 and hour < 8 then
			-- Lever de soleil — teinte rose-dorée
			local t = (hour - 5) / 3
			cc.TintColor = Color3.fromRGB(180, 190, 230):Lerp(Color3.fromRGB(255, 230, 200), t)
			cc.Brightness = -0.05 + t * 0.07
			cc.Saturation = -0.15 + t * 0.25
		else
			cc.TintColor = Color3.fromRGB(255, 240, 210)
			cc.Brightness = 0.02
			cc.Contrast = 0.05
			cc.Saturation = 0.1
		end
	end

	-- Allumer/éteindre les lumières
	local night = isNightTime(hour)
	if night ~= lastIsNight then
		lastIsNight = night
		toggleLights(night)
	end
end

function toggleLights(on)
	-- Lampes de la ville (Workspace)
	for _, obj in Workspace:GetChildren() do
		if obj.Name:match("^Lamppost_") or obj.Name:match("Light$") then
			for _, desc in obj:GetDescendants() do
				if desc:IsA("PointLight") or desc:IsA("SpotLight") then
					desc.Enabled = on
				end
			end
		end
	end

	-- Lumières dans le monde généré (torches, lampes mine)
	local world = Workspace:FindFirstChild("World")
	if world then
		for _, desc in world:GetDescendants() do
			if desc:IsA("PointLight") then
				-- Les lumières de zone (torches, lampes mine) toujours allumées la nuit
				-- Réduire le jour
				if on then
					desc.Brightness = desc:GetAttribute("NightBrightness") or desc.Brightness
				else
					if not desc:GetAttribute("NightBrightness") then
						desc:SetAttribute("NightBrightness", desc.Brightness)
					end
					-- Garder les lumières des cristaux/gisements même le jour (mais réduites)
					desc.Brightness = desc.Brightness * 0.3
				end
			end
		end
	end

	local state = if on then "NUIT" else "JOUR"
	print(`[DayNight] Transition → {state} ({math.floor(Lighting.ClockTime)}h)`)
end

-- Update toutes les secondes (pas besoin de frame-par-frame)
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed >= 1 then
		elapsed = 0
		updateVisuals()
	end
end)

print("[DayNightClient] Initialisé ✓")
