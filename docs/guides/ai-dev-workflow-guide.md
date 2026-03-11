# AI-Powered Roblox Development Guide (2025-2026)

Comprehensive reference for using Claude Code, MCP servers, and AI tooling to develop Roblox games efficiently.

---

## Table of Contents

1. [Roblox Studio MCP Servers](#1-roblox-studio-mcp-servers)
2. [Claude Code + Roblox Workflow](#2-claude-code--roblox-workflow)
3. [Rojo Workflow](#3-rojo-workflow)
4. [Other AI Tools for Roblox Dev](#4-other-ai-tools-for-roblox-dev)
5. [Testing & Debugging with AI](#5-testing--debugging-with-ai)
6. [Practical Workflow Recommendation](#6-practical-workflow-recommendation)

---

## 1. Roblox Studio MCP Servers

There are three MCP server options as of March 2026. Here is a breakdown of each.

### 1A. Studio Built-in MCP Server (NEW - Recommended)

As of March 2026, Roblox has brought the MCP server **natively into Studio**. This is now the recommended way to connect external AI tools.

**Key advantages:**
- No separate installation or build step required
- Tools stay in sync with Roblox Assistant automatically
- Always has the latest capabilities without manual updates
- Supported by Roblox directly

**How to enable:**
- Update Roblox Studio to the latest version
- The MCP server is available under Studio settings
- Connect via Claude Code, Cursor, or any MCP-compatible client using the local endpoint

**Available tools (built-in):**
- `run_code` - Execute Luau code in Studio, return printed output
- `insert_model` - Insert models from Creator Store into workspace
- `get_console_output` - Read Studio console/output
- `start_stop_play` - Start/stop play mode or run server
- `run_script_in_play_mode` - Run a script during playtest, auto-stop after timeout, return logs/errors/duration
- `get_studio_mode` - Check current mode (edit, play, server)

**Limitation:** Cannot directly set `Script.Source` (Roblox blocks this). All code changes go through `run_code` which executes Luau that creates/modifies instances programmatically.

### 1B. Official Open-Source MCP Server (Rust)

**Repository:** https://github.com/Roblox/studio-rust-mcp-server

A reference implementation written in Rust by Roblox. Still useful if you need a standalone server or want to customize behavior.

**Architecture:**
- Rust binary (axum web server + rmcp MCP server)
- Studio plugin long-polls the web server
- AI client connects via stdio transport
- Listens on `http://127.0.0.1:44756` with `/ws` (Studio WebSocket) and `/mcp` (AI client endpoint)

**Setup:**
```bash
# Prerequisites: Rust toolchain, Roblox Studio, Claude Desktop or Cursor
git clone https://github.com/Roblox/studio-rust-mcp-server.git
cd studio-rust-mcp-server
cargo run
```

`cargo run` does three things:
1. Builds the Rust MCP server binary
2. Configures Claude Desktop/Cursor to communicate with the server
3. Builds and installs the Studio plugin

**Claude Code MCP config (`.mcp.json`):**
```json
{
  "mcpServers": {
    "roblox-studio": {
      "command": "/path/to/studio-rust-mcp-server/target/release/rbx-studio-mcp",
      "args": []
    }
  }
}
```

**Same tools as built-in:** `run_code`, `insert_model`, `get_console_output`, `start_stop_play`, `run_script_in_play_mode`, `get_studio_mode`.

**When to use this over built-in:**
- You need to customize or extend the MCP server
- You want to run a specific pinned version
- You need to debug the MCP layer itself

### 1C. Community MCP Server (boshyxd/robloxstudio-mcp)

**Repository:** https://github.com/boshyxd/robloxstudio-mcp

A community-maintained Node.js MCP server with a much larger tool surface area. Built by BoshyDx who used it to ship a full game with a 2-person team.

**Setup:**
```bash
# 1. Install the Studio plugin from Roblox Creator Store (search "robloxstudio-mcp")
#    OR download MCPPlugin.rbxmx from GitHub Releases:
#    - macOS: ~/Documents/Roblox/Plugins/
#    - Windows: %LOCALAPPDATA%/Roblox/Plugins/

# 2. In Roblox Studio: Experience Settings > Security > Enable "Allow HTTP Requests"

# 3. No build step needed - runs via npx
```

**Claude Code MCP config (`.mcp.json`):**
```json
{
  "mcpServers": {
    "robloxstudio-mcp": {
      "command": "npx",
      "args": ["-y", "robloxstudio-mcp"]
    }
  }
}
```

**Full Edition - 22+ tools including:**

| Category | Tools |
|----------|-------|
| **Navigation** | `get_file_tree`, `get_project_structure`, `get_services`, `get_place_info` |
| **Search** | `search_objects`, `search_files`, `search_by_property`, `grep_scripts`, `search_materials`, `search_assets` |
| **Instance Management** | `create_object`, `delete_object`, `mass_create_objects`, `smart_duplicate`, `mass_duplicate` |
| **Properties** | `get_instance_properties`, `get_instance_children`, `set_property`, `set_calculated_property`, `set_relative_property`, `mass_set_property`, `mass_get_property` |
| **Scripts** | `get_script_source`, `set_script_source`, `edit_script_lines`, `insert_script_lines`, `delete_script_lines` |
| **Tags/Attributes** | `get_tags`, `add_tag`, `remove_tag`, `get_attributes`, `get_attribute`, `set_attribute`, `delete_attribute` |
| **Playtest** | `start_playtest`, `stop_playtest`, `get_playtest_output`, `execute_luau` |
| **Assets** | `insert_asset`, `search_assets`, `get_asset_details`, `preview_asset`, `list_library` |
| **Builds** | `create_build`, `generate_build`, `get_build`, `export_build`, `import_build` |
| **Other** | `undo`, `redo`, `capture_screenshot`, `get_selection` |

**Inspector Edition (read-only):** 21 tools, same as above minus write operations. Ideal for safely browsing game structure and reviewing scripts without risk of accidental changes.

**Key advantage over official:** Can directly read and write `Script.Source`, edit specific lines, search across all scripts with grep. This is critical for AI-assisted coding workflows.

### Comparison Matrix

| Feature | Built-in (March 2026) | Official Rust | Community (boshyxd) |
|---------|----------------------|---------------|---------------------|
| **Installation** | None (built into Studio) | Build from source (Rust) | npx (zero build) |
| **Read Script Source** | Via run_code workaround | Via run_code workaround | Direct (`get_script_source`) |
| **Write Script Source** | Via run_code (indirect) | Via run_code (indirect) | Direct (`set_script_source`, `edit_script_lines`) |
| **Search Scripts** | No | No | Yes (`grep_scripts`) |
| **Instance CRUD** | Via run_code | Via run_code | Direct tools |
| **Playtest Control** | Yes | Yes | Yes |
| **Console Output** | Yes | Yes | Yes (`get_playtest_output`) |
| **Asset Insert** | Yes (`insert_model`) | Yes (`insert_model`) | Yes (`insert_asset`, `search_assets`) |
| **Undo/Redo** | No | No | Yes (atomic) |
| **Screenshot** | No | No | Yes |
| **Maintained by** | Roblox | Roblox | Community |
| **Tool count** | ~6 | ~6 | 50+ |

**Recommendation:** Use **both**. The built-in/official server for playtest automation and `run_code` execution, and **boshyxd** for script reading/writing, searching, and instance management. They can coexist.

---

## 2. Claude Code + Roblox Workflow

### The Core Problem

Out of the box, Claude does not know Luau well. Common mistakes:
- Writes JavaScript or Lua 5.1 syntax instead of Luau
- Invents non-existent Roblox API methods and properties
- Does not understand Roblox services (ServerScriptService, ReplicatedStorage, etc.)
- Ignores Rojo file naming conventions (`.server.luau`, `.client.luau`)
- Uses `require()` with file paths instead of Roblox instance paths
- Forgets client-server boundary rules (what runs where)

### The Solution: CLAUDE.md

The single most important thing is a well-crafted `CLAUDE.md` in your project root. Claude reads this automatically on every session start.

**Recommended CLAUDE.md template for Roblox projects:**

```markdown
# Roblox Game Project

## Language
This project uses **Luau** (NOT Lua 5.1, NOT JavaScript, NOT TypeScript).
- File extension: `.luau` (preferred) or `.lua`
- Type annotations use Luau syntax: `function foo(x: number): string`
- Use `local` for all variable declarations
- String interpolation: backtick strings with `{variable}` (NOT template literals)
- No semicolons needed

## Roblox Architecture
- **Server scripts** run on the server (ServerScriptService). File suffix: `.server.luau`
- **Client scripts** run on the player's machine (StarterPlayerScripts, StarterGui). File suffix: `.client.luau`
- **Module scripts** are shared libraries. File suffix: `.luau` (no prefix) or `init.luau`
- **NEVER** access server-only services from client scripts
- **NEVER** access client-only services (like PlayerGui) from server scripts

## Project Structure (Rojo)
```
src/
  Server/          -> ServerScriptService
  Client/          -> StarterPlayerScripts
  Shared/          -> ReplicatedStorage.Shared
  StarterGui/      -> StarterGui
```

## Key Roblox Patterns
- Use RemoteEvents/RemoteFunctions for client-server communication
- Use ModuleScripts for shared logic (require by instance path, not file path)
- `require(game.ReplicatedStorage.Shared.ModuleName)` -- correct
- `require("./ModuleName")` -- WRONG, this is not Node.js
- Services: `game:GetService("Players")`, `game:GetService("RunService")`, etc.
- Roblox uses PascalCase for API (Instance.Name, Part.Position, etc.)

## Common Luau Patterns
- Tables as arrays: `{1, 2, 3}` (1-indexed!)
- Tables as dictionaries: `{key = value}`
- String format: `string.format()` or backtick interpolation
- Type checking: `typeof(x)` for Roblox types, `type(x)` for Lua primitives
- No `null` -- use `nil`
- Ternary: `if condition then valueA else valueB` (Luau expression form)

## File Naming (Rojo conventions)
- `ScriptName.server.luau` -> Script (runs on server)
- `ScriptName.client.luau` -> LocalScript (runs on client)
- `ModuleName.luau` -> ModuleScript
- `init.luau` -> ModuleScript that represents its parent folder
- `init.server.luau` -> Script that represents its parent folder
- `init.client.luau` -> LocalScript that represents its parent folder

## Testing
- Use `print()` and `warn()` for debug output (visible in Studio Output)
- Use `error()` to throw errors
- Check Output window in Studio for runtime errors
- Server output and client output are separate in Studio

## DO NOT
- Do not use `io`, `os`, `debug` libraries (sandboxed in Roblox)
- Do not use `loadstring` (disabled by default)
- Do not create files outside the Rojo project structure
- Do not use npm/node patterns
```

### What Claude Code is Good At for Roblox

- **Game system architecture** - Designing module structures, service patterns, event systems
- **Luau scripting** (with proper CLAUDE.md) - Writing server/client scripts, module scripts
- **Data structures** - Inventory systems, save data schemas, configuration tables
- **UI scripting** - Creating ScreenGuis, handling input, tween animations
- **Math-heavy code** - Physics calculations, pathfinding logic, procedural generation
- **Refactoring** - Splitting monolithic scripts into modules, improving code organization
- **Bug analysis** - Reading error output and suggesting fixes (especially with MCP console access)

### What Claude Code Struggles With

- **3D spatial reasoning** - Cannot visualize the game world; needs coordinate references
- **Roblox-specific visual properties** - Materials, lighting, terrain sculpting
- **Game feel** - Jump height, movement speed, camera angles require human playtesting
- **Complex UI layout** - UDim2 positioning is hard without visual feedback
- **Asset-dependent code** - Cannot verify asset IDs, model structures, or animation names
- **Performance optimization** - Cannot profile; needs you to provide MicroProfiler data
- **Niche APIs** - May hallucinate methods for lesser-documented services (e.g., MarketplaceService edge cases)

### Prompting Best Practices

**Be specific about Roblox context:**
```
BAD:  "Write a script that makes the player move faster"
GOOD: "Write a server script (ServerScriptService) that listens for a RemoteEvent
       called 'SpeedBoost' and increases the player's Character.Humanoid.WalkSpeed
       from 16 to 32 for 5 seconds, then resets it. Use a debounce per player."
```

**Reference your project structure:**
```
"Create a new module at src/Shared/Utils/MathHelpers.luau that exports:
- lerp(a, b, t) for number interpolation
- clampVector3(v, min, max) that clamps each axis
Make sure it returns a table with these functions."
```

**Ask Claude to use MCP tools when connected:**
```
"Use get_file_tree to see the current project structure, then create a
 DataService module in src/Server/Services/ that handles player data
 saving using DataStoreService."
```

**Iterate with error output:**
```
"Here's the error I'm getting in the Output window:
  ServerScriptService.GameManager:42: attempt to index nil with 'Character'
The player might not have spawned yet. Fix the script to wait for the character."
```

---

## 3. Rojo Workflow

Rojo is the bridge between your filesystem (where Claude Code works) and Roblox Studio (where the game runs). Without it, Claude writes code that sits on disk doing nothing.

### Installation

```bash
# Option 1: Using Rokit (recommended toolchain manager)
rokit install rojo-rbx/rojo

# Option 2: Using Aftman (older toolchain manager)
aftman install rojo-rbx/rojo

# Option 3: Direct from GitHub Releases
# Download binary from https://github.com/rojo-rbx/rojo/releases

# Verify
rojo --version
```

### Rojo Studio Plugin

```bash
# Build and install the plugin
rojo plugin install
# This places the plugin in your Studio plugins folder
```

Or install from the Roblox Creator Store (search "Rojo").

### Project Initialization

```bash
rojo init my-game
cd my-game
```

This creates:
```
my-game/
  src/
    client/
      init.client.luau
    server/
      init.server.luau
    shared/
      init.luau
  default.project.json
```

### default.project.json (Standard Layout)

```json
{
  "name": "MyGame",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Shared": {
        "$path": "src/Shared"
      }
    },
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "$ignoreUnknownInstances": true,
      "Server": {
        "$path": "src/Server"
      }
    },
    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "$ignoreUnknownInstances": true,
        "Client": {
          "$path": "src/Client"
        }
      }
    },
    "StarterGui": {
      "$className": "StarterGui",
      "$ignoreUnknownInstances": true,
      "Gui": {
        "$path": "src/StarterGui"
      }
    }
  }
}
```

### File Naming Conventions

| File Name | Roblox Instance Type | Runs On |
|-----------|---------------------|---------|
| `Script.server.luau` | Script | Server |
| `Script.client.luau` | LocalScript | Client |
| `Module.luau` | ModuleScript | Wherever required |
| `init.server.luau` | Script (named after parent folder) | Server |
| `init.client.luau` | LocalScript (named after parent folder) | Client |
| `init.luau` | ModuleScript (named after parent folder) | Wherever required |
| `data.json` | ModuleScript returning the JSON as a table | Wherever required |
| `localization.csv` | LocalizationTable | Client |
| `model.rbxmx` / `.rbxm` | Model (XML/binary) | N/A |

### Running Rojo

```bash
# Start live sync (watches files, pushes changes to Studio)
rojo serve

# In Studio: Click "Rojo" plugin > Connect (defaults to localhost:34872)
```

**Two-terminal workflow:**
```
Terminal 1: rojo serve              # File sync
Terminal 2: claude                   # Claude Code
```

Claude edits files on disk. Rojo detects changes and pushes them to Studio in real-time. You see results in Studio immediately.

### Building for Distribution

```bash
# Build a .rbxlx place file
rojo build -o game.rbxlx

# Build a .rbxm model file
rojo build -o model.rbxm
```

### Full Toolchain (Professional Setup)

| Tool | Purpose | Install |
|------|---------|---------|
| **Rokit** | Toolchain manager (manages versions of all below) | `curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh \| sh` |
| **Rojo** | File sync between filesystem and Studio | `rokit install rojo-rbx/rojo` |
| **Wally** | Package manager for Luau | `rokit install UpliftGames/wally` |
| **Selene** | Linter designed for Roblox Luau | `rokit install Kampfkarren/selene` |
| **StyLua** | Code formatter | `rokit install JohnnyMorganz/StyLua` |
| **Darklua** | Code processor (bundling, minification) | `rokit install seaofvoices/darklua` |

**`rokit.toml` example:**
```toml
[tools]
rojo = "rojo-rbx/rojo@7.4.4"
wally = "UpliftGames/wally@0.3.2"
selene = "Kampfkarren/selene@0.27.1"
stylua = "JohnnyMorganz/StyLua@0.20.0"
```

### Wally Package Management

```bash
# Initialize wally in your project
wally init

# Edit wally.toml to add dependencies
# [dependencies]
# promise = "evaera/promise@4.0.0"
# signal = "stravant/goodsignal@0.1.1"

# Install packages
wally install

# Packages go to Packages/ folder, add to .gitignore the lockfile
```

---

## 4. Other AI Tools for Roblox Dev

### Roblox Assistant (Built-in)

Roblox's own AI assistant embedded directly in Studio.

**Strengths:**
- Native integration, no setup required
- Understands the current place context natively
- Can create/modify instances, write scripts, insert assets
- Supports playtest automation (as of March 2026)
- Now supports external LLMs (you can connect your own Claude/GPT API key)
- Evaluated via OpenGameEval benchmark (47 hand-crafted test cases)

**Limitations:**
- Smaller context window than Claude Code
- Less capable at complex multi-file refactoring
- No filesystem access (cannot work with Rojo projects directly)
- Quality varies; not as strong as Claude for complex Luau logic

**Best for:** Quick in-Studio tasks, inserting assets, simple script generation, beginners.

### Cursor IDE

**Strengths:**
- Full project-wide context awareness (reads entire repo)
- Claude Sonnet/Opus as backend model options
- Works perfectly with Rojo projects
- Multi-file editing, go-to-definition, inline suggestions
- Tab completion that understands your codebase

**Limitations:**
- Paid subscription ($20/month+)
- Same Luau knowledge gaps as Claude (needs .cursorrules file, similar to CLAUDE.md)
- No direct Studio integration without MCP

**Best for:** Teams who prefer an IDE over terminal, developers who want inline suggestions while coding.

### GitHub Copilot

**Strengths:**
- Fast inline completions
- Good at boilerplate and repetitive patterns
- Works in VS Code, JetBrains, Neovim
- Affordable ($10/month individual)

**Limitations:**
- Weakest Luau understanding of the three (trained mostly on Lua 5.x and Python)
- No project-wide context (line-by-line completion)
- Cannot interact with Studio
- Frequently suggests non-existent Roblox APIs

**Best for:** Autocomplete while typing, boilerplate generation, developers already using it for other languages.

### Roblox-Specific AI Tools

| Tool | Type | Key Feature | Cost |
|------|------|-------------|------|
| **RoCode** | Studio Plugin | Native AI assistant in Studio widget, Luau-aware, avoids deprecated APIs | Free (beta) |
| **Lux** | Studio Plugin | AI coding agent that reads scripts, understands project structure, audits code | Free |
| **SuperbulletAI** | Web + Studio | Full game builder, UI/VFX/3D generation, proprietary LLMs | Free (1M tokens/month) |
| **Vibe Coder** | Web | AI-assisted Roblox scripting | Free tier available |

### Recommendation by Use Case

| Use Case | Best Tool |
|----------|-----------|
| Complex game systems, architecture | **Claude Code + MCP** |
| Quick in-Studio edits and assets | **Roblox Assistant** |
| Full IDE experience with AI | **Cursor + Rojo** |
| Autocomplete while coding | **Copilot in VS Code** |
| Beginners, rapid prototyping | **SuperbulletAI or RoCode** |
| Code auditing, finding bugs | **Lux** |

---

## 5. Testing & Debugging with AI

### AI-Assisted Debugging Loop (with MCP)

The most powerful debugging workflow uses the MCP playtest tools:

```
1. Claude writes/edits script via MCP (set_script_source or file edit + Rojo)
2. Claude starts playtest via MCP (start_playtest / start_stop_play)
3. Claude reads console output via MCP (get_playtest_output / get_console_output)
4. Claude analyzes errors, modifies code, repeats
```

This creates an **autonomous iteration loop** where Claude can:
- Add strategic `print()` statements for debugging
- Run the game
- Read the output
- Fix issues
- Re-run until it works

### Practical Debugging Prompts

**Error diagnosis:**
```
"I'm getting this error during playtest:
[error output from Studio console]
Read the relevant scripts using get_script_source and fix the issue."
```

**Performance investigation:**
```
"The game stutters when more than 10 NPCs are active. Read the NPC controller
script and look for:
1. Operations inside RenderStepped that should be in Heartbeat
2. Unnecessary Instance:FindFirstChild calls in loops
3. Missing debounce on collision events
Suggest optimizations."
```

**Architecture review:**
```
"Use get_file_tree to see the full project structure, then grep_scripts for
any use of 'wait()' (deprecated, should use task.wait()) and ':connect('
(should be ':Connect(' with capital C). List all occurrences."
```

### What AI Cannot Do for Testing

- **Cannot feel game mechanics** - Jump height, movement speed, camera angles require human play
- **Cannot assess visual quality** - Materials, lighting, particles need human eyes
- **Cannot evaluate fun** - Pacing, difficulty curves, engagement are subjective
- **Cannot profile performance** - Needs MicroProfiler data from a human; cannot run it autonomously
- **Cannot test multiplayer** - Cannot simulate multiple real players; can only test server logic
- **Cannot verify physics** - Collision, raycasting edge cases need in-game verification

### Testing Strategy with AI

| Phase | AI Role | Human Role |
|-------|---------|------------|
| **Unit logic** | Write and verify pure Luau functions | Review edge cases |
| **Script errors** | Read output, fix syntax/runtime errors | Trigger the errors through play |
| **Integration** | Review client-server communication patterns | Test actual networking |
| **Performance** | Analyze code for known antipatterns | Profile with MicroProfiler |
| **Game feel** | N/A | Playtest, tune values |
| **QA** | Grep for deprecated APIs, type errors | Exploratory testing |

### Automated Checks Claude Can Run

```
-- Via MCP run_code or execute_luau:

-- Check for deprecated API usage
-- grep_scripts for: "wait(", ":connect(", "spawn(", "delay("
-- Suggest: task.wait(), :Connect(), task.spawn(), task.delay()

-- Check for memory leaks
-- grep_scripts for: ":Connect(" without corresponding :Disconnect()
-- Look for event connections in loops without cleanup

-- Check for yielding in wrong context
-- Look for task.wait() or :WaitForChild() inside RenderStepped connections
```

---

## 6. Practical Workflow Recommendation

### Recommended Stack

```
Claude Code (terminal)     -- AI coding agent
  + boshyxd MCP server    -- Script read/write, search, instance management
  + Official/built-in MCP  -- Playtest automation, run_code, console output
Rojo                       -- File sync to Studio
Rokit + Wally + Selene     -- Toolchain, packages, linting
Git                        -- Version control
Roblox Studio              -- Visual editing, playtesting, publishing
```

### Directory Structure

```
my-roblox-game/
  .claude/                    # Claude Code settings
  CLAUDE.md                   # Roblox-specific instructions for Claude
  .mcp.json                   # MCP server configuration
  default.project.json        # Rojo project definition
  rokit.toml                  # Toolchain versions
  wally.toml                  # Package dependencies
  wally.lock
  selene.toml                 # Linter config
  .stylua.toml                # Formatter config
  .gitignore
  src/
    Server/                   # -> ServerScriptService
      Services/
        DataService.server.luau
        GameService.server.luau
      init.server.luau
    Client/                   # -> StarterPlayerScripts
      Controllers/
        InputController.client.luau
        UIController.client.luau
      init.client.luau
    Shared/                   # -> ReplicatedStorage.Shared
      Modules/
        Config.luau
        Types.luau
        Utils.luau
      init.luau
    StarterGui/               # -> StarterGui
      MainHUD/
        init.luau
  Packages/                   # Wally packages (gitignored)
  assets/                     # Reference images, design docs
  docs/                       # Game design docs
```

### `.mcp.json` Configuration

```json
{
  "mcpServers": {
    "robloxstudio-mcp": {
      "command": "npx",
      "args": ["-y", "robloxstudio-mcp"]
    }
  }
}
```

If also using the official Rust server:
```json
{
  "mcpServers": {
    "robloxstudio-mcp": {
      "command": "npx",
      "args": ["-y", "robloxstudio-mcp"]
    },
    "roblox-official": {
      "command": "/path/to/studio-rust-mcp-server/target/release/rbx-studio-mcp",
      "args": []
    }
  }
}
```

### The Development Loop

```
START SESSION
  |
  v
[1] Open Roblox Studio (load your .rbxlx or connect to Rojo)
  |
  v
[2] Terminal 1: `rojo serve`  (file sync running)
  |
  v
[3] Terminal 2: `claude`  (Claude Code with MCP)
  |
  v
[4] DESIGN PHASE
  |  - Describe what you want to build to Claude
  |  - Claude uses get_file_tree / get_project_structure to understand current state
  |  - Claude proposes architecture (which scripts, where they go, how they communicate)
  |  - You approve or adjust
  |
  v
[5] BUILD PHASE (iterative)
  |  - Claude writes scripts to src/ (Rojo syncs to Studio automatically)
  |  - OR Claude uses set_script_source via MCP to write directly to Studio
  |  - Claude creates instances via MCP (create_object, set_property)
  |  - You handle visual placement, terrain, asset insertion in Studio
  |
  v
[6] TEST PHASE (iterative)
  |  - Claude starts playtest via MCP
  |  - Claude reads console output
  |  - Claude fixes errors, re-runs
  |  - You playtest for feel, visuals, fun
  |  - You report issues to Claude with error messages or descriptions
  |
  v
[7] REFINE
  |  - Claude refactors code for cleanliness
  |  - Selene lint check: `selene src/`
  |  - StyLua format: `stylua src/`
  |  - Git commit
  |
  v
[8] REPEAT from [4] for next feature
```

### Team Workflow (Multiple Developers)

```
Developer A (Game Designer + Visual):
  - Works in Roblox Studio directly
  - Handles map design, visual polish, asset placement
  - Uses Roblox Assistant for quick script tweaks
  - Tests game feel, balancing

Developer B (Programmer + AI):
  - Works in Claude Code + terminal
  - Handles game systems, server logic, data persistence
  - Uses MCP to read Studio state and push code
  - Uses Rojo for file sync
  - Runs Selene/StyLua before commits

Sync via Git:
  - Rojo project in Git repo
  - Both developers pull/push to main branch
  - Visual assets exported as .rbxm models in repo
  - Rojo build generates the final .rbxlx
```

### Cost Estimate

| Item | Monthly Cost |
|------|-------------|
| Claude Code (API usage, typical Roblox dev) | $5-20 |
| Roblox Studio | Free |
| Rojo + toolchain | Free (open source) |
| boshyxd MCP server | Free (open source) |
| GitHub (for Git hosting) | Free |
| **Total** | **$5-20/month** |

### Tips from Production Teams

1. **Start with CLAUDE.md** - This single file transforms Claude from useless to excellent for Roblox. Spend 30 minutes writing a thorough one.

2. **Use MCP for context, filesystem for code** - Let Claude read the game structure via MCP, but write code to the filesystem where Rojo picks it up. This gives you Git history.

3. **Pin your CLAUDE.md examples to your project** - Include snippets of your actual code patterns so Claude mimics your style.

4. **Break complex systems into modules** - Claude handles 100-200 line modules well. 1000+ line scripts lead to errors and hallucinations.

5. **Always review generated code** - Especially `require()` paths, service access patterns, and client-server boundaries. These are where Claude makes the most mistakes.

6. **Use grep_scripts regularly** - Ask Claude to audit for deprecated APIs, missing error handling, and inconsistent patterns.

7. **Keep a BUGS.md or TODO.md** - When you encounter issues during playtesting, log them. Then feed them to Claude in batch for fixing.

8. **Playtest often, playtest manually** - AI cannot tell you if your game is fun. The fastest development loop alternates between AI-generated code and 2-minute manual playtests.

---

## Sources

### Official Roblox
- [Roblox Official MCP Server (Rust)](https://github.com/Roblox/studio-rust-mcp-server)
- [Introducing the Open Source Studio MCP Server](https://devforum.roblox.com/t/introducing-the-open-source-studio-mcp-server/3649365)
- [Studio MCP Server Updates and External LLM Support](https://devforum.roblox.com/t/studio-mcp-server-updates-and-external-llm-support-for-assistant/4415631)
- [Assistant Updates: Studio Built-in MCP Server and Playtest Automation](https://devforum.roblox.com/t/assistant-updates-studio-built-in-mcp-server-and-playtest-automation/4474643)
- [OpenGameEval Benchmark for AI Assistants](https://about.roblox.com/newsroom/2025/12/opengameeval-benchmark-agentic-ai-assistants-roblox-studio)

### Community MCP
- [boshyxd/robloxstudio-mcp (Community MCP Server)](https://github.com/boshyxd/robloxstudio-mcp)
- [We Built a Full Game With 2 People Using AI](https://devforum.roblox.com/t/we-built-a-full-game-with-2-people-using-ai-in-studio-heres-the-tool/4308613)
- [v2.5.0 Roblox Studio MCP](https://devforum.roblox.com/t/v250-roblox-studio-mcp-speed-up-your-workflow-by-letting-ai-read-paths-and-properties/3707071)

### Rojo & Toolchain
- [Rojo Documentation](https://rojo.space/docs/v7/)
- [Rojo Sync Details](https://rojo.space/docs/v7/sync-details/)
- [Rojo Project Format](https://rojo.space/docs/v6/project-format/)
- [Rojo GitHub](https://github.com/rojo-rbx/rojo)

### Guides & Workflows
- [How to Use Claude Code with Roblox Studio (Complete Guide) - Roxlit](https://roxlit.dev/blog/how-to-use-claude-code-with-roblox)
- [Vibecoding in Roblox (MCP + Cursor AI + Rojo)](https://blog.justforward.co/vibecoding-in-roblox-mcp-cursor-ai-rojo-88be3f1d4035)
- [Best AI Code Tools for Roblox 2025](https://superbulletstudios.com/blogs/best-ai-code-tools-for-roblox-2025)
- [Selene, StyLua, and Roblox LSP](https://devforum.roblox.com/t/selene-stylua-and-roblox-lsp-what-they-do-why-you-should-use-them/1977666)

### Roblox-Specific AI Tools
- [RoCode - AI Coding Assistant for Luau](https://devforum.roblox.com/t/beta-rocode-the-ai-coding-assistant-built-specifically-for-luau-roblox/4116633)
- [Lux - AI Coding Agent for Roblox Studio](https://devforum.roblox.com/t/lux-ai-coding-agent-for-roblox-studio-free/4207506)
- [SuperbulletAI](https://devforum.roblox.com/t/superbulletai-launched-the-most-powerful-ai-game-builder-for-roblox-and-its-free-for-everyone-to-try/3856417)
- [Official Roblox Studio MCP Server Guide (Skywork)](https://skywork.ai/skypage/en/roblox-studio-mcp-server-guide/1978332255713140736)
