# Gold Rush Legacy — Plan d'Exécution en 42 Sprints

> **Source** : `docs/specs/gold-rush-v1-tech-spec.md` (4600 lignes)
> **Deadline** : 6 avril 2026 (Roblox Incubator)
> **Méthode** : Chaque sprint = 1 unité de travail focalisée (~30-90 min)

---

## PHASE 1 — FONDATIONS (Sprints 1-8) — Semaine 1

### Sprint 1 : Setup Architecture Projet
- [ ] Créer l'arborescence complète dans Studio (Workspace/Map/, ServerScriptService/Core/, Systems/, Lib/, etc.)
- [ ] Créer les Folders : HubCentral, Zone1, Zone2, Zone3, ActiveGoldDeposits
- [ ] Créer ReplicatedStorage/Modules/Config/, Events/RemoteEvents/, Events/RemoteFunctions/
- [ ] Créer StarterGui avec les 11 ScreenGui (MainHUD, ShopUI, SellUI, CraftUI, InventoryUI, QuestUI, SaloonUI, BossUI, BateeMinigameUI, LevelUpUI, DialogueUI)
- [ ] Fichier : execute_luau pour créer toute la structure

### Sprint 2 : Config Modules (Part 1)
- [ ] Écrire `GameConfig.lua` (constantes globales + Saloon + Boss)
- [ ] Écrire `EconomyConfig.lua` (prix, XP, drops, tool bonuses, respawn timers)
- [ ] Écrire `ToolConfig.lua` (Batée, Tapis, Pioche — 3 niveaux chacun)
- [ ] Tous dans ReplicatedStorage/Modules/Config/

### Sprint 3 : Config Modules (Part 2)
- [ ] Écrire `NPCConfig.lua` (6 PNJ : Marchand, Négociant, Vendeur, Forgeron, Barman, Guide)
- [ ] Écrire `QuestConfig.lua` (pool de 7 quêtes quotidiennes)
- [ ] Écrire `CraftConfig.lua` (3 recettes : raffiner or pur, forger lingot, raffiner pépites)
- [ ] Écrire `GemConfig.lua` (Quartz, Améthyste, Topaze)
- [ ] Écrire `ZoneConfig.lua` (3 zones avec niveaux, outils, spawn settings)

### Sprint 4 : RemoteEvents & RemoteFunctions
- [ ] Créer les 30 RemoteEvents dans ReplicatedStorage/Events/RemoteEvents/
  - RequestMine, MineResult, StartBateeMinigame, BateeMinigameResult
  - RequestSell, SellResult, RequestBuyTool, RequestUpgradeTool, ShopResult
  - RequestCraft, CraftResult, RequestClaimQuest, QuestsUpdated, QuestProgressUpdated, QuestRewardClaimed
  - RequestBuyDrink, SaloonResult, BuffExpired
  - RequestAttackBoss, BossSpawned, BossHealthUpdated, BossAttacked, BossAttackResult, BossDefeated, BossDespawned
  - InitPlayerData, PlayerDataUpdated, LevelUp, TimeOfDayChanged, StartTutorial, NotifyPlayer
- [ ] Créer les 6 RemoteFunctions dans ReplicatedStorage/Events/RemoteFunctions/
  - GetPlayerData, GetCraftRecipes, GetActiveQuests, GetSaloonMenu, GetLeaderboard, FetchShopItems

### Sprint 5 : DataManager (ProfileStore)
- [ ] Intégrer ProfileStore (module externe) dans ServerScriptService/Lib/
- [ ] Écrire `DataManager.server.lua` complet :
  - Init, LoadProfile, GetProfile, GetData
  - SaveAndReleaseProfile, SaveAllProfiles
  - AddToInventory, RemoveFromInventory, AddCash, RemoveCash, AddXP (avec level up)
- [ ] Tester : charger/sauver un profil, vérifier les valeurs par défaut

### Sprint 6 : GameManager (Orchestrateur)
- [ ] Écrire `GameManager.server.lua` :
  - Initialize (init tous les managers dans l'ordre)
  - OnPlayerAdded (charger profil, check quêtes, équiper outils, envoyer data au client)
  - OnPlayerRemoving (sauver profil)
  - UpdateDayNightCycle (Heartbeat, Lighting.ClockTime interpolation)
  - BindToClose (sauvegarde d'urgence)
- [ ] Tester : joueur rejoint → données chargées → client notifié

### Sprint 7 : Map — Hub Central (Terrain + Structure)
- [ ] Terrain : Cobblestone pour la place, herbe autour, chemin de terre vers mines
- [ ] Créer les bâtiments placeholder du hub :
  - Marchand (Model + ProximityPrompt)
  - Négociant (Model + ProximityPrompt)
  - MagasinOutils (Model + ProximityPrompt)
  - Forge (Model + enclume + ProximityPrompt)
  - Saloon (Model + intérieur + ProximityPrompt)
  - Leaderboard (Part + SurfaceGui)
- [ ] SpawnLocation au centre
- [ ] Décorations : arbres, lampadaires, fontaine, panneaux directionnels

### Sprint 8 : Map — 3 Zones de Minage
- [ ] Zone 1 — Rivière Tranquille : terrain rivière (Sand + Water), 8 GoldSpawnPoints, BateeStations (3), NPC_Guide + ProximityPrompt, ZoneTrigger
- [ ] Zone 2 — Collines Ambrées : terrain collines (Rock hills), 10 points (FilonSpots + DetecteurZones), ZoneTrigger
- [ ] Zone 3 — Mine de Crow Creek : entrée de mine, tunnels intérieurs, OreNodes (12), GemSpawnPoints (6), BossArena (trigger + door + spawn point), ZoneTrigger
- [ ] ServerStorage/Templates : créer les 7 templates (GoldDeposit_Paillette/Pepite/Filon, Gem_Quartz/Amethyste/Topaze, Boss_GardienMine)

---

## PHASE 2 — GAMEPLAY CORE (Sprints 9-18) — Semaine 2

### Sprint 9 : GoldSpawner
- [ ] Écrire `GoldSpawner.server.lua` complet :
  - Init (lancer un spawner par zone)
  - StartZoneSpawner (boucle while true + SpawnInterval)
  - SpawnDeposit (clone template, set attributes, ProximityPrompt)
  - PickTemplate (logique par zone : paillette, pépite, filon, gemme)
  - DestroyDeposit (nettoyer ActiveDeposits)
- [ ] Tester : les gisements apparaissent dans chaque zone

### Sprint 10 : MiningSystem (Serveur)
- [ ] Écrire `MiningSystem.server.lua` complet :
  - HandleMineRequest (anti-spam, distance check, zone level check, tool check)
  - ProcessMining (drop table, tool bonus, saloon buff, score multiplier, drops, XP)
  - HandleBateeResult (valider score 0-1, relayer à ProcessMining)
  - HasValidTool, GetBestToolLevel, GetDepositPosition
  - EquipOwnedTools, GiveTool (Tool dans Backpack)
- [ ] Tester : miner un gisement → drops corrects dans l'inventaire

### Sprint 11 : MiningClient (Client)
- [ ] Écrire `MiningClient.client.lua` :
  - Listener DescendantAdded sur ActiveGoldDeposits pour ProximityPrompts
  - Handler MineResult : afficher drops flottants, particules, son, refresh HUD
  - Gérer aussi les prompts déjà présents au chargement
- [ ] Tester : approcher un spot → prompt → cliquer → feedback visuel + son

### Sprint 12 : BateeMinigame (Mini-jeu Zone 1)
- [ ] Créer le UI BateeMinigameUI dans StarterGui :
  - Cercle, Indicateur rotatif, Zone verte, Texte instruction
- [ ] Écrire `BateeMinigame.client.lua` :
  - Écouter StartBateeMinigame
  - Animation rotation indicateur (200°/sec)
  - Input Space/Touch → calculer score (Parfait 1.0, Bon 0.7, Moyen 0.4, Raté 0.1)
  - Envoyer BateeMinigameResult au serveur
- [ ] Tester : mini-jeu s'ouvre en Zone 1, score envoyé, drops reçus

### Sprint 13 : EconomyManager (Vente + Achat)
- [ ] Écrire `EconomyManager.server.lua` complet :
  - HandleSell (validation, price table, remove inventory, add cash, XP, quest callback)
  - HandleBuyTool (check owned, check cash, give tool)
  - HandleUpgradeTool (check level, check cash, upgrade)
- [ ] Tester : vendre des paillettes au marchand → cash augmente

### Sprint 14 : SellUI + ShopUI (Client)
- [ ] Créer SellUI dans StarterGui :
  - Liste des items vendables avec quantité + prix
  - Slider ou bouton +/- pour quantité
  - Bouton Vendre → RequestSell → afficher SellResult
- [ ] Créer ShopUI dans StarterGui :
  - Liste des outils (Batée, Tapis, Pioche) avec prix achat/upgrade
  - Bouton Acheter/Améliorer → RequestBuyTool/RequestUpgradeTool
- [ ] Tester : ouvrir le shop via PNJ, acheter un outil

### Sprint 15 : InteractionClient (PNJ)
- [ ] Écrire `InteractionClient.client.lua` :
  - SetupNPCPrompts pour chaque PNJ du hub (Marchand, Négociant, Vendeur, Forgeron, Barman)
  - SetupNPCPrompts pour le Guide (Zone 1)
  - Fonctions OpenSellUI, OpenShopUI, OpenCraftUI, OpenSaloonUI, OpenDialogueUI
  - SetupZoneTriggers (afficher le nom de la zone en entrant)
- [ ] Tester : approcher chaque PNJ → prompt → UI s'ouvre

### Sprint 16 : UIManager (HUD Principal)
- [ ] Créer MainHUD dans StarterGui :
  - CashDisplay (Frame + TextLabel "$50")
  - XPBar (Frame + Fill bar + Text "0/500 XP")
  - LevelText ("Nv.1 — Amateur")
  - InventoryButton (ImageButton)
  - QuestTracker (Frame, 3 slots de quête)
- [ ] Écrire `UIManager.client.lua` (module) :
  - Init, RefreshHUD (cash, XP bar, level)
  - ShowFloatingText (drops dorés)
  - ShowNotification (success/error/info/warning)
  - ShowZoneTitle (fade in/out grand texte)
  - ShowLevelUpScreen
  - OnTimeOfDayChanged
- [ ] Tester : HUD affiche correctement les données, notifications fonctionnent

### Sprint 17 : InventoryUI
- [ ] Créer InventoryUI dans StarterGui :
  - Grille d'items avec icône, nom, quantité
  - Catégories : Matières Premières, Gemmes, Outils
  - Bouton fermer
- [ ] Lier à l'InventoryButton du HUD
- [ ] Mettre à jour en temps réel (écouter PlayerDataUpdated)

### Sprint 18 : Sauvegarde & Test Core Loop
- [ ] Vérifier DataStore fonctionne : quitter → rejoindre → données persistées
- [ ] Test complet du core loop :
  - Spawn → voir HUD → aller Zone 1 → miner (batée) → voir drops → retourner hub → vendre → acheter outil → re-miner
- [ ] Fix bugs trouvés
- [ ] Vérifier les anti-exploits (distance, cooldown, quantité)

---

## PHASE 3 — ENRICHISSEMENTS (Sprints 19-30) — Semaine 3

### Sprint 19 : CraftManager (Forge)
- [ ] Écrire `CraftManager.server.lua` :
  - HandleCraft (valider recette, level, matériaux → consommer → produire)
  - GetAvailableRecipes (liste filtrée par niveau + matériaux)
  - CalcMaxCraftable
- [ ] Tester : raffiner 5 paillettes → 1 or pur, forger 3 or pur + 2 minerai → 1 lingot

### Sprint 20 : CraftUI (Client)
- [ ] Créer CraftUI dans StarterGui :
  - Liste des recettes avec inputs/output
  - Indicateur "Peut crafter" / "Matériaux manquants"
  - Bouton Crafter + barre de progression (timer CraftTime)
  - Quantité +/-
- [ ] Tester : ouvrir via Forgeron, crafter, voir inventaire mis à jour

### Sprint 21 : QuestManager (Quêtes Quotidiennes)
- [ ] Écrire `QuestManager.server.lua` :
  - CheckDailyReset (reset à 00:00 UTC)
  - AssignDailyQuests (3 random du pool, filtrées par niveau)
  - OnItemCollected, OnSellTransaction, OnItemCrafted (callbacks des autres managers)
  - UpdateProgress (matcher type + target)
  - HandleClaimQuest (donner rewards)
  - GetActiveQuests (pour UI)
- [ ] Tester : 3 quêtes assignées, progressent avec le minage/vente

### Sprint 22 : QuestUI (Client)
- [ ] Créer QuestUI dans StarterGui :
  - Liste des 3 quêtes actives avec titre, description, barre de progression
  - Bouton "Réclamer" quand complétée
  - Animation de complétion
- [ ] Mettre à jour le QuestTracker dans le MainHUD (résumé des quêtes)
- [ ] Tester : progression visible, réclamer reward → cash + XP

### Sprint 23 : SaloonManager (Boissons + Buffs)
- [ ] Écrire `SaloonManager.server.lua` :
  - HandleBuyDrink (max 3/jour, check buff actif, prix nuit -20%, appliquer buff)
  - GetMenu (liste des boissons avec prix/disponibilité)
  - OnTimeOfDayChanged (tracker jour/nuit)
  - Timer d'expiration du buff
- [ ] Tester : acheter un whiskey → buff SpeedBoost 5 min → buff expire

### Sprint 24 : SaloonUI (Client)
- [ ] Créer SaloonUI dans StarterGui :
  - Menu des boissons (nom, description, prix, buff)
  - Indicateur "Nuit = -20%"
  - Compteur "Verres restants : X/3"
  - Bouton Commander
- [ ] Tester : ouvrir via Barman, commander, voir buff actif dans HUD

### Sprint 25 : BossManager (Gardien de la Mine)
- [ ] Écrire `BossManager.server.lua` :
  - Arena trigger (Touched/TouchEnded)
  - SpawnBoss (clone template, init HP, fermer porte)
  - BossAITick (chercher joueur le plus proche, MoveTo, attaque basique + éboulement)
  - HandlePlayerAttack (check pioche, calculer dégâts selon niveau, update HP)
  - OnBossDefeated (rewards à tous les participants, ouvrir porte)
  - DespawnBoss (si plus personne)
- [ ] Créer le template Boss_GardienMine dans ServerStorage (Model + Humanoid + PrimaryPart)

### Sprint 26 : BossUI (Client)
- [ ] Créer BossUI dans StarterGui :
  - Barre de vie du boss (rouge, nom "Gardien de la Mine")
  - Indicateur de dégâts infligés
  - Notification attaque reçue (flash rouge)
- [ ] Écouter BossSpawned, BossHealthUpdated, BossAttacked, BossDefeated
- [ ] Bouton Attaquer (ou click) → RequestAttackBoss
- [ ] Tester : entrer arène → boss spawn → combat → victoire → rewards

### Sprint 27 : Cycle Jour/Nuit (Visuel)
- [ ] Écrire `DayNightClient.client.lua` :
  - Écouter TimeOfDayChanged
  - Interpoler Lighting.ClockTime (Jour=14, Nuit=22)
  - Changer Atmosphere (jour : clair, nuit : bleu sombre)
  - Allumer/éteindre les lampadaires de la ville
  - Changer l'ambiance sonore
- [ ] Tester : cycle visible, lampadaires s'allument la nuit

### Sprint 28 : DialogueUI (Conversations PNJ)
- [ ] Créer DialogueUI dans StarterGui :
  - Portrait PNJ (image ou placeholder)
  - Nom du PNJ
  - Texte de dialogue (typewriter effect)
  - Bouton Suivant / Fermer
- [ ] Implémenter les dialogues du Guide (6 étapes tutoriel)
- [ ] Implémenter les greetings de chaque PNJ marchand
- [ ] Tester : parler au Guide → texte tutoriel s'affiche

### Sprint 29 : Tutoriel Joueur
- [ ] Écrire la logique tutoriel dans GameClient/UIManager :
  - Step 1 : "Bienvenue" → highlight rivière
  - Step 2 : "Utilise ta batée" → highlight spot
  - Step 3 : "Bravo !" → montrer résultat
  - Step 4 : "Va vendre au marchand" → highlight chemin
  - Step 5 : "Continue à miner"
  - Step 6 : "Tutoriel complété"
- [ ] Sauver Tutorial.Step et Tutorial.Completed dans PlayerData
- [ ] Tester : nouveau joueur → tutoriel guidé de bout en bout

### Sprint 30 : Détecteur de Métaux (Zone 2)
- [ ] Écrire `DetecteurSystem.client.lua` :
  - Quand le joueur est en Zone 2 avec Tapis/Pioche
  - Feedback visuel : indicateur qui "bip" plus fort à proximité d'un spot
  - UI : boussole/radar qui pointe vers le spot le plus proche
- [ ] Créer les DetecteurZones (Parts invisibles trigger) en Zone 2
- [ ] Tester : le détecteur guide le joueur vers les filons

---

## PHASE 4 — POLISH & UX (Sprints 31-38) — Semaine 4 début

### Sprint 31 : LeaderboardManager
- [ ] Écrire `LeaderboardManager.server.lua` :
  - OrderedDataStore pour Cash et XP
  - RefreshLeaderboards (Top 10) toutes les 30s
  - UpdatePhysicalDisplay (SurfaceGui dans le hub)
  - RemoteFunction GetLeaderboard pour UI client
- [ ] Tester : leaderboard affiché dans le hub, mis à jour

### Sprint 32 : LevelUpUI + Progression Visuelle
- [ ] Créer LevelUpUI dans StarterGui :
  - Grand texte "LEVEL UP !"
  - Nom du nouveau niveau
  - Liste des déblocages (nouvelle zone, nouveaux outils)
  - Animation festive (particules, flash)
- [ ] Notification de déblocage de zone
- [ ] Tester : passer niveau 2 → animation + zone 2 débloquée

### Sprint 33 : Effets Visuels (Particules + Feedback)
- [ ] Particules de minage (poussière dorée quand on mine)
- [ ] Particules sur les gisements (lueur pour attirer le joueur)
- [ ] Effet de vente (pièces qui volent)
- [ ] Effet de craft (flammes/étincelles)
- [ ] Flash de dégâts (boss)
- [ ] Indicateur buff actif (icône au-dessus du personnage)

### Sprint 34 : Sons & Musique
- [ ] Ajouter des SoundIds valides :
  - Pioche qui frappe la roche
  - Eau de rivière (ambient Zone 1)
  - Pièces qui tombent (vente)
  - Forge (marteau sur enclume)
  - Boss rugissement
  - Level up fanfare
  - Musique ambient western (hub)
  - Musique tension (Zone 3 / boss)
- [ ] Système de musique par zone (crossfade)

### Sprint 35 : Anti-Exploit (Validation Serveur)
- [ ] Vérifier toutes les validations dans le tech spec :
  - Distance check sur minage (max 15 studs)
  - Cooldown anti-spam (1s entre requêtes)
  - Quantité cap (max 9999)
  - Type check (number, string, integer)
  - Level check pour zones
  - Tool check pour minage
  - Cash check avant achat
  - Inventory check avant vente/craft
  - Score clamp (0-1) pour batée
  - Boss distance check (max 10 studs)
- [ ] Ajouter des warn() pour détecter les tentatives d'exploit

### Sprint 36 : Balancing Pass
- [ ] Tester et ajuster :
  - Drop rates (pas trop généreux, pas trop avare)
  - Prix de vente (progression satisfaisante)
  - XP thresholds (level up ni trop rapide ni trop lent)
  - Respawn timers (assez rapides pour pas s'ennuyer)
  - Boss HP/dégâts (challenging mais faisable solo)
  - Coût des outils (progression logique)
  - Buffs du saloon (utiles mais pas OP)
- [ ] Au moins 3 playthroughs complets

### Sprint 37 : UI Polish
- [ ] Couleurs cohérentes (palette western : or, brun, crème)
- [ ] Fonts cohérents (GothamBold pour titres, Gotham pour texte)
- [ ] UICorner sur tous les frames
- [ ] UIStroke pour lisibilité
- [ ] Transitions smooth (tweens d'ouverture/fermeture)
- [ ] Responsive (fonctionne en différentes résolutions)
- [ ] Icônes pour chaque item (placeholder ou Roblox decals)

### Sprint 38 : Map Polish
- [ ] Affiner le terrain (transitions douces entre zones)
- [ ] Ajouter de la végétation (arbres, buissons, herbes)
- [ ] Détails de mine (rails, chariots, lanternes, poutres)
- [ ] Améliorer les bâtiments du hub (textures, détails)
- [ ] Panneaux de signalisation entre les zones
- [ ] Éclairage intérieur (forge, saloon, mine)

---

## PHASE 5 — SOUMISSION (Sprints 39-42) — Derniers jours

### Sprint 39 : Playtest Complet #1
- [ ] Test du core loop entier (minage → vente → achat → craft → boss)
- [ ] Test de la progression (niveau 1 → 2 → 3)
- [ ] Test de chaque PNJ
- [ ] Test des quêtes
- [ ] Test du saloon
- [ ] Test du cycle jour/nuit
- [ ] Test du leaderboard
- [ ] Test du tutoriel (nouveau joueur)
- [ ] Log tous les bugs trouvés

### Sprint 40 : Fix Bugs Critiques
- [ ] Fixer tous les bugs P0 (crash, perte de données, blocage)
- [ ] Fixer bugs P1 (UX cassée, visuels incorrects)
- [ ] Re-tester après chaque fix
- [ ] Vérifier que DataStore ne perd pas de données

### Sprint 41 : Screenshots + Vidéo
- [ ] 10 screenshots 1920x1080 :
  - Vue aérienne du Hub Central
  - Gameplay minage Zone 1 (batée)
  - Interface inventaire
  - Shop d'outils
  - Forge/Craft en action
  - Combat du Boss (Zone 3)
  - Saloon intérieur
  - Leaderboard
  - Mini-jeu batée
  - Vue panoramique des 3 zones
- [ ] Vidéo 2-3 min :
  - Arrivée dans le Hub
  - Tutoriel Zone 1
  - Minage + vente
  - Craft à la forge
  - Boss fight
  - Leaderboard

### Sprint 42 : Soumission Roblox Incubator
- [ ] Publier le jeu sur Roblox (accès public ou unlisted)
- [ ] Rédiger la description :
  - Titre : "Gold Rush Legacy"
  - Genre : Mining Tycoon / Adventure RPG
  - Cible : 10-16 ans
  - Pitch : 2 phrases
  - Mécaniques clés (6 points)
  - Points forts (4 points)
- [ ] Upload vidéo (YouTube unlisted)
- [ ] Remplir le formulaire Incubator
- [ ] Soumettre avant le 6 avril 23:59 UTC

---

## RÉCAP PAR SEMAINE

| Semaine | Sprints | Focus | Résultat |
|---------|---------|-------|----------|
| S1 (11-17 mars) | 1-8 | Fondations + Map | Structure complète, map jouable, DataStore |
| S2 (18-24 mars) | 9-18 | Gameplay Core | Minage, vente, achat, HUD, inventaire, core loop complet |
| S3 (25-31 mars) | 19-30 | Enrichissements | Craft, quêtes, saloon, boss, jour/nuit, tutoriel, détecteur |
| S4 (1-6 avril) | 31-42 | Polish + Soumission | Leaderboard, VFX, sons, balancing, playtest, vidéo, soumission |

## PRIORITÉS SI EN RETARD

Si le temps manque, couper dans cet ordre (du moins au plus important) :
1. ~~Sprint 30 (Détecteur)~~ → remplacer par minage direct en Zone 2
2. ~~Sprint 27 (Cycle jour/nuit visuel)~~ → garder ClockTime fixe
3. ~~Sprint 31 (Leaderboard)~~ → placeholder statique
4. ~~Sprint 34 (Sons)~~ → silence acceptable pour démo
5. ~~Sprint 23-24 (Saloon)~~ → simplifier à 1 bouton "Boire = buff"

**NE JAMAIS COUPER** : Sprints 1-18 (core loop), Sprint 25-26 (boss), Sprint 39-42 (soumission).

---

## COMMENCER

Le Sprint 1 commence maintenant. Dis "Sprint 1 go" et je crée toute l'architecture dans Studio.
