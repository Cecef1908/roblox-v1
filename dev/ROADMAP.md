# Gold Rush Legacy — Roadmap de Developpement

> **Date** : 14 mars 2026
> **Deadline Incubator** : 6 avril 2026 (~3 semaines)
> **Methode** : Baby steps, test-first, placeholders uniquement
> **Regle d'or** : Chaque sprint se termine par un playtest valide

---

## ETAT DES LIEUX — Ce qui est DEJA fait

### Systemes Serveur (ServerScriptService/)
| Systeme | Fichier | Statut | Lignes |
|---------|---------|--------|--------|
| GameManager | Core/GameManager.server.lua | COMPLET | ~200 |
| DataManager | Core/DataManager.lua | COMPLET (ProfileStore) | ~300 |
| EconomyManager | Core/EconomyManager.lua | COMPLET (sell/buy/upgrade) | ~250 |
| MapBuilder | Systems/MapBuilder.lua | COMPLET (world gen, NPCs, templates) | ~1500 |
| MiningSystem | Systems/MiningSystem.lua | COMPLET (anti-exploit, drops, tools) | ~350 |
| GoldSpawner | Systems/GoldSpawner.lua | COMPLET (spawn/respawn 3 zones) | ~200 |
| QuestManager | Systems/QuestManager.lua | COMPLET (daily quests, tracking) | ~250 |
| CraftManager | Systems/CraftManager.lua | COMPLET (3 recettes) | ~150 |
| SaloonManager | Systems/SaloonManager.lua | COMPLET (drinks, buffs, night discount) | ~150 |
| LeaderboardManager | Systems/LeaderboardManager.lua | COMPLET (native leaderstats) | ~100 |
| **BossManager** | Systems/BossManager.lua | **STUB** | 3 |

### Systemes Client (StarterPlayerScripts/)
| Systeme | Fichier | Statut | Lignes |
|---------|---------|--------|--------|
| InteractionClient | Core/InteractionClient.client.lua | COMPLET (5 NPCs, shop, sell, craft, saloon, quests) | ~1040 |
| MiningClient | Core/MiningClient.client.lua | COMPLET (mine, animation, VFX) | ~305 |
| UIManager | Core/UIManager.lua | COMPLET (HUD, inventory, notifications, level-up) | ~1200 |
| BateeMinigame | Systems/BateeMinigame.client.lua | COMPLET (timing minigame) | ~380 |
| DayNightClient | Systems/DayNightClient.client.lua | COMPLET (visual cycle) | ~115 |
| **DetecteurSystem** | Systems/DetecteurSystem.client.lua | **STUB** | 3 |
| ClientUtils | Lib/ClientUtils.lua | VIDE | 2 |

### Configs (ReplicatedStorage/Modules/Config/)
Tous les 8 fichiers sont COMPLETS : GameConfig, ToolConfig, EconomyConfig, ZoneConfig, GemConfig, NPCConfig, QuestConfig, CraftConfig

### RemoteEvents (17 crees par MapBuilder)
Mining (4), PlayerData (2), Notifications (2), Time (1), Tutorial (1), Economy (5), Craft (2), Saloon (2), Quests (3) — TOUS crees

### Packages (Wally)
- Matter 0.8.5 (ECS) — installe, pas utilise activement
- ProfileStore 1.0.3 — utilise par DataManager
- SimplePath 2.2.6 — installe, pas utilise activement

---

## CE QUI RESTE A FAIRE

### Critiques (sans ca le jeu ne fonctionne pas)
1. **Valider le core loop en playtest** — jamais teste end-to-end
2. **Fixer les bugs** — inevitablement des erreurs
3. **Activer le Day/Night cycle** — code present mais disabled

### Importants (enrichissent le jeu)
4. **BossManager** — le boss de Zone 3 (Gardien de la Mine)
5. **Tutoriel** — guider le nouveau joueur
6. **DetecteurSystem** — feedback visuel Zone 2

### Polish (necessaires pour submission)
7. **Sons & musique** — ambiance western
8. **VFX supplementaires** — particules, effets
9. **Map polish** — details, decorations, eclairage
10. **Balancing** — ajuster drops, prix, XP
11. **Screenshots & video** — pour soumission Incubator

---

## ROADMAP — 20 Sprints en 3 semaines

### PHASE 1 — VALIDATION (Sprints 1-5) — Jours 1-3

> Objectif : Le core loop fonctionne de A a Z sans erreur

#### Sprint 1 : Smoke Test Initial
**Duree** : ~45 min
- [ ] Lancer `rojo serve` + verifier sync
- [ ] Executer MapBuilder:Init() en edit mode → voir la map dans le viewport
- [ ] Screenshot de la map generee
- [ ] Lancer un playtest
- [ ] Lire get_playtest_output — collecter TOUTES les erreurs
- [ ] Lister tous les problemes trouves
**Validation** : Map visible, pas de crash au lancement

#### Sprint 2 : Fix Erreurs de Boot + Quick Fixes
**Duree** : ~60 min
- [ ] Fixer chaque erreur listee au Sprint 1
- [ ] **FIX CRITIQUE** : Supprimer le manual auto-save loop dans DataManager.lua (lignes 92-105) — bypass ProfileStore session locking, risque corruption data
- [ ] Verifier que BateeMinigameResult valide qu'un minigame a bien ete demarre (anti-exploit)
- [ ] Re-playtest apres chaque fix
- [ ] Verifier dans la console :
  - "DataManager initialized"
  - "MapBuilder:Init() completed"
  - "GoldSpawner ready"
  - "MiningSystem ready"
  - Aucune erreur rouge
**Validation** : Boot clean, 0 erreurs dans la console

#### Sprint 3 : Test Core Loop — Mining
**Duree** : ~45 min
- [ ] Aller en Zone 1 (Riviere Tranquille)
- [ ] Verifier que les gold deposits apparaissent (ProximityPrompt visible)
- [ ] Miner un deposit → verifier MineResult dans la console
- [ ] Verifier que le BateeMinigame se lance
- [ ] Jouer le minigame → verifier le score → verifier les drops
- [ ] Verifier le HUD : cash, XP, inventaire mis a jour
- [ ] Verifier qu'un nouveau deposit respawn apres destruction
**Validation** : Mining loop complete, drops dans l'inventaire, HUD a jour

#### Sprint 4 : Test Core Loop — Economy
**Duree** : ~45 min
- [ ] Approcher Marcel le Marchand → ProximityPrompt → ouvrir panneau vente
- [ ] Vendre des paillettes → verifier cash augmente
- [ ] Approcher Jacques l'Outilleur → ouvrir panneau shop
- [ ] Acheter le Tapis (si assez de cash) → verifier outil dans backpack
- [ ] Approcher Gustave le Forgeron → ouvrir panneau craft
- [ ] Crafter OrPur (5 paillettes → 1 OrPur) → verifier inventaire
- [ ] Verifier le leaderboard (leaderstats)
**Validation** : Vente, achat, craft fonctionnent. Argent correct.

#### Sprint 5 : Test Persistence + Quests + Saloon
**Duree** : ~45 min
- [ ] Miner + vendre → accumuler XP → verifier level up
- [ ] Si level 2 : verifier Zone 2 accessible
- [ ] Tester les quetes : RequestQuestData → verifier 3 quetes assignees
- [ ] Miner pour progresser une quete → verifier progression
- [ ] Tester le Saloon : acheter un whiskey → verifier buff actif
- [ ] Stop playtest → re-lancer → verifier donnees sauvegardees (cash, level, inventory)
- [ ] Verifier daily quest reset logic
**Validation** : Progression, quetes, saloon, persistence OK

---

### PHASE 2 — COMPLETUDE (Sprints 6-11) — Jours 4-8

> Objectif : Toutes les features fonctionnent

#### Sprint 6 : Activer Day/Night Cycle
**Duree** : ~30 min
- [ ] Decomenter/activer le day/night dans GameManager.server.lua (ligne ~70)
- [ ] Verifier que TimeOfDayChanged event est fire
- [ ] Verifier le DayNightClient recoit et applique les changements
- [ ] Verifier les lumieres s'allument/eteignent
- [ ] Verifier le SaloonManager applique le rabais de nuit
- [ ] Ajuster la vitesse du cycle si necessaire (GameConfig.DayNight.CycleDuration)
**Validation** : Cycle jour/nuit visible, transitions smooth

#### Sprint 7 : BossManager — Spawn & AI de base
**Duree** : ~90 min
- [ ] Ecrire BossManager.lua complet :
  - Init() : trouver la BossArena dans Zone 3
  - SpawnBoss() : creer le modele Humanoid (placeholder R6/R15)
  - BossAI() : loop — chercher joueur proche, MoveTo, attaque basique
  - TakeDamage() : reduire HP, fire BossHealthUpdated
  - OnBossDefeated() : rewards (cash + XP + drops), destroy boss
  - Respawn timer (300s)
- [ ] Config deja dans GameConfig.Boss (HP 500, Damage 15, etc.)
- [ ] Creer RemoteEvents manquants : RequestAttackBoss, BossSpawned, BossHealthUpdated, BossDefeated
**Validation** : Boss spawn en Zone 3, attaque, peut etre tue

#### Sprint 8 : BossManager — Client UI
**Duree** : ~60 min
- [ ] Ajouter dans UIManager ou creer BossUI :
  - Barre de vie du boss (visible quand en Zone 3)
  - Indicateur de degats recus
  - Notification de victoire + rewards
- [ ] Ajouter le bouton/mecanisme d'attaque (click sur boss ou ProximityPrompt)
- [ ] Ecouter les events : BossSpawned, BossHealthUpdated, BossDefeated
**Validation** : Combat boss jouable de bout en bout, UI feedback

#### Sprint 9 : Tutoriel Nouveau Joueur
**Duree** : ~60 min
- [ ] Implementer le tutoriel (5-6 etapes) :
  - Step 1 : "Bienvenue a Dusthaven !" — message d'intro
  - Step 2 : "Va voir Tom le Guide pres de la riviere" — fleche/highlight
  - Step 3 : "Mine ton premier gisement" — highlight spot dore
  - Step 4 : "Bravo ! Retourne au village vendre ton or" — highlight marchand
  - Step 5 : "Achete de meilleurs outils chez l'Outilleur" — highlight shop
  - Step 6 : "Tu es pret ! Explore les zones et deviens riche !"
- [ ] Marquer Tutorial.Completed = true dans PlayerData
- [ ] Ne pas re-montrer si deja complete (check au join)
**Validation** : Nouveau joueur guide, pas de confusion

#### Sprint 10 : DetecteurSystem (Zone 2 Feedback)
**Duree** : ~45 min
- [ ] Implementer un systeme de "radar" simple pour Zone 2 :
  - Quand joueur est en Zone 2
  - Calculer distance au deposit le plus proche
  - Afficher un indicateur visuel (UI ou particle)
  - Plus le joueur est proche, plus le signal est fort
  - Signal : couleur qui change (rouge loin → vert proche) ou son "bip" qui accelere
- [ ] Utiliser RunService.Heartbeat pour update en temps reel
**Validation** : Le joueur sait ou chercher en Zone 2

#### Sprint 11 : Test Integration Complet
**Duree** : ~60 min
- [ ] Playthrough complet du jeu :
  1. Spawn → tutoriel → Zone 1 → mine batee → minigame → drops
  2. Retour hub → vendre au marchand → acheter tapis
  3. Craft a la forge (paillettes → or pur)
  4. XP accumule → level 2 → Zone 2 debloquee
  5. Zone 2 → detecteur actif → mine avec pioche
  6. Quetes quotidiennes → progression → completion
  7. Saloon → whiskey → buff speed → mine booste
  8. Level 3 → Zone 3 → combat boss → victoire
  9. Leaderboard → stats correctes
  10. Quitter → revenir → donnees sauvegardees
- [ ] Logger TOUTES les erreurs/bugs
**Validation** : Le jeu est jouable de A a Z

---

### PHASE 3 — POLISH (Sprints 12-17) — Jours 9-14

> Objectif : Le jeu est agreable, immersif, equilibre

#### Sprint 12 : Sons & Ambiance
**Duree** : ~45 min
- [ ] Trouver des SoundIds Roblox pour :
  - Musique ambient western (hub) — en loop
  - Son riviere (Zone 1) — ambient
  - Son mine/caverne (Zone 3) — ambient
  - Son pioche qui frappe — mining action
  - Son pieces — vente
  - Son craft — forge
  - Son level up — fanfare
  - Son boss — rugissement
- [ ] Implementer un systeme de musique par zone (crossfade simple)
- [ ] Ajouter les sons d'action aux systemes existants
**Validation** : Ambiance sonore immersive

#### Sprint 13 : VFX & Particules
**Duree** : ~45 min
- [ ] Verifier/ameliorer les particules existantes :
  - Gold deposits : lueur attirante ✓ (deja dans templates)
  - Mining : poussiere doree ✓ (deja dans MiningClient)
  - Vente : ajouter effet "pieces qui volent"
  - Craft : ajouter effet "etincelles/flammes"
  - Level up : ajouter effet "explosion doree" ✓ (deja dans UIManager)
  - Boss : effet de degats (flash rouge)
- [ ] Ajouter des Beam/Trail sur les outils equipes
**Validation** : Feedback visuel satisfaisant partout

#### Sprint 14 : Map Polish — Terrain & Decor
**Duree** : ~60 min
- [ ] Ameliorer le MapBuilder :
  - Plus de vegetation (arbres, buissons, herbes)
  - Details du hub (tonneaux, caisses, charettes, puits)
  - Panneaux entre les zones ("→ Zone 2 : Collines Ambrees")
  - Eclairage interieur (forge, saloon — PointLights chauds)
  - Rails de mine en Zone 3 (Parts + cylindres)
  - Ameliorer le pont (garde-corps, planches)
- [ ] Ajouter des SpawnLocations secondaires si besoin
**Validation** : Map visuellement riche et coherente

#### Sprint 15 : Balancing Pass
**Duree** : ~60 min
- [ ] Faire 3 playthroughs chronometres (noter le temps pour chaque milestone) :
  - Temps pour premier level up (cible : 5-8 min)
  - Temps pour acheter Tapis (cible : 10-15 min)
  - Temps pour level 3 (cible : 30-45 min)
- [ ] Ajuster si necessaire :
  - Drop rates dans EconomyConfig
  - Prix de vente
  - XP rewards
  - Spawn timers dans ZoneConfig
  - Boss HP/damage dans GameConfig
  - Cout des outils dans ToolConfig
- [ ] Re-tester apres ajustements
**Validation** : Progression satisfaisante, ni trop lente ni trop rapide

#### Sprint 16 : UI Polish
**Duree** : ~45 min
- [ ] Verifier la coherence visuelle :
  - Palette western (or #FFD700, brun, creme) — deja utilisee
  - UICorner sur tous les panels
  - UIStroke pour lisibilite
  - Animations d'ouverture/fermeture (tweens) — deja dans InteractionClient
- [ ] Tester en resolution mobile (responsive)
- [ ] Verifier que tous les boutons sont cliquables
- [ ] Verifier les textes francais (pas de texte coupe)
**Validation** : UI propre et coherente

#### Sprint 17 : Anti-Exploit Audit
**Duree** : ~30 min
- [ ] Verifier toutes les validations serveur :
  - [x] Distance check mining (15 studs) — dans MiningSystem
  - [x] Cooldown anti-spam (2s mining, 1s craft) — dans MiningSystem/CraftManager
  - [x] Quantity cap (1-9999) — dans EconomyManager
  - [x] Level check zones — dans MiningSystem
  - [x] Tool check — dans MiningSystem
  - [x] Cash check avant achat — dans EconomyManager
  - [x] Inventory check avant vente/craft — dans EconomyManager/CraftManager
  - [x] Score clamp (0-1) batee — dans MiningSystem
  - [ ] Boss distance check — a ajouter dans BossManager
  - [ ] Rate limit sur RemoteEvents (a ajouter si pas present)
**Validation** : Aucun exploit connu possible

---

### PHASE 4 — SUBMISSION (Sprints 18-20) — Jours 15-21

> Objectif : Jeu publie et soumis au Roblox Incubator

#### Sprint 18 : Playtest Final + Bug Bash
**Duree** : ~90 min
- [ ] Playtest complet (tout le jeu)
- [ ] Inviter 1-2 testeurs si possible
- [ ] Fixer tous les bugs P0 (crash, data loss, blocage)
- [ ] Fixer bugs P1 (UX cassee, visuels incorrects)
- [ ] Verifier 30 minutes sans crash
- [ ] Verifier console propre (0 erreurs)
**Validation** : Jeu stable, 0 crash en 30 min

#### Sprint 19 : Monetization Setup + Game Icon
**Duree** : ~60 min
- [ ] Creer le Game Icon (512x512) et Thumbnail (1920x1080)
- [ ] Configurer les Game Passes (optionnel pour submission) :
  - "Pack Prospecteur" — +50% XP (99 Robux)
  - "Chance d'Or" — +25% drop rate (149 Robux)
- [ ] Ecrire la description du jeu (francais + anglais)
- [ ] Configurer les parametres du jeu :
  - Max players : 12
  - Genre : Adventure
  - Allowed on phone/tablet/PC
**Validation** : Page du jeu prete

#### Sprint 20 : Publication & Soumission Incubator
**Duree** : ~60 min
- [ ] Publier le jeu sur Roblox (public ou unlisted)
- [ ] Prendre 10 screenshots :
  1. Vue aerienne Dusthaven
  2. Mining Zone 1 (riviere)
  3. BateeMinigame en action
  4. NPC Marchand (vente)
  5. Shop outils
  6. Craft a la forge
  7. Zone 2 (collines)
  8. Zone 3 (mine) + Boss
  9. HUD complet
  10. Leaderboard
- [ ] Enregistrer une video 2-3 min du gameplay
- [ ] Remplir le formulaire Roblox Incubator
- [ ] Soumettre avant le 6 avril 23:59 UTC
**Validation** : SOUMIS !

---

## RESUME VISUEL

```
Semaine 1 (14-17 mars)   : Sprints 1-5   VALIDATION     "Est-ce que ca marche ?"
Semaine 1-2 (17-22 mars) : Sprints 6-11  COMPLETUDE     "Tout fonctionne"
Semaine 2-3 (22-28 mars) : Sprints 12-17 POLISH         "C'est beau et equilibre"
Semaine 3-4 (28 mar-6 avr): Sprints 18-20 SUBMISSION    "On publie !"
```

---

## REGLES DE TRAVAIL

### Chaque Sprint
1. Lire le sprint → comprendre l'objectif
2. Coder les changements (filesystem, Rojo sync)
3. Rebuild map si MapBuilder modifie : `execute_luau MapBuilder:Init()`
4. Start playtest : `start_playtest`
5. Monitor console : `get_playtest_output`
6. Fixer les erreurs
7. Valider le critere de validation
8. Cocher les cases → passer au sprint suivant

### Principes
- **Placeholders uniquement** — pas d'assets definitifs, on utilise les Parts basiques Roblox
- **Test-first** — on valide AVANT d'avancer
- **Baby steps** — chaque sprint est petit et focuse
- **Pas de refactoring premature** — on fait marcher d'abord
- **Console propre** — 0 erreurs rouges = le standard

### Si on est en retard
Couper dans cet ordre (du moins important au plus important) :
1. ~~DetecteurSystem (Sprint 10)~~ — mine directement en Zone 2
2. ~~Sons & musique (Sprint 12)~~ — silence acceptable
3. ~~Map polish details (Sprint 14)~~ — le placeholder suffit
4. ~~Monetization (Sprint 19)~~ — pas necessaire pour Incubator
5. **NE JAMAIS COUPER** : Sprints 1-5 (validation), 7-8 (boss), 18 (playtest final), 20 (submission)

---

## INVENTAIRE TECHNIQUE

### Architecture existante (17 RemoteEvents)
```
Client → Server              Server → Client
─────────────────            ─────────────────
RequestMine                  MineResult
BateeMinigameResult          StartBateeMinigame
RequestSell                  SellResult
RequestBuyTool               ShopResult
RequestUpgradeTool
RequestCraft                 CraftResult
RequestDrink                 DrinkResult
RequestQuestData             QuestDataResponse
                             QuestCompleted
                             InitPlayerData
                             PlayerDataUpdated
                             LevelUp
                             NotifyPlayer
                             TimeOfDayChanged
                             StartTutorial
```

### A creer pour le Boss (Sprint 7)
```
Client → Server              Server → Client
─────────────────            ─────────────────
RequestAttackBoss            BossSpawned
                             BossHealthUpdated
                             BossDefeated
```

### PlayerData Structure (ProfileStore)
```lua
{
  Version = 1,
  Cash = 0, TotalCashEarned = 0,
  XP = 0, Level = 1,
  Inventory = { Paillettes=0, OrPur=0, Lingots=0, Pepites=0, MineraiOr=0, Quartz=0, Amethyste=0, Topaze=0 },
  Tools = { Batee={Owned=true,Level=1}, Tapis={Owned=false,Level=0}, Pioche={Owned=false,Level=0} },
  Quests = { DailyReset=0, Active={}, Completed={} },
  Zones = { Zone1_Unlocked=true, Zone2_Unlocked=false, Zone3_Unlocked=false },
  Saloon = { LastDrinkTime=0, DrinksToday=0, BuffActive="", BuffExpiry=0 },
  Boss = { GardienDefeated=0, LastBossAttempt=0 },
  Tutorial = { Completed=false, Step=1 }
}
```

### Game Balance Reference
```
Level 1 (Amateur)      : 0-499 XP
Level 2 (Orpailleur)   : 500-1999 XP    → unlock Zone 2
Level 3 (Prospecteur)  : 2000+ XP       → unlock Zone 3

Tools : Batee (free) → Tapis (100$) → Pioche (200$)
Upgrades : Level 2 (150-600$) → Level 3 (500-1500$)

Zone 1 drops : 80% Paillettes, 15% Quartz, 5% Pepites
Zone 2 drops : 50-60% Pepites, 25-30% Paillettes, 10-15% Amethyste, 5% Topaze
Zone 3 drops : 45% MineraiOr, 25% Pepites, 15% Amethyste, 10% Topaze, 5% Quartz

Sell prices (Marchand) : Paillettes 2$, Pepites 15$, MineraiOr 5$, OrPur 10$, Lingots 50$
Sell prices (Negociant) : OrPur 13$, Lingots 65$, Amethyste 33$, Topaze 52$

Craft : 5 Paillettes → 1 OrPur (3s) | 3 OrPur + 2 MineraiOr → 1 Lingot (5s)

Boss : 500 HP, 15 dmg, rewards 200$ + 200 XP + drops
```
