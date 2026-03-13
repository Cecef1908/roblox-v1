# MCP Roblox Studio — Master Reference

> Synthese de 6 recherches paralleles (GitHub, Reddit, Roblox Docs, Tutorials, execute_luau patterns, MCP ecosystem)
> Date: 2026-03-12

---

## 1. LANDSCAPE MCP ROBLOX (Mars 2026)

### 3 options disponibles

| Option | Outils | Statut | Notes |
|--------|--------|--------|-------|
| **boshyxd/robloxstudio-mcp** (v2.5.1) | **51 outils** | Actif, community | Le plus complet. C'est celui qu'on utilise |
| **Roblox Built-in MCP** (Feb 2026) | ~14 outils | Officiel, nouveau | Integre dans Studio nativement. Input simulation |
| **Roblox/studio-rust-mcp-server** | ~5 outils | Deprecie | Remplace par le built-in |

### Notre setup actuel = le meilleur pattern
Claude Code + Rojo (filesystem sync) + boshyxd MCP (Studio control) + CLAUDE.md (context)
C'est exactement le workflow recommande par la communaute Reddit, DevForum, et les blogs.

---

## 2. REFERENCE COMPLETE DES 51 OUTILS (boshyxd/robloxstudio-mcp)

### Exploration (Read)

| Outil | Params | Usage |
|-------|--------|-------|
| `get_file_tree` | `path?` | Arbre d'instances Studio |
| `get_project_structure` | `path?`, `maxDepth?` (def 3), `scriptsOnly?` | Hierarchie complete |
| `get_place_info` | — | Place ID, nom, settings |
| `get_services` | `serviceName?` | Services disponibles |
| `get_instance_properties` | `instancePath`, `excludeSource?` | Props d'une instance |
| `get_instance_children` | `instancePath` | Enfants + classes |
| `get_class_info` | `className` | Props/methodes d'une classe Roblox |
| `search_objects` | `query`, `searchType?` (name/class/property) | Chercher instances |
| `search_files` | `query`, `searchType?` | Chercher par nom/type/contenu |
| `search_by_property` | `propertyName`, `propertyValue` | Chercher par valeur de prop |
| `get_selection` | — | Objets selectionnes dans Studio |

### Scripts (Read/Write)

| Outil | Params | Usage |
|-------|--------|-------|
| `get_script_source` | `instancePath`, `startLine?`, `endLine?` | Lire source (numerotee) |
| `set_script_source` | `instancePath`, `source` | Remplacer source complete |
| `edit_script_lines` | `instancePath`, `startLine`, `endLine`, `newContent` | Editer range de lignes |
| `insert_script_lines` | `instancePath`, `afterLine?`, `newContent` | Inserer lignes |
| `delete_script_lines` | `instancePath`, `startLine`, `endLine` | Supprimer lignes |
| `grep_scripts` | `pattern`, `caseSensitive?`, `contextLines?`, `path?`, `classFilter?` | Recherche dans tous les scripts |

### Properties (Write)

| Outil | Params | Usage |
|-------|--------|-------|
| `set_property` | `instancePath`, `propertyName`, `propertyValue` | Set une prop |
| `mass_set_property` | `paths[]`, `propertyName`, `propertyValue` | Set prop sur N instances |
| `mass_get_property` | `paths[]`, `propertyName` | Lire prop de N instances |
| `set_calculated_property` | `paths[]`, `propertyName`, `formula` | Props via formule (ex: "index * 50") |
| `set_relative_property` | `paths[]`, `propertyName`, `operation`, `value` | Modifier relatif (add/multiply...) |

### Creation/Suppression (Write)

| Outil | Params | Usage |
|-------|--------|-------|
| `create_object` | `className`, `parent`, `name?`, `properties?` | Creer instance |
| `mass_create_objects` | `objects[]` | Creer N instances en batch |
| `delete_object` | `instancePath` | Supprimer instance |
| `smart_duplicate` | `instancePath`, `count`, `options?` (namePattern, positionOffset, rotationOffset, propertyVariations) | Dupliquer intelligent |
| `mass_duplicate` | `duplications[]` | Batch de smart_duplicate |

### Attributes & Tags

| Outil | Params | Usage |
|-------|--------|-------|
| `get_attribute` / `get_attributes` | `instancePath` | Lire attributs |
| `set_attribute` | `instancePath`, `attributeName`, `attributeValue` | Set attribut |
| `delete_attribute` | `instancePath`, `attributeName` | Supprimer attribut |
| `get_tags` | `instancePath` | Lire tags |
| `add_tag` / `remove_tag` | `instancePath`, `tagName` | Ajouter/retirer tag |
| `get_tagged` | `tagName` | Toutes instances avec un tag |

### Execution & Playtest

| Outil | Params | Usage |
|-------|--------|-------|
| `execute_luau` | `code` | Executer Luau en contexte plugin (edit mode) |
| `start_playtest` | `mode` ("play"/"run") | Lancer playtest |
| `stop_playtest` | — | Arreter playtest + retourner output |
| `get_playtest_output` | — | Poll console sans arreter |
| `undo` / `redo` | — | Annuler/refaire |

### Build Library

| Outil | Params | Usage |
|-------|--------|-------|
| `export_build` | `instancePath`, `outputId?`, `style?` | Exporter Model vers JSON |
| `create_build` | `id`, `style`, `palette`, `parts[]` | Creer build from scratch |
| `generate_build` | `id`, `style`, `palette`, `code` (JS avec primitives) | Generer proceduralement |
| `import_build` | `buildData` (ou library ID), `targetPath`, `position?` | Importer build dans Studio |
| `import_scene` | `sceneData` (models + placements) | Importer scene complete |
| `list_library` | `style?` | Lister builds disponibles |
| `get_build` | `id` | Recuperer build par ID |
| `search_materials` | `query?` | Chercher MaterialVariants |

### Assets (Creator Store)

| Outil | Params | Usage |
|-------|--------|-------|
| `search_assets` | `assetType`, `query?`, `maxResults?` | Chercher sur Creator Store |
| `get_asset_details` | `assetId` | Details d'un asset |
| `get_asset_thumbnail` | `assetId`, `size?` | Thumbnail base64 |
| `insert_asset` | `assetId`, `parentPath?`, `position?` | Inserer asset dans Studio |
| `preview_asset` | `assetId` | Preview sans insertion |

### Screenshot

| Outil | Params | Usage |
|-------|--------|-------|
| `capture_screenshot` | — | Screenshot viewport (edit mode, necessite EditableImage API) |

---

## 3. PRIMITIVES generate_build

Le `generate_build` execute du JS sandboxe avec ces primitives :

### Haut niveau (remplace 5-20 lignes chacune)
- `room(x,y,z, w,h,d, wallKey, floorKey?, ceilKey?)` — Piece complete
- `roof(x,y,z, w,d, style, key)` — style: "flat"/"gable"/"hip"
- `stairs(x1,y1,z1, x2,y2,z2, width, key)` — Escalier auto
- `column(x,y,z, height, radius, key)` — Colonne avec base+chapiteau
- `arch(x,y,z, w,h, thickness, key)` — Arche
- `fence(x1,z1, x2,z2, y, key)` — Cloture avec poteaux
- `pew(x,y,z, w,d, seatKey, legKey?)` — Banc

### Basiques
- `part(x,y,z, sx,sy,sz, key)` — Part simple
- `rpart(x,y,z, sx,sy,sz, rx,ry,rz, key)` — Part avec rotation
- `wall(x1,z1, x2,z2, height, thickness, key)` — Mur point-a-point
- `floor(x1,z1, x2,z2, y, thickness, key)` — Sol
- `fill(x1,y1,z1, x2,y2,z2, key)` — Volume 3D
- `beam(x1,y1,z1, x2,y2,z2, thickness, key)` — Poutre

### Repetition
- `row(x,y,z, count, spacingX, spacingZ, fn)` — Repetition lineaire
- `grid(x,y,z, countX, countZ, spacingX, spacingZ, fn)` — Grille 2D
- `rng()` — Random seede (deterministe, seed=42)

---

## 4. PITFALLS CONNUS ET SOLUTIONS

| Probleme | Cause | Solution |
|----------|-------|----------|
| Script edits non appliques | Draft mode asymetry | Update plugin v2.3.0+ |
| edit_script_lines corrompt les quotes | Double-escaping JSON | Utiliser `set_script_source` ou `execute_luau` avec `[[ ]]` |
| execute_luau timeout | WaitForChild qui bloque | Utiliser FindFirstChild |
| Plugin deconnecte apres playtests | Limitation connue | Restart session |
| insert_asset "Unknown endpoint" | Vieux plugin | Reinstaller MCPPlugin.rbxmx |
| Connection echoue | HTTP Requests desactive | Activer dans Experience Settings > Security |
| NPC R15 ne s'anime pas | Parts Anchored = true | Utiliser AlignPosition + AlignOrientation au lieu de Anchor |

---

## 5. PATTERNS execute_luau ESSENTIELS

### makePart — factory universelle (TOUJOURS set Parent en dernier)
```luau
local function makePart(props)
    local p = Instance.new("Part")
    p.Anchored = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    for k, v in pairs(props) do
        if k ~= "Parent" then p[k] = v end
    end
    p.Parent = props.Parent or workspace
    return p
end
```

### Terrain
```luau
-- Sol plat
terrain:FillBlock(CFrame.new(0, -2, 0), Vector3.new(200, 4, 200), Enum.Material.Sand)
-- Colline organique (empiler des FillBall)
terrain:FillBall(Vector3.new(0, 0, 0), 50, Enum.Material.Sand)
terrain:FillBall(Vector3.new(0, 10, 0), 30, Enum.Material.Rock)
-- Riviere (carve Air puis fill Water avec CFrame oriente)
terrain:FillBlock(cf, Vector3.new(width, 8, segLen), Enum.Material.Air)
terrain:FillBlock(cfWater, Vector3.new(width, 7, segLen), Enum.Material.Water)
```

### NPC R15 anime (pattern critique)
```luau
-- 1. CreateHumanoidModelFromDescription (pcall!)
-- 2. Un-anchor ALL parts (sinon Motor6D ne marche pas)
-- 3. AlignPosition + AlignOrientation sur HumanoidRootPart (maintient en place)
-- 4. ProximityPrompt pour interaction
-- 5. SetAttribute pour metadata ("NPCType", "NPCName")
```

### Lighting western
```luau
-- Atmosphere (haze desert), Bloom, SunRays, ColorCorrection (warm tint), DepthOfField
```

### Organisation Workspace
```luau
-- Folders (pas Models) pour grouper — plus performant
-- Creer TOUS les RemoteEvents AVANT de parent au tree
-- Hierarchie plate (2-3 niveaux max)
```

---

## 6. WORKFLOW OPTIMAL (CONFIRME PAR LA COMMUNAUTE)

```
1. Ecrire le code .lua sur filesystem (Claude Code)
2. Rojo sync → Studio en temps reel
3. execute_luau → MapBuilder:Init() (build map en edit mode)
4. start_playtest → lancer le jeu
5. get_playtest_output → lire console (prints, errors)
6. Diagnostiquer → fixer le code
7. Repeter 3-6 jusqu'a clean
```

### Regles d'or
- **Read-first** : toujours `get_project_structure` ou `get_script_source` avant de modifier
- **Batch operations** : preferer `mass_create_objects` / `mass_set_property` aux appels individuels
- **execute_luau pour la logique complexe** : boucles, conditionnels, terrain, NPCs
- **MCP tools pour les ops simples** : create_object, set_property
- **Build Library pour les structures** : export_build → import_build / import_scene

---

## 7. OUTILS COMPLEMENTAIRES

| Outil | Description | URL |
|-------|-------------|-----|
| **Roxlit** | Setup one-click (Rojo + MCP + context packs) | roxlit.dev |
| **BloxBot** | Desktop app AI + MCP multi-model | bloxbot.ai |
| **Script Exporter Pro** | Exporte codebase pour AI | scriptexporter.com |
| **Vibe Coder** | Plugin Studio, support GPT/Claude/Gemini | rbxvibecoder.com |
| **OpenGameEval** | Benchmark Roblox pour agents AI | roblox.com |

---

## 8. DECOUVERTE MAJEURE : MCP NATIF STUDIO (Feb 2026)

Roblox a integre un MCP server directement dans Studio :
- **Activation** : Assistant > Settings > MCP Servers > toggle on
- **Claude Code setup macOS** : `claude mcp add Roblox_Studio -- /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`
- **Outils** : script_read, multi_edit, script_search, script_grep, search_game_tree, inspect_instance, execute_luau, start_stop_play, console_output, character_navigation, keyboard_input, mouse_input
- **Nouveau** : simulation d'input joueur (clavier, souris, navigation personnage) pour tests automatises
- **Docs** : https://create.roblox.com/docs/studio/mcp

On peut potentiellement utiliser les DEUX MCP en parallele (boshyxd pour build library/assets, natif pour playtest automation).

---

## SOURCES

- [boshyxd/robloxstudio-mcp](https://github.com/boshyxd/robloxstudio-mcp) — 51 outils, v2.5.1
- [Roblox Official MCP Docs](https://create.roblox.com/docs/studio/mcp)
- [DevForum: Built-in MCP + External LLM](https://devforum.roblox.com/t/studio-mcp-server-updates-and-external-llm-support-for-assistant/4415631)
- [DevForum: Built a Full Game With 2 People Using AI](https://devforum.roblox.com/t/we-built-a-full-game-with-2-people-using-ai-in-studio-heres-the-tool/4308613)
- [How to Use Claude Code with Roblox - Roxlit](https://roxlit.dev/blog/how-to-use-claude-code-with-roblox)
- [Roblox Creator Hub](https://create.roblox.com/docs)
- [OpenGameEval Benchmark](https://about.roblox.com/newsroom/2025/12/opengameeval-benchmark-agentic-ai-assistants-roblox-studio)
- Reddit: r/robloxgamedev, r/ClaudeAI, r/ROBLOXStudio
