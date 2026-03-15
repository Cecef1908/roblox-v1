# Gold Rush Legacy — Audit du Codebase (14 mars 2026)

## Score Global : ~80% complete

---

## SERVEUR — Analyse fichier par fichier

### GameManager.server.lua — COMPLET
- Boot sequence OK (MapBuilder → DataManager → tous les systemes)
- OnPlayerAdded : charge profil, equipe outils, envoie data client
- OnPlayerRemoving : sauvegarde profil
- BindToClose : sauvegarde d'urgence
- Day/Night : **CODE PRESENT MAIS DESACTIVE** (ligne ~70)
- A FAIRE : decomenter le cycle jour/nuit

### DataManager.lua — COMPLET
- ProfileStore integration complete
- LoadProfile avec ForceLoad (anti-corruption)
- AddCash/RemoveCash avec validation
- AddXP avec detection auto level-up + unlock zones
- Auto-save toutes les 60 secondes
- Structure data complete (inventory, tools, quests, saloon, boss, tutorial)

### EconomyManager.lua — COMPLET
- HandleSell : validation quantity (integer, 1-9999), check NPC type, check inventory
- HandleBuyTool : check ownership, check cash
- HandleUpgradeTool : check level, check cash
- Integration QuestManager callbacks
- Leaderboard update after transactions

### MapBuilder.lua — COMPLET (1507 lignes)
- 17 RemoteEvents crees
- 6 templates gold deposit (Paillette, Pepite, Filon, Gem x3)
- 3 tool models (Batee, Tapis, Pioche)
- World generation : terrain, riviere, pont, collines, Dusthaven, trails, decor
- 5 NPCs crees (Marcel, Pierre, Jacques, Gustave, Bill, Tom)
- R15 humanoids avec ProximityPrompt
- Atmosphere setup (lighting, sky)

### MiningSystem.lua — COMPLET
- Anti-spam : 2s cooldown par joueur
- Distance check : 15 studs max
- Zone level check + tool check
- Zone 1 → BateeMinigame, Zone 2-3 → ProcessMining direct
- Drop calculation avec tool bonus + saloon buff + minigame score
- Callback QuestManager:OnMineGold()
- GiveTool/EquipOwnedTools pour gestion outils dans Backpack

### GoldSpawner.lua — COMPLET
- 1 spawner background par zone
- Spawn logic : clone template, position, rotation, ProximityPrompt
- Template selection : Zone1=Paillette, Zone2=70/30 Pepite/Filon, Zone3=60/30/10 Filon/Pepite/Gem
- DestroyDeposit avec cleanup du tracking
- Respects MaxActiveDeposits et SpawnInterval de ZoneConfig

### QuestManager.lua — COMPLET
- Daily reset check (UTC 00:00)
- AssignDailyQuests : 3 random parmi pool eligible (filtre par level)
- Callbacks : OnMineGold, OnSellTransaction, OnCraft
- Progress tracking + auto-completion + reward distribution
- SendQuestData pour synchro client

### CraftManager.lua — COMPLET
- Anti-spam : 1s cooldown
- Validation recette, level, materiaux
- Remove inputs + add output + XP reward
- Callback QuestManager:OnCraft()
- 3 recettes definies dans CraftConfig

### SaloonManager.lua — COMPLET
- Max 3 drinks/jour, daily reset
- Night discount (20% off)
- Buff system : SpeedBoost, LuckBoost
- BuffExpiry tracking
- Integration MiningSystem (LuckBoost x1.15)

### LeaderboardManager.lua — COMPLET
- Native Roblox leaderstats (Cash, Level)
- Refresh toutes les 30s
- Update on transactions

### BossManager.lua — STUB (3 lignes)
- Init() print uniquement
- TOUT A IMPLEMENTER

---

## CLIENT — Analyse fichier par fichier

### InteractionClient.client.lua — COMPLET (1039 lignes)
- 5 systemes NPC complets :
  - Tool Shop (Jacques) : liste outils, buy, upgrade
  - Merchant (Marcel) : liste items, sell avec quantite
  - Crafter (Gustave) : liste recettes, craft
  - Saloon (Bill) : menu drinks, buy
  - Tutor (Tom) : dialogue tutoriel multi-etapes
- Quest integration avec badge counter
- UI panels modaux avec style western (or + brun)
- Dialogue bubbles au-dessus des NPCs

### MiningClient.client.lua — COMPLET (305 lignes)
- Auto-equip meilleur outil (Pioche > Tapis > Batee)
- Animation de minage procedurale (6 phases, ~1.45s)
- VFX : water splash, gold flakes, glow tweens
- Communication : RequestMine → MineResult

### UIManager.lua — COMPLET (1196 lignes)
- HUD responsive (mobile detection, scaling 0.55-0.85x)
- TopBar : Cash avec delta animation, Level/XP bar
- InventoryPanel : collapsible, couleurs par rarete
- ToolBar : outil equipe avec icone
- Notifications : toast Success/Error/Info/LevelUp
- Effets : floating text, mine particles, loot feed, NPC bubble
- Typewriter effect pour dialogues (~25ms/char)

### BateeMinigame.client.lua — COMPLET (383 lignes)
- UI compact circulaire (180x180px)
- Needle rotation 200 deg/sec
- Scoring : Perfect (1.0), Good (0.7), Medium (0.4), Missed (0.1)
- Timeout 10s avec auto-submit
- Input : F (desktop) ou Touch (mobile)

### DayNightClient.client.lua — COMPLET (114 lignes)
- ColorCorrection effect
- 4 periodes : Night, Sunset, Sunrise, Day
- Lerp transitions pour sunset/sunrise
- Toggle PointLight/SpotLight dans workspace
- Update every 1s via Heartbeat

### DetecteurSystem.client.lua — STUB (3 lignes)
- TODO comment uniquement
- TOUT A IMPLEMENTER

### ClientUtils.lua — VIDE (2 lignes)
- Module vide, return {}

---

## CONFIGS — Toutes completes

| Config | Contenu cle |
|--------|-------------|
| GameConfig | AutoSave 60s, Saloon 3 drinks/jour, Boss HP 500 |
| ToolConfig | 3 outils x 3 niveaux (Batee, Tapis, Pioche) |
| EconomyConfig | Prix, XP, drops par zone, tool bonuses, respawn timers |
| ZoneConfig | 3 zones, positions, niveaux requis, outils autorises |
| GemConfig | 3 gemmes (Quartz, Amethyste, Topaze) |
| NPCConfig | 6 NPCs (Marcel, Pierre, Jacques, Gustave, Bill, Tom) |
| QuestConfig | 7 quetes quotidiennes, pick 3/jour |
| CraftConfig | 3 recettes (paillettes→or pur, or pur+minerai→lingot, pepites→or pur) |

---

## RISQUES IDENTIFIES

1. **Jamais teste en playtest** — bugs inevitables a la premiere execution
2. **Day/Night desactive** — peut causer des erreurs si reactive sans test
3. **BossManager stub** — feature importante pour Zone 3
4. **Tutorial non implemente cote serveur** — events existent mais pas de logique
5. **Pas de sons** — le jeu sera silencieux
6. **MapBuilder 1500 lignes** — complexe, potentiel de bugs de generation
7. **BUG DataManager auto-save** — lignes 92-105 appellent `SetAsync()` directement sur le DataStore, ce qui bypass le session locking de ProfileStore. ProfileStore fait deja l'auto-save en interne (~30s). CE CODE DOIT ETRE SUPPRIME pour eviter corruption de donnees.
8. **BateeMinigameResult pas rate-limited** — le serveur valide le score mais ne verifie pas qu'un minigame a bien ete demarre pour ce deposit. Un exploiter pourrait spammer des scores.
9. **Negociant (Pierre) pas wire** — le NPC existe dans NPCConfig et MapBuilder le spawn, mais InteractionClient n'a pas de menu specifique pour lui (il utilise peut-etre le meme que Marcel)

---

## DIVERGENCES DOC vs CODE

La doc originale (tech-spec) mentionne :
- 5 outils → **Code a 3 outils** (Batee, Tapis, Pioche)
- 4 zones → **Code a 3 zones** (Riviere, Collines, Mine)
- 6 gemmes → **Code a 3 gemmes** (Quartz, Amethyste, Topaze)
- Detecteur (outil) → **Non implemente** (prevu comme systeme client)
- Foreuse industrielle → **Non dans le code**

Ces divergences sont NORMALES — le code represente le scope realiste pour le MVP.
Le tech-spec etait le scope ideal. On ship avec ce qui est code.
