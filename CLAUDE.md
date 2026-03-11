# Gold Rush Legacy — Roblox Game Project

## Language
This project uses **Luau** (NOT Lua 5.1, NOT JavaScript, NOT TypeScript).
- File extension: `.lua` (project convention)
- Type annotations: `function foo(x: number): string`
- Use `local` for ALL variable declarations
- String interpolation: backtick strings `` `Hello {playerName}` `` (NOT template literals, NOT string.format for simple cases)
- No semicolons
- 1-indexed arrays
- `nil` not `null`
- Ternary: `if condition then valueA else valueB` (Luau if-expression)

## Roblox Architecture

### Client-Server Boundary (CRITICAL)
- **Server scripts** (`*.server.lua`) run in `ServerScriptService` — trusted, authoritative
- **Client scripts** (`*.client.lua`) run in `StarterPlayerScripts` / `StarterGui` — untrusted
- **ModuleScripts** (`*.lua` without prefix) — shared libraries in `ReplicatedStorage`
- **NEVER** access server-only services from client scripts
- **NEVER** trust client input — always validate on server
- Use `RemoteEvents` / `RemoteFunctions` for client↔server communication

### Project Structure (Rojo — at project root)
```
roblox-v1/
├── default.project.json                  # Rojo project config (rojo serve here)
├── wally.toml                            # Package manager config
├── Packages/                             # Wally shared packages (Matter)
├── ServerPackages/                       # Wally server packages (ProfileStore, SimplePath)
├── ServerScriptService/
│   ├── Core/
│   │   ├── GameManager.server.lua        # Main entry point — boots all systems
│   │   ├── DataManager.lua               # Player data (ProfileStore)
│   │   └── EconomyManager.lua            # Currency operations
│   ├── Systems/
│   │   ├── MapBuilder.lua                # World generation (town, river, 4 zones, NPCs)
│   │   ├── MiningSystem.lua              # Mining mechanics
│   │   ├── GoldSpawner.lua               # Gold spot spawning
│   │   ├── QuestManager.lua              # Quest system (stub)
│   │   ├── BossManager.lua               # Boss system (stub)
│   │   ├── CraftManager.lua              # Crafting system (stub)
│   │   ├── SaloonManager.lua             # Saloon NPC (stub)
│   │   └── LeaderboardManager.lua        # Leaderboard (stub)
│   └── Lib/
│       └── ProfileStore.lua              # ProfileStore local copy
├── ReplicatedStorage/
│   └── Modules/
│       └── Config/                       # Shared game configs
│           ├── GameConfig.lua            # General game settings
│           ├── ToolConfig.lua            # Tools (batée → foreuse)
│           ├── EconomyConfig.lua         # Economy settings & gold types
│           ├── ZoneConfig.lua            # Mining zones
│           ├── GemConfig.lua             # Gems
│           ├── NPCConfig.lua             # NPC definitions
│           ├── QuestConfig.lua           # Quest definitions
│           └── CraftConfig.lua           # Crafting recipes
├── StarterPlayerScripts/
│   ├── Core/
│   │   ├── InteractionClient.client.lua  # NPC/object interactions
│   │   ├── MiningClient.client.lua       # Mining UI/input
│   │   └── UIManager.lua                 # HUD, shop, notifications
│   ├── Systems/
│   │   ├── BateeMinigame.client.lua      # Pan minigame
│   │   ├── DayNightClient.client.lua     # Day/night cycle (stub)
│   │   └── DetecteurSystem.client.lua    # Detector visual (stub)
│   └── Lib/
│       └── ClientUtils.lua               # Client utilities
├── StarterGui/                           # Client GUI
├── GoldRushLegacy.rbxlx                  # Roblox place file (Studio)
└── docs/                                 # All documentation
```

### How Rojo Works
- `rojo serve` syncs filesystem → Studio in real-time
- File naming determines instance type:
  - `Script.server.lua` → Script (server)
  - `Script.client.lua` → LocalScript (client)
  - `Module.lua` → ModuleScript
- `default.project.json` maps folders to Roblox services

## Key Roblox Patterns

### Require
```luau
-- CORRECT: require by Roblox instance path
local Config = require(ReplicatedStorage:WaitForChild("Config"))

-- WRONG: this is not Node.js
local Config = require("./Config")
```

### Services
```luau
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
```

### RemoteEvents
```luau
-- Server: listen
remoteEvent.OnServerEvent:Connect(function(player, ...)
    -- validate args here! never trust client
end)

-- Client: fire
remoteEvent:FireServer(...)
```

### Naming Conventions
- Roblox API: `PascalCase` (Instance.Name, Part.Position)
- Local variables: `camelCase`
- Constants: `UPPER_SNAKE` or config tables
- Module tables: `PascalCase`

## Game-Specific Context

### Core Loop
`Prospecter → Extraire → Vendre → Réinvestir`

### Config Modules (ReplicatedStorage/Modules/Config/)
- `ToolConfig` — 5 tools (batée → foreuse industrielle)
- `EconomyConfig` — Gold types, pricing, drop weights
- `GemConfig` — 6 gem types (quartz → diamant)
- `ZoneConfig` — 4 mining zones with level gates
- `NPCConfig` — NPC definitions (merchants, quest givers)
- `QuestConfig` — Quest definitions
- `CraftConfig` — Crafting recipes
- `GameConfig` — General game settings

### Wally Packages (installed)
- **Matter** (ECS) — `require(ReplicatedStorage.Packages.Matter)`
- **ProfileStore** (data) — `require(ServerScriptService.ServerPackages.ProfileStore)`
- **SimplePath** (NPC pathfinding) — `require(ServerScriptService.ServerPackages.SimplePath)`

## Code Style (match existing code)
- Use `--[[ block comments ]]` for file headers
- Use `print("[ModuleName] ...")` for debug logging with module prefix
- Use `pcall` for DataStore and external API calls
- Use `-- ═══════════════` separators for major sections
- Tab indentation
- French for user-facing strings, English for code identifiers

## Dev Workflow (CRITICAL — follow this ALWAYS)

### Tools disponibles
- **Rojo** (`rojo serve`) tourne en permanence — sync filesystem → Studio en temps réel
- **robloxstudio-mcp** est configuré et connecté — utiliser TOUJOURS les outils MCP

### Workflow obligatoire après chaque changement de code
1. **Écrire le code** sur le filesystem (les fichiers .lua)
2. **Lancer le playtest** via MCP : `start_playtest`
3. **Monitorer la console** via MCP : `get_playtest_output` — lire les prints, erreurs, warnings
4. **Diagnostiquer** les problèmes à partir de l'output console
5. **Itérer** : fixer le code → relancer le playtest → re-monitorer
6. Ne JAMAIS dire "tu peux tester" — c'est MOI qui teste et qui débug

### Outils MCP à utiliser
- `get_file_tree` — explorer la structure du jeu dans Studio
- `get_script_source` / `set_script_source` — lire/écrire les scripts dans Studio
- `grep_scripts` — chercher dans tous les scripts
- `execute_luau` — tester des snippets de code
- `start_playtest` — lancer le playtest (F5)
- `stop_playtest` — arrêter le playtest
- `get_playtest_output` — lire la console Output (prints, errors, warnings)

### Règles
- Après tout changement serveur (ServerScriptService/), il FAUT relancer le playtest
- Les changements client (StarterPlayerScripts/) sont hot-reloaded par Rojo
- TOUJOURS vérifier la console Output après un playtest pour détecter les erreurs
- TOUJOURS monitorer `get_playtest_output` pour valider que le code fonctionne

## DO NOT
- Do not use `io`, `os`, `debug` libraries (sandboxed in Roblox)
- Do not use `loadstring` (disabled)
- Do not use `pairs()` when iterating arrays — use `ipairs()` or generalized `for i, v in array`
- Do not use `require()` with file paths — use instance paths
- Do not create npm/node patterns
- Do not use `string.format` for simple concatenation — use backtick interpolation
- Do not commit `.rbxlx.lock` files

## Documentation
All project docs are in `docs/`. Key references:
- `docs/guides/luau-best-practices.md` — Architecture patterns, ProfileStore, security
- `docs/guides/3d-assets-guide.md` — Asset creation pipeline (Meshy, Sloyd, Roblox Cube)
- `docs/guides/ai-dev-workflow-guide.md` — MCP setup, Rojo, workflow
- `docs/guides/publishing-monetization-guide.md` — Creator Programs, monetization
- `docs/specs/gold-rush-v1-tech-spec.md` — Full tech spec
- `docs/dev-resources-guide.md` — Links to tutorials, assets, docs
