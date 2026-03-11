# Gold Rush Legacy — V1 Démo — Spécification Technique Complète

> **Version** : 1.0  
> **Date** : 2026-03-11  
> **Scope** : 3 zones de minage + 1 hub central  
> **Cible** : Développeur junior avec MCP Roblox Studio + Claude Code  
> **Moteur** : Roblox Studio (Luau)

---

## Table des matières

- [A. Architecture Projet Roblox Studio](#a-architecture-projet-roblox-studio)
- [B. Data Model Détaillé](#b-data-model-détaillé)
- [C. Scripts Serveur (Pseudo-code)](#c-scripts-serveur-pseudo-code)
- [D. Scripts Client (Pseudo-code)](#d-scripts-client-pseudo-code)
- [E. Système d'Événements](#e-système-dévénements)
- [F. UI Screens](#f-ui-screens)
- [G. Prompts Claude Code / MCP](#g-prompts-claude-code--mcp)
- [H. Anti-Exploit](#h-anti-exploit)

---

## A. Architecture Projet Roblox Studio

### A.1 Arborescence complète

```
game
├── Workspace
│   ├── Map
│   │   ├── HubCentral/               -- Ville au centre
│   │   │   ├── Buildings/
│   │   │   │   ├── Marchand/          -- PNJ Marchand local
│   │   │   │   │   ├── NPC_Marchand   (Model)
│   │   │   │   │   └── ProximityPrompt
│   │   │   │   ├── Negociant/         -- PNJ Négociant
│   │   │   │   │   ├── NPC_Negociant  (Model)
│   │   │   │   │   └── ProximityPrompt
│   │   │   │   ├── MagasinOutils/     -- Magasin d'outils
│   │   │   │   │   ├── NPC_Vendeur    (Model)
│   │   │   │   │   └── ProximityPrompt
│   │   │   │   ├── Saloon/            -- Saloon simplifié
│   │   │   │   │   ├── NPC_Barman     (Model)
│   │   │   │   │   ├── ProximityPrompt
│   │   │   │   │   └── SaloonInterior (Model)
│   │   │   │   ├── Forge/             -- Craft/Raffinage
│   │   │   │   │   ├── NPC_Forgeron   (Model)
│   │   │   │   │   ├── Enclume        (Part)
│   │   │   │   │   └── ProximityPrompt
│   │   │   │   └── Leaderboard/
│   │   │   │       └── LeaderboardDisplay (SurfaceGui sur Part)
│   │   │   ├── Spawns/
│   │   │   │   └── SpawnLocation
│   │   │   └── Decorations/
│   │   │
│   │   ├── Zone1_RiviereTransquille/  -- Zone tutoriel
│   │   │   ├── Terrain/
│   │   │   ├── WaterArea/             -- Rivière
│   │   │   ├── GoldSpawnPoints/       -- Folder avec Part "SpawnPoint_01..N"
│   │   │   ├── NPC_Guide              (Model) -- PNJ tutoriel
│   │   │   ├── ProximityPrompt_Guide
│   │   │   ├── BateeStations/         -- Spots de batée (Part + ProximityPrompt)
│   │   │   │   ├── BateeSpot_01
│   │   │   │   ├── BateeSpot_02
│   │   │   │   └── BateeSpot_03
│   │   │   └── ZoneTrigger            (Part, CanCollide=false, Transparency=1)
│   │   │
│   │   ├── Zone2_CollinesAmbrees/     -- Zone intermédiaire
│   │   │   ├── Terrain/
│   │   │   ├── GoldSpawnPoints/
│   │   │   ├── FilonSpots/            -- Spots de filon (Part + ProximityPrompt)
│   │   │   │   ├── Filon_01
│   │   │   │   ├── Filon_02
│   │   │   │   └── Filon_03
│   │   │   ├── DetecteurZones/        -- Zones détecteur (Part invisible trigger)
│   │   │   │   ├── DetectZone_01
│   │   │   │   └── DetectZone_02
│   │   │   └── ZoneTrigger
│   │   │
│   │   └── Zone3_MineCrowCreek/       -- Mine souterraine
│   │       ├── Entrance/              -- Entrée de la mine
│   │       │   └── ProximityPrompt_Enter
│   │       ├── MineInterior/
│   │       │   ├── Tunnels/
│   │       │   ├── Rails/             -- Rails de mine (décor)
│   │       │   ├── MineCartSpawn/     -- Position chariot
│   │       │   ├── OreNodes/          -- Nœuds de minerai
│   │       │   │   ├── OreNode_01
│   │       │   │   ├── OreNode_02
│   │       │   │   └── OreNode_03..N
│   │       │   └── GemSpawnPoints/    -- Spawn de gemmes
│   │       ├── BossArena/
│   │       │   ├── BossSpawnPoint     (Part)
│   │       │   ├── ArenaTrigger       (Part, CanCollide=false)
│   │       │   └── ArenaDoor          (Part, verrouillable)
│   │       └── ZoneTrigger
│   │
│   └── ActiveGoldDeposits/            -- Folder dynamique (or/gemmes spawned)
│
├── ServerScriptService
│   ├── Core/
│   │   ├── GameManager.server.lua
│   │   ├── DataManager.server.lua
│   │   └── EconomyManager.server.lua
│   ├── Systems/
│   │   ├── GoldSpawner.server.lua
│   │   ├── MiningSystem.server.lua
│   │   ├── CraftManager.server.lua
│   │   ├── QuestManager.server.lua
│   │   ├── BossManager.server.lua
│   │   ├── SaloonManager.server.lua
│   │   └── LeaderboardManager.server.lua
│   └── Lib/
│       ├── ProfileStore.lua           -- Module ProfileStore (externe)
│       └── Utils.lua
│
├── ServerStorage
│   ├── Templates/
│   │   ├── GoldDeposit_Paillette.rbxm   -- Template paillette
│   │   ├── GoldDeposit_Pepite.rbxm       -- Template pépite
│   │   ├── GoldDeposit_Filon.rbxm        -- Template filon
│   │   ├── Gem_Quartz.rbxm
│   │   ├── Gem_Amethyste.rbxm
│   │   ├── Gem_Topaze.rbxm
│   │   └── Boss_GardienMine.rbxm         -- Template boss
│   └── ItemModels/
│       ├── Tool_Batee.rbxm
│       ├── Tool_Tapis.rbxm
│       └── Tool_Pioche.rbxm
│
├── ReplicatedStorage
│   ├── Modules/
│   │   ├── Config/
│   │   │   ├── GameConfig.lua         -- Config globale (constantes)
│   │   │   ├── EconomyConfig.lua      -- Prix, taux, XP
│   │   │   ├── ToolConfig.lua         -- Config outils
│   │   │   ├── NPCConfig.lua          -- Config PNJ
│   │   │   ├── QuestConfig.lua        -- Config quêtes
│   │   │   ├── CraftConfig.lua        -- Recettes de craft
│   │   │   ├── GemConfig.lua          -- Config gemmes
│   │   │   └── ZoneConfig.lua         -- Config zones
│   │   └── Shared/
│   │       ├── Types.lua              -- Types partagés
│   │       └── Enums.lua              -- Enums partagés
│   ├── Events/
│   │   ├── RemoteEvents/             -- Folder RemoteEvent
│   │   └── RemoteFunctions/          -- Folder RemoteFunction
│   └── Assets/
│       └── UI/                        -- Assets UI (images, icônes)
│
├── StarterPlayerScripts
│   ├── Core/
│   │   ├── MiningClient.client.lua
│   │   ├── InteractionClient.client.lua
│   │   └── UIManager.client.lua
│   ├── Systems/
│   │   ├── BateeMinigame.client.lua
│   │   ├── DetecteurSystem.client.lua
│   │   └── DayNightClient.client.lua
│   └── Lib/
│       └── ClientUtils.lua
│
├── StarterGui
│   ├── MainHUD/                       -- ScreenGui
│   │   ├── CashDisplay                (Frame)
│   │   ├── XPBar                      (Frame)
│   │   ├── InventoryButton            (ImageButton)
│   │   └── QuestTracker               (Frame)
│   ├── ShopUI/                        -- ScreenGui (Enabled=false)
│   ├── SellUI/                        -- ScreenGui (Enabled=false)
│   ├── CraftUI/                       -- ScreenGui (Enabled=false)
│   ├── InventoryUI/                   -- ScreenGui (Enabled=false)
│   ├── QuestUI/                       -- ScreenGui (Enabled=false)
│   ├── SaloonUI/                      -- ScreenGui (Enabled=false)
│   ├── BossUI/                        -- ScreenGui (Enabled=false)
│   ├── BateeMinigameUI/              -- ScreenGui (Enabled=false)
│   ├── LevelUpUI/                     -- ScreenGui (Enabled=false)
│   └── DialogueUI/                    -- ScreenGui (Enabled=false)
│
└── StarterPack
    └── (vide — outils donnés via scripts)
```

### A.2 Conventions de nommage

| Type | Convention | Exemple |
|------|-----------|---------|
| Folders | PascalCase | `GoldSpawnPoints` |
| Scripts serveur | PascalCase.server.lua | `GameManager.server.lua` |
| Scripts client | PascalCase.client.lua | `MiningClient.client.lua` |
| ModuleScripts | PascalCase.lua | `EconomyConfig.lua` |
| Models/Parts Workspace | PascalCase + underscore numéro | `BateeSpot_01`, `OreNode_03` |
| RemoteEvents | PascalCase verbe | `RequestMine`, `UpdateInventory` |
| RemoteFunctions | Get/Fetch + PascalCase | `GetPlayerData`, `FetchShopItems` |
| UI ScreenGui | PascalCase + "UI" | `ShopUI`, `CraftUI` |
| Config modules | PascalCase + "Config" | `EconomyConfig` |
| Attributs | camelCase | `goldAmount`, `isActive` |
| Constantes | UPPER_SNAKE_CASE | `MAX_INVENTORY_SLOTS` |

---

## B. Data Model Détaillé

### B.1 PlayerData — Structure Luau complète

```lua
-- Type complet du profil joueur sauvegardé via ProfileStore
export type PlayerData = {
    -- === IDENTITÉ ===
    Version: number,           -- Version du schéma (migration)
    FirstJoin: number,         -- os.time() du premier login
    LastLogin: number,         -- os.time() du dernier login
    TotalPlayTime: number,     -- Secondes jouées cumulées

    -- === ÉCONOMIE ===
    Cash: number,              -- Argent ($) courant
    TotalCashEarned: number,   -- Total gagné (lifetime, pour leaderboard)

    -- === XP & NIVEAU ===
    XP: number,                -- XP courant
    Level: number,             -- 1=Amateur, 2=Orpailleur, 3=Prospecteur
    -- Seuils XP : Level 1→2 = 500 XP, Level 2→3 = 2000 XP

    -- === INVENTAIRE ===
    Inventory: {
        -- Matières premières
        Paillettes: number,        -- Paillettes d'or (brut)
        OrPur: number,             -- Or pur (raffiné depuis paillettes)
        Lingots: number,           -- Lingots d'or (crafté depuis or pur)
        Pepites: number,           -- Pépites d'or (Zone 2+)
        MineraiOr: number,         -- Minerai d'or brut (Zone 3)

        -- Gemmes
        Quartz: number,
        Amethyste: number,
        Topaze: number,
    },

    -- === OUTILS ===
    Tools: {
        Batee: {
            Owned: boolean,
            Level: number,         -- 1=Bois, 2=Cuivre, 3=Fer
        },
        Tapis: {
            Owned: boolean,
            Level: number,         -- 1=Base, 2=Amélioré, 3=Pro
        },
        Pioche: {
            Owned: boolean,
            Level: number,         -- 1=Bois, 2=Fer, 3=Acier
        },
    },

    -- === QUÊTES ===
    Quests: {
        DailyReset: number,        -- os.time() du dernier reset quotidien
        Active: { [string]: QuestProgress },
        Completed: { [string]: number },  -- questId → nombre de fois complétée
    },

    -- === ZONES ===
    Zones: {
        Zone1_Unlocked: boolean,   -- Toujours true (tutoriel)
        Zone2_Unlocked: boolean,   -- Débloquée à Level 2
        Zone3_Unlocked: boolean,   -- Débloquée à Level 3
    },

    -- === SALOON ===
    Saloon: {
        LastDrinkTime: number,     -- os.time() dernier verre
        DrinksToday: number,       -- Nombre de verres aujourd'hui
        BuffActive: string?,       -- nil ou "SpeedBoost" ou "LuckBoost"
        BuffExpiry: number,        -- os.time() expiration du buff
    },

    -- === BOSS ===
    Boss: {
        GardienDefeated: number,   -- Nombre de fois vaincu
        LastBossAttempt: number,   -- os.time() dernière tentative
    },

    -- === TUTORIEL ===
    Tutorial: {
        Completed: boolean,
        Step: number,              -- Étape courante du tuto (1-6)
    },
}

export type QuestProgress = {
    QuestId: string,
    Progress: number,          -- Avancement courant
    Goal: number,              -- Objectif à atteindre
    Completed: boolean,
    ClaimedReward: boolean,
}
```

### B.2 Valeurs par défaut (nouveau joueur)

```lua
local DEFAULT_PLAYER_DATA: PlayerData = {
    Version = 1,
    FirstJoin = 0,
    LastLogin = 0,
    TotalPlayTime = 0,

    Cash = 50,                 -- 50$ de départ
    TotalCashEarned = 0,

    XP = 0,
    Level = 1,                 -- Amateur

    Inventory = {
        Paillettes = 0,
        OrPur = 0,
        Lingots = 0,
        Pepites = 0,
        MineraiOr = 0,
        Quartz = 0,
        Amethyste = 0,
        Topaze = 0,
    },

    Tools = {
        Batee = { Owned = true, Level = 1 },     -- Donnée au tutoriel
        Tapis = { Owned = false, Level = 0 },
        Pioche = { Owned = false, Level = 0 },
    },

    Quests = {
        DailyReset = 0,
        Active = {},
        Completed = {},
    },

    Zones = {
        Zone1_Unlocked = true,
        Zone2_Unlocked = false,
        Zone3_Unlocked = false,
    },

    Saloon = {
        LastDrinkTime = 0,
        DrinksToday = 0,
        BuffActive = nil,
        BuffExpiry = 0,
    },

    Boss = {
        GardienDefeated = 0,
        LastBossAttempt = 0,
    },

    Tutorial = {
        Completed = false,
        Step = 1,
    },
}
```

### B.3 Config Économique — `EconomyConfig.lua`

```lua
local EconomyConfig = {}

-- ============================================================
-- PRIX DE VENTE — Ce que le joueur reçoit en vendant aux PNJ
-- ============================================================
EconomyConfig.SellPrices = {
    -- Marchand Local (achète tout, prix standard)
    MarchandLocal = {
        Paillettes   = 2,      -- $/unité
        OrPur        = 10,     -- $/unité
        Lingots      = 50,     -- $/unité
        Pepites      = 15,     -- $/unité
        MineraiOr    = 5,      -- $/unité
        Quartz       = 8,      -- $/unité
        Amethyste    = 25,     -- $/unité
        Topaze       = 40,     -- $/unité
    },

    -- Négociant (prix supérieurs +30%, mais n'achète que or pur + lingots + gemmes)
    Negociant = {
        OrPur        = 13,     -- +30%
        Lingots      = 65,     -- +30%
        Amethyste    = 33,     -- +30%
        Topaze       = 52,     -- +30%
        -- N'achète PAS : Paillettes, Pepites, MineraiOr, Quartz
    },
}

-- ============================================================
-- XP REWARDS
-- ============================================================
EconomyConfig.XPRewards = {
    -- Minage
    MinePaillette    = 5,
    MinePepite       = 15,
    MineMineraiOr    = 20,
    MineGem          = 25,

    -- Craft
    CraftOrPur       = 10,
    CraftLingot      = 30,

    -- Vente
    SellTransaction  = 5,      -- Par transaction (pas par item)

    -- Quêtes
    QuestComplete    = 50,

    -- Boss
    BossDefeat       = 200,
}

-- ============================================================
-- LEVEL THRESHOLDS
-- ============================================================
EconomyConfig.LevelThresholds = {
    [1] = { Name = "Amateur",      MinXP = 0,    MaxXP = 499  },
    [2] = { Name = "Orpailleur",   MinXP = 500,  MaxXP = 1999 },
    [3] = { Name = "Prospecteur",  MinXP = 2000, MaxXP = math.huge },
}

-- ============================================================
-- DROP RATES (probabilités en %)
-- ============================================================
EconomyConfig.DropRates = {
    -- Zone 1 — Rivière Tranquille (batée uniquement)
    Zone1 = {
        Paillettes   = { Chance = 80, MinQty = 1, MaxQty = 3 },
        Quartz       = { Chance = 15, MinQty = 1, MaxQty = 1 },
        Pepites      = { Chance = 5,  MinQty = 1, MaxQty = 1 },  -- Rare ici
    },

    -- Zone 2 — Collines Ambrées (détecteur + filons)
    Zone2_Detecteur = {
        Pepites      = { Chance = 60, MinQty = 1, MaxQty = 2 },
        Paillettes   = { Chance = 25, MinQty = 2, MaxQty = 5 },
        Amethyste    = { Chance = 10, MinQty = 1, MaxQty = 1 },
        Topaze       = { Chance = 5,  MinQty = 1, MaxQty = 1 },
    },
    Zone2_Filon = {
        MineraiOr    = { Chance = 50, MinQty = 2, MaxQty = 4 },
        Pepites      = { Chance = 30, MinQty = 1, MaxQty = 2 },
        Amethyste    = { Chance = 15, MinQty = 1, MaxQty = 1 },
        Topaze       = { Chance = 5,  MinQty = 1, MaxQty = 1 },
    },

    -- Zone 3 — Mine de Crow Creek (pioche sur OreNodes)
    Zone3 = {
        MineraiOr    = { Chance = 45, MinQty = 3, MaxQty = 6 },
        Pepites      = { Chance = 25, MinQty = 1, MaxQty = 3 },
        Amethyste    = { Chance = 15, MinQty = 1, MaxQty = 2 },
        Topaze       = { Chance = 10, MinQty = 1, MaxQty = 1 },
        Quartz       = { Chance = 5,  MinQty = 2, MaxQty = 4 },
    },
}

-- ============================================================
-- TOOL LEVEL BONUSES (multiplicateurs appliqués aux drops)
-- ============================================================
EconomyConfig.ToolBonuses = {
    -- Multiplicateur de quantité de drop
    QuantityMultiplier = {
        [1] = 1.0,    -- Niveau 1 : base
        [2] = 1.5,    -- Niveau 2 : +50%
        [3] = 2.0,    -- Niveau 3 : +100%
    },
    -- Réduction du temps de minage (secondes)
    SpeedMultiplier = {
        [1] = 1.0,    -- Niveau 1 : base
        [2] = 0.8,    -- Niveau 2 : 20% plus rapide
        [3] = 0.6,    -- Niveau 3 : 40% plus rapide
    },
}

-- ============================================================
-- RESPAWN TIMERS (secondes)
-- ============================================================
EconomyConfig.RespawnTimers = {
    Zone1_GoldSpot     = 30,    -- 30 sec
    Zone2_DetectSpot   = 45,    -- 45 sec
    Zone2_Filon        = 90,    -- 1min30
    Zone3_OreNode      = 60,    -- 1 min
    Zone3_GemNode      = 120,   -- 2 min
    Boss_Respawn       = 300,   -- 5 min
}

return EconomyConfig
```

### B.4 Config Outils — `ToolConfig.lua`

```lua
local ToolConfig = {}

ToolConfig.Tools = {
    Batee = {
        DisplayName = "Batée",
        Description = "Permet de tamiser l'or dans la rivière",
        Category = "Mining",
        RequiredZones = { "Zone1", "Zone2" },  -- Utilisable en Zone 1 et 2
        BaseActionTime = 5,    -- Secondes pour une action de minage
        Levels = {
            [1] = {
                Name = "Batée en Bois",
                BuyPrice = 0,           -- Gratuite (tutoriel)
                UpgradePrice = nil,      -- Pas de level 0→1
            },
            [2] = {
                Name = "Batée en Cuivre",
                BuyPrice = nil,          -- Upgrade depuis level 1
                UpgradePrice = 150,
            },
            [3] = {
                Name = "Batée en Fer",
                BuyPrice = nil,
                UpgradePrice = 500,
            },
        },
    },

    Tapis = {
        DisplayName = "Tapis de Prospection",
        Description = "Tapis pour filtrer les sédiments — meilleur rendement",
        Category = "Mining",
        RequiredZones = { "Zone1", "Zone2" },
        BaseActionTime = 8,
        Levels = {
            [1] = {
                Name = "Tapis Basique",
                BuyPrice = 100,
                UpgradePrice = nil,
            },
            [2] = {
                Name = "Tapis Amélioré",
                BuyPrice = nil,
                UpgradePrice = 300,
            },
            [3] = {
                Name = "Tapis Pro",
                BuyPrice = nil,
                UpgradePrice = 800,
            },
        },
    },

    Pioche = {
        DisplayName = "Pioche",
        Description = "Pour miner les filons et le minerai dans la mine",
        Category = "Mining",
        RequiredZones = { "Zone2", "Zone3" },
        BaseActionTime = 4,
        Levels = {
            [1] = {
                Name = "Pioche en Bois",
                BuyPrice = 200,
                UpgradePrice = nil,
            },
            [2] = {
                Name = "Pioche en Fer",
                BuyPrice = nil,
                UpgradePrice = 600,
            },
            [3] = {
                Name = "Pioche en Acier",
                BuyPrice = nil,
                UpgradePrice = 1500,
            },
        },
    },
}

return ToolConfig
```

### B.5 Config PNJ — `NPCConfig.lua`

```lua
local NPCConfig = {}

NPCConfig.NPCs = {
    Marchand = {
        DisplayName = "Marcel le Marchand",
        Location = "HubCentral",
        Type = "Buyer",
        Dialogue = {
            Greeting = "Bonjour voyageur ! Tu as de l'or à vendre ?",
            NoItems = "Reviens quand tu auras quelque chose pour moi !",
            Success = "Marché conclu ! Voici tes %d$ !",
        },
        BuysAll = true,           -- Achète tous les items
        PriceTable = "MarchandLocal",  -- Réf vers EconomyConfig.SellPrices
        ProximityMaxDistance = 10,
        ProximityActionText = "Vendre",
    },

    Negociant = {
        DisplayName = "Pierre le Négociant",
        Location = "HubCentral",
        Type = "Buyer",
        Dialogue = {
            Greeting = "Je ne prends que la qualité. Or pur, lingots, gemmes nobles.",
            NoItems = "Rien d'intéressant ? Reviens avec du raffiné.",
            Success = "Excellent ! %d$ pour ces merveilles !",
        },
        BuysAll = false,
        AcceptedItems = { "OrPur", "Lingots", "Amethyste", "Topaze" },
        PriceTable = "Negociant",
        ProximityMaxDistance = 10,
        ProximityActionText = "Négocier",
    },

    Vendeur = {
        DisplayName = "Jacques l'Outilleur",
        Location = "HubCentral",
        Type = "ShopKeeper",
        Dialogue = {
            Greeting = "Bienvenue ! J'ai les meilleurs outils de la région !",
            NotEnoughCash = "Tu n'as pas assez d'argent, reviens plus tard.",
            Purchase = "Bon choix ! Prends-en soin !",
            MaxLevel = "Cet outil est déjà au maximum !",
        },
        ProximityMaxDistance = 10,
        ProximityActionText = "Acheter",
    },

    Forgeron = {
        DisplayName = "Gustave le Forgeron",
        Location = "HubCentral",
        Type = "Crafter",
        Dialogue = {
            Greeting = "Apporte-moi du minerai, je te ferai de l'or pur !",
            NoMaterials = "Il te manque des matériaux.",
            Success = "Et voilà ! Du beau travail !",
        },
        ProximityMaxDistance = 8,
        ProximityActionText = "Forger",
    },

    Barman = {
        DisplayName = "Bill le Barman",
        Location = "HubCentral.Saloon",
        Type = "Saloon",
        Dialogue = {
            Greeting = "Bienvenue au Saloon ! Un remontant ?",
            MaxDrinks = "T'as assez bu pour aujourd'hui, cow-boy.",
            BuffActive = "Tu as déjà un boost actif !",
            Serve = "Santé ! Tu te sens %s pendant %d minutes !",
        },
        ProximityMaxDistance = 8,
        ProximityActionText = "Boire un verre",
    },

    Guide = {
        DisplayName = "Tom le Guide",
        Location = "Zone1_RiviereTransquille",
        Type = "Tutor",
        Dialogue = {
            Step1 = "Bienvenue, nouveau ! Je vais t'apprendre à chercher de l'or. Approche-toi de la rivière !",
            Step2 = "Vois ces reflets dans l'eau ? Utilise ta batée là-bas. Appuie sur E !",
            Step3 = "Bravo ! Tu as trouvé des paillettes ! Maintenant, tourne la batée pour filtrer...",
            Step4 = "Super ! Tu peux vendre ça au marchand en ville, ou le raffiner à la forge !",
            Step5 = "Continue à miner. Quand tu seras Orpailleur, les Collines t'ouvriront leurs secrets...",
            Complete = "Tu te débrouilles bien ! La rivière est à toi maintenant.",
        },
        ProximityMaxDistance = 12,
        ProximityActionText = "Parler",
    },
}

return NPCConfig
```

### B.6 Config Quêtes — `QuestConfig.lua`

```lua
local QuestConfig = {}

-- Les quêtes sont réinitialisées chaque jour à 00:00 UTC.
-- Le joueur reçoit 3 quêtes aléatoires parmi le pool ci-dessous.

QuestConfig.DailyQuestPool = {
    {
        Id = "MINE_PAILLETTES_10",
        Title = "L'Or de la Rivière",
        Description = "Récupère 10 paillettes d'or",
        Type = "Collect",
        Target = "Paillettes",
        Goal = 10,
        Reward = { Cash = 30, XP = 50 },
        MinLevel = 1,
    },
    {
        Id = "MINE_PEPITES_5",
        Title = "Chercheur de Pépites",
        Description = "Récupère 5 pépites d'or",
        Type = "Collect",
        Target = "Pepites",
        Goal = 5,
        Reward = { Cash = 50, XP = 75 },
        MinLevel = 2,
    },
    {
        Id = "SELL_ITEMS_3",
        Title = "Le Commerce d'Abord",
        Description = "Effectue 3 ventes chez un marchand",
        Type = "Sell",
        Target = "AnyTransaction",
        Goal = 3,
        Reward = { Cash = 40, XP = 50 },
        MinLevel = 1,
    },
    {
        Id = "CRAFT_OR_PUR_5",
        Title = "Apprenti Forgeron",
        Description = "Raffine 5 lots d'or pur",
        Type = "Craft",
        Target = "OrPur",
        Goal = 5,
        Reward = { Cash = 60, XP = 80 },
        MinLevel = 1,
    },
    {
        Id = "MINE_GEMS_3",
        Title = "Chasseur de Gemmes",
        Description = "Trouve 3 gemmes (peu importe le type)",
        Type = "Collect",
        Target = "AnyGem",
        Goal = 3,
        Reward = { Cash = 75, XP = 100 },
        MinLevel = 2,
    },
    {
        Id = "MINE_ORE_10",
        Title = "Mineur de Fond",
        Description = "Récupère 10 minerais d'or dans la mine",
        Type = "Collect",
        Target = "MineraiOr",
        Goal = 10,
        Reward = { Cash = 80, XP = 100 },
        MinLevel = 3,
    },
    {
        Id = "EARN_CASH_200",
        Title = "Millionnaire en Herbe",
        Description = "Gagne 200$ en ventes",
        Type = "Earn",
        Target = "Cash",
        Goal = 200,
        Reward = { Cash = 50, XP = 75 },
        MinLevel = 1,
    },
}

QuestConfig.DAILY_QUEST_COUNT = 3       -- Nombre de quêtes attribuées par jour
QuestConfig.QUEST_RESET_HOUR_UTC = 0    -- Reset à minuit UTC

return QuestConfig
```

### B.7 Config Craft — `CraftConfig.lua`

```lua
local CraftConfig = {}

CraftConfig.Recipes = {
    -- Raffinage : Paillettes → Or Pur
    {
        Id = "REFINE_OR_PUR",
        Name = "Raffiner de l'Or Pur",
        Description = "5 paillettes → 1 or pur",
        Inputs = {
            { Item = "Paillettes", Quantity = 5 },
        },
        Output = { Item = "OrPur", Quantity = 1 },
        CraftTime = 3,         -- Secondes
        RequiredLevel = 1,
        XPReward = 10,
    },

    -- Forge : Or Pur → Lingot
    {
        Id = "FORGE_LINGOT",
        Name = "Forger un Lingot",
        Description = "3 or pur + 2 minerai d'or → 1 lingot",
        Inputs = {
            { Item = "OrPur", Quantity = 3 },
            { Item = "MineraiOr", Quantity = 2 },
        },
        Output = { Item = "Lingots", Quantity = 1 },
        CraftTime = 5,
        RequiredLevel = 2,
        XPReward = 30,
    },

    -- Raffinage Pépites : Pépites → Or Pur (rendement meilleur)
    {
        Id = "REFINE_PEPITES",
        Name = "Raffiner des Pépites",
        Description = "2 pépites → 1 or pur",
        Inputs = {
            { Item = "Pepites", Quantity = 2 },
        },
        Output = { Item = "OrPur", Quantity = 1 },
        CraftTime = 2,
        RequiredLevel = 1,
        XPReward = 8,
    },
}

return CraftConfig
```

### B.8 Config Gemmes — `GemConfig.lua`

```lua
local GemConfig = {}

GemConfig.Gems = {
    Quartz = {
        DisplayName = "Quartz",
        Color = Color3.fromRGB(255, 255, 255),   -- Blanc
        Rarity = "Common",
        BaseValue = 8,          -- Réf EconomyConfig pour prix réel
        Glow = false,
    },
    Amethyste = {
        DisplayName = "Améthyste",
        Color = Color3.fromRGB(148, 103, 189),   -- Violet
        Rarity = "Uncommon",
        BaseValue = 25,
        Glow = true,
    },
    Topaze = {
        DisplayName = "Topaze",
        Color = Color3.fromRGB(255, 193, 37),     -- Doré
        Rarity = "Rare",
        BaseValue = 40,
        Glow = true,
    },
}

return GemConfig
```

### B.9 Config Zones — `ZoneConfig.lua`

```lua
local ZoneConfig = {}

ZoneConfig.Zones = {
    Zone1 = {
        Name = "Rivière Tranquille",
        DisplayName = "Zone 1 — Rivière Tranquille",
        Description = "Eaux calmes, or facile à trouver. Parfait pour apprendre.",
        RequiredLevel = 1,
        AllowedTools = { "Batee", "Tapis" },
        MaxActiveDeposits = 8,        -- Max de gisements actifs simultanés
        SpawnInterval = 15,            -- Secondes entre chaque spawn
        IsTutorialZone = true,
    },

    Zone2 = {
        Name = "Collines Ambrées",
        DisplayName = "Zone 2 — Collines Ambrées",
        Description = "Terrain vallonné, pépites et premiers filons. Détecteur recommandé.",
        RequiredLevel = 2,
        AllowedTools = { "Batee", "Tapis", "Pioche" },
        MaxActiveDeposits = 10,
        SpawnInterval = 20,
        IsTutorialZone = false,
    },

    Zone3 = {
        Name = "Mine de Crow Creek",
        DisplayName = "Zone 3 — Mine de Crow Creek",
        Description = "Mine souterraine profonde. Riches filons, mais danger !",
        RequiredLevel = 3,
        AllowedTools = { "Pioche" },
        MaxActiveDeposits = 12,
        SpawnInterval = 25,
        IsTutorialZone = false,
        HasBoss = true,
        BossId = "GardienMine",
    },
}

return ZoneConfig
```

### B.10 Config Saloon — Intégré dans `GameConfig.lua`

```lua
-- Section Saloon de GameConfig.lua
GameConfig.Saloon = {
    MaxDrinksPerDay = 3,
    DrinkCost = 15,                -- $ par verre
    
    Drinks = {
        {
            Id = "WHISKEY_VITESSE",
            Name = "Whiskey du Mineur",
            Description = "+20% vitesse de minage pendant 5 min",
            BuffType = "SpeedBoost",
            BuffValue = 0.20,      -- +20%
            Duration = 300,        -- 5 minutes en secondes
            Cost = 15,
        },
        {
            Id = "BIERE_CHANCE",
            Name = "Bière Porte-Bonheur",
            Description = "+15% chance de gemmes pendant 5 min",
            BuffType = "LuckBoost",
            BuffValue = 0.15,      -- +15%
            Duration = 300,
            Cost = 20,
        },
    },

    -- Dual loop jour/nuit (simplifié)
    DayNight = {
        CycleDuration = 720,       -- 12 minutes = 1 cycle complet
        DayRatio = 0.6,            -- 60% jour (7.2 min)
        NightRatio = 0.4,          -- 40% nuit (4.8 min)
        -- La nuit : Saloon ouvert, prix -20%, ambiance différente
        -- Le jour : Saloon ouvert aussi mais pas de bonus prix
        NightDrinkDiscount = 0.20, -- -20% sur les boissons la nuit
    },
}
```

### B.11 Config Boss — Intégré dans `GameConfig.lua`

```lua
GameConfig.Boss = {
    GardienMine = {
        DisplayName = "Le Gardien de la Mine",
        Health = 500,
        Damage = 15,               -- Dégâts par attaque
        AttackInterval = 2,        -- Secondes entre les attaques
        MoveSpeed = 12,
        AggroRange = 30,           -- Distance d'aggro
        LeashRange = 50,           -- Distance max avant reset
        SpawnCooldown = 300,       -- 5 min entre les apparitions

        -- Patterns d'attaque (simple)
        Attacks = {
            { Name = "Coup de Pioche", Damage = 15, Range = 5, Cooldown = 2 },
            { Name = "Éboulement", Damage = 25, Range = 15, Cooldown = 10 },
                -- Éboulement : rocks tombent dans l'arène
        },

        -- Récompenses (tout le monde dans l'arène)
        Rewards = {
            Cash = 200,
            XP = 200,
            Drops = {
                { Item = "Lingots", Quantity = 2, Chance = 100 },
                { Item = "Topaze", Quantity = 1, Chance = 50 },
                { Item = "Amethyste", Quantity = 2, Chance = 75 },
            },
        },

        -- Barres de vie affichées côté client
        HealthBarVisible = true,
    },
}
```

---

## C. Scripts Serveur (Pseudo-code Détaillé)

### C.1 GameManager.server.lua — Orchestrateur principal

```lua
--[[
    GameManager.server.lua
    RÔLE : Point d'entrée serveur. Initialise tous les systèmes,
           gère le cycle jour/nuit, coordonne les managers.
    DÉPENDANCES : DataManager, EconomyManager, GoldSpawner, QuestManager,
                  CraftManager, BossManager, SaloonManager, LeaderboardManager
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local DataManager = require(ServerScriptService.Core.DataManager)
local EconomyManager = require(ServerScriptService.Core.EconomyManager)
local GoldSpawner = require(ServerScriptService.Systems.GoldSpawner)
local MiningSystem = require(ServerScriptService.Systems.MiningSystem)
local CraftManager = require(ServerScriptService.Systems.CraftManager)
local QuestManager = require(ServerScriptService.Systems.QuestManager)
local BossManager = require(ServerScriptService.Systems.BossManager)
local SaloonManager = require(ServerScriptService.Systems.SaloonManager)
local LeaderboardManager = require(ServerScriptService.Systems.LeaderboardManager)
local GameConfig = require(ReplicatedStorage.Modules.Config.GameConfig)

-- État global serveur
local GameState = {
    TimeOfDay = "Day",         -- "Day" ou "Night"
    CycleTimer = 0,
    ServerStartTime = os.time(),
    ActivePlayers = {},         -- { [userId] = true }
}

-- ==========================================
-- INITIALISATION
-- ==========================================
function Initialize()
    print("[GameManager] Initialisation du serveur...")

    -- 1. Initialiser le DataManager (ProfileStore)
    DataManager:Init()

    -- 2. Initialiser les systèmes
    EconomyManager:Init()
    GoldSpawner:Init()          -- Commence le spawn de dépôts dans toutes les zones
    MiningSystem:Init()
    CraftManager:Init()
    QuestManager:Init()
    BossManager:Init()
    SaloonManager:Init()
    LeaderboardManager:Init()

    -- 3. Connecter les événements joueurs
    Players.PlayerAdded:Connect(OnPlayerAdded)
    Players.PlayerRemoving:Connect(OnPlayerRemoving)

    -- 4. Gérer les joueurs déjà présents (en cas de script reload)
    for _, player in Players:GetPlayers() do
        task.spawn(OnPlayerAdded, player)
    end

    -- 5. Lancer le cycle jour/nuit
    RunService.Heartbeat:Connect(UpdateDayNightCycle)

    print("[GameManager] Serveur initialisé ✓")
end

-- ==========================================
-- JOUEUR REJOINT
-- ==========================================
function OnPlayerAdded(player: Player)
    print("[GameManager] Joueur rejoint :", player.Name)

    -- 1. Charger / créer le profil
    local profile = DataManager:LoadProfile(player)
    if not profile then
        player:Kick("Erreur de chargement des données. Réessaie.")
        return
    end

    -- 2. Mettre à jour LastLogin
    profile.Data.LastLogin = os.time()
    if profile.Data.FirstJoin == 0 then
        profile.Data.FirstJoin = os.time()
    end

    -- 3. Initialiser la zone du joueur
    GameState.ActivePlayers[player.UserId] = true

    -- 4. Vérifier reset quotidien des quêtes
    QuestManager:CheckDailyReset(player)

    -- 5. Donner les outils possédés
    MiningSystem:EquipOwnedTools(player)

    -- 6. Envoyer les données initiales au client
    local initEvent = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("InitPlayerData")
    initEvent:FireClient(player, profile.Data)

    -- 7. Si tutoriel non complété, déclencher le tuto
    if not profile.Data.Tutorial.Completed then
        -- Le client gère l'affichage, le serveur suit l'état
        local tutEvent = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("StartTutorial")
        tutEvent:FireClient(player, profile.Data.Tutorial.Step)
    end

    -- 8. Mettre à jour le leaderboard
    LeaderboardManager:UpdatePlayer(player)
end

-- ==========================================
-- JOUEUR QUITTE
-- ==========================================
function OnPlayerRemoving(player: Player)
    print("[GameManager] Joueur quitte :", player.Name)

    -- 1. Sauvegarder le profil
    DataManager:SaveAndReleaseProfile(player)

    -- 2. Nettoyer
    GameState.ActivePlayers[player.UserId] = nil
end

-- ==========================================
-- CYCLE JOUR/NUIT
-- ==========================================
function UpdateDayNightCycle(deltaTime: number)
    local config = GameConfig.Saloon.DayNight
    GameState.CycleTimer = GameState.CycleTimer + deltaTime

    if GameState.CycleTimer >= config.CycleDuration then
        GameState.CycleTimer = 0
    end

    local dayDuration = config.CycleDuration * config.DayRatio
    local newTimeOfDay = (GameState.CycleTimer <= dayDuration) and "Day" or "Night"

    if newTimeOfDay ~= GameState.TimeOfDay then
        GameState.TimeOfDay = newTimeOfDay
        -- Notifier tous les clients
        local event = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("TimeOfDayChanged")
        event:FireAllClients(newTimeOfDay)

        -- Notifier le SaloonManager
        SaloonManager:OnTimeOfDayChanged(newTimeOfDay)

        print("[GameManager] Changement :", newTimeOfDay)
    end
end

-- ==========================================
-- GAME CLOSE — Sauvegarde d'urgence
-- ==========================================
game:BindToClose(function()
    print("[GameManager] Serveur en fermeture — sauvegarde d'urgence")
    DataManager:SaveAllProfiles()
    task.wait(3)  -- Laisser le temps à ProfileStore
end)

-- Lancer !
Initialize()
```

### C.2 DataManager.server.lua — Sauvegarde ProfileStore

```lua
--[[
    DataManager.server.lua
    RÔLE : Gère le chargement, la sauvegarde et la libération des profils joueurs.
    UTILISE : ProfileStore (module externe)
    DONNÉES : Voir PlayerData dans Types.lua
]]

local DataManager = {}

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileStore = require(ServerScriptService.Lib.ProfileStore)

-- CONSTANTES
local DATASTORE_NAME = "GoldRush_PlayerData_V1"
local SAVE_INTERVAL = 60   -- Auto-save toutes les 60 secondes

-- État
local ProfileStoreInstance = nil
local Profiles = {}        -- { [player] = Profile }

-- ==========================================
-- DEFAULT DATA (nouveau joueur)
-- ==========================================
local DEFAULT_DATA = {
    Version = 1,
    FirstJoin = 0,
    LastLogin = 0,
    TotalPlayTime = 0,
    Cash = 50,
    TotalCashEarned = 0,
    XP = 0,
    Level = 1,
    Inventory = {
        Paillettes = 0, OrPur = 0, Lingots = 0,
        Pepites = 0, MineraiOr = 0,
        Quartz = 0, Amethyste = 0, Topaze = 0,
    },
    Tools = {
        Batee = { Owned = true, Level = 1 },
        Tapis = { Owned = false, Level = 0 },
        Pioche = { Owned = false, Level = 0 },
    },
    Quests = { DailyReset = 0, Active = {}, Completed = {} },
    Zones = { Zone1_Unlocked = true, Zone2_Unlocked = false, Zone3_Unlocked = false },
    Saloon = { LastDrinkTime = 0, DrinksToday = 0, BuffActive = nil, BuffExpiry = 0 },
    Boss = { GardienDefeated = 0, LastBossAttempt = 0 },
    Tutorial = { Completed = false, Step = 1 },
}

-- ==========================================
-- INIT
-- ==========================================
function DataManager:Init()
    ProfileStoreInstance = ProfileStore.New(DATASTORE_NAME, DEFAULT_DATA)
    print("[DataManager] ProfileStore initialisé")
end

-- ==========================================
-- CHARGER UN PROFIL
-- ==========================================
function DataManager:LoadProfile(player: Player)
    local profileKey = "Player_" .. player.UserId

    local profile = ProfileStoreInstance:LoadProfileAsync(profileKey, "ForceLoad")

    if not profile then
        warn("[DataManager] Échec chargement profil pour", player.Name)
        return nil
    end

    -- Si le joueur a quitté pendant le chargement
    if not player:IsDescendantOf(Players) then
        profile:Release()
        return nil
    end

    -- Listener de release
    profile:AddUserId(player.UserId)
    profile:Reconcile()  -- Ajoute les champs manquants (migration)
    profile:ListenToRelease(function()
        Profiles[player] = nil
        player:Kick("Profil relâché — reconnecte-toi.")
    end)

    Profiles[player] = profile

    -- Auto-save périodique
    task.spawn(function()
        while Profiles[player] do
            task.wait(SAVE_INTERVAL)
            -- ProfileStore gère le save auto, mais on peut forcer
        end
    end)

    print("[DataManager] Profil chargé pour", player.Name)
    return profile
end

-- ==========================================
-- OBTENIR LE PROFIL D'UN JOUEUR
-- ==========================================
function DataManager:GetProfile(player: Player)
    return Profiles[player]
end

function DataManager:GetData(player: Player)
    local profile = Profiles[player]
    if profile then
        return profile.Data
    end
    return nil
end

-- ==========================================
-- SAUVEGARDER ET RELÂCHER
-- ==========================================
function DataManager:SaveAndReleaseProfile(player: Player)
    local profile = Profiles[player]
    if profile then
        profile:Release()
        Profiles[player] = nil
        print("[DataManager] Profil sauvé et relâché pour", player.Name)
    end
end

-- ==========================================
-- SAUVEGARDE D'URGENCE (tous les joueurs)
-- ==========================================
function DataManager:SaveAllProfiles()
    for player, profile in pairs(Profiles) do
        if profile then
            profile:Release()
        end
    end
    Profiles = {}
    print("[DataManager] Tous les profils sauvés et relâchés")
end

-- ==========================================
-- UTILITAIRES DE MODIFICATION
-- ==========================================
function DataManager:UpdateData(player: Player, key: string, value: any)
    local data = self:GetData(player)
    if data then
        data[key] = value
    end
end

function DataManager:AddToInventory(player: Player, itemName: string, quantity: number)
    local data = self:GetData(player)
    if data and data.Inventory[itemName] ~= nil then
        data.Inventory[itemName] = data.Inventory[itemName] + quantity
        return true
    end
    return false
end

function DataManager:RemoveFromInventory(player: Player, itemName: string, quantity: number): boolean
    local data = self:GetData(player)
    if data and data.Inventory[itemName] and data.Inventory[itemName] >= quantity then
        data.Inventory[itemName] = data.Inventory[itemName] - quantity
        return true
    end
    return false
end

function DataManager:AddCash(player: Player, amount: number)
    local data = self:GetData(player)
    if data then
        data.Cash = data.Cash + amount
        data.TotalCashEarned = data.TotalCashEarned + amount
    end
end

function DataManager:RemoveCash(player: Player, amount: number): boolean
    local data = self:GetData(player)
    if data and data.Cash >= amount then
        data.Cash = data.Cash - amount
        return true
    end
    return false
end

function DataManager:AddXP(player: Player, amount: number)
    local data = self:GetData(player)
    if data then
        data.XP = data.XP + amount
        -- Vérifier level up
        local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
        for level, threshold in pairs(EconomyConfig.LevelThresholds) do
            if data.XP >= threshold.MinXP and level > data.Level then
                data.Level = level
                -- Débloquer zones
                if level == 2 then data.Zones.Zone2_Unlocked = true end
                if level == 3 then data.Zones.Zone3_Unlocked = true end
                -- Notifier le client
                local event = ReplicatedStorage.Events.RemoteEvents:FindFirstChild("LevelUp")
                event:FireClient(player, level, threshold.Name)
                print("[DataManager] Level up!", player.Name, "→", threshold.Name)
            end
        end
    end
end

return DataManager
```

### C.3 EconomyManager.server.lua

```lua
--[[
    EconomyManager.server.lua
    RÔLE : Gère toutes les transactions d'achat/vente.
    VALIDATION : Toutes les vérifications sont serveur-side.
]]

local EconomyManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)
local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
local ToolConfig = require(ReplicatedStorage.Modules.Config.ToolConfig)

-- ==========================================
-- INIT
-- ==========================================
function EconomyManager:Init()
    -- Connecter les RemoteEvents
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestSell.OnServerEvent:Connect(function(player, npcType, itemName, quantity)
        self:HandleSell(player, npcType, itemName, quantity)
    end)

    events.RequestBuyTool.OnServerEvent:Connect(function(player, toolName)
        self:HandleBuyTool(player, toolName)
    end)

    events.RequestUpgradeTool.OnServerEvent:Connect(function(player, toolName)
        self:HandleUpgradeTool(player, toolName)
    end)

    print("[EconomyManager] Initialisé ✓")
end

-- ==========================================
-- VENDRE DES ITEMS
-- ==========================================
function EconomyManager:HandleSell(player: Player, npcType: string, itemName: string, quantity: number)
    -- VALIDATION
    if type(quantity) ~= "number" or quantity <= 0 or quantity ~= math.floor(quantity) then
        warn("[EconomyManager] Quantité invalide de", player.Name)
        return
    end
    if quantity > 9999 then return end  -- Anti-exploit cap

    local priceTable = EconomyConfig.SellPrices[npcType]
    if not priceTable then return end

    local pricePerUnit = priceTable[itemName]
    if not pricePerUnit then
        -- Ce PNJ n'achète pas cet item
        ReplicatedStorage.Events.RemoteEvents.SellResult:FireClient(
            player, false, "Ce marchand n'achète pas cet item."
        )
        return
    end

    -- Vérifier que le joueur possède assez
    local data = DataManager:GetData(player)
    if not data or not data.Inventory[itemName] or data.Inventory[itemName] < quantity then
        ReplicatedStorage.Events.RemoteEvents.SellResult:FireClient(
            player, false, "Quantité insuffisante."
        )
        return
    end

    -- Effectuer la vente
    local totalCash = pricePerUnit * quantity
    DataManager:RemoveFromInventory(player, itemName, quantity)
    DataManager:AddCash(player, totalCash)
    DataManager:AddXP(player, EconomyConfig.XPRewards.SellTransaction)

    -- Notifier le QuestManager
    local QuestManager = require(ServerScriptService.Systems.QuestManager)
    QuestManager:OnSellTransaction(player, itemName, quantity, totalCash)

    -- Résultat au client
    ReplicatedStorage.Events.RemoteEvents.SellResult:FireClient(
        player, true, string.format("Vendu %dx %s pour %d$ !", quantity, itemName, totalCash)
    )

    -- Mettre à jour le leaderboard
    local LeaderboardManager = require(ServerScriptService.Systems.LeaderboardManager)
    LeaderboardManager:UpdatePlayer(player)

    print("[EconomyManager]", player.Name, "a vendu", quantity, itemName, "pour", totalCash, "$")
end

-- ==========================================
-- ACHETER UN OUTIL
-- ==========================================
function EconomyManager:HandleBuyTool(player: Player, toolName: string)
    local toolData = ToolConfig.Tools[toolName]
    if not toolData then return end

    local data = DataManager:GetData(player)
    if not data then return end

    -- Vérifier si déjà possédé
    if data.Tools[toolName] and data.Tools[toolName].Owned then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Tu possèdes déjà cet outil !"
        )
        return
    end

    -- Prix d'achat (level 1)
    local price = toolData.Levels[1].BuyPrice
    if not price or price == 0 then return end  -- Outil gratuit ou invalide

    -- Vérifier cash
    if not DataManager:RemoveCash(player, price) then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Pas assez d'argent !"
        )
        return
    end

    -- Donner l'outil
    data.Tools[toolName] = { Owned = true, Level = 1 }

    -- Équiper physiquement
    local MiningSystem = require(ServerScriptService.Systems.MiningSystem)
    MiningSystem:GiveTool(player, toolName)

    ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
        player, true, string.format("%s acheté pour %d$ !", toolData.DisplayName, price)
    )
end

-- ==========================================
-- UPGRADE UN OUTIL
-- ==========================================
function EconomyManager:HandleUpgradeTool(player: Player, toolName: string)
    local toolData = ToolConfig.Tools[toolName]
    if not toolData then return end

    local data = DataManager:GetData(player)
    if not data then return end

    local currentTool = data.Tools[toolName]
    if not currentTool or not currentTool.Owned then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Tu ne possèdes pas cet outil !"
        )
        return
    end

    local nextLevel = currentTool.Level + 1
    local nextLevelData = toolData.Levels[nextLevel]
    if not nextLevelData then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Outil déjà au niveau maximum !"
        )
        return
    end

    local price = nextLevelData.UpgradePrice
    if not DataManager:RemoveCash(player, price) then
        ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
            player, false, "Pas assez d'argent !"
        )
        return
    end

    -- Upgrade
    data.Tools[toolName].Level = nextLevel

    ReplicatedStorage.Events.RemoteEvents.ShopResult:FireClient(
        player, true, string.format(
            "%s amélioré au niveau %d pour %d$ !",
            toolData.DisplayName, nextLevel, price
        )
    )
end

return EconomyManager
```

### C.4 GoldSpawner.server.lua

```lua
--[[
    GoldSpawner.server.lua
    RÔLE : Gère le spawn/respawn de gisements d'or et de gemmes dans les 3 zones.
    MÉCANIQUE : Chaque zone a des SpawnPoints. Le spawner crée des instances
                à partir de templates (ServerStorage) sur ces points.
]]

local GoldSpawner = {}

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
local ZoneConfig = require(ReplicatedStorage.Modules.Config.ZoneConfig)

-- État
local ActiveDeposits = {}  -- { [zone] = { [spawnPointName] = depositInstance } }

-- ==========================================
-- INIT
-- ==========================================
function GoldSpawner:Init()
    -- Initialiser chaque zone
    for zoneId, zoneData in pairs(ZoneConfig.Zones) do
        ActiveDeposits[zoneId] = {}
        self:StartZoneSpawner(zoneId, zoneData)
    end

    print("[GoldSpawner] Initialisé ✓")
end

-- ==========================================
-- SPAWNER PAR ZONE
-- ==========================================
function GoldSpawner:StartZoneSpawner(zoneId: string, zoneData)
    task.spawn(function()
        while true do
            local zoneFolder = self:GetZoneFolder(zoneId)
            if zoneFolder then
                local spawnPoints = self:GetSpawnPoints(zoneFolder)
                local activeCount = self:CountActiveDeposits(zoneId)

                -- Spawn si en dessous du max
                if activeCount < zoneData.MaxActiveDeposits then
                    for _, spawnPoint in ipairs(spawnPoints) do
                        if not ActiveDeposits[zoneId][spawnPoint.Name] then
                            self:SpawnDeposit(zoneId, spawnPoint)
                            break  -- Un seul spawn par tick
                        end
                    end
                end
            end

            task.wait(zoneData.SpawnInterval)
        end
    end)
end

-- ==========================================
-- SPAWN UN GISEMENT
-- ==========================================
function GoldSpawner:SpawnDeposit(zoneId: string, spawnPoint: BasePart)
    -- Déterminer le type de gisement selon la zone
    local template = self:PickTemplate(zoneId)
    if not template then return end

    local deposit = template:Clone()
    deposit.Name = "Deposit_" .. spawnPoint.Name
    deposit:SetAttribute("ZoneId", zoneId)
    deposit:SetAttribute("SpawnPointName", spawnPoint.Name)
    deposit:SetAttribute("IsActive", true)
    deposit:SetAttribute("SpawnTime", os.time())
    deposit.Parent = Workspace.ActiveGoldDeposits

    -- Positionner
    if deposit:IsA("Model") then
        deposit:PivotTo(spawnPoint.CFrame)
    else
        deposit.CFrame = spawnPoint.CFrame
    end

    -- Ajouter ProximityPrompt
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Miner"
    prompt.ObjectText = deposit:GetAttribute("DisplayName") or "Gisement"
    prompt.MaxActivationDistance = 8
    prompt.HoldDuration = 0.5
    prompt.Parent = deposit:IsA("Model") and deposit.PrimaryPart or deposit

    ActiveDeposits[zoneId][spawnPoint.Name] = deposit
end

-- ==========================================
-- CHOISIR UN TEMPLATE
-- ==========================================
function GoldSpawner:PickTemplate(zoneId: string): Instance?
    local templates = ServerStorage.Templates
    if zoneId == "Zone1" then
        return templates.GoldDeposit_Paillette
    elseif zoneId == "Zone2" then
        -- 70% pépite, 30% filon
        return math.random() < 0.7
            and templates.GoldDeposit_Pepite
            or templates.GoldDeposit_Filon
    elseif zoneId == "Zone3" then
        -- 60% minerai (filon), 30% pépite, 10% gemme aléatoire
        local roll = math.random()
        if roll < 0.6 then
            return templates.GoldDeposit_Filon
        elseif roll < 0.9 then
            return templates.GoldDeposit_Pepite
        else
            -- Gemme aléatoire
            local gems = {"Gem_Quartz", "Gem_Amethyste", "Gem_Topaze"}
            return templates[gems[math.random(#gems)]]
        end
    end
    return nil
end

-- ==========================================
-- DÉTRUIRE UN GISEMENT (après minage)
-- ==========================================
function GoldSpawner:DestroyDeposit(deposit: Instance)
    local zoneId = deposit:GetAttribute("ZoneId")
    local spawnPointName = deposit:GetAttribute("SpawnPointName")

    if zoneId and spawnPointName then
        ActiveDeposits[zoneId][spawnPointName] = nil
    end

    deposit:Destroy()
end

-- ==========================================
-- HELPERS
-- ==========================================
function GoldSpawner:GetZoneFolder(zoneId: string): Folder?
    local map = {
        Zone1 = Workspace.Map.Zone1_RiviereTransquille,
        Zone2 = Workspace.Map.Zone2_CollinesAmbrees,
        Zone3 = Workspace.Map.Zone3_MineCrowCreek,
    }
    return map[zoneId]
end

function GoldSpawner:GetSpawnPoints(zoneFolder: Folder): { BasePart }
    local points = {}
    -- Cherche GoldSpawnPoints, FilonSpots, OreNodes, GemSpawnPoints
    for _, subfolder in zoneFolder:GetChildren() do
        if subfolder.Name:match("Spawn") or subfolder.Name:match("Filon")
            or subfolder.Name:match("Ore") or subfolder.Name:match("Gem") then
            for _, point in subfolder:GetChildren() do
                if point:IsA("BasePart") then
                    table.insert(points, point)
                end
            end
        end
    end
    return points
end

function GoldSpawner:CountActiveDeposits(zoneId: string): number
    local count = 0
    for _ in pairs(ActiveDeposits[zoneId] or {}) do
        count = count + 1
    end
    return count
end

return GoldSpawner
```

### C.5 MiningSystem.server.lua

```lua
--[[
    MiningSystem.server.lua
    RÔLE : Gère la logique de minage côté serveur.
           Reçoit les requêtes du client, valide, calcule les drops, distribue.
]]

local MiningSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)
local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)
local ToolConfig = require(ReplicatedStorage.Modules.Config.ToolConfig)

-- Cooldowns anti-spam
local MiningCooldowns = {}  -- { [userId] = lastMineTime }
local MIN_MINE_INTERVAL = 1  -- Minimum 1 seconde entre deux requêtes

-- ==========================================
-- INIT
-- ==========================================
function MiningSystem:Init()
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestMine.OnServerEvent:Connect(function(player, depositId)
        self:HandleMineRequest(player, depositId)
    end)

    events.BateeMinigameResult.OnServerEvent:Connect(function(player, depositId, score)
        self:HandleBateeResult(player, depositId, score)
    end)

    print("[MiningSystem] Initialisé ✓")
end

-- ==========================================
-- TRAITER UNE REQUÊTE DE MINAGE
-- ==========================================
function MiningSystem:HandleMineRequest(player: Player, depositId: string)
    -- Anti-spam
    local now = os.clock()
    if MiningCooldowns[player.UserId] and (now - MiningCooldowns[player.UserId]) < MIN_MINE_INTERVAL then
        return  -- Ignorer silencieusement
    end
    MiningCooldowns[player.UserId] = now

    -- Trouver le gisement
    local deposit = game.Workspace.ActiveGoldDeposits:FindFirstChild(depositId)
    if not deposit or not deposit:GetAttribute("IsActive") then
        return
    end

    -- Vérifier la distance (anti-exploit)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local distance = (character.HumanoidRootPart.Position - self:GetDepositPosition(deposit)).Magnitude
    if distance > 15 then  -- Max 15 studs
        warn("[MiningSystem] Distance exploit détecté :", player.Name, distance)
        return
    end

    -- Vérifier la zone et le niveau requis
    local zoneId = deposit:GetAttribute("ZoneId")
    local data = DataManager:GetData(player)
    if not data then return end

    local ZoneConfig = require(ReplicatedStorage.Modules.Config.ZoneConfig)
    local zoneData = ZoneConfig.Zones[zoneId]
    if data.Level < zoneData.RequiredLevel then
        ReplicatedStorage.Events.RemoteEvents.MineResult:FireClient(
            player, false, "Niveau insuffisant pour cette zone !"
        )
        return
    end

    -- Vérifier que le joueur a un outil adapté
    local hasTool = self:HasValidTool(player, zoneId)
    if not hasTool then
        ReplicatedStorage.Events.RemoteEvents.MineResult:FireClient(
            player, false, "Tu n'as pas l'outil requis !"
        )
        return
    end

    -- Zone 1 : déclencher le mini-jeu de batée côté client
    if zoneId == "Zone1" then
        deposit:SetAttribute("IsActive", false)  -- Réserver le gisement
        ReplicatedStorage.Events.RemoteEvents.StartBateeMinigame:FireClient(player, depositId)
        return  -- Attendre BateeMinigameResult
    end

    -- Zones 2 et 3 : minage direct
    self:ProcessMining(player, deposit, zoneId, 1.0)  -- score 1.0 = rendement normal
end

-- ==========================================
-- RÉSULTAT DU MINI-JEU DE BATÉE
-- ==========================================
function MiningSystem:HandleBateeResult(player: Player, depositId: string, score: number)
    -- Valider le score (0.0 à 1.0)
    if type(score) ~= "number" then return end
    score = math.clamp(score, 0, 1)

    local deposit = game.Workspace.ActiveGoldDeposits:FindFirstChild(depositId)
    if not deposit then return end

    local zoneId = deposit:GetAttribute("ZoneId")
    self:ProcessMining(player, deposit, zoneId, score)
end

-- ==========================================
-- TRAITEMENT DU MINAGE (calcul des drops)
-- ==========================================
function MiningSystem:ProcessMining(player: Player, deposit: Instance, zoneId: string, score: number)
    local data = DataManager:GetData(player)
    if not data then return end

    -- Déterminer la table de drops
    local dropTable = self:GetDropTable(zoneId, deposit)
    if not dropTable then return end

    -- Déterminer le bonus d'outil
    local toolLevel = self:GetBestToolLevel(player, zoneId)
    local qtyMultiplier = EconomyConfig.ToolBonuses.QuantityMultiplier[toolLevel] or 1.0

    -- Vérifier buff Saloon
    if data.Saloon.BuffActive == "LuckBoost" and os.time() < data.Saloon.BuffExpiry then
        -- Augmenter les chances de drop
        qtyMultiplier = qtyMultiplier * (1 + data.Saloon.BuffValue or 0.15)
    end

    -- Appliquer le score du mini-jeu (0-1) au multiplicateur
    qtyMultiplier = qtyMultiplier * math.max(0.3, score)  -- Minimum 30% même si score = 0

    -- Calculer les drops
    local drops = {}
    for itemName, dropData in pairs(dropTable) do
        local roll = math.random(1, 100)
        if roll <= dropData.Chance then
            local baseQty = math.random(dropData.MinQty, dropData.MaxQty)
            local finalQty = math.max(1, math.floor(baseQty * qtyMultiplier))
            drops[itemName] = finalQty

            -- Ajouter à l'inventaire
            DataManager:AddToInventory(player, itemName, finalQty)

            -- XP
            local xpKey = "Mine" .. itemName
            local xp = EconomyConfig.XPRewards[xpKey] or 5
            DataManager:AddXP(player, xp)
        end
    end

    -- Si aucun drop (malchance), donner au moins 1 paillette
    if next(drops) == nil then
        drops["Paillettes"] = 1
        DataManager:AddToInventory(player, "Paillettes", 1)
        DataManager:AddXP(player, EconomyConfig.XPRewards.MinePaillette)
    end

    -- Notifier le QuestManager
    local QuestManager = require(ServerScriptService.Systems.QuestManager)
    for itemName, qty in pairs(drops) do
        QuestManager:OnItemCollected(player, itemName, qty)
    end

    -- Envoyer le résultat au client
    ReplicatedStorage.Events.RemoteEvents.MineResult:FireClient(player, true, drops)

    -- Détruire le gisement et programmer le respawn
    local GoldSpawner = require(ServerScriptService.Systems.GoldSpawner)
    GoldSpawner:DestroyDeposit(deposit)
end

-- ==========================================
-- HELPERS
-- ==========================================
function MiningSystem:GetDropTable(zoneId: string, deposit: Instance)
    if zoneId == "Zone1" then
        return EconomyConfig.DropRates.Zone1
    elseif zoneId == "Zone2" then
        if deposit.Name:match("Filon") then
            return EconomyConfig.DropRates.Zone2_Filon
        end
        return EconomyConfig.DropRates.Zone2_Detecteur
    elseif zoneId == "Zone3" then
        return EconomyConfig.DropRates.Zone3
    end
    return nil
end

function MiningSystem:HasValidTool(player: Player, zoneId: string): boolean
    local data = DataManager:GetData(player)
    if not data then return false end

    local ZoneConfig = require(ReplicatedStorage.Modules.Config.ZoneConfig)
    local zoneData = ZoneConfig.Zones[zoneId]

    for _, toolName in ipairs(zoneData.AllowedTools) do
        if data.Tools[toolName] and data.Tools[toolName].Owned then
            return true
        end
    end
    return false
end

function MiningSystem:GetBestToolLevel(player: Player, zoneId: string): number
    local data = DataManager:GetData(player)
    if not data then return 1 end

    local ZoneConfig = require(ReplicatedStorage.Modules.Config.ZoneConfig)
    local zoneData = ZoneConfig.Zones[zoneId]
    local bestLevel = 1

    for _, toolName in ipairs(zoneData.AllowedTools) do
        if data.Tools[toolName] and data.Tools[toolName].Owned then
            bestLevel = math.max(bestLevel, data.Tools[toolName].Level)
        end
    end
    return bestLevel
end

function MiningSystem:GetDepositPosition(deposit: Instance): Vector3
    if deposit:IsA("Model") and deposit.PrimaryPart then
        return deposit.PrimaryPart.Position
    elseif deposit:IsA("BasePart") then
        return deposit.Position
    end
    return Vector3.zero
end

function MiningSystem:EquipOwnedTools(player: Player)
    local data = DataManager:GetData(player)
    if not data then return end

    for toolName, toolData in pairs(data.Tools) do
        if toolData.Owned then
            self:GiveTool(player, toolName)
        end
    end
end

function MiningSystem:GiveTool(player: Player, toolName: string)
    -- Créer un Tool dans le Backpack du joueur
    local ServerStorage = game:GetService("ServerStorage")
    local template = ServerStorage.ItemModels["Tool_" .. toolName]
    if template then
        local tool = template:Clone()
        tool.Name = toolName
        tool.Parent = player.Backpack
    end
end

return MiningSystem
```

### C.6 CraftManager.server.lua

```lua
--[[
    CraftManager.server.lua
    RÔLE : Gère le craft/raffinage. Le joueur interagit avec le Forgeron.
]]

local CraftManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)
local CraftConfig = require(ReplicatedStorage.Modules.Config.CraftConfig)
local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)

-- ==========================================
-- INIT
-- ==========================================
function CraftManager:Init()
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestCraft.OnServerEvent:Connect(function(player, recipeId, quantity)
        self:HandleCraft(player, recipeId, quantity)
    end)

    -- RemoteFunction pour lister les recettes disponibles
    local funcs = ReplicatedStorage.Events.RemoteFunctions
    funcs.GetCraftRecipes.OnServerInvoke = function(player)
        return self:GetAvailableRecipes(player)
    end

    print("[CraftManager] Initialisé ✓")
end

-- ==========================================
-- TRAITER UNE REQUÊTE DE CRAFT
-- ==========================================
function CraftManager:HandleCraft(player: Player, recipeId: string, quantity: number)
    -- Validation
    if type(quantity) ~= "number" or quantity <= 0 or quantity ~= math.floor(quantity) then
        return
    end
    quantity = math.min(quantity, 100)  -- Cap anti-exploit

    -- Trouver la recette
    local recipe = nil
    for _, r in ipairs(CraftConfig.Recipes) do
        if r.Id == recipeId then
            recipe = r
            break
        end
    end
    if not recipe then return end

    local data = DataManager:GetData(player)
    if not data then return end

    -- Vérifier le niveau requis
    if data.Level < recipe.RequiredLevel then
        ReplicatedStorage.Events.RemoteEvents.CraftResult:FireClient(
            player, false, "Niveau insuffisant !"
        )
        return
    end

    -- Vérifier les matériaux (pour la quantité demandée)
    for _, input in ipairs(recipe.Inputs) do
        local needed = input.Quantity * quantity
        if not data.Inventory[input.Item] or data.Inventory[input.Item] < needed then
            ReplicatedStorage.Events.RemoteEvents.CraftResult:FireClient(
                player, false, string.format("Il te manque du %s !", input.Item)
            )
            return
        end
    end

    -- Consommer les matériaux
    for _, input in ipairs(recipe.Inputs) do
        DataManager:RemoveFromInventory(player, input.Item, input.Quantity * quantity)
    end

    -- Produire l'output
    local outputQty = recipe.Output.Quantity * quantity
    DataManager:AddToInventory(player, recipe.Output.Item, outputQty)

    -- XP
    DataManager:AddXP(player, recipe.XPReward * quantity)

    -- Notifier QuestManager
    local QuestManager = require(ServerScriptService.Systems.QuestManager)
    QuestManager:OnItemCrafted(player, recipe.Output.Item, outputQty)

    -- Résultat au client
    ReplicatedStorage.Events.RemoteEvents.CraftResult:FireClient(
        player, true, string.format(
            "Crafté %dx %s !",
            outputQty, recipe.Output.Item
        )
    )

    print("[CraftManager]", player.Name, "a crafté", outputQty, recipe.Output.Item)
end

-- ==========================================
-- RECETTES DISPONIBLES POUR UN JOUEUR
-- ==========================================
function CraftManager:GetAvailableRecipes(player: Player)
    local data = DataManager:GetData(player)
    if not data then return {} end

    local available = {}
    for _, recipe in ipairs(CraftConfig.Recipes) do
        local canCraft = data.Level >= recipe.RequiredLevel
        local hasInputs = true
        for _, input in ipairs(recipe.Inputs) do
            if not data.Inventory[input.Item] or data.Inventory[input.Item] < input.Quantity then
                hasInputs = false
                break
            end
        end

        table.insert(available, {
            Id = recipe.Id,
            Name = recipe.Name,
            Description = recipe.Description,
            Inputs = recipe.Inputs,
            Output = recipe.Output,
            CanCraft = canCraft and hasInputs,
            RequiredLevel = recipe.RequiredLevel,
            MaxCraftable = canCraft and self:CalcMaxCraftable(data, recipe) or 0,
        })
    end
    return available
end

function CraftManager:CalcMaxCraftable(data, recipe): number
    local maxQty = math.huge
    for _, input in ipairs(recipe.Inputs) do
        local have = data.Inventory[input.Item] or 0
        maxQty = math.min(maxQty, math.floor(have / input.Quantity))
    end
    return maxQty == math.huge and 0 or maxQty
end

return CraftManager
```

### C.7 QuestManager.server.lua

```lua
--[[
    QuestManager.server.lua
    RÔLE : Gère les quêtes quotidiennes (3 quêtes/jour, reset à 00:00 UTC).
]]

local QuestManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)
local QuestConfig = require(ReplicatedStorage.Modules.Config.QuestConfig)

-- ==========================================
-- INIT
-- ==========================================
function QuestManager:Init()
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestClaimQuest.OnServerEvent:Connect(function(player, questId)
        self:HandleClaimQuest(player, questId)
    end)

    local funcs = ReplicatedStorage.Events.RemoteFunctions
    funcs.GetActiveQuests.OnServerInvoke = function(player)
        return self:GetActiveQuests(player)
    end

    print("[QuestManager] Initialisé ✓")
end

-- ==========================================
-- VÉRIFIER LE RESET QUOTIDIEN
-- ==========================================
function QuestManager:CheckDailyReset(player: Player)
    local data = DataManager:GetData(player)
    if not data then return end

    -- Calculer le timestamp du dernier 00:00 UTC
    local now = os.time()
    local todayReset = now - (now % 86400)  -- Minuit UTC aujourd'hui

    if data.Quests.DailyReset < todayReset then
        -- Reset nécessaire
        data.Quests.Active = {}
        data.Quests.DailyReset = todayReset

        -- Attribuer de nouvelles quêtes
        self:AssignDailyQuests(player)

        print("[QuestManager] Quêtes réinitialisées pour", player.Name)
    end
end

-- ==========================================
-- ATTRIBUER DES QUÊTES QUOTIDIENNES
-- ==========================================
function QuestManager:AssignDailyQuests(player: Player)
    local data = DataManager:GetData(player)
    if not data then return end

    -- Filtrer par niveau
    local eligibleQuests = {}
    for _, quest in ipairs(QuestConfig.DailyQuestPool) do
        if data.Level >= quest.MinLevel then
            table.insert(eligibleQuests, quest)
        end
    end

    -- Sélectionner N quêtes aléatoires (sans doublon)
    local count = math.min(QuestConfig.DAILY_QUEST_COUNT, #eligibleQuests)
    local selected = {}
    local used = {}

    for i = 1, count do
        local idx
        repeat
            idx = math.random(1, #eligibleQuests)
        until not used[idx]
        used[idx] = true

        local quest = eligibleQuests[idx]
        data.Quests.Active[quest.Id] = {
            QuestId = quest.Id,
            Progress = 0,
            Goal = quest.Goal,
            Completed = false,
            ClaimedReward = false,
        }
        table.insert(selected, quest.Id)
    end

    -- Notifier le client
    ReplicatedStorage.Events.RemoteEvents.QuestsUpdated:FireClient(player, data.Quests.Active)
end

-- ==========================================
-- CALLBACKS — À appeler depuis d'autres managers
-- ==========================================
function QuestManager:OnItemCollected(player: Player, itemName: string, quantity: number)
    self:UpdateProgress(player, "Collect", itemName, quantity)
end

function QuestManager:OnSellTransaction(player: Player, itemName: string, quantity: number, cashAmount: number)
    self:UpdateProgress(player, "Sell", "AnyTransaction", 1)
    self:UpdateProgress(player, "Earn", "Cash", cashAmount)
end

function QuestManager:OnItemCrafted(player: Player, itemName: string, quantity: number)
    self:UpdateProgress(player, "Craft", itemName, quantity)
end

-- ==========================================
-- METTRE À JOUR LA PROGRESSION
-- ==========================================
function QuestManager:UpdateProgress(player: Player, questType: string, target: string, amount: number)
    local data = DataManager:GetData(player)
    if not data then return end

    for questId, questProgress in pairs(data.Quests.Active) do
        if questProgress.Completed then continue end

        -- Trouver la config de cette quête
        local questDef = nil
        for _, q in ipairs(QuestConfig.DailyQuestPool) do
            if q.Id == questId then
                questDef = q
                break
            end
        end
        if not questDef then continue end

        -- Vérifier si cette quête matche le type/target
        if questDef.Type ~= questType then continue end

        local matches = false
        if questDef.Target == target then
            matches = true
        elseif questDef.Target == "AnyGem" and (target == "Quartz" or target == "Amethyste" or target == "Topaze") then
            matches = true
        end

        if matches then
            questProgress.Progress = math.min(questProgress.Progress + amount, questProgress.Goal)
            if questProgress.Progress >= questProgress.Goal then
                questProgress.Completed = true
            end

            -- Notifier le client
            ReplicatedStorage.Events.RemoteEvents.QuestProgressUpdated:FireClient(
                player, questId, questProgress
            )
        end
    end
end

-- ==========================================
-- RÉCLAMER UNE RÉCOMPENSE
-- ==========================================
function QuestManager:HandleClaimQuest(player: Player, questId: string)
    local data = DataManager:GetData(player)
    if not data then return end

    local questProgress = data.Quests.Active[questId]
    if not questProgress or not questProgress.Completed or questProgress.ClaimedReward then
        return
    end

    -- Trouver les rewards
    local questDef = nil
    for _, q in ipairs(QuestConfig.DailyQuestPool) do
        if q.Id == questId then
            questDef = q
            break
        end
    end
    if not questDef then return end

    -- Donner les récompenses
    if questDef.Reward.Cash then
        DataManager:AddCash(player, questDef.Reward.Cash)
    end
    if questDef.Reward.XP then
        DataManager:AddXP(player, questDef.Reward.XP)
    end

    questProgress.ClaimedReward = true

    -- Compteur de complétion
    data.Quests.Completed[questId] = (data.Quests.Completed[questId] or 0) + 1

    ReplicatedStorage.Events.RemoteEvents.QuestRewardClaimed:FireClient(
        player, questId, questDef.Reward
    )

    print("[QuestManager]", player.Name, "a réclamé la quête", questId)
end

-- ==========================================
-- OBTENIR LES QUÊTES ACTIVES (pour UI)
-- ==========================================
function QuestManager:GetActiveQuests(player: Player)
    local data = DataManager:GetData(player)
    if not data then return {} end

    local result = {}
    for questId, progress in pairs(data.Quests.Active) do
        -- Trouver le displayname
        for _, q in ipairs(QuestConfig.DailyQuestPool) do
            if q.Id == questId then
                table.insert(result, {
                    Id = questId,
                    Title = q.Title,
                    Description = q.Description,
                    Progress = progress.Progress,
                    Goal = progress.Goal,
                    Completed = progress.Completed,
                    ClaimedReward = progress.ClaimedReward,
                    Reward = q.Reward,
                })
                break
            end
        end
    end
    return result
end

return QuestManager
```

### C.8 BossManager.server.lua

```lua
--[[
    BossManager.server.lua
    RÔLE : Gère le boss event "Gardien de la Mine" dans Zone 3.
    MÉCANIQUE : Le boss apparaît dans l'arène quand un joueur entre.
                Tous les joueurs dans l'arène participent.
                Récompenses distribuées à tous les participants.
]]

local BossManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local DataManager = require(ServerScriptService.Core.DataManager)
local GameConfig = require(ReplicatedStorage.Modules.Config.GameConfig)

-- État
local BossState = {
    IsActive = false,
    Instance = nil,             -- Le modèle du boss
    Health = 0,
    MaxHealth = 0,
    LastSpawnTime = 0,
    PlayersInArena = {},        -- { [player] = true }
    DamageDealers = {},         -- { [player] = totalDamage }
    AttackCooldown = 0,
}

-- ==========================================
-- INIT
-- ==========================================
function BossManager:Init()
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestAttackBoss.OnServerEvent:Connect(function(player)
        self:HandlePlayerAttack(player)
    end)

    -- Détecter l'entrée dans l'arène
    local arenaTrigger = Workspace.Map.Zone3_MineCrowCreek.BossArena.ArenaTrigger
    arenaTrigger.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            self:OnPlayerEnterArena(player)
        end
    end)

    arenaTrigger.TouchEnded:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            self:OnPlayerLeaveArena(player)
        end
    end)

    -- Boucle d'AI du boss
    task.spawn(function()
        while true do
            if BossState.IsActive then
                self:BossAITick()
            end
            task.wait(0.5)
        end
    end)

    print("[BossManager] Initialisé ✓")
end

-- ==========================================
-- JOUEUR ENTRE DANS L'ARÈNE
-- ==========================================
function BossManager:OnPlayerEnterArena(player: Player)
    -- Vérifier le niveau
    local data = DataManager:GetData(player)
    if not data or data.Level < 3 then return end

    BossState.PlayersInArena[player] = true

    -- Spawner le boss si pas actif et cooldown passé
    if not BossState.IsActive then
        local config = GameConfig.Boss.GardienMine
        if os.time() - BossState.LastSpawnTime >= config.SpawnCooldown then
            self:SpawnBoss()
        end
    end
end

function BossManager:OnPlayerLeaveArena(player: Player)
    BossState.PlayersInArena[player] = nil

    -- Si plus personne, reset le boss
    if BossState.IsActive and next(BossState.PlayersInArena) == nil then
        self:DespawnBoss("Tous les joueurs ont quitté l'arène.")
    end
end

-- ==========================================
-- SPAWN DU BOSS
-- ==========================================
function BossManager:SpawnBoss()
    local config = GameConfig.Boss.GardienMine

    -- Créer l'instance
    local template = ServerStorage.Templates.Boss_GardienMine
    local boss = template:Clone()
    boss.Name = "Boss_GardienMine"
    boss.Parent = Workspace.Map.Zone3_MineCrowCreek.BossArena

    local spawnPoint = Workspace.Map.Zone3_MineCrowCreek.BossArena.BossSpawnPoint
    boss:PivotTo(spawnPoint.CFrame)

    -- Initialiser l'état
    BossState.IsActive = true
    BossState.Instance = boss
    BossState.Health = config.Health
    BossState.MaxHealth = config.Health
    BossState.DamageDealers = {}
    BossState.LastSpawnTime = os.time()

    -- Fermer la porte de l'arène
    local door = Workspace.Map.Zone3_MineCrowCreek.BossArena.ArenaDoor
    door.CanCollide = true
    door.Transparency = 0

    -- Notifier les clients
    for player in pairs(BossState.PlayersInArena) do
        ReplicatedStorage.Events.RemoteEvents.BossSpawned:FireClient(
            player, config.DisplayName, BossState.Health, BossState.MaxHealth
        )
    end

    print("[BossManager] Boss spawné ! HP:", config.Health)
end

-- ==========================================
-- AI DU BOSS (tick toutes les 0.5s)
-- ==========================================
function BossManager:BossAITick()
    if not BossState.Instance then return end
    local config = GameConfig.Boss.GardienMine

    -- Trouver le joueur le plus proche
    local closestPlayer = nil
    local closestDist = math.huge
    local bossPos = BossState.Instance.PrimaryPart and BossState.Instance.PrimaryPart.Position

    if not bossPos then return end

    for player in pairs(BossState.PlayersInArena) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local dist = (char.HumanoidRootPart.Position - bossPos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPlayer = player
            end
        end
    end

    if not closestPlayer then return end

    -- Déplacer vers le joueur
    local humanoid = BossState.Instance:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local targetPos = closestPlayer.Character.HumanoidRootPart.Position
        humanoid:MoveTo(targetPos)
    end

    -- Attaque si à portée
    BossState.AttackCooldown = BossState.AttackCooldown - 0.5
    if BossState.AttackCooldown <= 0 and closestDist <= config.Attacks[1].Range then
        -- Attaque basique
        local attack = config.Attacks[1]
        local targetHumanoid = closestPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHumanoid then
            targetHumanoid:TakeDamage(attack.Damage)
        end
        BossState.AttackCooldown = attack.Cooldown

        ReplicatedStorage.Events.RemoteEvents.BossAttacked:FireClient(
            closestPlayer, attack.Name, attack.Damage
        )
    end

    -- Attaque spéciale (Éboulement) périodique
    -- (simplifié : dégâts de zone toutes les 10 secondes)
    -- Géré par un timer séparé dans SpawnBoss
end

-- ==========================================
-- JOUEUR ATTAQUE LE BOSS
-- ==========================================
function BossManager:HandlePlayerAttack(player: Player)
    if not BossState.IsActive then return end
    if not BossState.PlayersInArena[player] then return end

    -- Vérifier distance
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if not BossState.Instance or not BossState.Instance.PrimaryPart then return end

    local dist = (char.HumanoidRootPart.Position - BossState.Instance.PrimaryPart.Position).Magnitude
    if dist > 10 then return end  -- Trop loin

    -- Calculer les dégâts (basé sur le niveau de pioche)
    local data = DataManager:GetData(player)
    if not data then return end

    local pickLevel = data.Tools.Pioche and data.Tools.Pioche.Level or 0
    if pickLevel == 0 then
        ReplicatedStorage.Events.RemoteEvents.BossAttackResult:FireClient(
            player, false, "Il te faut une pioche !"
        )
        return
    end

    local baseDamage = 10
    local damage = baseDamage * pickLevel  -- 10, 20, 30 selon niveau pioche

    -- Appliquer les dégâts
    BossState.Health = BossState.Health - damage
    BossState.DamageDealers[player] = (BossState.DamageDealers[player] or 0) + damage

    -- Notifier tous les joueurs dans l'arène
    for p in pairs(BossState.PlayersInArena) do
        ReplicatedStorage.Events.RemoteEvents.BossHealthUpdated:FireClient(
            p, BossState.Health, BossState.MaxHealth
        )
    end

    -- Boss mort ?
    if BossState.Health <= 0 then
        self:OnBossDefeated()
    end
end

-- ==========================================
-- BOSS VAINCU
-- ==========================================
function BossManager:OnBossDefeated()
    local config = GameConfig.Boss.GardienMine

    -- Distribuer les récompenses à tous les participants
    for player in pairs(BossState.DamageDealers) do
        if player:IsDescendantOf(Players) then
            DataManager:AddCash(player, config.Rewards.Cash)
            DataManager:AddXP(player, config.Rewards.XP)

            -- Drops
            for _, drop in ipairs(config.Rewards.Drops) do
                if math.random(1, 100) <= drop.Chance then
                    DataManager:AddToInventory(player, drop.Item, drop.Quantity)
                end
            end

            -- Mettre à jour le compteur boss
            local data = DataManager:GetData(player)
            if data then
                data.Boss.GardienDefeated = data.Boss.GardienDefeated + 1
            end

            ReplicatedStorage.Events.RemoteEvents.BossDefeated:FireClient(
                player, config.Rewards
            )
        end
    end

    -- Ouvrir la porte
    local door = Workspace.Map.Zone3_MineCrowCreek.BossArena.ArenaDoor
    door.CanCollide = false
    door.Transparency = 1

    -- Despawn
    self:DespawnBoss()

    print("[BossManager] Boss vaincu !")
end

function BossManager:DespawnBoss(reason: string?)
    if BossState.Instance then
        BossState.Instance:Destroy()
    end
    BossState.IsActive = false
    BossState.Instance = nil
    BossState.DamageDealers = {}

    if reason then
        for player in pairs(BossState.PlayersInArena) do
            ReplicatedStorage.Events.RemoteEvents.BossDespawned:FireClient(player, reason)
        end
    end
end

return BossManager
```

### C.9 SaloonManager.server.lua

```lua
--[[
    SaloonManager.server.lua
    RÔLE : Gère le saloon — boissons, buffs, cycle jour/nuit.
    SIMPLIFIÉ : 2 boissons, buffs temporaires, max 3 verres/jour.
]]

local SaloonManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)
local GameConfig = require(ReplicatedStorage.Modules.Config.GameConfig)

-- État global
local CurrentTimeOfDay = "Day"

-- ==========================================
-- INIT
-- ==========================================
function SaloonManager:Init()
    local events = ReplicatedStorage.Events.RemoteEvents

    events.RequestBuyDrink.OnServerEvent:Connect(function(player, drinkId)
        self:HandleBuyDrink(player, drinkId)
    end)

    local funcs = ReplicatedStorage.Events.RemoteFunctions
    funcs.GetSaloonMenu.OnServerInvoke = function(player)
        return self:GetMenu(player)
    end

    print("[SaloonManager] Initialisé ✓")
end

-- ==========================================
-- CHANGEMENT JOUR/NUIT
-- ==========================================
function SaloonManager:OnTimeOfDayChanged(timeOfDay: string)
    CurrentTimeOfDay = timeOfDay
end

-- ==========================================
-- ACHETER UNE BOISSON
-- ==========================================
function SaloonManager:HandleBuyDrink(player: Player, drinkId: string)
    local data = DataManager:GetData(player)
    if not data then return end

    local saloonConfig = GameConfig.Saloon

    -- Trouver la boisson
    local drink = nil
    for _, d in ipairs(saloonConfig.Drinks) do
        if d.Id == drinkId then
            drink = d
            break
        end
    end
    if not drink then return end

    -- Vérifier le max quotidien
    -- Reset si nouveau jour
    local todayReset = os.time() - (os.time() % 86400)
    if data.Saloon.LastDrinkTime < todayReset then
        data.Saloon.DrinksToday = 0
    end

    if data.Saloon.DrinksToday >= saloonConfig.MaxDrinksPerDay then
        ReplicatedStorage.Events.RemoteEvents.SaloonResult:FireClient(
            player, false, "Tu as assez bu pour aujourd'hui !"
        )
        return
    end

    -- Vérifier si un buff est déjà actif
    if data.Saloon.BuffActive and os.time() < data.Saloon.BuffExpiry then
        ReplicatedStorage.Events.RemoteEvents.SaloonResult:FireClient(
            player, false, "Tu as déjà un buff actif !"
        )
        return
    end

    -- Calculer le prix (réduction la nuit)
    local price = drink.Cost
    if CurrentTimeOfDay == "Night" then
        price = math.floor(price * (1 - saloonConfig.DayNight.NightDrinkDiscount))
    end

    -- Vérifier le cash
    if not DataManager:RemoveCash(player, price) then
        ReplicatedStorage.Events.RemoteEvents.SaloonResult:FireClient(
            player, false, "Pas assez d'argent !"
        )
        return
    end

    -- Appliquer le buff
    data.Saloon.BuffActive = drink.BuffType
    data.Saloon.BuffExpiry = os.time() + drink.Duration
    data.Saloon.LastDrinkTime = os.time()
    data.Saloon.DrinksToday = data.Saloon.DrinksToday + 1
    data.Saloon.BuffValue = drink.BuffValue

    ReplicatedStorage.Events.RemoteEvents.SaloonResult:FireClient(
        player, true, string.format(
            "%s ! Buff %s pendant %d min.",
            drink.Name, drink.BuffType, drink.Duration / 60
        )
    )

    -- Timer pour expiration du buff
    task.delay(drink.Duration, function()
        local currentData = DataManager:GetData(player)
        if currentData and currentData.Saloon.BuffActive == drink.BuffType then
            currentData.Saloon.BuffActive = nil
            currentData.Saloon.BuffExpiry = 0
            ReplicatedStorage.Events.RemoteEvents.BuffExpired:FireClient(player, drink.BuffType)
        end
    end)
end

-- ==========================================
-- MENU DU SALOON
-- ==========================================
function SaloonManager:GetMenu(player: Player)
    local data = DataManager:GetData(player)
    if not data then return {} end

    local saloonConfig = GameConfig.Saloon
    local menu = {}

    for _, drink in ipairs(saloonConfig.Drinks) do
        local price = drink.Cost
        if CurrentTimeOfDay == "Night" then
            price = math.floor(price * (1 - saloonConfig.DayNight.NightDrinkDiscount))
        end

        table.insert(menu, {
            Id = drink.Id,
            Name = drink.Name,
            Description = drink.Description,
            Price = price,
            IsNightDiscount = CurrentTimeOfDay == "Night",
            CanBuy = data.Cash >= price and data.Saloon.DrinksToday < saloonConfig.MaxDrinksPerDay,
            DrinksRemaining = saloonConfig.MaxDrinksPerDay - data.Saloon.DrinksToday,
        })
    end

    return menu
end

return SaloonManager
```

### C.10 LeaderboardManager.server.lua

```lua
--[[
    LeaderboardManager.server.lua
    RÔLE : Gère le leaderboard affiché dans le hub.
    UTILISE : OrderedDataStore pour le classement persistant.
]]

local LeaderboardManager = {}

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Core.DataManager)

-- DataStores
local CashLeaderboard = DataStoreService:GetOrderedDataStore("Leaderboard_TotalCash_V1")
local XPLeaderboard = DataStoreService:GetOrderedDataStore("Leaderboard_XP_V1")

-- Constantes
local UPDATE_INTERVAL = 30     -- Mise à jour toutes les 30 secondes
local DISPLAY_COUNT = 10       -- Top 10

-- État
local CachedLeaderboard = {
    Cash = {},
    XP = {},
}

-- ==========================================
-- INIT
-- ==========================================
function LeaderboardManager:Init()
    -- Boucle de mise à jour
    task.spawn(function()
        while true do
            self:RefreshLeaderboards()
            task.wait(UPDATE_INTERVAL)
        end
    end)

    -- RemoteFunction pour obtenir le leaderboard
    local funcs = ReplicatedStorage.Events.RemoteFunctions
    funcs.GetLeaderboard.OnServerInvoke = function(player, category)
        return CachedLeaderboard[category] or {}
    end

    print("[LeaderboardManager] Initialisé ✓")
end

-- ==========================================
-- METTRE À JOUR UN JOUEUR
-- ==========================================
function LeaderboardManager:UpdatePlayer(player: Player)
    local data = DataManager:GetData(player)
    if not data then return end

    pcall(function()
        CashLeaderboard:SetAsync(tostring(player.UserId), data.TotalCashEarned)
        XPLeaderboard:SetAsync(tostring(player.UserId), data.XP)
    end)
end

-- ==========================================
-- RAFRAÎCHIR LES CLASSEMENTS
-- ==========================================
function LeaderboardManager:RefreshLeaderboards()
    -- Top Cash
    local success1, cashPages = pcall(function()
        return CashLeaderboard:GetSortedAsync(false, DISPLAY_COUNT)
    end)

    if success1 then
        local cashData = cashPages:GetCurrentPage()
        CachedLeaderboard.Cash = {}
        for rank, entry in ipairs(cashData) do
            local userId = tonumber(entry.key)
            local playerName = "???"
            pcall(function()
                playerName = Players:GetNameFromUserIdAsync(userId)
            end)
            table.insert(CachedLeaderboard.Cash, {
                Rank = rank,
                Name = playerName,
                Value = entry.value,
            })
        end
    end

    -- Top XP
    local success2, xpPages = pcall(function()
        return XPLeaderboard:GetSortedAsync(false, DISPLAY_COUNT)
    end)

    if success2 then
        local xpData = xpPages:GetCurrentPage()
        CachedLeaderboard.XP = {}
        for rank, entry in ipairs(xpData) do
            local userId = tonumber(entry.key)
            local playerName = "???"
            pcall(function()
                playerName = Players:GetNameFromUserIdAsync(userId)
            end)
            table.insert(CachedLeaderboard.XP, {
                Rank = rank,
                Name = playerName,
                Value = entry.value,
            })
        end
    end

    -- Mettre à jour le SurfaceGui dans le hub
    self:UpdatePhysicalDisplay()
end

-- ==========================================
-- AFFICHAGE PHYSIQUE (SurfaceGui)
-- ==========================================
function LeaderboardManager:UpdatePhysicalDisplay()
    local display = Workspace.Map.HubCentral.Buildings.Leaderboard:FindFirstChild("LeaderboardDisplay")
    if not display then return end

    local surfaceGui = display:FindFirstChildOfClass("SurfaceGui")
    if not surfaceGui then return end

    -- Mettre à jour le texte (le client peut aussi le faire via RemoteEvent)
    local textLabel = surfaceGui:FindFirstChild("LeaderboardText")
    if textLabel then
        local lines = { "🏆 TOP 10 ORPAILLEURS 🏆\n" }
        for _, entry in ipairs(CachedLeaderboard.Cash) do
            table.insert(lines, string.format(
                "#%d  %s  —  %d$", entry.Rank, entry.Name, entry.Value
            ))
        end
        textLabel.Text = table.concat(lines, "\n")
    end
end

return LeaderboardManager
```

---

## D. Scripts Client (Pseudo-code Détaillé)

### D.1 MiningClient.client.lua

```lua
--[[
    MiningClient.client.lua
    RÔLE : Gère les interactions de minage côté client.
           Détecte les ProximityPrompt, envoie les requêtes au serveur,
           affiche les résultats (particules, sons, notifications).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Events = ReplicatedStorage.Events.RemoteEvents

-- ==========================================
-- ÉCOUTER LES ProximityPrompts SUR LES GISEMENTS
-- ==========================================
-- Les ProximityPrompts sont sur les gisements dans Workspace.ActiveGoldDeposits
-- On utilise un DescendantAdded listener pour les détecter dynamiquement

Workspace.ActiveGoldDeposits.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        descendant.Triggered:Connect(function(triggeringPlayer)
            if triggeringPlayer == player then
                local deposit = descendant.Parent
                -- deposit est soit un Model soit un Part
                local depositName = deposit:IsA("Model") and deposit.Name or deposit.Parent.Name
                Events.RequestMine:FireServer(depositName)
            end
        end)
    end
end)

-- Aussi écouter les prompts déjà présents
for _, deposit in Workspace.ActiveGoldDeposits:GetChildren() do
    local prompt = deposit:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        prompt.Triggered:Connect(function(triggeringPlayer)
            if triggeringPlayer == player then
                Events.RequestMine:FireServer(deposit.Name)
            end
        end)
    end
end

-- ==========================================
-- RÉSULTAT DE MINAGE
-- ==========================================
Events.MineResult.OnClientEvent:Connect(function(success, data)
    if success then
        -- data = { [itemName] = quantity, ... }
        local UIManager = require(script.Parent.Parent.Core.UIManager)

        -- Afficher les drops en popup
        for itemName, qty in pairs(data) do
            UIManager:ShowFloatingText(
                player.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0),
                string.format("+%d %s", qty, itemName),
                Color3.fromRGB(255, 215, 0)  -- Doré
            )
        end

        -- Effet de particules
        UIManager:PlayMineEffect(player.Character.HumanoidRootPart.Position)

        -- Son
        UIManager:PlaySound("MineSuccess")

        -- Mettre à jour le HUD
        UIManager:RefreshHUD()
    else
        -- data = message d'erreur string
        local UIManager = require(script.Parent.Parent.Core.UIManager)
        UIManager:ShowNotification(data, "Error")
    end
end)
```

### D.2 BateeMinigame.client.lua

```lua
--[[
    BateeMinigame.client.lua
    RÔLE : Mini-jeu de la batée.
    MÉCANIQUE :
      - Un cercle apparaît avec un indicateur rotatif
      - Le joueur doit cliquer/appuyer quand l'indicateur est dans la "zone verte"
      - Plus le timing est bon, plus le score (0-1) est élevé
      - Le score est envoyé au serveur pour calculer les drops
    
    UI : BateeMinigameUI (ScreenGui dans StarterGui)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Events = ReplicatedStorage.Events.RemoteEvents

-- UI References
local gui = player.PlayerGui:WaitForChild("BateeMinigameUI")
local circle = gui:WaitForChild("Circle")            -- ImageLabel (cercle)
local indicator = gui:WaitForChild("Indicator")       -- ImageLabel (aiguille rotative)
local greenZone = gui:WaitForChild("GreenZone")       -- ImageLabel (zone cible)
local instruction = gui:WaitForChild("InstructionText") -- TextLabel

-- État
local isPlaying = false
local currentDepositId = nil
local rotationSpeed = 200      -- Degrés par seconde
local currentAngle = 0
local greenZoneCenter = 0      -- Angle du centre de la zone verte
local greenZoneWidth = 60      -- Largeur en degrés (±30°)

-- ==========================================
-- DÉMARRER LE MINI-JEU
-- ==========================================
Events.StartBateeMinigame.OnClientEvent:Connect(function(depositId)
    currentDepositId = depositId
    isPlaying = true

    -- Randomiser la zone verte
    greenZoneCenter = math.random(0, 359)
    greenZone.Rotation = greenZoneCenter

    -- Afficher le UI
    gui.Enabled = true
    currentAngle = 0
    instruction.Text = "Appuie sur ESPACE quand l'aiguille est dans la zone verte !"

    -- Animation de rotation de l'indicateur
    task.spawn(function()
        while isPlaying do
            currentAngle = (currentAngle + rotationSpeed * task.wait()) % 360
            indicator.Rotation = currentAngle
        end
    end)
end)

-- ==========================================
-- INPUT — APPUYER POUR VALIDER
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not isPlaying then return end

    if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch then
        -- Calculer le score basé sur la proximité de la zone verte
        local angleDiff = math.abs(currentAngle - greenZoneCenter)
        if angleDiff > 180 then
            angleDiff = 360 - angleDiff
        end

        local score = 0
        local halfWidth = greenZoneWidth / 2

        if angleDiff <= halfWidth * 0.3 then
            score = 1.0       -- PARFAIT — dans le centre (30% de la zone)
            instruction.Text = "⭐ PARFAIT ! ⭐"
        elseif angleDiff <= halfWidth then
            score = 0.7       -- BON — dans la zone verte
            instruction.Text = "👍 Bon !"
        elseif angleDiff <= halfWidth * 1.5 then
            score = 0.4       -- MOYEN — proche de la zone
            instruction.Text = "😐 Moyen..."
        else
            score = 0.1       -- RATÉ — loin de la zone
            instruction.Text = "❌ Raté !"
        end

        -- Terminer le mini-jeu
        isPlaying = false

        -- Feedback visuel
        task.wait(1)
        gui.Enabled = false

        -- Envoyer le résultat au serveur
        Events.BateeMinigameResult:FireServer(currentDepositId, score)
    end
end)
```

### D.3 InteractionClient.client.lua

```lua
--[[
    InteractionClient.client.lua
    RÔLE : Gère toutes les interactions PNJ via ProximityPrompt.
           Ouvre les UI appropriés selon le type de PNJ.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Events = ReplicatedStorage.Events.RemoteEvents
local Functions = ReplicatedStorage.Events.RemoteFunctions
local NPCConfig = require(ReplicatedStorage.Modules.Config.NPCConfig)

-- ==========================================
-- SETUP DES ProximityPrompts POUR CHAQUE PNJ
-- ==========================================
local function SetupNPCPrompts()
    local hub = Workspace.Map.HubCentral.Buildings

    -- Marchand
    local marchandPrompt = hub.Marchand:FindFirstChild("ProximityPrompt")
    if marchandPrompt then
        marchandPrompt.ActionText = NPCConfig.NPCs.Marchand.ProximityActionText
        marchandPrompt.MaxActivationDistance = NPCConfig.NPCs.Marchand.ProximityMaxDistance
        marchandPrompt.Triggered:Connect(function(p)
            if p == player then
                OpenSellUI("MarchandLocal")
            end
        end)
    end

    -- Négociant
    local negociantPrompt = hub.Negociant:FindFirstChild("ProximityPrompt")
    if negociantPrompt then
        negociantPrompt.ActionText = NPCConfig.NPCs.Negociant.ProximityActionText
        negociantPrompt.MaxActivationDistance = NPCConfig.NPCs.Negociant.ProximityMaxDistance
        negociantPrompt.Triggered:Connect(function(p)
            if p == player then
                OpenSellUI("Negociant")
            end
        end)
    end

    -- Vendeur (Magasin)
    local vendeurPrompt = hub.MagasinOutils:FindFirstChild("ProximityPrompt")
    if vendeurPrompt then
        vendeurPrompt.ActionText = NPCConfig.NPCs.Vendeur.ProximityActionText
        vendeurPrompt.MaxActivationDistance = NPCConfig.NPCs.Vendeur.ProximityMaxDistance
        vendeurPrompt.Triggered:Connect(function(p)
            if p == player then
                OpenShopUI()
            end
        end)
    end

    -- Forgeron
    local forgeronPrompt = hub.Forge:FindFirstChild("ProximityPrompt")
    if forgeronPrompt then
        forgeronPrompt.ActionText = NPCConfig.NPCs.Forgeron.ProximityActionText
        forgeronPrompt.MaxActivationDistance = NPCConfig.NPCs.Forgeron.ProximityMaxDistance
        forgeronPrompt.Triggered:Connect(function(p)
            if p == player then
                OpenCraftUI()
            end
        end)
    end

    -- Barman
    local barmanPrompt = hub.Saloon:FindFirstChild("ProximityPrompt")
    if barmanPrompt then
        barmanPrompt.ActionText = NPCConfig.NPCs.Barman.ProximityActionText
        barmanPrompt.MaxActivationDistance = NPCConfig.NPCs.Barman.ProximityMaxDistance
        barmanPrompt.Triggered:Connect(function(p)
            if p == player then
                OpenSaloonUI()
            end
        end)
    end

    -- Guide (Zone 1)
    local guidePrompt = Workspace.Map.Zone1_RiviereTransquille:FindFirstChild("ProximityPrompt_Guide")
    if guidePrompt then
        guidePrompt.ActionText = NPCConfig.NPCs.Guide.ProximityActionText
        guidePrompt.MaxActivationDistance = NPCConfig.NPCs.Guide.ProximityMaxDistance
        guidePrompt.Triggered:Connect(function(p)
            if p == player then
                OpenDialogueUI("Guide")
            end
        end)
    end
end

-- ==========================================
-- OUVRIR LES UI
-- ==========================================
function OpenSellUI(npcType: string)
    local gui = player.PlayerGui:WaitForChild("SellUI")
    gui.Enabled = true
    -- Passer le type de PNJ au script SellUI
    gui:SetAttribute("NPCType", npcType)
    -- Le SellUI script interne gère le reste
end

function OpenShopUI()
    local gui = player.PlayerGui:WaitForChild("ShopUI")
    gui.Enabled = true
end

function OpenCraftUI()
    local gui = player.PlayerGui:WaitForChild("CraftUI")
    gui.Enabled = true
end

function OpenSaloonUI()
    local gui = player.PlayerGui:WaitForChild("SaloonUI")
    gui.Enabled = true
end

function OpenDialogueUI(npcId: string)
    local gui = player.PlayerGui:WaitForChild("DialogueUI")
    gui.Enabled = true
    gui:SetAttribute("NPCId", npcId)
end

-- ==========================================
-- ZONE DETECTION (pour UI feedback)
-- ==========================================
local function SetupZoneTriggers()
    local zones = {
        { Folder = "Zone1_RiviereTransquille", Name = "Rivière Tranquille" },
        { Folder = "Zone2_CollinesAmbrees", Name = "Collines Ambrées" },
        { Folder = "Zone3_MineCrowCreek", Name = "Mine de Crow Creek" },
    }

    for _, zone in ipairs(zones) do
        local trigger = Workspace.Map[zone.Folder]:FindFirstChild("ZoneTrigger")
        if trigger then
            trigger.Touched:Connect(function(hit)
                if hit.Parent == player.Character then
                    local UIManager = require(script.Parent.Parent.Core.UIManager)
                    UIManager:ShowZoneTitle(zone.Name)
                end
            end)
        end
    end
end

-- ==========================================
-- INIT
-- ==========================================
SetupNPCPrompts()
SetupZoneTriggers()
```

### D.4 UIManager.client.lua

```lua
--[[
    UIManager.client.lua
    RÔLE : Module centralisé pour toutes les mises à jour UI.
           Gère le HUD principal, les notifications, les effets visuels.
]]

local UIManager = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Events = ReplicatedStorage.Events.RemoteEvents
local EconomyConfig = require(ReplicatedStorage.Modules.Config.EconomyConfig)

-- UI References (initialisées à l'appel de Init)
local mainHUD = nil
local cashDisplay = nil
local xpBar = nil
local xpText = nil
local levelText = nil
local questTracker = nil

-- État local (synchronisé depuis le serveur)
local LocalPlayerData = nil

-- ==========================================
-- INIT
-- ==========================================
function UIManager:Init()
    mainHUD = player.PlayerGui:WaitForChild("MainHUD")
    cashDisplay = mainHUD:WaitForChild("CashDisplay"):WaitForChild("Amount")
    xpBar = mainHUD:WaitForChild("XPBar"):WaitForChild("Fill")
    xpText = mainHUD:WaitForChild("XPBar"):WaitForChild("XPText")
    levelText = mainHUD:WaitForChild("XPBar"):WaitForChild("LevelText")
    questTracker = mainHUD:WaitForChild("QuestTracker")

    -- Écouter les données initiales
    Events.InitPlayerData.OnClientEvent:Connect(function(data)
        LocalPlayerData = data
        self:RefreshHUD()
    end)

    -- Écouter les mises à jour
    Events.PlayerDataUpdated.OnClientEvent:Connect(function(key, value)
        if LocalPlayerData then
            LocalPlayerData[key] = value
            self:RefreshHUD()
        end
    end)

    -- Level up
    Events.LevelUp.OnClientEvent:Connect(function(newLevel, levelName)
        self:ShowLevelUpScreen(newLevel, levelName)
    end)

    -- Jour/Nuit
    Events.TimeOfDayChanged.OnClientEvent:Connect(function(timeOfDay)
        self:OnTimeOfDayChanged(timeOfDay)
    end)

    -- Buff expiré
    Events.BuffExpired.OnClientEvent:Connect(function(buffType)
        self:ShowNotification("Buff " .. buffType .. " terminé !", "Info")
    end)
end

-- ==========================================
-- RAFRAÎCHIR LE HUD
-- ==========================================
function UIManager:RefreshHUD()
    if not LocalPlayerData then return end

    -- Cash
    cashDisplay.Text = string.format("$%d", LocalPlayerData.Cash)

    -- XP Bar
    local level = LocalPlayerData.Level
    local xp = LocalPlayerData.XP
    local threshold = EconomyConfig.LevelThresholds[level]
    local nextThreshold = EconomyConfig.LevelThresholds[level + 1]

    if nextThreshold then
        local xpInLevel = xp - threshold.MinXP
        local xpForLevel = nextThreshold.MinXP - threshold.MinXP
        local fillRatio = math.clamp(xpInLevel / xpForLevel, 0, 1)

        xpBar.Size = UDim2.new(fillRatio, 0, 1, 0)
        xpText.Text = string.format("%d / %d XP", xpInLevel, xpForLevel)
    else
        xpBar.Size = UDim2.new(1, 0, 1, 0)
        xpText.Text = "MAX"
    end

    levelText.Text = string.format("Nv.%d — %s", level, threshold.Name)
end

-- ==========================================
-- TEXTE FLOTTANT (drops)
-- ==========================================
function UIManager:ShowFloatingText(worldPosition: Vector3, text: string, color: Color3)
    -- Créer un BillboardGui temporaire
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Position = worldPosition
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 0, 0)
    billboard.Adornee = part
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    -- Animation : monter et disparaître
    local tween = TweenService:Create(part, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
        Position = worldPosition + Vector3.new(0, 5, 0),
    })
    local fadeTween = TweenService:Create(label, TweenInfo.new(1.5), {
        TextTransparency = 1,
    })
    tween:Play()
    fadeTween:Play()

    task.delay(1.5, function()
        part:Destroy()
    end)
end

-- ==========================================
-- NOTIFICATION
-- ==========================================
function UIManager:ShowNotification(message: string, notifType: string)
    -- notifType: "Success", "Error", "Info", "Warning"
    local colors = {
        Success = Color3.fromRGB(46, 204, 113),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219),
        Warning = Color3.fromRGB(241, 196, 15),
    }

    -- Créer un frame notification temporaire dans le MainHUD
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0.3, 0, 0.05, 0)
    notifFrame.Position = UDim2.new(0.35, 0, 0.02, 0)
    notifFrame.BackgroundColor3 = colors[notifType] or colors.Info
    notifFrame.BackgroundTransparency = 0.2
    notifFrame.Parent = mainHUD

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notifFrame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, 0)
    text.Position = UDim2.new(0, 10, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = notifFrame

    -- Disparaître après 3 secondes
    task.delay(3, function()
        local tween = TweenService:Create(notifFrame, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
        })
        tween:Play()
        task.delay(0.5, function()
            notifFrame:Destroy()
        end)
    end)
end

-- ==========================================
-- ZONE TITLE
-- ==========================================
function UIManager:ShowZoneTitle(zoneName: string)
    -- Grand texte centré qui apparaît et disparaît
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 0.1, 0)
    titleLabel.Position = UDim2.new(0.2, 0, 0.4, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = zoneName
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    titleLabel.TextTransparency = 1
    titleLabel.Parent = mainHUD

    -- Fade in
    local fadeIn = TweenService:Create(titleLabel, TweenInfo.new(0.5), {
        TextTransparency = 0,
    })
    fadeIn:Play()

    -- Hold 2 sec puis fade out
    task.delay(2.5, function()
        local fadeOut = TweenService:Create(titleLabel, TweenInfo.new(1), {
            TextTransparency = 1,
        })
        fadeOut:Play()
        task.delay(1, function()
            titleLabel:Destroy()
        end)
    end)
end

-- ==========================================
-- LEVEL UP SCREEN
-- ==========================================
function UIManager:ShowLevelUpScreen(newLevel: number, levelName: string)
    local gui = player.PlayerGui:WaitForChild("LevelUpUI")
    local title = gui:WaitForChild("Title")
    local subtitle = gui:WaitForChild("Subtitle")

    title.Text = "⬆️ LEVEL UP !"
    subtitle.Text = string.format("Tu es maintenant %s (Nv.%d)", levelName, newLevel)

    gui.Enabled = true

    -- Fermer après 4 secondes
    task.delay(4, function()
        gui.Enabled = false
    end)

    -- Mettre à jour le HUD
    self:RefreshHUD()
end

-- ==========================================
-- JOUR/NUIT — Changer l'ambiance
-- ==========================================
function UIManager:OnTimeOfDayChanged(timeOfDay: string)
    local Lighting = game:GetService("Lighting")

    if timeOfDay == "Night" then
        TweenService:Create(Lighting, TweenInfo.new(5), {
            ClockTime = 22,
            Brightness = 0.5,
            Ambient = Color3.fromRGB(50, 50, 80),
        }):Play()
    else
        TweenService:Create(Lighting, TweenInfo.new(5), {
            ClockTime = 14,
            Brightness = 2,
            Ambient = Color3.fromRGB(128, 128, 128),
        }):Play()
    end

    self:ShowNotification(
        timeOfDay == "Night" and "🌙 La nuit tombe..." or "☀️ Le jour se lève !",
        "Info"
    )
end

-- ==========================================
-- EFFETS
-- ==========================================
function UIManager:PlayMineEffect(position: Vector3)
    -- Particules dorées
    local attachment = Instance.new("Attachment")
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = Workspace
    attachment.Parent = part

    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
    particles.Size = NumberSequence.new(0.3, 0)
    particles.Lifetime = NumberRange.new(0.5, 1)
    particles.Speed = NumberRange.new(3, 8)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Rate = 50
    particles.Parent = attachment

    task.delay(0.3, function()
        particles.Enabled = false
    end)
    task.delay(1.5, function()
        part:Destroy()
    end)
end

function UIManager:PlaySound(soundName: string)
    -- Sons stockés dans ReplicatedStorage.Assets
    local soundsMap = {
        MineSuccess = "rbxassetid://0",     -- Remplacer par un vrai ID
        LevelUp = "rbxassetid://0",
        Purchase = "rbxassetid://0",
        Error = "rbxassetid://0",
    }

    local soundId = soundsMap[soundName]
    if soundId then
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 0.5
        sound.Parent = player.PlayerGui
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end
end

return UIManager
```

### D.5 DayNightClient.client.lua — Déjà couvert dans UIManager (OnTimeOfDayChanged)

> Le cycle jour/nuit est géré côté serveur (GameManager) et notifié au client via `TimeOfDayChanged`. Le UIManager applique le changement de Lighting. Pas de script séparé nécessaire.

### D.6 DetecteurSystem.client.lua

```lua
--[[
    DetecteurSystem.client.lua
    RÔLE : Feedback visuel/audio quand le joueur est en Zone 2 avec le tapis/batée.
           Simule un "détecteur de métaux" qui bipe plus fort près des gisements.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- État
local isInZone2 = false
local detectorActive = false
local lastBeepTime = 0
local BEEP_INTERVAL_MAX = 2.0    -- Loin d'un gisement
local BEEP_INTERVAL_MIN = 0.2    -- Très proche

-- ==========================================
-- DÉTECTION DE LA ZONE
-- ==========================================
local zone2Trigger = Workspace.Map.Zone2_CollinesAmbrees:FindFirstChild("ZoneTrigger")
if zone2Trigger then
    zone2Trigger.Touched:Connect(function(hit)
        if hit.Parent == player.Character then
            isInZone2 = true
            detectorActive = true
        end
    end)
    zone2Trigger.TouchEnded:Connect(function(hit)
        if hit.Parent == player.Character then
            isInZone2 = false
            detectorActive = false
        end
    end)
end

-- ==========================================
-- BOUCLE DE DÉTECTION
-- ==========================================
RunService.Heartbeat:Connect(function()
    if not detectorActive then return end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local playerPos = character.HumanoidRootPart.Position

    -- Trouver le gisement le plus proche
    local closestDist = math.huge
    for _, deposit in Workspace.ActiveGoldDeposits:GetChildren() do
        if deposit:GetAttribute("ZoneId") == "Zone2" then
            local depositPos
            if deposit:IsA("Model") and deposit.PrimaryPart then
                depositPos = deposit.PrimaryPart.Position
            elseif deposit:IsA("BasePart") then
                depositPos = deposit.Position
            end
            if depositPos then
                local dist = (playerPos - depositPos).Magnitude
                closestDist = math.min(closestDist, dist)
            end
        end
    end

    -- Calculer l'intervalle de beep
    local maxRange = 50  -- Commence à biper à 50 studs
    if closestDist < maxRange then
        local ratio = closestDist / maxRange  -- 0 = sur le gisement, 1 = à maxRange
        local beepInterval = BEEP_INTERVAL_MIN + (BEEP_INTERVAL_MAX - BEEP_INTERVAL_MIN) * ratio

        if os.clock() - lastBeepTime >= beepInterval then
            lastBeepTime = os.clock()

            -- Jouer un son de beep
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://0"  -- Remplacer par un vrai beep
            sound.Volume = math.clamp(1 - ratio, 0.1, 1)
            sound.PlaybackSpeed = 1 + (1 - ratio) * 0.5  -- Plus aigu quand proche
            sound.Parent = player.PlayerGui
            sound:Play()
            sound.Ended:Connect(function() sound:Destroy() end)
        end
    end
end)
```

---

## E. Système d'Événements (RemoteEvents / RemoteFunctions)

### E.1 Liste complète des RemoteEvents

> **Convention** : Tous dans `ReplicatedStorage.Events.RemoteEvents`

| Nom | Direction | Payload | Description |
|-----|-----------|---------|-------------|
| `InitPlayerData` | S → C | `PlayerData` (table complète) | Envoi des données initiales au login |
| `PlayerDataUpdated` | S → C | `key: string, value: any` | Mise à jour partielle côté client |
| `RequestMine` | C → S | `depositId: string` | Le joueur veut miner un gisement |
| `MineResult` | S → C | `success: bool, data: table\|string` | Résultat du minage (drops ou erreur) |
| `StartBateeMinigame` | S → C | `depositId: string` | Déclencher le mini-jeu de batée |
| `BateeMinigameResult` | C → S | `depositId: string, score: number` | Résultat du mini-jeu (0-1) |
| `RequestSell` | C → S | `npcType: string, itemName: string, qty: number` | Vendre des items |
| `SellResult` | S → C | `success: bool, message: string` | Résultat de la vente |
| `RequestBuyTool` | C → S | `toolName: string` | Acheter un outil |
| `RequestUpgradeTool` | C → S | `toolName: string` | Améliorer un outil |
| `ShopResult` | S → C | `success: bool, message: string` | Résultat d'achat/upgrade |
| `RequestCraft` | C → S | `recipeId: string, quantity: number` | Crafter un item |
| `CraftResult` | S → C | `success: bool, message: string` | Résultat du craft |
| `RequestClaimQuest` | C → S | `questId: string` | Réclamer la récompense d'une quête |
| `QuestsUpdated` | S → C | `activeQuests: table` | Nouvelles quêtes assignées |
| `QuestProgressUpdated` | S → C | `questId: string, progress: QuestProgress` | Mise à jour de progression |
| `QuestRewardClaimed` | S → C | `questId: string, reward: table` | Récompense réclamée |
| `RequestBuyDrink` | C → S | `drinkId: string` | Acheter une boisson au Saloon |
| `SaloonResult` | S → C | `success: bool, message: string` | Résultat de l'achat |
| `BuffExpired` | S → C | `buffType: string` | Un buff a expiré |
| `TimeOfDayChanged` | S → C | `timeOfDay: "Day"\|"Night"` | Changement jour/nuit |
| `StartTutorial` | S → C | `step: number` | Démarrer/reprendre le tutoriel |
| `TutorialStepComplete` | C → S | `step: number` | Le joueur a terminé une étape du tuto |
| `RequestAttackBoss` | C → S | *(aucun)* | Le joueur attaque le boss |
| `BossAttackResult` | S → C | `success: bool, message: string` | Feedback d'attaque |
| `BossSpawned` | S → C | `name: string, hp: number, maxHp: number` | Boss apparu |
| `BossHealthUpdated` | S → C | `hp: number, maxHp: number` | Mise à jour HP du boss |
| `BossAttacked` | S → C | `attackName: string, damage: number` | Le boss attaque le joueur |
| `BossDefeated` | S → C | `rewards: table` | Boss vaincu, récompenses |
| `BossDespawned` | S → C | `reason: string` | Boss disparu |
| `LevelUp` | S → C | `newLevel: number, levelName: string` | Le joueur monte de niveau |

### E.2 Liste complète des RemoteFunctions

> **Convention** : Tous dans `ReplicatedStorage.Events.RemoteFunctions`

| Nom | Direction | Args | Return | Description |
|-----|-----------|------|--------|-------------|
| `GetPlayerData` | C → S | *(aucun)* | `PlayerData` | Obtenir les données complètes du joueur |
| `GetCraftRecipes` | C → S | *(aucun)* | `{RecipeInfo}` | Liste des recettes avec disponibilité |
| `GetActiveQuests` | C → S | *(aucun)* | `{QuestInfo}` | Liste des quêtes actives |
| `GetLeaderboard` | C → S | `category: string` | `{LeaderboardEntry}` | Top 10 (Cash ou XP) |
| `GetSaloonMenu` | C → S | *(aucun)* | `{DrinkInfo}` | Menu du Saloon avec prix actuels |
| `GetShopItems` | C → S | *(aucun)* | `{ShopItemInfo}` | Liste des outils en magasin |

### E.3 Création des Events (script d'initialisation)

```lua
-- À placer dans un script serveur (ou dans GameManager:Init)
-- Crée tous les RemoteEvents et RemoteFunctions au démarrage

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Créer les dossiers
local eventsFolder = Instance.new("Folder")
eventsFolder.Name = "Events"
eventsFolder.Parent = ReplicatedStorage

local remoteEventsFolder = Instance.new("Folder")
remoteEventsFolder.Name = "RemoteEvents"
remoteEventsFolder.Parent = eventsFolder

local remoteFunctionsFolder = Instance.new("Folder")
remoteFunctionsFolder.Name = "RemoteFunctions"
remoteFunctionsFolder.Parent = eventsFolder

-- RemoteEvents
local remoteEventNames = {
    "InitPlayerData", "PlayerDataUpdated",
    "RequestMine", "MineResult",
    "StartBateeMinigame", "BateeMinigameResult",
    "RequestSell", "SellResult",
    "RequestBuyTool", "RequestUpgradeTool", "ShopResult",
    "RequestCraft", "CraftResult",
    "RequestClaimQuest", "QuestsUpdated", "QuestProgressUpdated", "QuestRewardClaimed",
    "RequestBuyDrink", "SaloonResult", "BuffExpired",
    "TimeOfDayChanged",
    "StartTutorial", "TutorialStepComplete",
    "RequestAttackBoss", "BossAttackResult",
    "BossSpawned", "BossHealthUpdated", "BossAttacked", "BossDefeated", "BossDespawned",
    "LevelUp",
}

for _, name in ipairs(remoteEventNames) do
    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = remoteEventsFolder
end

-- RemoteFunctions
local remoteFunctionNames = {
    "GetPlayerData", "GetCraftRecipes", "GetActiveQuests",
    "GetLeaderboard", "GetSaloonMenu", "GetShopItems",
}

for _, name in ipairs(remoteFunctionNames) do
    local func = Instance.new("RemoteFunction")
    func.Name = name
    func.Parent = remoteFunctionsFolder
end

print("[EventSetup] Tous les events créés ✓")
```

---

## F. UI Screens — Wireframes Textuels

### F.1 MainHUD (toujours visible)

```
┌────────────────────────────────────────────────────────────┐
│  [$2,450]              ☀️ Jour                [📋 Quêtes]  │
│                                                            │
│  [XP ████████░░░░░ 340/500]  Nv.1 Amateur                │
│                                                            │
│                     (zone de jeu)                          │
│                                                            │
│                                                            │
│                                                            │
│                                                            │
│  ┌─── Quêtes actives ───┐                                 │
│  │ ⚒️ L'Or de la Rivière │  [🎒]    [⚙️]                  │
│  │   ████░░ 6/10        │  Inventaire  Paramètres         │
│  │ 💰 Commerce d'Abord   │                                 │
│  │   ██░░░░ 1/3         │                                 │
│  └──────────────────────┘                                 │
└────────────────────────────────────────────────────────────┘
```

### F.2 ShopUI (Magasin d'outils)

```
┌──────────────────────────────────────────────┐
│  [X]        🔧 MAGASIN D'OUTILS             │
│─────────────────────────────────────────────│
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ 🥘 Batée en Bois (Nv.1)            │    │
│  │    "Tamise l'or dans la rivière"    │    │
│  │    [Améliorer → Nv.2 : 150$]       │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ 🧹 Tapis de Prospection            │    │
│  │    "Filtre les sédiments"           │    │
│  │    [ACHETER : 100$]                 │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ ⛏️ Pioche                           │    │
│  │    "Mine les filons et minerais"    │    │
│  │    [ACHETER : 200$]                 │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  Ton argent : $2,450                         │
└──────────────────────────────────────────────┘
```

### F.3 SellUI (Vente au marchand)

```
┌──────────────────────────────────────────────┐
│  [X]        💰 VENDRE — Marcel le Marchand   │
│─────────────────────────────────────────────│
│                                              │
│  "Bonjour voyageur ! Tu as de l'or ?"       │
│                                              │
│  ┌────────────────────────────────────┐     │
│  │  Item          Qté    Prix/u  Total│     │
│  │──────────────────────────────────── │     │
│  │  Paillettes    12     2$     24$   │     │
│  │  [-] [███████████] [+]  [VENDRE]  │     │
│  │                                     │     │
│  │  Pépites       3      15$    45$   │     │
│  │  [-] [███████████] [+]  [VENDRE]  │     │
│  │                                     │     │
│  │  Quartz        2      8$     16$   │     │
│  │  [-] [███████████] [+]  [VENDRE]  │     │
│  └────────────────────────────────────┘     │
│                                              │
│  [TOUT VENDRE : 85$]                        │
│                                              │
│  Ton argent : $2,450                         │
└──────────────────────────────────────────────┘
```

### F.4 CraftUI (Forge)

```
┌──────────────────────────────────────────────┐
│  [X]        🔨 FORGE — Gustave le Forgeron   │
│─────────────────────────────────────────────│
│                                              │
│  "Apporte-moi du minerai !"                 │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ 🔥 Raffiner de l'Or Pur             │    │
│  │    5 Paillettes → 1 Or Pur          │    │
│  │    Tu as : 12 Paillettes            │    │
│  │    Max craftable : 2                 │    │
│  │    [-] [2] [+]  [FORGER]            │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ ⚒️ Forger un Lingot                  │    │
│  │    3 Or Pur + 2 Minerai → 1 Lingot  │    │
│  │    Tu as : 5 Or Pur, 4 Minerai      │    │
│  │    Max craftable : 1                 │    │
│  │    [-] [1] [+]  [FORGER]            │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ 🔶 Raffiner des Pépites  🔒 Nv.1   │    │
│  │    2 Pépites → 1 Or Pur             │    │
│  │    Tu as : 3 Pépites                │    │
│  │    [-] [1] [+]  [FORGER]            │    │
│  └─────────────────────────────────────┘    │
└──────────────────────────────────────────────┘
```

### F.5 InventoryUI

```
┌──────────────────────────────────────────────┐
│  [X]        🎒 INVENTAIRE                    │
│─────────────────────────────────────────────│
│                                              │
│  === OR & MINERAI ===                        │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐   │
│  │ ✨   │  │ 🟡   │  │ ⬛   │  │ 🟠   │   │
│  │Paill. │  │OrPur │  │Miner.│  │Pépite│   │
│  │  12   │  │  5   │  │  4   │  │  3   │   │
│  └──────┘  └──────┘  └──────┘  └──────┘   │
│                                              │
│  === LINGOTS ===                             │
│  ┌──────┐                                   │
│  │ 🏅   │                                   │
│  │Lingot│                                   │
│  │  1   │                                   │
│  └──────┘                                   │
│                                              │
│  === GEMMES ===                              │
│  ┌──────┐  ┌──────┐  ┌──────┐              │
│  │ 💎   │  │ 💜   │  │ 💛   │              │
│  │Quartz│  │Améth.│  │Topaze│              │
│  │  2   │  │  1   │  │  0   │              │
│  └──────┘  └──────┘  └──────┘              │
│                                              │
│  === OUTILS ===                              │
│  ⛏️ Batée Nv.1 | 🧹 Tapis Nv.1 | ❌ Pioche │
└──────────────────────────────────────────────┘
```

### F.6 QuestUI (Détail des quêtes)

```
┌──────────────────────────────────────────────┐
│  [X]        📋 QUÊTES DU JOUR               │
│─────────────────────────────────────────────│
│  Reset dans : 14h 32min                      │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ ⚒️ L'Or de la Rivière               │    │
│  │  "Récupère 10 paillettes d'or"      │    │
│  │  [████████░░░░] 8/10                │    │
│  │  Récompense : 30$ + 50 XP           │    │
│  │  [En cours...]                       │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ 💰 Le Commerce d'Abord       ✅     │    │
│  │  "Effectue 3 ventes"                │    │
│  │  [████████████] 3/3  COMPLÉTÉE     │    │
│  │  Récompense : 40$ + 50 XP           │    │
│  │  [RÉCLAMER]                          │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ 🔨 Apprenti Forgeron                │    │
│  │  "Raffine 5 lots d'or pur"          │    │
│  │  [██░░░░░░░░░] 1/5                 │    │
│  │  Récompense : 60$ + 80 XP           │    │
│  │  [En cours...]                       │    │
│  └─────────────────────────────────────┘    │
└──────────────────────────────────────────────┘
```

### F.7 SaloonUI

```
┌──────────────────────────────────────────────┐
│  [X]        🍺 SALOON — Bill le Barman       │
│─────────────────────────────────────────────│
│                                              │
│  🌙 C'est la nuit ! -20% sur les boissons  │
│  Verres restants aujourd'hui : 2/3           │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ 🥃 Whiskey du Mineur         12$    │    │
│  │  +20% vitesse de minage (5 min)    │    │
│  │  Prix normal : 15$ (-20% nuit)     │    │
│  │  [COMMANDER]                        │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │ 🍺 Bière Porte-Bonheur      16$    │    │
│  │  +15% chance de gemmes (5 min)     │    │
│  │  Prix normal : 20$ (-20% nuit)     │    │
│  │  [COMMANDER]                        │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  Ton argent : $2,450                         │
└──────────────────────────────────────────────┘
```

### F.8 BossUI (pendant le combat)

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│            ⚔️ LE GARDIEN DE LA MINE ⚔️                    │
│     [████████████████░░░░] 320/500 HP                     │
│                                                            │
│                     (zone de jeu — arène)                  │
│                                                            │
│                                                            │
│                                                            │
│  ┌─────────────────┐                                      │
│  │ [ATTAQUER] (E)  │    ⚠️ Éboulement dans 5s...         │
│  └─────────────────┘                                      │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### F.9 BateeMinigameUI

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│              🥘 TOURNEZ LA BATÉE !                        │
│                                                            │
│                    ╭─────────╮                            │
│                   ╱  🟢🟢🟢  ╲    ← Zone verte (cible)  │
│                  │             │                           │
│                  │      │      │   ← Aiguille (tourne)    │
│                  │      ↓      │                           │
│                   ╲           ╱                            │
│                    ╰─────────╯                            │
│                                                            │
│           Appuie sur [ESPACE] au bon moment !             │
│                                                            │
│                     ⭐ PARFAIT ! ⭐                       │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### F.10 LevelUpUI (popup temporaire)

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                                                            │
│                    ⬆️ LEVEL UP !                          │
│                                                            │
│              Tu es maintenant                              │
│           🌟 ORPAILLEUR (Nv.2) 🌟                        │
│                                                            │
│          Nouvelle zone débloquée :                         │
│          🏔️ Collines Ambrées !                            │
│                                                            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### F.11 DialogueUI (PNJ tutoriel/conversations)

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                     (zone de jeu)                          │
│                                                            │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │  👤 Tom le Guide                                    │   │
│  │                                                     │   │
│  │  "Bienvenue, nouveau ! Je vais t'apprendre à       │   │
│  │   chercher de l'or. Approche-toi de la rivière !"  │   │
│  │                                                     │   │
│  │                               [Continuer →]        │   │
│  └────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘
```

---

## G. Prompts Claude Code / MCP — Guide d'Implémentation Étape par Étape

> **IMPORTANT** : Ces prompts sont conçus pour être copiés-collés dans Claude Code avec le MCP Roblox Studio. Chaque prompt est autonome et peut être exécuté dans l'ordre. Commence par le Prompt 1 et avance séquentiellement.

### Prompt 1 — Setup du projet et structure

```
Tu travailles sur un jeu Roblox appelé "Gold Rush Legacy" — un mining tycoon dans le Far West.

ÉTAPE 1 : Crée la structure de dossiers suivante dans le jeu Roblox Studio :

Workspace > Map :
- HubCentral (Folder) avec sous-dossiers : Buildings, Spawns, Decorations
- Dans Buildings : Marchand (Folder), Negociant (Folder), MagasinOutils (Folder), Saloon (Folder), Forge (Folder), Leaderboard (Folder)
- Zone1_RiviereTransquille (Folder) avec : Terrain, WaterArea, GoldSpawnPoints (Folder avec 8 Parts nommées SpawnPoint_01 à SpawnPoint_08), BateeStations (Folder avec 3 Parts BateeSpot_01 à 03), ZoneTrigger (Part invisible CanCollide=false)
- Zone2_CollinesAmbrees (Folder) avec : Terrain, GoldSpawnPoints (8 Parts), FilonSpots (3 Parts Filon_01 à 03), DetecteurZones (2 Parts invisibles), ZoneTrigger
- Zone3_MineCrowCreek (Folder) avec : Entrance, MineInterior (Folder avec Tunnels, Rails, OreNodes Folder avec 6 Parts OreNode_01 à 06, GemSpawnPoints Folder avec 4 Parts), BossArena (Folder avec BossSpawnPoint Part, ArenaTrigger Part invisible, ArenaDoor Part)

Workspace > ActiveGoldDeposits (Folder vide — les gisements seront spawnés dynamiquement)

ServerScriptService > Core (Folder), Systems (Folder), Lib (Folder)
ServerStorage > Templates (Folder), ItemModels (Folder)
ReplicatedStorage > Modules > Config (Folder), Shared (Folder)
ReplicatedStorage > Events > RemoteEvents (Folder), RemoteFunctions (Folder)
ReplicatedStorage > Assets > UI (Folder)

La ville (HubCentral) est AU CENTRE de la map. Les 3 zones rayonnent autour comme des quartiers.
Zone 1 : au nord-est (rivière)
Zone 2 : au sud-est (collines)  
Zone 3 : à l'ouest (entrée de mine)

Pour chaque PNJ (Marchand, Negociant, Vendeur dans MagasinOutils, Forgeron dans Forge, Barman dans Saloon, Guide dans Zone1), crée un Model simple (bloc humanoïde) avec un ProximityPrompt enfant.

Chaque zone doit avoir un SpawnLocation pour que les joueurs puissent s'y téléporter (ou marcher).
```

### Prompt 2 — Configs et modules partagés

```
Crée les ModuleScripts de configuration dans ReplicatedStorage.Modules.Config.

Fichier 1 : GameConfig.lua
- Contient les constantes globales du jeu
- Section Saloon : MaxDrinksPerDay=3, boissons (Whiskey +20% vitesse 5min à 15$, Bière +15% chance 5min à 20$), cycle jour/nuit (12 min cycle, 60% jour, 40% nuit, -20% prix nuit)
- Section Boss GardienMine : 500 HP, 15 dmg, attaque toutes les 2s, aggro 30 studs, 2 attaques (Coup 15dmg range 5, Éboulement 25dmg range 15 cooldown 10), rewards (200$ + 200XP + drops)

Fichier 2 : EconomyConfig.lua
- Prix de vente : Marchand Local (Paillettes 2$, OrPur 10$, Lingots 50$, Pepites 15$, MineraiOr 5$, Quartz 8$, Amethyste 25$, Topaze 40$)
- Négociant : +30% mais seulement OrPur, Lingots, Amethyste, Topaze
- XP : MinePaillette 5, MinePepite 15, MineMineraiOr 20, MineGem 25, CraftOrPur 10, CraftLingot 30, SellTransaction 5, QuestComplete 50, BossDefeat 200
- Levels : Amateur 0-499, Orpailleur 500-1999, Prospecteur 2000+
- Drop rates par zone (voir la spec technique complète pour les valeurs exactes)
- Tool bonuses par niveau (qty multiplier 1.0/1.5/2.0, speed 1.0/0.8/0.6)
- Respawn timers (30s zone1, 45s zone2 detect, 90s filon, 60s zone3, 120s gem, 300s boss)

Fichier 3 : ToolConfig.lua
- 3 outils : Batée (gratuite, upgrade 150$/500$), Tapis (achat 100$, upgrade 300$/800$), Pioche (achat 200$, upgrade 600$/1500$)
- Chaque outil a DisplayName, Description, zones autorisées, temps d'action de base

Fichier 4 : NPCConfig.lua
- 6 PNJ avec DisplayName, dialogues, type (Buyer/ShopKeeper/Crafter/Saloon/Tutor), ProximityPrompt settings

Fichier 5 : QuestConfig.lua
- Pool de 7 quêtes quotidiennes (3 attribuées par jour, filtrées par niveau)
- Types : Collect, Sell, Craft, Earn
- Reset à 00:00 UTC

Fichier 6 : CraftConfig.lua
- 3 recettes : 5 Paillettes → 1 OrPur, 3 OrPur + 2 MineraiOr → 1 Lingot, 2 Pepites → 1 OrPur

Fichier 7 : GemConfig.lua
- 3 gemmes : Quartz (blanc, commun), Amethyste (violet, uncommon), Topaze (doré, rare)

Fichier 8 : ZoneConfig.lua
- 3 zones avec nom, niveau requis, outils autorisés, max gisements, intervalle spawn
```

### Prompt 3 — DataManager (ProfileStore)

```
Crée le DataManager dans ServerScriptService.Core.DataManager.

Il utilise ProfileStore (ajoute le module ProfileStore dans ServerScriptService.Lib).

Structure PlayerData complète :
- Version, FirstJoin, LastLogin, TotalPlayTime
- Cash (défaut 50$), TotalCashEarned, XP (0), Level (1)
- Inventory : Paillettes, OrPur, Lingots, Pepites, MineraiOr, Quartz, Amethyste, Topaze (tous à 0)
- Tools : Batee (Owned=true, Level=1), Tapis/Pioche (Owned=false, Level=0)
- Quests : DailyReset, Active table, Completed table
- Zones : Zone1 true, Zone2/3 false
- Saloon : LastDrinkTime, DrinksToday, BuffActive, BuffExpiry
- Boss : GardienDefeated, LastBossAttempt
- Tutorial : Completed false, Step 1

DataStore name : "GoldRush_PlayerData_V1"

Fonctions nécessaires :
- Init(), LoadProfile(player), GetProfile(player), GetData(player)
- SaveAndReleaseProfile(player), SaveAllProfiles()
- AddToInventory(player, item, qty), RemoveFromInventory(player, item, qty)
- AddCash(player, amount), RemoveCash(player, amount)
- AddXP(player, amount) — avec vérification automatique de level up, déblocage de zones, notification client via LevelUp RemoteEvent

Utilise Reconcile() pour la migration de schéma.
Bind to game:BindToClose pour sauvegarde d'urgence.
```

### Prompt 4 — GameManager + Events Setup

```
Crée deux scripts :

1. EventSetup (ServerScript dans ServerScriptService.Core) :
Crée TOUS les RemoteEvents et RemoteFunctions au démarrage du serveur :
RemoteEvents : InitPlayerData, PlayerDataUpdated, RequestMine, MineResult, StartBateeMinigame, BateeMinigameResult, RequestSell, SellResult, RequestBuyTool, RequestUpgradeTool, ShopResult, RequestCraft, CraftResult, RequestClaimQuest, QuestsUpdated, QuestProgressUpdated, QuestRewardClaimed, RequestBuyDrink, SaloonResult, BuffExpired, TimeOfDayChanged, StartTutorial, TutorialStepComplete, RequestAttackBoss, BossAttackResult, BossSpawned, BossHealthUpdated, BossAttacked, BossDefeated, BossDespawned, LevelUp
RemoteFunctions : GetPlayerData, GetCraftRecipes, GetActiveQuests, GetLeaderboard, GetSaloonMenu, GetShopItems

2. GameManager (ServerScript dans ServerScriptService.Core) :
- Initialise TOUS les managers dans l'ordre : DataManager, EconomyManager, GoldSpawner, MiningSystem, CraftManager, QuestManager, BossManager, SaloonManager, LeaderboardManager
- PlayerAdded : charge profil, met à jour login, check daily quest reset, équipe les outils, envoie InitPlayerData au client, démarre tuto si pas complété
- PlayerRemoving : sauve et relâche le profil
- Cycle jour/nuit : Heartbeat qui alterne Day/Night toutes les 12 min (60% jour, 40% nuit), fire TimeOfDayChanged à tous les clients
- game:BindToClose pour sauvegarde d'urgence
```

### Prompt 5 — Mining System (Serveur + Client)

```
Implémente le système de minage :

SERVEUR (ServerScriptService.Systems.MiningSystem) :
- Écoute RequestMine : valide (cooldown 1s anti-spam, distance max 15 studs, niveau zone, outil requis)
- Si Zone 1 : marque le gisement inactif et fire StartBateeMinigame au client
- Si Zone 2/3 : ProcessMining direct avec score 1.0
- Écoute BateeMinigameResult : valide score (clamp 0-1), appelle ProcessMining
- ProcessMining : calcule drops selon DropRates de la zone, applique multiplicateur outil (QuantityMultiplier), applique buff Saloon si actif, applique score mini-jeu (min 30%), si aucun drop → donne 1 paillette, notifie QuestManager, fire MineResult au client, détruit le gisement

CLIENT (StarterPlayerScripts.Core.MiningClient) :
- Écoute les ProximityPrompt sur ActiveGoldDeposits (DescendantAdded pour les nouveaux)
- Sur Triggered : fire RequestMine au serveur
- Écoute MineResult : si succès, affiche texte flottant doré (+N Item), particules, son ; si échec, notification d'erreur

SERVEUR (ServerScriptService.Systems.GoldSpawner) :
- Init : démarre une boucle par zone
- Chaque boucle : vérifie le nombre de gisements actifs, si < max, spawn sur un point libre
- SpawnDeposit : clone un template (Paillette/Pepite/Filon/Gem selon zone et RNG), positionne, ajoute ProximityPrompt
- DestroyDeposit : supprime l'instance et libère le point de spawn

CLIENT (StarterPlayerScripts.Systems.BateeMinigame) :
- Mini-jeu : cercle avec aiguille rotative (200°/sec), zone verte aléatoire (60° de large)
- Le joueur appuie sur Espace au bon moment
- Scoring : dans le centre 30% → 1.0 (parfait), dans la zone → 0.7, proche → 0.4, loin → 0.1
- Envoie BateeMinigameResult au serveur
```

### Prompt 6 — Économie (Vente + Magasin)

```
Implémente le système économique :

SERVEUR (ServerScriptService.Core.EconomyManager) :
- HandleSell : valide quantité, vérifie que le PNJ accepte l'item, vérifie inventaire, calcule total, RemoveFromInventory + AddCash + AddXP, notifie QuestManager, fire SellResult, update leaderboard
- HandleBuyTool : vérifie pas déjà possédé, vérifie cash, RemoveCash, donne l'outil (data + physique via MiningSystem:GiveTool)
- HandleUpgradeTool : vérifie possédé, vérifie level max pas atteint, vérifie cash, upgrade level dans data

CLIENT — ShopUI (StarterGui.ShopUI) :
- Liste les 3 outils avec état (Acheter / Améliorer Nv.X / Max)
- Boutons Acheter et Améliorer qui fire RequestBuyTool ou RequestUpgradeTool
- Écoute ShopResult pour feedback
- Bouton X pour fermer

CLIENT — SellUI (StarterGui.SellUI) :
- Affiche les items vendables selon le type de PNJ (SellUI:SetAttribute("NPCType"))
- Slider ou +/- pour la quantité
- Affiche le prix unitaire et le total
- Bouton VENDRE par item et TOUT VENDRE
- Écoute SellResult pour feedback
```

### Prompt 7 — Craft + Quêtes + Saloon

```
Implémente 3 systèmes :

1. CRAFT (ServerScriptService.Systems.CraftManager) :
- HandleCraft : valide recipeId et quantity, vérifie niveau, vérifie matériaux (pour qty demandée), consomme inputs, produit output, AddXP, notifie QuestManager, fire CraftResult
- GetCraftRecipes (RemoteFunction) : retourne les recettes avec CanCraft et MaxCraftable

CLIENT CraftUI :
- Liste les recettes avec inputs nécessaires, quantité possédée, slider quantité, bouton FORGER
- Griser les recettes non disponibles (niveau ou matériaux)

2. QUÊTES (ServerScriptService.Systems.QuestManager) :
- CheckDailyReset : compare DailyReset au 00:00 UTC du jour, reset si nécessaire
- AssignDailyQuests : filtre par niveau, sélectionne 3 aléatoires sans doublon
- Callbacks : OnItemCollected, OnSellTransaction, OnItemCrafted — mettent à jour la progression
- HandleClaimQuest : vérifie completed + pas claimed, donne rewards, fire QuestRewardClaimed

CLIENT QuestUI :
- Liste les quêtes actives avec barre de progression, état, bouton RÉCLAMER si complétée
- Quest tracker dans le MainHUD (mini version avec progression)

3. SALOON (ServerScriptService.Systems.SaloonManager) :
- HandleBuyDrink : vérifie max verres/jour (reset si nouveau jour), vérifie pas de buff actif, calcule prix (discount nuit), vérifie cash, applique buff (dans PlayerData.Saloon), programme expiration via task.delay
- GetSaloonMenu (RemoteFunction) : retourne les boissons avec prix actuels et disponibilité
- OnTimeOfDayChanged : mémorise le time pour les prix

CLIENT SaloonUI :
- Liste les boissons avec description, prix (barré si nuit), bouton COMMANDER
- Affiche verres restants
```

### Prompt 8 — Boss + Leaderboard + Tutoriel

```
Implémente 3 systèmes :

1. BOSS (ServerScriptService.Systems.BossManager) :
- Détection d'entrée dans l'arène (ArenaTrigger.Touched)
- SpawnBoss : clone template, positionne, init HP, ferme la porte, notifie les clients (BossSpawned)
- BossAITick (boucle 0.5s) : trouve joueur le plus proche, se déplace vers lui, attaque si à portée (Coup de Pioche), cooldown
- HandlePlayerAttack : vérifie dans l'arène + distance + possède pioche, dégâts = 10 * pickLevel, update HP, fire BossHealthUpdated
- OnBossDefeated : distribue rewards à tous les damage dealers, ouvre la porte, despawn, fire BossDefeated
- Si tous quittent l'arène → despawn et reset

CLIENT BossUI :
- Apparaît quand BossSpawned reçu
- Affiche barre de HP du boss
- Bouton/touche ATTAQUER (E)
- Messages d'attaque du boss

2. LEADERBOARD (ServerScriptService.Systems.LeaderboardManager) :
- Utilise OrderedDataStore pour Cash et XP
- RefreshLeaderboards toutes les 30s : GetSortedAsync top 10
- UpdatePlayer : SetAsync à chaque vente
- Affichage physique : met à jour un SurfaceGui dans le hub
- GetLeaderboard (RemoteFunction) pour le client

3. TUTORIEL :
- Géré par GameManager qui fire StartTutorial si Tutorial.Completed == false
- 6 étapes : 1) Guide parle, 2) Aller à la rivière, 3) Miner (batée), 4) Mini-jeu, 5) Résultat, 6) Direction forge/marchand
- Le client avance les étapes (TutorialStepComplete)
- Le serveur valide et marque Completed quand step > 6
- Utilise le DialogueUI pour les dialogues du Guide
```

### Prompt 9 — UI Manager + MainHUD

```
Implémente le UIManager et le HUD principal :

MODULE (StarterPlayerScripts.Core.UIManager) :
- Init : récupère les références UI, écoute InitPlayerData, PlayerDataUpdated, LevelUp, TimeOfDayChanged, BuffExpired
- RefreshHUD : met à jour Cash display, XP bar (fill ratio), level text
- ShowFloatingText : BillboardGui temporaire qui monte et disparaît (1.5s)
- ShowNotification : frame temporaire en haut (Success vert, Error rouge, Info bleu, Warning jaune), disparaît en 3s
- ShowZoneTitle : grand texte doré centré, fade in/out (3.5s total)
- ShowLevelUpScreen : active LevelUpUI 4 secondes
- OnTimeOfDayChanged : tweene le Lighting (ClockTime, Brightness, Ambient) sur 5 secondes
- PlayMineEffect : ParticleEmitter dorées pendant 0.3s
- PlaySound : joue un son depuis un dictionnaire d'IDs

MAINHUD (StarterGui.MainHUD — ScreenGui toujours visible) :
- En haut à gauche : CashDisplay (icône $ + montant)
- En haut centre : indicateur jour/nuit (☀️/🌙)
- En haut à droite : bouton Quêtes
- Sous le cash : barre XP avec texte (340/500 XP) et level (Nv.1 Amateur)
- En bas à gauche : mini quest tracker (2-3 quêtes avec barre progression)
- En bas à droite : boutons Inventaire et Paramètres

CLIENT InteractionClient :
- Setup des ProximityPrompts pour chaque PNJ (Marchand→SellUI, Negociant→SellUI, Vendeur→ShopUI, Forgeron→CraftUI, Barman→SaloonUI, Guide→DialogueUI)
- Détection des ZoneTrigger pour afficher le nom de zone
```

### Prompt 10 — Détecteur Zone 2 + Polish

```
Dernière étape — finitions :

1. DÉTECTEUR (StarterPlayerScripts.Systems.DetecteurSystem) :
- Actif seulement en Zone 2 (détecté via ZoneTrigger)
- Heartbeat : trouve le gisement Zone2 le plus proche
- Si < 50 studs : joue un beep dont la fréquence augmente en approchant (2s loin → 0.2s proche)
- Volume proportionnel à la proximité

2. TOUS LES SCREENUI dans StarterGui :
- Tous commencent Enabled=false
- Tous ont un bouton [X] en haut à droite pour fermer (Enabled=false)
- Style western/bois/sépia cohérent :
  * Background : brun foncé (RGB 62,39,35) avec 0.1 transparence
  * Texte : doré (RGB 255,215,0) ou crème (RGB 255,248,220)
  * Boutons : fond brun clair (RGB 139,90,43), hover plus clair
  * Bordures : UIStroke brun (RGB 101,67,33)
  * Coins arrondis : UICorner 8px
  * Police : GothamBold pour les titres, Gotham pour le texte

3. SONS (à ajouter dans ReplicatedStorage.Assets) :
- MineSuccess : son de pioche/métal
- LevelUp : fanfare courte
- Purchase : son de pièces
- Error : buzz court
- BossRoar : rugissement grave (spawn boss)
- Beep : bip court (détecteur)

4. VÉRIFICATION FINALE :
- Toutes les requêtes client→serveur sont validées côté serveur
- Aucune donnée de jeu n'est trustée côté client
- Les ProximityPrompts ont tous HoldDuration > 0 (anti-spam)
- Le cycle jour/nuit fonctionne et affecte le Saloon
- Le leaderboard se met à jour
- Le tutoriel guide le nouveau joueur
```

---

## H. Anti-Exploit — Règles de Sécurité Serveur-Side

### H.1 Principes fondamentaux

```
RÈGLE D'OR : NE JAMAIS FAIRE CONFIANCE AU CLIENT.
Le client est un terminal d'affichage et d'input.
Toute logique de jeu (drops, cash, XP, inventaire) est calculée et validée sur le serveur.
```

### H.2 Validations par système

| Système | Validation | Implémentation |
|---------|-----------|----------------|
| **Minage** | Distance max | `(playerPos - depositPos).Magnitude <= 15` |
| **Minage** | Cooldown anti-spam | 1 seconde minimum entre deux `RequestMine` |
| **Minage** | Gisement existe et actif | Vérifier `IsActive` attribute + existence dans Workspace |
| **Minage** | Zone/Niveau requis | `player.Level >= zone.RequiredLevel` |
| **Minage** | Outil requis | Vérifier `Tools[toolName].Owned == true` |
| **Batée** | Score valide | `math.clamp(score, 0, 1)` — jamais au-dessus de 1.0 |
| **Vente** | Quantité valide | `qty > 0`, `qty == math.floor(qty)`, `qty <= 9999` |
| **Vente** | Inventaire suffisant | `Inventory[item] >= qty` |
| **Vente** | PNJ accepte l'item | Vérifier dans `EconomyConfig.SellPrices[npcType]` |
| **Achat** | Cash suffisant | `Cash >= price` |
| **Achat** | Pas de doublon | `Tools[name].Owned == false` avant achat |
| **Upgrade** | Pas de skip de level | `nextLevel = currentLevel + 1`, pas de saut |
| **Craft** | Matériaux suffisants | Vérifier chaque input × quantité |
| **Craft** | Quantité raisonnable | `qty <= 100` cap |
| **Quêtes** | Récompense non dupliquée | `ClaimedReward == false` avant reward |
| **Saloon** | Max verres/jour | `DrinksToday < MaxDrinksPerDay` |
| **Saloon** | Pas de buff stack | `BuffActive == nil or BuffExpiry < os.time()` |
| **Boss** | Distance d'attaque | `dist <= 10` studs |
| **Boss** | Dans l'arène | `PlayersInArena[player] == true` |
| **Boss** | Outil requis | `Tools.Pioche.Owned == true` |

### H.3 Patterns anti-exploit généraux

```lua
-- 1. JAMAIS exécuter de code client sur le serveur
-- Pas de loadstring, pas de require sur des modules non-fiables

-- 2. Rate limiting sur TOUS les RemoteEvents
local RateLimits = {}  -- { [player] = { [eventName] = lastTime } }

local function CheckRateLimit(player, eventName, minInterval)
    local now = os.clock()
    if not RateLimits[player] then RateLimits[player] = {} end
    if RateLimits[player][eventName] and
       (now - RateLimits[player][eventName]) < minInterval then
        return false  -- Trop rapide
    end
    RateLimits[player][eventName] = now
    return true
end

-- 3. Validation de type sur TOUS les arguments reçus du client
local function ValidateArgs(player, ...)
    for _, arg in ipairs({...}) do
        if arg == nil then return false end
    end
    return true
end

-- 4. Nettoyer les rate limits quand un joueur quitte
Players.PlayerRemoving:Connect(function(player)
    RateLimits[player] = nil
end)

-- 5. Logging des comportements suspects
local function LogSuspicious(player, reason)
    warn(string.format("[ANTI-EXPLOIT] %s: %s", player.Name, reason))
    -- Optionnel : stocker dans un DataStore pour review
end
```

### H.4 Sanity checks spécifiques

```lua
-- Vérifier que le Cash ne devient jamais négatif
function DataManager:RemoveCash(player, amount)
    local data = self:GetData(player)
    if not data then return false end
    if amount <= 0 then return false end           -- Pas de montant négatif/zéro
    if amount ~= math.floor(amount) then return false end  -- Entiers uniquement
    if data.Cash < amount then return false end     -- Pas de dette
    data.Cash = data.Cash - amount
    return true
end

-- Vérifier que l'inventaire ne déborde pas
local MAX_ITEM_STACK = 99999
function DataManager:AddToInventory(player, itemName, quantity)
    local data = self:GetData(player)
    if not data then return false end
    if quantity <= 0 then return false end
    local current = data.Inventory[itemName] or 0
    data.Inventory[itemName] = math.min(current + quantity, MAX_ITEM_STACK)
    return true
end
```

### H.5 Checklist de sécurité pré-publication

- [ ] Tous les `RemoteEvent.OnServerEvent` valident les arguments reçus
- [ ] Aucune valeur client n'est utilisée pour modifier Cash, XP, ou Inventory directement
- [ ] Les drops sont calculés UNIQUEMENT côté serveur
- [ ] Le score du mini-jeu batée est clampé entre 0 et 1
- [ ] Les quantités de craft/vente sont plafonnées
- [ ] Le boss ne peut être attaqué que depuis l'arène (vérification distance + état)
- [ ] Les quêtes ne peuvent pas être réclamées deux fois
- [ ] ProfileStore avec `ForceLoad` pour éviter les duplications de profil
- [ ] `game:BindToClose` sauvegarde tous les profils en urgence
- [ ] Pas de `require()` sur des ModuleScripts hors du jeu
- [ ] Pas de `loadstring()` nulle part

---

## Annexe — Résumé du Core Loop

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│ PROSPECTER   │────▶│  EXTRAIRE    │────▶│  TRAITER     │
│ (aller en   │     │  (miner avec │     │  (raffiner   │
│  zone, batée│     │   outil,     │     │   à la forge)│
│  détecteur) │     │   mini-jeu)  │     │              │
└─────────────┘     └──────────────┘     └──────┬───────┘
                                                 │
┌─────────────┐     ┌──────────────┐             │
│ RÉINVESTIR  │◀────│   VENDRE     │◀────────────┘
│ (acheter    │     │  (marchand   │
│  outils,    │     │   ou négo-   │
│  upgrades,  │     │   ciant)     │
│  saloon)    │     │              │
└─────────────┘     └──────────────┘
```

---

*Fin de la spécification technique — Gold Rush Legacy V1 Démo*
*Document autonome — Tout ce qu'il faut pour implémenter est ici.*