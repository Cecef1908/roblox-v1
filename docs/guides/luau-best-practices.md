# Roblox Luau Scripting Best Practices & Patterns (2025-2026)

> Comprehensive reference for building a mining tycoon game ("Gold Rush Legacy") with modern Luau patterns.

---

## Table of Contents

1. [Code Architecture Patterns](#1-code-architecture-patterns)
2. [Data Management](#2-data-management)
3. [Networking](#3-networking)
4. [Performance Optimization](#4-performance-optimization)
5. [Type Checking](#5-type-checking)
6. [Tycoon/Simulator Game Patterns](#6-tycoonsimulator-game-patterns)
7. [Security](#7-security)
8. [Modern Luau Features (2025-2026)](#8-modern-luau-features-2025-2026)

---

## 1. Code Architecture Patterns

### 1.1 Project Folder Structure

The standard Rojo-based project layout for a mining tycoon:

```
roblox/
  default.project.json
  ReplicatedStorage/
    Shared/                    -- Shared modules (client + server)
      Types.luau               -- Shared type definitions
      Constants.luau           -- Game constants (ore values, rebirth costs, etc.)
      Util.luau                -- Pure utility functions
    Remotes/                   -- Remote event/function definitions
      init.luau
    Packages/                  -- Wally packages (ProfileStore, etc.)
  ServerScriptService/
    Services/                  -- Server-side service modules
      DataService.luau         -- Player data (ProfileStore)
      TycoonService.luau       -- Tycoon state management
      MiningService.luau       -- Ore generation, dropper logic
      RebirthService.luau      -- Rebirth system
      CurrencyService.luau     -- Currency operations
    Main.server.luau           -- Single entry point, boots all services
  ServerStorage/
    Templates/                 -- Tycoon plot templates, ore models
  StarterPlayerScripts/
    Controllers/               -- Client-side controller modules
      TycoonController.luau    -- UI for tycoon interactions
      InputController.luau     -- Player input handling
      CameraController.luau    -- Camera management
    Main.client.luau           -- Single entry point, boots all controllers
  StarterGui/
    GameHUD/                   -- ScreenGuis
```

### 1.2 Framework Choice in 2026

**Knit** (by Sleitnick) was the dominant framework for years but is **no longer actively maintained**. The author himself wrote about its limitations and how to build better alternatives.

**Recommended approach for 2026: Custom lightweight service/controller pattern.**

The idea is simple: one server Script boots ModuleScript "services," one client LocalScript boots ModuleScript "controllers." No heavyweight framework needed.

```luau
-- ServerScriptService/Main.server.luau
--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService:FindFirstChild("Services")

type Service = {
    Name: string,
    Init: (self: Service) -> (),
    Start: (self: Service) -> (),
}

local loadedServices: { Service } = {}

-- Phase 1: Require all services
for _, moduleScript in Services:GetChildren() do
    if moduleScript:IsA("ModuleScript") then
        local service = require(moduleScript) :: Service
        table.insert(loadedServices, service)
    end
end

-- Phase 2: Init (set up references, no yielding)
for _, service in loadedServices do
    if service.Init then
        service:Init()
    end
end

-- Phase 3: Start (begin logic, yielding OK)
for _, service in loadedServices do
    if service.Start then
        task.spawn(service.Start, service)
    end
end

print("[Server] All services started")
```

### 1.3 Service Module Pattern

```luau
-- ServerScriptService/Services/CurrencyService.luau
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyService = {}
CurrencyService.Name = "CurrencyService"

-- Private state
local playerBalances: { [Player]: number } = {}

function CurrencyService:Init()
    -- Set up references, connect to other services
end

function CurrencyService:Start()
    Players.PlayerAdded:Connect(function(player)
        playerBalances[player] = 0
    end)

    Players.PlayerRemoving:Connect(function(player)
        playerBalances[player] = nil
    end)
end

-- Public API
function CurrencyService:GetBalance(player: Player): number
    return playerBalances[player] or 0
end

function CurrencyService:AddCurrency(player: Player, amount: number): boolean
    if amount <= 0 then return false end
    local current = playerBalances[player] or 0
    playerBalances[player] = current + amount
    return true
end

function CurrencyService:SpendCurrency(player: Player, amount: number): boolean
    local current = playerBalances[player] or 0
    if current < amount or amount <= 0 then return false end
    playerBalances[player] = current - amount
    return true
end

return CurrencyService
```

### 1.4 Client Controller Pattern

```luau
-- StarterPlayerScripts/Controllers/TycoonController.luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TycoonController = {}
TycoonController.Name = "TycoonController"

local localPlayer = Players.LocalPlayer

function TycoonController:Init()
    -- Set up UI references
end

function TycoonController:Start()
    -- Connect to UI events, listen for server updates
end

return TycoonController
```

### 1.5 Key Architecture Rules

1. **Services are singletons** -- one instance per server, hold server-side game state.
2. **Controllers are singletons** -- one instance per client, handle UI and input.
3. **Two-phase boot** -- `Init()` runs first (no yields, set up references), then `Start()` runs (yields OK, begin logic).
4. **Services never require controllers** and vice versa. Communication goes through RemoteEvents/RemoteFunctions.
5. **Shared modules** in ReplicatedStorage for types, constants, and pure utility functions.
6. **GetService alphabetical order** at the top of every file:

```luau
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
```

---

## 2. Data Management

### 2.1 Library Comparison (2026)

| Library | Status | Session Lock | Auto-Save | Migration | Recommended |
|---------|--------|-------------|-----------|-----------|-------------|
| **ProfileStore** | Active, maintained | Yes (improved) | 300s default | Backward compat w/ ProfileService | **Yes** |
| ProfileService | Stable, no longer supported | Yes | 30s default | N/A | Legacy only |
| DataStore2 | Outdated | No | Manual | N/A | No |
| Raw DataStoreService | Engine API | No | Manual | Manual | Only for custom needs |

**ProfileStore is the recommended choice for all new projects in 2026.**

Key advantages over ProfileService:
- MessagingService integration for faster session lock conflict resolution
- 10x fewer DataStore calls (300s auto-save vs 30s)
- Better queue system -- calls to the same key execute as soon as previous calls finish
- Backward compatible with ProfileService data

### 2.2 ProfileStore Setup for a Mining Tycoon

```luau
-- ServerScriptService/Services/DataService.luau
--!strict

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = require(ServerScriptService.Packages.ProfileStore)

local DataService = {}
DataService.Name = "DataService"

-- Define your data template
local PROFILE_TEMPLATE = {
    -- Currency
    Gold = 0,
    Gems = 0,

    -- Tycoon state
    UnlockedItems = {} :: { string },     -- List of unlocked tycoon item IDs
    DropperLevels = {} :: { [string]: number }, -- Dropper ID -> upgrade level

    -- Progression
    RebirthCount = 0,
    RebirthMultiplier = 1,
    TotalGoldEarned = 0,
    PlayTime = 0,

    -- Inventory
    Ores = {} :: { [string]: number },     -- OreType -> count
    Pickaxes = { "BasicPickaxe" } :: { string },
    EquippedPickaxe = "BasicPickaxe",

    -- Settings
    MusicEnabled = true,
    SFXEnabled = true,

    -- Schema version for migrations
    DataVersion = 1,
}

export type PlayerData = typeof(PROFILE_TEMPLATE)

local PlayerStore = ProfileStore.New("PlayerData_v1", PROFILE_TEMPLATE)

-- Active profiles cache
local profiles: { [Player]: typeof(PlayerStore:StartSessionAsync(nil :: any)) } = {}

function DataService:Init()
    -- Nothing to init
end

function DataService:Start()
    -- Load data for players already in the server
    for _, player in Players:GetPlayers() do
        task.spawn(self._loadProfile, self, player)
    end

    Players.PlayerAdded:Connect(function(player)
        self:_loadProfile(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:_releaseProfile(player)
    end)

    -- Handle server shutdown
    game:BindToClose(function()
        for _, player in Players:GetPlayers() do
            self:_releaseProfile(player)
        end
    end)
end

function DataService:_loadProfile(player: Player)
    local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
        Cancel = function()
            return player.Parent ~= Players
        end,
    })

    if profile == nil then
        player:Kick("Failed to load your data. Please rejoin.")
        return
    end

    -- Session lock stolen by another server
    profile:AddUserId(player.UserId)
    profile:Reconcile() -- Fill missing template keys

    profile.OnSessionEnd:Connect(function()
        profiles[player] = nil
        if player.Parent == Players then
            player:Kick("Your data session ended. Please rejoin.")
        end
    end)

    if player.Parent ~= Players then
        profile:EndSession()
        return
    end

    -- Run migrations
    self:_migrateData(profile.Data)

    profiles[player] = profile
    print(`[DataService] Loaded profile for {player.Name}`)
end

function DataService:_releaseProfile(player: Player)
    local profile = profiles[player]
    if profile then
        profile:EndSession()
        profiles[player] = nil
    end
end

function DataService:_migrateData(data: PlayerData)
    -- Example migration: v1 -> v2
    if data.DataVersion < 2 then
        -- Add new fields that didn't exist in v1
        -- data.NewField = defaultValue
        data.DataVersion = 2
    end
end

function DataService:GetData(player: Player): PlayerData?
    local profile = profiles[player]
    if profile then
        return profile.Data
    end
    return nil
end

function DataService:GetProfile(player: Player)
    return profiles[player]
end

return DataService
```

### 2.3 Data Migration Pattern

```luau
-- Run migrations sequentially -- each step brings data from version N to N+1
function DataService:_migrateData(data: PlayerData)
    if data.DataVersion < 2 then
        -- v1 -> v2: Added Gems currency
        if data.Gems == nil then
            data.Gems = 0
        end
        data.DataVersion = 2
    end

    if data.DataVersion < 3 then
        -- v2 -> v3: Renamed "pickaxe" to "Pickaxes" array
        if type(data.Pickaxes) == "string" then
            data.Pickaxes = { data.Pickaxes :: any }
        end
        data.DataVersion = 3
    end
end
```

### 2.4 Session Locking Explained

Session locking prevents the same player's data from being edited by multiple servers simultaneously (a leading cause of data duplication/loss bugs).

**How it works in ProfileStore:**
1. Server A loads player data and acquires a session lock
2. If player teleports to Server B, Server B tries to acquire the lock
3. Server B sends a MessagingService message to Server A requesting release
4. Server A releases the lock and Server B acquires it
5. If Server A is unresponsive, ProfileStore has a timeout-based fallback

**Never bypass session locking.** If `StartSessionAsync` returns nil, kick the player.

---

## 3. Networking

### 3.1 Remote Event Setup Pattern

Centralize remote definitions in ReplicatedStorage:

```luau
-- ReplicatedStorage/Remotes/init.luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

-- Create a folder to hold all remotes
local remoteFolder = Instance.new("Folder")
remoteFolder.Name = "Remotes"
remoteFolder.Parent = ReplicatedStorage

local function createRemote(name: string, className: string): Instance
    local remote = Instance.new(className)
    remote.Name = name
    remote.Parent = remoteFolder
    return remote
end

-- Reliable events (important state changes)
Remotes.PurchaseItem = createRemote("PurchaseItem", "RemoteEvent") :: RemoteEvent
Remotes.CollectOre = createRemote("CollectOre", "RemoteEvent") :: RemoteEvent
Remotes.Rebirth = createRemote("Rebirth", "RemoteEvent") :: RemoteEvent
Remotes.UpgradeDropper = createRemote("UpgradeDropper", "RemoteEvent") :: RemoteEvent

-- Server -> Client updates
Remotes.DataUpdate = createRemote("DataUpdate", "RemoteEvent") :: RemoteEvent
Remotes.NotifyPlayer = createRemote("NotifyPlayer", "RemoteEvent") :: RemoteEvent

-- Request/Response (client asks server for data)
Remotes.GetPlayerData = createRemote("GetPlayerData", "RemoteFunction") :: RemoteFunction

-- Unreliable events (high-frequency, loss-tolerant)
Remotes.MiningParticle = createRemote("MiningParticle", "UnreliableRemoteEvent") :: UnreliableRemoteEvent

return Remotes
```

### 3.2 RemoteEvent vs RemoteFunction

| Feature | RemoteEvent | RemoteFunction | UnreliableRemoteEvent |
|---------|-------------|----------------|----------------------|
| Direction | Both ways | Both ways | Both ways |
| Yields caller | No | Yes (waits for return) | No |
| Reliable | Yes | Yes | No (can be dropped) |
| Use for | Actions, notifications | Data requests | VFX, position updates |

**Critical rules:**
- **Never use RemoteFunction from server to client.** Exploiters can hang the server by never returning. Use RemoteEvent with a callback pattern instead.
- **RemoteFunctions client-to-server are OK** for requesting data (e.g., "give me my inventory").
- **UnreliableRemoteEvents** for mining particles, ore position updates, cosmetic effects -- anything where dropping a packet is fine.

### 3.3 Rate Limiting

```luau
-- Server-side rate limiter
local rateLimits: { [Player]: { [string]: { count: number, resetTime: number } } } = {}

local function checkRateLimit(player: Player, action: string, maxPerSecond: number): boolean
    local now = os.clock()

    if not rateLimits[player] then
        rateLimits[player] = {}
    end

    local limits = rateLimits[player]
    if not limits[action] then
        limits[action] = { count = 0, resetTime = now + 1 }
    end

    local limit = limits[action]

    if now > limit.resetTime then
        limit.count = 0
        limit.resetTime = now + 1
    end

    limit.count += 1

    if limit.count > maxPerSecond then
        warn(`[RateLimit] {player.Name} exceeded {action} limit ({limit.count}/{maxPerSecond})`)
        return false
    end

    return true
end

-- Clean up on player leaving
Players.PlayerRemoving:Connect(function(player)
    rateLimits[player] = nil
end)
```

### 3.4 Input Validation Pattern

```luau
-- Server-side handler for PurchaseItem remote
local Remotes = require(ReplicatedStorage.Remotes)

Remotes.PurchaseItem.OnServerEvent:Connect(function(player: Player, itemId: unknown)
    -- 1. Rate limit
    if not checkRateLimit(player, "PurchaseItem", 5) then return end

    -- 2. Type check ALL arguments
    if typeof(itemId) ~= "string" then
        warn(`[PurchaseItem] {player.Name} sent invalid itemId type: {typeof(itemId)}`)
        return
    end

    -- 3. Validate the value
    local itemConfig = Constants.Items[itemId]
    if not itemConfig then
        warn(`[PurchaseItem] {player.Name} sent unknown itemId: {itemId}`)
        return
    end

    -- 4. Business logic checks (server authority)
    local data = DataService:GetData(player)
    if not data then return end

    if data.Gold < itemConfig.Price then
        return -- Not enough gold, silently reject
    end

    if table.find(data.UnlockedItems, itemId) then
        return -- Already owns this item
    end

    -- 5. Execute the action (server-authoritative)
    data.Gold -= itemConfig.Price
    table.insert(data.UnlockedItems, itemId)

    -- 6. Notify client of success
    Remotes.DataUpdate:FireClient(player, "Gold", data.Gold)
    Remotes.NotifyPlayer:FireClient(player, "Purchased " .. itemConfig.Name)
end)
```

### 3.5 Argument Type Guard Utility

```luau
-- ReplicatedStorage/Shared/TypeGuard.luau
--!strict

local TypeGuard = {}

function TypeGuard.isString(value: unknown): boolean
    return typeof(value) == "string"
end

function TypeGuard.isNumber(value: unknown): boolean
    return typeof(value) == "number"
end

function TypeGuard.isInteger(value: unknown): boolean
    return typeof(value) == "number" and value % 1 == 0
end

function TypeGuard.isPositiveNumber(value: unknown): boolean
    return typeof(value) == "number" and (value :: number) > 0
end

function TypeGuard.isInstance(value: unknown, className: string?): boolean
    if typeof(value) ~= "Instance" then return false end
    if className then
        return (value :: Instance):IsA(className)
    end
    return true
end

function TypeGuard.isVector3(value: unknown): boolean
    return typeof(value) == "Vector3"
end

function TypeGuard.isEnum(value: unknown, enumType: Enum): boolean
    if typeof(value) ~= "EnumItem" then return false end
    for _, item in (enumType :: any):GetEnumItems() do
        if value == item then return true end
    end
    return false
end

return TypeGuard
```

---

## 4. Performance Optimization

### 4.1 Common Luau Performance Pitfalls

**1. Avoid allocating in tight loops:**
```luau
-- BAD: Creates a new Vector3 every frame
RunService.Heartbeat:Connect(function()
    for _, part in workspace.Ores:GetChildren() do
        part.Position = part.Position + Vector3.new(0, -1, 0) -- allocation every iteration
    end
end)

-- GOOD: Cache the vector
local DOWN = Vector3.new(0, -1, 0)
RunService.Heartbeat:Connect(function()
    for _, part in workspace.Ores:GetChildren() do
        part.Position = part.Position + DOWN
    end
end)
```

**2. Cache frequently accessed properties:**
```luau
-- BAD: GetChildren() called every frame
RunService.Heartbeat:Connect(function()
    for _, child in workspace.Ores:GetChildren() do
        -- process
    end
end)

-- GOOD: Listen for additions/removals, maintain a cached list
local ores: { BasePart } = {}
workspace.Ores.ChildAdded:Connect(function(child)
    if child:IsA("BasePart") then
        table.insert(ores, child)
    end
end)
workspace.Ores.ChildRemoved:Connect(function(child)
    local index = table.find(ores, child)
    if index then
        -- Swap-remove for O(1) removal
        ores[index] = ores[#ores]
        ores[#ores] = nil
    end
end)
```

**3. Don't use `wait()` -- use `task.wait()`:**
```luau
-- BAD: Deprecated, less precise
wait(1)

-- GOOD: Modern task library
task.wait(1)
```

**4. Avoid excessive Instance creation in tycoon droppers:**
```luau
-- BAD: Creating + destroying ore parts constantly
local function dropOre()
    local ore = Instance.new("Part")
    ore.Parent = workspace.Ores
    task.delay(10, function()
        ore:Destroy()
    end)
end

-- GOOD: Object pool
local OrePool = {}
local pool: { BasePart } = {}
local template = Instance.new("Part")
template.Size = Vector3.new(1, 1, 1)
template.Anchored = false

function OrePool.get(): BasePart
    local ore = table.remove(pool)
    if not ore then
        ore = template:Clone()
    end
    ore.Parent = workspace.Ores
    return ore
end

function OrePool.release(ore: BasePart)
    ore.CFrame = CFrame.new(0, -100, 0) -- Move out of view
    ore.Anchored = true
    ore.AssemblyLinearVelocity = Vector3.zero
    ore.AssemblyAngularVelocity = Vector3.zero
    ore.Parent = nil -- Remove from workspace to stop physics
    table.insert(pool, ore)
end
```

### 4.2 Instance Streaming

Enable `StreamingEnabled` on Workspace for large tycoon maps. Key settings:

| Property | Recommended | Notes |
|----------|------------|-------|
| `StreamingEnabled` | `true` | Essential for mobile performance |
| `StreamingMinRadius` | 128-256 | Minimum radius around player that stays loaded |
| `StreamingTargetRadius` | 512-1024 | Target radius, degrades on low-end devices |
| `StreamingIntegrityMode` | `Default` | Use `PauseOutsideLoadedArea` for competitive games |
| `ModelStreamingBehavior` | `Improved` | Better model streaming (2025 update) |

**Streaming-safe coding:**
```luau
-- BAD: Assumes part exists (may not be streamed in)
local ore = workspace.MineZone.BigRock
ore.Color = Color3.new(1, 0, 0)

-- GOOD: Wait for streaming or use WaitForChild on client
local mineZone = workspace:WaitForChild("MineZone")
local bigRock = mineZone:WaitForChild("BigRock")
bigRock.Color = Color3.new(1, 0, 0)
```

**Server scripts don't need WaitForChild** -- the server always has all instances.

### 4.3 MicroProfiler Usage

Open with `Ctrl+F6` (or `Ctrl+Shift+F6` for detailed view).

**What to look for:**
- Frame bars exceeding the 16ms line (for 60 FPS) or 33ms (for 30 FPS)
- `RunService.Heartbeat` spikes -- indicates expensive per-frame scripts
- `Replication` bars -- excessive remote traffic
- `Physics` bars -- too many unanchored parts or complex assemblies

**2025 additions:** Memory profiling, flame graphs, diffs, and X-Ray mode for visualizing memory allocations.

**For a mining tycoon specifically, watch for:**
- Dropper part creation/destruction frequency
- Physics step time (conveyor belt simulation with many parts)
- LuaHeap growth over time (memory leaks from uncleaned references)

### 4.4 Part Count Optimization

For a mining tycoon with many droppers and ore parts:

- **Cap active ore parts** at 50-100 per player tycoon. Destroy the oldest when limit is reached.
- **Use `MeshPart` + `CollectionService` tags** instead of complex Model hierarchies.
- **Anchor parts that don't need physics.** Conveyor belts should be anchored; ores on them move via `AssemblyLinearVelocity`.
- **Merge static geometry** -- use `Union` or MeshParts for complex tycoon structures.
- **Destroy far-away effects** -- particles, beams, and trails should only exist near the player's view.

### 4.5 Native Code Generation

Add `--!native` at the top of performance-critical scripts for Luau-to-machine-code compilation:

```luau
--!native
--!strict

-- This module will be compiled to native code
-- Best for: math-heavy calculations, pathfinding, data processing
-- NOT beneficial for: scripts that mostly call Roblox APIs (already native)
```

**When to use `--!native`:**
- Custom math-heavy ore value calculations
- Procedural generation algorithms
- Custom pathfinding or spatial queries
- Data serialization/deserialization

**When NOT to use it:**
- Scripts that mostly call Roblox engine APIs (Instance creation, property changes)
- Short scripts with minimal computation
- Scripts using unsupported patterns (check Roblox docs for limitations)

---

## 5. Type Checking

### 5.1 Enable Strict Mode Everywhere

Create a `.luaurc` at the project root:

```json
{
    "languageMode": "strict"
}
```

Or add per-file:
```luau
--!strict
```

**Rule: All new files must use `--!strict`.** Never use `--!nonstrict` or `--!nocheck` in production code.

### 5.2 Type Annotation Best Practices

```luau
--!strict

-- Type aliases for game concepts
type OreType = "Coal" | "Iron" | "Gold" | "Diamond" | "Emerald"

type OreConfig = {
    Name: string,
    Value: number,
    Color: Color3,
    Rarity: number,      -- 0.0 to 1.0
    MinPickaxeTier: number,
}

type PlayerTycoon = {
    Owner: Player,
    PlotModel: Model,
    Droppers: { Dropper },
    Collectors: { BasePart },
    TotalEarned: number,
}

type Dropper = {
    Model: Model,
    OreType: OreType,
    Level: number,
    DropRate: number,    -- seconds between drops
    ValueMultiplier: number,
}

-- Function signatures with full types
local function calculateOreValue(
    oreType: OreType,
    dropperLevel: number,
    rebirthMultiplier: number
): number
    local config = OreConfigs[oreType]
    local baseValue = config.Value
    local levelBonus = 1 + (dropperLevel * 0.15)
    return math.floor(baseValue * levelBonus * rebirthMultiplier)
end

-- Generic function
local function findFirst<T>(list: { T }, predicate: (T) -> boolean): T?
    for _, item in list do
        if predicate(item) then
            return item
        end
    end
    return nil
end
```

### 5.3 Module Return Typing

```luau
--!strict

-- Explicitly type the module table
local MiningUtil = {}

function MiningUtil.getOreTier(oreType: string): number
    -- implementation
    return 1
end

function MiningUtil.formatCurrency(amount: number): string
    if amount >= 1_000_000_000 then
        return string.format("%.1fB", amount / 1_000_000_000)
    elseif amount >= 1_000_000 then
        return string.format("%.1fM", amount / 1_000_000)
    elseif amount >= 1_000 then
        return string.format("%.1fK", amount / 1_000)
    end
    return tostring(math.floor(amount))
end

return MiningUtil
```

### 5.4 New Type Solver (2025-2026)

Luau's new type solver reached **general release in late 2025**. Key features:

**Type Functions** -- functions that run at analysis time and operate on types:
```luau
-- Type-level computation (requires new type solver)
type function Readonly<T>
    -- Makes all properties of a table type read-only
    -- This is a built-in type function
end
```

**Read-only properties:**
```luau
type GameConfig = {
    read MaxPlayers: number,
    read OreTypes: { string },
    MutableSetting: boolean,
}
```

**Better inference:** The new solver is smarter about tracking types across statements, narrowing types after `if` checks, and understanding complex generics.

---

## 6. Tycoon/Simulator Game Patterns

### 6.1 Tycoon Plot System

```luau
-- ServerScriptService/Services/TycoonService.luau
--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local TycoonService = {}
TycoonService.Name = "TycoonService"

type TycoonPlot = {
    Owner: Player?,
    Model: Model,
    SpawnPoint: BasePart,
    Buttons: { TycoonButton },
    UnlockedItems: { [string]: boolean },
}

type TycoonButton = {
    Part: BasePart,
    ItemId: string,
    Price: number,
    Dependencies: { string },   -- Items that must be unlocked first
    Unlocked: boolean,
}

local plots: { TycoonPlot } = {}
local playerPlots: { [Player]: TycoonPlot } = {}

function TycoonService:Init()
    -- Find all plot models tagged with "TycoonPlot"
    for _, plotModel in CollectionService:GetTagged("TycoonPlot") do
        local plot: TycoonPlot = {
            Owner = nil,
            Model = plotModel,
            SpawnPoint = plotModel:FindFirstChild("SpawnPoint") :: BasePart,
            Buttons = {},
            UnlockedItems = {},
        }
        self:_setupButtons(plot)
        table.insert(plots, plot)
    end
end

function TycoonService:_setupButtons(plot: TycoonPlot)
    local buttonsFolder = plot.Model:FindFirstChild("Buttons")
    if not buttonsFolder then return end

    for _, buttonPart in buttonsFolder:GetChildren() do
        if buttonPart:IsA("BasePart") then
            local config = buttonPart:FindFirstChild("Config") :: Configuration?
            if config then
                local button: TycoonButton = {
                    Part = buttonPart,
                    ItemId = buttonPart:GetAttribute("ItemId") or buttonPart.Name,
                    Price = buttonPart:GetAttribute("Price") or 100,
                    Dependencies = string.split(
                        buttonPart:GetAttribute("Dependencies") or "", ","
                    ),
                    Unlocked = false,
                }
                table.insert(plot.Buttons, button)
            end
        end
    end
end

function TycoonService:ClaimPlot(player: Player): boolean
    if playerPlots[player] then return false end -- Already has a plot

    for _, plot in plots do
        if plot.Owner == nil then
            plot.Owner = player
            playerPlots[player] = plot
            self:_loadPlayerProgress(player, plot)
            return true
        end
    end

    return false -- No available plots
end

function TycoonService:PurchaseButton(player: Player, itemId: string): boolean
    local plot = playerPlots[player]
    if not plot then return false end

    -- Find the button
    local button: TycoonButton? = nil
    for _, b in plot.Buttons do
        if b.ItemId == itemId and not b.Unlocked then
            button = b
            break
        end
    end

    if not button then return false end

    -- Check dependencies
    for _, dep in button.Dependencies do
        if dep ~= "" and not plot.UnlockedItems[dep] then
            return false
        end
    end

    -- Check & deduct currency (via CurrencyService)
    -- local success = CurrencyService:SpendCurrency(player, button.Price)
    -- if not success then return false end

    -- Unlock the item
    button.Unlocked = true
    plot.UnlockedItems[itemId] = true

    -- Spawn the associated model/dropper
    self:_spawnItem(plot, itemId)

    return true
end

function TycoonService:_spawnItem(plot: TycoonPlot, itemId: string)
    local template = ServerStorage.Templates:FindFirstChild(itemId)
    if not template then return end

    local item = template:Clone()
    item.Parent = plot.Model:FindFirstChild("Items") or plot.Model
end

function TycoonService:_loadPlayerProgress(player: Player, plot: TycoonPlot)
    -- Load from DataService and rebuild unlocked items
    -- local data = DataService:GetData(player)
    -- for _, itemId in data.UnlockedItems do
    --     self:_spawnItem(plot, itemId)
    --     plot.UnlockedItems[itemId] = true
    -- end
end

function TycoonService:Start()
    Players.PlayerAdded:Connect(function(player)
        self:ClaimPlot(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        local plot = playerPlots[player]
        if plot then
            -- Clean up plot
            plot.Owner = nil
            plot.UnlockedItems = {}
            for _, button in plot.Buttons do
                button.Unlocked = false
            end
            playerPlots[player] = nil
        end
    end)
end

return TycoonService
```

### 6.2 Dropper System

```luau
-- ServerScriptService/Services/MiningService.luau
--!strict

local RunService = game:GetService("RunService")

local MiningService = {}
MiningService.Name = "MiningService"

type ActiveDropper = {
    Owner: Player,
    OreType: string,
    Level: number,
    DropPosition: Vector3,
    DropInterval: number,   -- seconds between drops
    TimeSinceLastDrop: number,
    ValuePerDrop: number,
    Active: boolean,
}

local activeDroppers: { ActiveDropper } = {}
local MAX_ORES_PER_PLAYER = 50
local playerOreCounts: { [Player]: number } = {}

function MiningService:RegisterDropper(dropper: ActiveDropper)
    table.insert(activeDroppers, dropper)
    if not playerOreCounts[dropper.Owner] then
        playerOreCounts[dropper.Owner] = 0
    end
end

function MiningService:Start()
    -- Main dropper loop using Heartbeat for frame-accurate timing
    RunService.Heartbeat:Connect(function(dt: number)
        for _, dropper in activeDroppers do
            if not dropper.Active then continue end

            dropper.TimeSinceLastDrop += dt

            if dropper.TimeSinceLastDrop >= dropper.DropInterval then
                dropper.TimeSinceLastDrop = 0

                -- Check ore cap
                local count = playerOreCounts[dropper.Owner] or 0
                if count >= MAX_ORES_PER_PLAYER then
                    continue
                end

                self:_spawnOre(dropper)
                playerOreCounts[dropper.Owner] = count + 1
            end
        end
    end)
end

function MiningService:_spawnOre(dropper: ActiveDropper)
    local ore = OrePool.get() -- From the object pool
    ore.CFrame = CFrame.new(dropper.DropPosition)
    ore.Anchored = false

    -- Tag the ore with metadata using attributes
    ore:SetAttribute("OreType", dropper.OreType)
    ore:SetAttribute("Value", dropper.ValuePerDrop)
    ore:SetAttribute("Owner", dropper.Owner.UserId)

    -- Auto-cleanup after timeout
    task.delay(30, function()
        if ore.Parent then
            OrePool.release(ore)
            local count = playerOreCounts[dropper.Owner]
            if count then
                playerOreCounts[dropper.Owner] = math.max(0, count - 1)
            end
        end
    end)
end

return MiningService
```

### 6.3 Collector / Sell System

```luau
-- Server-side collector that converts ores to gold when they touch it
local function setupCollector(collectorPart: BasePart, plot: TycoonPlot)
    collectorPart.Touched:Connect(function(hit: BasePart)
        -- Debounce: check if ore hasn't already been collected
        if hit:GetAttribute("Collected") then return end

        local oreType = hit:GetAttribute("OreType")
        local value = hit:GetAttribute("Value")
        local ownerId = hit:GetAttribute("Owner")

        if not oreType or not value or not ownerId then return end

        -- Verify the ore belongs to this plot's owner
        if plot.Owner and plot.Owner.UserId ~= ownerId then return end

        -- Mark as collected to prevent double-processing
        hit:SetAttribute("Collected", true)

        -- Add currency
        if plot.Owner then
            CurrencyService:AddCurrency(plot.Owner, value)
        end

        -- Return ore to pool
        OrePool.release(hit)
    end)
end
```

### 6.4 Rebirth System

```luau
-- ServerScriptService/Services/RebirthService.luau
--!strict

local RebirthService = {}
RebirthService.Name = "RebirthService"

-- Rebirth cost scales exponentially
local function getRebirthCost(currentRebirths: number): number
    local baseCost = 10_000
    return math.floor(baseCost * (2.5 ^ currentRebirths))
end

-- Rebirth multiplier formula
local function getRebirthMultiplier(rebirths: number): number
    -- Each rebirth gives +25% bonus, compounding
    return 1 + (rebirths * 0.25)
end

function RebirthService:AttemptRebirth(player: Player): boolean
    local data = DataService:GetData(player)
    if not data then return false end

    local cost = getRebirthCost(data.RebirthCount)
    if data.TotalGoldEarned < cost then
        return false -- Haven't earned enough total gold
    end

    -- Reset tycoon progress
    data.Gold = 0
    data.UnlockedItems = {}
    data.DropperLevels = {}
    data.Ores = {}

    -- Increment rebirth and update multiplier
    data.RebirthCount += 1
    data.RebirthMultiplier = getRebirthMultiplier(data.RebirthCount)

    -- Reset the physical tycoon plot
    TycoonService:ResetPlot(player)

    -- Notify client
    Remotes.DataUpdate:FireClient(player, "FullSync", data)
    Remotes.NotifyPlayer:FireClient(player,
        `Rebirth #{data.RebirthCount}! New multiplier: {data.RebirthMultiplier}x`
    )

    return true
end

return RebirthService
```

### 6.5 Currency Formatting

```luau
-- ReplicatedStorage/Shared/FormatUtil.luau
--!strict

local FormatUtil = {}

function FormatUtil.currency(amount: number): string
    if amount >= 1_000_000_000_000 then
        return string.format("%.2fT", amount / 1_000_000_000_000)
    elseif amount >= 1_000_000_000 then
        return string.format("%.2fB", amount / 1_000_000_000)
    elseif amount >= 1_000_000 then
        return string.format("%.2fM", amount / 1_000_000)
    elseif amount >= 1_000 then
        return string.format("%.1fK", amount / 1_000)
    end
    return tostring(math.floor(amount))
end

function FormatUtil.time(seconds: number): string
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    if hours > 0 then
        return string.format("%dh %dm %ds", hours, mins, secs)
    elseif mins > 0 then
        return string.format("%dm %ds", mins, secs)
    end
    return string.format("%ds", secs)
end

return FormatUtil
```

### 6.6 Conveyor Belt System

```luau
-- Conveyor belt: anchored part that moves unanchored parts touching it
local function setupConveyor(beltPart: BasePart, speed: number, direction: Vector3)
    -- Set velocity on the belt surface
    beltPart.AssemblyLinearVelocity = direction.Unit * speed

    -- Alternative: use Touched to apply velocity to ores
    -- This is more reliable for intermittent contact
    beltPart.Touched:Connect(function(hit: BasePart)
        if hit:GetAttribute("OreType") and not hit.Anchored then
            hit.AssemblyLinearVelocity = direction.Unit * speed
        end
    end)
end
```

### 6.7 Upgrade System Pattern

```luau
-- Constants for dropper upgrades
local DROPPER_UPGRADE_CONFIG = {
    maxLevel = 25,
    baseCost = 100,
    costScaling = 1.5,           -- Cost multiplier per level
    speedBonusPerLevel = 0.05,   -- 5% faster per level
    valueBonusPerLevel = 0.10,   -- 10% more value per level
}

local function getUpgradeCost(currentLevel: number): number
    return math.floor(
        DROPPER_UPGRADE_CONFIG.baseCost
        * (DROPPER_UPGRADE_CONFIG.costScaling ^ currentLevel)
    )
end

local function getDropInterval(baseInterval: number, level: number): number
    local speedMultiplier = 1 - (level * DROPPER_UPGRADE_CONFIG.speedBonusPerLevel)
    return math.max(0.5, baseInterval * speedMultiplier) -- Min 0.5s interval
end

local function getDropValue(baseValue: number, level: number, rebirthMultiplier: number): number
    local levelMultiplier = 1 + (level * DROPPER_UPGRADE_CONFIG.valueBonusPerLevel)
    return math.floor(baseValue * levelMultiplier * rebirthMultiplier)
end
```

---

## 7. Security

### 7.1 The Golden Rule: Never Trust the Client

Exploiters have **complete control** over:
- All LocalScripts and ModuleScripts on the client
- All Instances on the client
- All RemoteEvent/RemoteFunction calls they send
- Their character's properties (speed, position, etc.)

Exploiters **cannot**:
- Execute code on the server
- Access ServerScriptService or ServerStorage contents
- Modify server-side data directly

### 7.2 Common Roblox Exploits to Guard Against

| Exploit | Description | Mitigation |
|---------|-------------|------------|
| **Remote spam** | Firing RemoteEvents thousands of times per second | Server-side rate limiting |
| **Remote spoofing** | Sending invalid/manipulated arguments | Type checking + value validation |
| **Speed hacking** | Modifying WalkSpeed/JumpPower | Server-side movement validation or use Roblox's built-in server authority |
| **Teleportation** | Setting CFrame to anywhere | Distance checks, server-side position validation |
| **Currency manipulation** | Trying to purchase with negative prices | Server computes all costs, never trust client-sent amounts |
| **Inventory duplication** | Exploiting race conditions in data | Session locking (ProfileStore), atomic operations |
| **Noclip** | Disabling collision on character | Server-side raycasts to validate position |
| **GUI manipulation** | Changing visible prices/values | Server ignores all client UI state |
| **Infinite yield** | Never returning from a RemoteFunction callback | Never use RemoteFunction server -> client |

### 7.3 Server Authority Pattern

```luau
-- BAD: Client tells server "I mined 500 gold worth of ore"
Remotes.MinedOre.OnServerEvent:Connect(function(player, goldAmount)
    data.Gold += goldAmount -- EXPLOITABLE: client controls the amount
end)

-- GOOD: Client tells server "I hit this ore", server calculates everything
Remotes.MinedOre.OnServerEvent:Connect(function(player: Player, oreId: unknown)
    if typeof(oreId) ~= "string" then return end
    if not checkRateLimit(player, "Mine", 10) then return end

    -- Server finds the ore, validates it exists and is in range
    local orePart = workspace.Ores:FindFirstChild(oreId)
    if not orePart then return end

    -- Verify player is close enough to mine it
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not rootPart then return end

    local distance = (rootPart.Position - orePart.Position).Magnitude
    if distance > 15 then return end -- Too far away

    -- Server calculates the value
    local oreType = orePart:GetAttribute("OreType")
    local data = DataService:GetData(player)
    if not data then return end

    local value = calculateOreValue(oreType, data.DropperLevels[oreType] or 0, data.RebirthMultiplier)
    data.Gold += value
    data.TotalGoldEarned += value

    -- Clean up the ore
    orePart:Destroy()

    -- Update client
    Remotes.DataUpdate:FireClient(player, "Gold", data.Gold)
end)
```

### 7.4 Roblox Official Security Features (2025)

Roblox released updated **Security Tactics and Cheat Mitigation** documentation in September 2025 covering:

1. **Server Authority Model** -- engine-level support for ensuring critical logic runs server-side.
2. **Three tiers of enforcement:**
   - **Quiet mitigation** -- silently drop invalid requests, clamp values, sync correct state
   - **Temporary restrictions** -- limit specific capabilities for suspected cheaters
   - **Visible enforcement** -- kicks, temp bans, permanent bans
3. **Server-side avatar validation** -- `Humanoid:ApplyDescription` now automatically validates avatar assets server-side by default.

### 7.5 Practical Security Checklist for Mining Tycoon

- [ ] All currency additions happen on the server only
- [ ] All purchase validations happen on the server (price lookup, balance check)
- [ ] All ore values are calculated by the server, never sent by the client
- [ ] RemoteEvent arguments are type-checked and range-validated
- [ ] Rate limiting on all client -> server remotes
- [ ] No RemoteFunctions fired from server to client
- [ ] Player proximity checks for mining and collecting
- [ ] Session-locked data via ProfileStore
- [ ] `game:BindToClose()` properly saves all player data
- [ ] No sensitive game logic in ReplicatedStorage (ore formulas, economy constants are OK if server enforces them)

---

## 8. Modern Luau Features (2025-2026)

### 8.1 Generalized Iteration (use everywhere)

```luau
-- OLD way
for i, v in ipairs(myArray) do end
for k, v in pairs(myTable) do end

-- MODERN way (preferred in 2025+)
for i, v in myArray do end     -- Numeric iteration over arrays
for k, v in myTable do end     -- Key-value iteration over dictionaries

-- Performance is comparable to ipairs/pairs, so prefer the cleaner syntax
```

### 8.2 String Interpolation

```luau
-- OLD
local msg = "Player " .. player.Name .. " earned " .. tostring(gold) .. " gold"

-- MODERN
local msg = `Player {player.Name} earned {gold} gold`

-- Expressions work inside braces
local msg = `{player.Name} now has {FormatUtil.currency(data.Gold)} gold ({data.RebirthMultiplier}x multiplier)`
```

### 8.3 `if` Expressions (Ternary)

```luau
-- Luau supports inline if-else expressions
local label = if rebirthCount > 0 then `Rebirth {rebirthCount}` else "New Player"
local color = if oreType == "Gold" then Color3.new(1, 0.84, 0) else Color3.new(0.5, 0.5, 0.5)
```

### 8.4 `continue` Keyword

```luau
for _, ore in ores do
    if ore:GetAttribute("Collected") then
        continue -- Skip already-collected ores
    end
    processOre(ore)
end
```

### 8.5 `buffer` Type

Buffers are fixed-size mutable binary data, useful for compact network payloads or binary data processing:

```luau
-- Create a buffer for efficient ore data packing
local buf = buffer.create(12) -- 12 bytes
buffer.writef32(buf, 0, posX)   -- 4 bytes: X position
buffer.writef32(buf, 4, posY)   -- 4 bytes: Y position
buffer.writef32(buf, 8, posZ)   -- 4 bytes: Z position

-- New in 2025: bit-level read/write
buffer.writebits(buf, 0, 4, oreTypeId) -- Write 4 bits
```

### 8.6 Math Library Additions (2025)

```luau
-- math.lerp: Linear interpolation (new in 2025)
local smoothedValue = math.lerp(currentValue, targetValue, 0.1)

-- math.map: Remap a value from one range to another
local healthBarWidth = math.map(currentHP, 0, maxHP, 0, 200) -- 0-200 pixels

-- math.isnan / math.isinf / math.isfinite
if math.isnan(value) then
    value = 0 -- Recover from NaN
end
```

### 8.7 Vector Library

```luau
-- Built-in vector operations (fast-call optimized)
local dot = vector.dot(v1, v2)
local lerped = vector.lerp(startPos, endPos, alpha)
local mag = vector.magnitude(v)
local normalized = vector.normalize(v)
```

### 8.8 Type Functions (New Type Solver)

```luau
-- Type functions run at analysis time
-- They transform types, not values
-- Requires the new type solver (enabled by default since late 2025)

-- Example: Built-in Readonly type function
type ReadonlyConfig = Readonly<{
    MaxPlayers: number,
    OreTypes: { string },
}>

-- The above makes all properties read-only at the type level
```

### 8.9 `table.freeze` and `table.isfrozen`

```luau
-- Make configuration tables immutable at runtime
local ORE_CONFIG = table.freeze({
    Coal = { Value = 1, Color = Color3.new(0.2, 0.2, 0.2), Rarity = 1.0 },
    Iron = { Value = 5, Color = Color3.new(0.7, 0.7, 0.7), Rarity = 0.7 },
    Gold = { Value = 25, Color = Color3.new(1, 0.84, 0), Rarity = 0.3 },
    Diamond = { Value = 100, Color = Color3.new(0.3, 0.9, 1), Rarity = 0.1 },
    Emerald = { Value = 75, Color = Color3.new(0.2, 0.9, 0.3), Rarity = 0.15 },
})

-- Any attempt to modify this table will error at runtime
-- ORE_CONFIG.Coal.Value = 999 -- ERROR!
```

### 8.10 Parallel Luau (Actor Model)

For CPU-intensive operations like procedural mine generation:

```luau
-- Each Actor runs on its own thread
-- Use for: NPC AI, chunk generation, spatial queries
-- Don't use for: simple game logic, anything needing frequent cross-thread communication

-- Inside an Actor script:
local actor = script:GetActor()

-- Switch to parallel execution
task.desynchronize()
-- Heavy computation here (no Roblox API calls)
local result = heavyCalculation()

-- Switch back to serial for Roblox API calls
task.synchronize()
workspace.Part.Position = result

-- SharedTable for cross-actor communication
local shared = SharedTable.new()
SharedTable.update(shared, "key", function(old)
    return (old or 0) + 1
end)
```

### 8.11 Task Library (use instead of legacy functions)

```luau
-- LEGACY (avoid)         -- MODERN (use these)
wait(1)                   --> task.wait(1)
spawn(fn)                 --> task.spawn(fn)
delay(1, fn)              --> task.delay(1, fn)
                          --> task.defer(fn)  -- runs next resumption cycle
                          --> task.cancel(thread) -- cancel a spawned task
```

---

## Tooling Recommendations

### Rojo
File-based project management. Sync your VS Code files directly to Roblox Studio.

### Wally
Package manager for Roblox (like npm). Install ProfileStore, utility libraries, etc.

```toml
# wally.toml
[package]
name = "studio/gold-rush-legacy"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "server"

[dependencies]
ProfileStore = "madstudioroblox/profilestore@1.0.0"

[server-dependencies]

[dev-dependencies]
```

### Selene
Static analysis / linting for Luau. Catches common bugs.

### StyLua
Auto-formatter for Luau code. Enforces consistent style.

### Luau LSP
Language server for VS Code. Provides intellisense, type checking, and diagnostics.

---

## Sources

### Architecture & Frameworks
- [Knit Framework (GitHub)](https://github.com/Sleitnick/Knit)
- [Knit History and How to Build Better (Sleitnick/Medium)](https://medium.com/@sleitnick/knit-its-history-and-how-to-build-it-better-3100da97b36)
- [Kampfkarren's Luau Guidelines and Patterns](https://github.com/Kampfkarren/kampfkarren-luau-guidelines)
- [Single Script Architecture and Modular Programming (DevForum)](https://devforum.roblox.com/t/single-script-architecture-and-modular-programming/2432662)
- [The Module Framework (MonzterDev)](https://monzter.dev/lessons/the-module-framework/)
- [How to Organize Your Project (DevForum)](https://devforum.roblox.com/t/how-to-organize-your-project-correctly/3419400)
- [Service Registry Design Pattern (DevForum)](https://devforum.roblox.com/t/the-service-registry-design-pattern-in-roblox-luau-a-comprehensive-guide/3614490)

### Data Management
- [ProfileStore Documentation](https://madstudioroblox.github.io/ProfileStore/)
- [ProfileStore GitHub](https://github.com/MadStudioRoblox/ProfileStore)
- [ProfileStore DevForum Announcement](https://devforum.roblox.com/t/profilestore-save-your-player-data-easy-datastore-module/3190543)
- [ProfileService Documentation](https://madstudioroblox.github.io/ProfileService/)
- [DataStoreService vs ProfileService (DevForum)](https://devforum.roblox.com/t/datastoreservice-vs-profileservice-which-should-you-use-for-your-game/3582901)

### Networking & Security
- [How to Secure RemoteEvents (DevForum)](https://devforum.roblox.com/t/how-to-secure-your-remoteevent-and-remotefunction/3345363)
- [Airtight Remote Security Guide (DevForum)](https://devforum.roblox.com/t/a-comprehensive-guide-to-airtight-remote-security/3079489)
- [Introducing UnreliableRemoteEvents (DevForum)](https://devforum.roblox.com/t/introducing-unreliableremoteevents/2724155)
- [Security Tactics and Cheat Mitigation (Roblox Docs)](https://create.roblox.com/docs/scripting/security/security-tactics)
- [Server Authority Model (Roblox Docs)](https://create.roblox.com/docs/projects/server-authority)
- [Stop Building Exploits Into Your Game (DevForum)](https://devforum.roblox.com/t/stop-building-exploits-into-your-game-a-lesson-on-how-to-secure-your-server/1394825)

### Performance
- [Roblox Performance Optimization (Creator Docs GitHub)](https://github.com/Roblox/creator-docs/blob/main/content/en-us/performance-optimization/improve.md)
- [How We Make Luau Fast (luau.org)](https://luau.org/performance/)
- [MicroProfiler Memory Profiling (DevForum)](https://devforum.roblox.com/t/introducing-microprofiler-memory-profiling-flame-graphs-diffs-and-much-more/3226910)
- [Instance Streaming (Roblox Docs)](https://create.roblox.com/docs/workspace/streaming)
- [SLIM: Scalable Lightweight Interactive Models](https://about.roblox.com/newsroom/2025/12/introducing-roblox-slim-scalable-lightweight-interactive-models)
- [Luau Optimizations (DevForum)](https://devforum.roblox.com/t/luau-optimizations-make-your-game-run-faster/4378272)
- [Native Code Generation (Roblox Docs)](https://create.roblox.com/docs/luau/native-code-gen)

### Type Checking
- [Luau Type Checking (Roblox Docs)](https://create.roblox.com/docs/luau/type-checking)
- [Luau Types Introduction (luau.org)](https://luau.org/types/)
- [New Type Solver General Release (DevForum)](https://devforum.roblox.com/t/general-release-luau%E2%80%99s-new-type-solver/4084991)
- [Type Functions Tutorial (DevForum)](https://devforum.roblox.com/t/luaus-new-type-solver-how-to-utilize-type-functions/3637378)
- [Type Functions (luau.org)](https://luau.org/types/type-functions/)

### Modern Luau
- [Luau Recap 2025: Runtime](https://luau.org/news/2025-12-19-luau-recap-runtime-2025/)
- [Luau Syntax by Example](https://luau.org/syntax/)
- [Luau Releases (GitHub)](https://github.com/luau-lang/luau/releases)
- [Parallel Luau Documentation](https://create.roblox.com/docs/scripting/multithreading)
- [Generalized Iteration RFC](https://rfcs.luau.org/generalized-iteration.html)
- [math.lerp RFC](https://rfcs.luau.org/function-math-lerp.html)

### Tooling
- [Rojo Documentation](https://rojo.space/docs/v7/)
- [Wally Package Manager](https://wally.run/)
- [Wally GitHub](https://github.com/UpliftGames/wally)
