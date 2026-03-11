# ⛏️ Gold Rush Legacy — Spec Technique Démo V1

*Date : 10 mars 2026*
*Objectif : Première démo jouable (POC)*
*Durée estimée : 1-2 semaines*
*Référence GDD : `docs/plans/gold-rush-legacy-concept.md`*

---

## 1. SCOPE DE LA DÉMO

### Ce qu'on build (MVP)
- ✅ 1 zone jouable (Rivière Tranquille)
- ✅ 1 hub ville (simplifié — 3 bâtiments)
- ✅ Core loop fonctionnel : Prospecter → Extraire → Vendre → Acheter
- ✅ 1 outil (batée) + 1 upgrade (tapis)
- ✅ 1 PNJ acheteur (marchand local)
- ✅ Système de cash + leaderboard basique
- ✅ Sauvegarde progression (DataStore)
- ✅ Multijoueur (auto Roblox)

### Ce qu'on build PAS encore
- ❌ Guildes / trading entre joueurs
- ❌ Système de compétences
- ❌ Craft / raffinage / bijoux
- ❌ Zones 2-5
- ❌ Événements compétitifs
- ❌ Game passes / monétisation
- ❌ Voix NPC (ElevenLabs)
- ❌ Season pass

---

## 2. ARCHITECTURE TECHNIQUE

### 2.1 Structure du projet Roblox

```
game/
├── Workspace/
│   ├── Map/
│   │   ├── Town/                    -- Hub ville
│   │   │   ├── GoldBuyer            -- Bâtiment marchand
│   │   │   ├── ToolShop             -- Magasin d'outils
│   │   │   └── Leaderboard          -- Panneau classement
│   │   └── RiverZone/               -- Zone d'extraction
│   │       ├── Terrain              -- Rivière + berges
│   │       ├── GoldSpots/           -- Points d'or (spawners)
│   │       └── Decorations          -- Rochers, arbres, etc.
│   └── SpawnLocation               -- Point d'apparition
│
├── ServerScriptService/
│   ├── GameManager.lua              -- Orchestrateur principal
│   ├── GoldSpawner.lua              -- Spawn/respawn des spots d'or
│   ├── EconomyManager.lua           -- Gestion cash + transactions
│   ├── DataManager.lua              -- Sauvegarde/chargement DataStore
│   └── LeaderboardManager.lua       -- Mise à jour classements
│
├── ReplicatedStorage/
│   ├── Modules/
│   │   ├── GoldConfig.lua           -- Config : prix, drop rates, etc.
│   │   └── ToolConfig.lua           -- Config : outils, stats
│   ├── Events/
│   │   ├── MineGold                 -- RemoteEvent : joueur mine
│   │   ├── SellGold                 -- RemoteEvent : joueur vend
│   │   └── BuyTool                  -- RemoteEvent : joueur achète outil
│   └── Assets/
│       ├── Tools/                   -- Modèles 3D outils
│       └── Items/                   -- Modèles 3D or/pépites
│
├── StarterGui/
│   ├── HUD/
│   │   ├── CashDisplay.lua          -- Affichage cash
│   │   ├── InventoryDisplay.lua     -- Inventaire or
│   │   └── NotificationSystem.lua   -- Notifications
│   └── Menus/
│       ├── ShopMenu.lua             -- UI magasin outils
│       └── SellMenu.lua             -- UI vente au marchand
│
├── StarterPack/
│   └── Batea                        -- Outil de départ (batée)
│
└── StarterPlayerScripts/
    ├── MiningClient.lua             -- Logique client extraction
    └── InteractionClient.lua        -- Interactions PNJ/objets
```

### 2.2 Data Model

```lua
-- PlayerData (sauvegardé dans DataStore)
PlayerData = {
    cash = 0,                    -- Argent du joueur
    goldInventory = {
        flakes = 0,             -- Paillettes d'or
        smallNuggets = 0,       -- Petites pépites
        nuggets = 0,            -- Pépites
    },
    tools = {"batea"},           -- Outils possédés
    equippedTool = "batea",      -- Outil équipé
    totalGoldMined = 0,          -- Stats : total or miné
    totalCashEarned = 0,         -- Stats : total cash gagné
    level = 1,                   -- Niveau joueur (1-5)
    xp = 0,                      -- XP actuel
}
```

### 2.3 Config économique (à balancer en playtest)

```lua
-- GoldConfig.lua
GoldConfig = {
    -- Spots d'or dans la rivière
    spotSpawnInterval = 30,      -- Nouveau spot toutes les 30 sec
    maxSpotsPerZone = 20,        -- Max spots actifs
    spotRespawnTime = 60,        -- Respawn après minage : 60 sec

    -- Drop table (batée)
    bateaDrops = {
        {item = "flakes", chance = 0.70, amount = {1, 3}},
        {item = "smallNuggets", chance = 0.25, amount = {1, 1}},
        {item = "nuggets", chance = 0.05, amount = {1, 1}},
    },

    -- Drop table (tapis — meilleur rendement)
    tapisDrops = {
        {item = "flakes", chance = 0.50, amount = {2, 5}},
        {item = "smallNuggets", chance = 0.35, amount = {1, 2}},
        {item = "nuggets", chance = 0.15, amount = {1, 1}},
    },

    -- Prix de vente au marchand
    sellPrices = {
        flakes = 5,              -- 5$ par paillette
        smallNuggets = 25,       -- 25$ par petite pépite
        nuggets = 100,           -- 100$ par pépite
    },

    -- XP par action
    xpPerMine = 10,
    xpPerSell = 5,
    xpToLevel2 = 500,           -- XP pour passer niveau 2
}

-- ToolConfig.lua
ToolConfig = {
    batea = {
        name = "Batée",
        mineTime = 3,            -- 3 secondes pour miner
        price = 0,               -- Gratuit (outil de départ)
        level = 1,
    },
    tapis = {
        name = "Tapis d'orpaillage",
        mineTime = 2,            -- 2 secondes (plus rapide)
        price = 500,             -- 500$ au magasin
        level = 1,
        passive = true,          -- Collecte passive
        passiveInterval = 10,    -- Collecte toutes les 10 sec
    },
}
```

---

## 3. GAMEPLAY FLOW (DÉMO)

### 3.1 Onboarding (30 secondes)
1. Le joueur spawn dans la **Ville**
2. Texte tutoriel : "Bienvenue, prospecteur ! Prends ta batée et va à la rivière trouver de l'or."
3. Flèche directionnelle vers la rivière
4. Le joueur a déjà la batée dans son inventaire

### 3.2 Minage
1. Le joueur marche jusqu'à la **Rivière**
2. Des **spots dorés** brillent au sol/dans l'eau (particules lumineuses)
3. Le joueur s'approche d'un spot → prompt : "Appuie sur E pour orpailler"
4. **Animation** : le personnage se penche, utilise la batée (3 sec)
5. **Drop** : notification "Tu as trouvé 2 paillettes d'or !" (avec son satisfaisant)
6. L'or va dans l'inventaire
7. Le spot disparaît et respawn ailleurs après 60 sec

### 3.3 Vente
1. Le joueur retourne en ville au **Bureau d'achat d'or**
2. Interaction avec le PNJ marchand → UI s'ouvre
3. Affiche l'inventaire : "Paillettes x12 | Pépites x1"
4. Bouton "Vendre tout" → cash affiché avec animation
5. Notification : "+185$ !"

### 3.4 Upgrade
1. Le joueur va au **Magasin d'outils**
2. Interaction → UI avec les outils disponibles
3. "Tapis d'orpaillage — 500$" → Bouton acheter
4. Quand acheté : nouvel outil dans l'inventaire, meilleur rendement

### 3.5 Loop
→ Retour à la rivière avec le meilleur outil → plus de rendement → plus de cash → save & continue

---

## 4. ASSETS NÉCESSAIRES (DÉMO)

### 4.1 Modèles 3D (Meshy.ai)

| Asset | Description | Priorité |
|-------|-------------|----------|
| Batée | Outil d'orpaillage en métal/bois | 🔴 Critique |
| Tapis d'orpaillage | Tapis posable au sol | 🔴 Critique |
| PNJ Marchand | Personnage western, barbe, chapeau | 🔴 Critique |
| PNJ Vendeur outils | Personnage forgeron | 🟡 Haute |
| Pépite d'or (petite) | Item collectible brillant | 🔴 Critique |
| Pépite d'or (grosse) | Item rare, plus imposant | 🟡 Haute |
| Lingot d'or | Pour l'UI et futur craft | 🟢 Basse |
| Bâtiment : Bureau d'achat | Petite cabane western | 🔴 Critique |
| Bâtiment : Magasin outils | Forge/atelier | 🔴 Critique |
| Bâtiment : Taverne | Pour le futur social hub | 🟢 Basse |

### 4.2 Terrain (Roblox Studio)

- **Rivière** : Terrain Roblox natif (eau + berges + rochers)
- **Forêt** : Arbres du Creator Marketplace (gratuit)
- **Ville** : 3 bâtiments simples + chemin de terre
- **Éclairage** : Golden hour permanent (warm, doré)

### 4.3 UI (StarterGui)

| Écran | Éléments |
|-------|----------|
| **HUD** | Cash (coin d'écran), inventaire mini, XP bar |
| **Menu Vente** | Liste items + quantités + prix + bouton vendre |
| **Menu Achat** | Liste outils + prix + bouton acheter |
| **Notifications** | Pop-up central "Tu as trouvé X !" |
| **Leaderboard** | Top joueurs du serveur (cash total) |

### 4.4 Sons & Effets

| Son | Quand |
|-----|-------|
| Splash eau | Utilisation batée |
| Clink métallique | Trouver de l'or |
| Cha-ching | Vendre de l'or |
| Ambiance nature | Loop rivière (oiseaux, eau) |
| Ambiance ville | Loop ville (bruit de fond) |

---

## 5. SCRIPTS PRINCIPAUX (PSEUDO-CODE)

### 5.1 GoldSpawner (Server)

```lua
-- Spawn des spots d'or dans la zone rivière
-- Chaque spot est un Part avec des particules dorées
-- Quand miné : disparaît, respawn après cooldown
-- Max spots simultanés : 20
-- Position aléatoire dans la zone définie
```

### 5.2 MiningClient (Client)

```lua
-- Détecte proximité avec un spot d'or
-- Affiche prompt "E pour orpailler"
-- Au clic : joue animation + timer (3s batée / 2s tapis)
-- Envoie RemoteEvent "MineGold" au server
-- Server calcule le drop (RNG) et met à jour l'inventaire
-- Client reçoit la notification du drop
```

### 5.3 EconomyManager (Server)

```lua
-- Gère le cash de chaque joueur
-- Reçoit "SellGold" : calcule le total, déduit l'inventaire, ajoute le cash
-- Reçoit "BuyTool" : vérifie le cash, déduit, ajoute l'outil
-- Anti-exploit : toute transaction validée côté serveur
```

### 5.4 DataManager (Server)

```lua
-- Sauvegarde dans Roblox DataStore
-- Auto-save toutes les 60 secondes
-- Save on player leave
-- Charge les données au join
-- Gère les erreurs (retry, fallback)
```

---

## 6. PROMPT CLAUDE CODE (copier-coller)

```
Tu es un développeur Roblox expert en Luau. Tu as accès à Roblox Studio via le MCP Server.

OBJECTIF : Créer la démo jouable de "Gold Rush Legacy" — un jeu d'orpaillage/tycoon.

CONTEXTE : Le joueur commence avec une batée au bord d'une rivière, cherche de l'or, le vend en ville, et achète de meilleurs outils. C'est la version MVP/démo.

ÉTAPE 1 — MAP
- Crée un terrain avec une rivière (eau + berges + rochers)
- Ajoute une forêt autour (arbres du Toolbox)
- Crée une petite ville à côté : 3 bâtiments simples en bois (style western)
- Éclairage warm/doré (golden hour)
- Place le SpawnLocation dans la ville

ÉTAPE 2 — SPOTS D'OR
- Dans la zone rivière, crée un système de spawner
- Les spots sont des Parts avec des ParticleEmitter dorés
- 20 spots max, spawn toutes les 30 sec, respawn 60 sec après minage
- Placement aléatoire dans la zone rivière

ÉTAPE 3 — SYSTÈME DE MINAGE
- Quand le joueur s'approche d'un spot (< 8 studs) : affiche ProximityPrompt "Orpailler"
- Au clic : animation de minage (3 sec), puis calcul du drop :
  - 70% chance : 1-3 paillettes (valeur 5$ chacune)
  - 25% chance : 1 petite pépite (valeur 25$)
  - 5% chance : 1 pépite (valeur 100$)
- Notification à l'écran du drop
- Le spot disparaît après minage

ÉTAPE 4 — INVENTAIRE & CASH
- Chaque joueur a : cash (nombre), et un inventaire {flakes, smallNuggets, nuggets}
- Affiche le cash en haut à droite de l'écran
- Affiche l'inventaire en bas à gauche

ÉTAPE 5 — PNJ MARCHAND
- Place un PNJ devant le Bureau d'achat (personnage avec dialogue)
- ProximityPrompt "Vendre de l'or"
- Ouvre un menu UI : liste les items, les quantités, le prix total
- Bouton "Vendre tout" : cash += total, inventaire vidé
- Son cha-ching + notification du gain

ÉTAPE 6 — MAGASIN D'OUTILS
- PNJ vendeur devant le magasin
- ProximityPrompt "Acheter des outils"
- Menu UI : "Tapis d'orpaillage — 500$"
- Si assez de cash : achat, le tapis remplace la batée (mine time 2s au lieu de 3s, meilleurs drops)

ÉTAPE 7 — LEADERBOARD
- Leaderboard Roblox standard en haut à droite
- Colonnes : Cash, Or Total Miné

ÉTAPE 8 — SAUVEGARDE
- DataStore : sauvegarde cash, inventaire, outils, stats
- Auto-save toutes les 60 sec + save on leave
- Load on join

Fais tout étape par étape. Teste chaque étape avant de passer à la suivante. Toute la logique économique doit être côté serveur (anti-exploit).
```

---

## 7. CRITÈRES DE VALIDATION (Démo OK quand...)

- [ ] Le joueur peut se balader dans la map (rivière + ville)
- [ ] Les spots d'or apparaissent et brillent dans la rivière
- [ ] Le joueur peut miner un spot et recevoir de l'or
- [ ] Le joueur peut vendre son or au marchand PNJ
- [ ] Le joueur peut acheter le tapis d'orpaillage
- [ ] Le tapis a un meilleur rendement que la batée
- [ ] Le cash et l'inventaire se sauvegardent entre les sessions
- [ ] Le leaderboard fonctionne en multi
- [ ] Ça tourne bien sur mobile
- [ ] 2+ joueurs peuvent jouer en même temps sans bug

---

*Ce document est le brief technique pour la V1 de la démo. Une fois validé par playtest, on itère vers les features suivantes : raffinage, artisanat, zones supplémentaires, trading, guildes.*
