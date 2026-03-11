# 🪙 Gold Rush Legacy — Roadmap V1 Démo
> Dev junior | Roblox Studio + Claude Code/Cursor | Deadline Incubator : **6 avril 2026**

---

## 📅 Vue d'ensemble — 4 semaines

| Semaine | Focus | Objectif clé |
|---------|-------|-------------|
| S1 (11–17 mars) | Fondations | Map + déplacement + minage basique fonctionnel |
| S2 (18–24 mars) | Gameplay Core | Inventaire, shop, quêtes S1, PNJ, sauvegarde |
| S3 (25–31 mars) | Enrichissements | Craft/Forge, Saloon, boss Crow Creek, Zone 3 complète |
| S4 (1–6 avril) | Polish & Soumission | Balancing, bugs, vidéo, screenshots, candidature |

---

## 🗓️ SEMAINE 1 — Fondations (11–17 mars)

> **Objectif** : Le jeu peut tourner. Le joueur peut se déplacer et miner.

### Tâches S1

| # | Tâche | Description | Dépendances | Heures | Priorité |
|---|-------|-------------|-------------|--------|----------|
| T01 | Setup projet Roblox | Créer le projet Studio, configurer les services (DataStore, etc.), arborescence de base | — | 2h | P0 |
| T02 | Map de base — Hub Central | Modéliser la ville centrale (placeholder cubes), zones de connexion vers les 3 mines | T01 | 4h | P0 |
| T03 | Zone 1 — Rivière Tranquille | Map tutoriel : terrain, veines de minerai placées, marqueurs de spawn | T02 | 3h | P0 |
| T04 | Zone 2 — Collines Ambrées | Map intermédiaire : terrain + veines + obstacles simples | T02 | 3h | P1 |
| T05 | Zone 3 — Mine de Crow Creek | Map avancée : intérieur de mine, veines rares, zone boss (placeholder) | T02 | 4h | P1 |
| T06 | Core Loop — Minage (pickaxe) | Script : clic sur roche → animation → minerai dans inventaire temporaire | T03 | 5h | P0 |
| T07 | Spawner de ressources | Les veines re-spawn après X secondes, types différents par zone | T06 | 3h | P0 |
| T08 | Système de déplacement / zones | Portails ou zones de téléport Hub ↔ Mines, chargement de zones | T02 | 3h | P0 |
| T09 | GUI — HUD de base | Affichage : minerais en poche, niveau joueur, barre de vie/stamina | T06 | 4h | P1 |

**Total estimé S1 : ~31h**

---

## 🗓️ SEMAINE 2 — Gameplay Core (18–24 mars)

> **Objectif** : La boucle de jeu est complète. Ramasser → vendre → acheter → reminer.

### Tâches S2

| # | Tâche | Description | Dépendances | Heures | Priorité |
|---|-------|-------------|-------------|--------|----------|
| T10 | Inventaire complet | Module inventaire (slots, poids max, tri), synchronisé serveur | T06 | 6h | P0 |
| T11 | Marchand — Vente minerais | PNJ vendeur : GUI liste de minerais, prix dynamiques par type | T10 | 4h | P0 |
| T12 | Magasin outils | GUI shop : acheter pickaxes (niveaux 1–3), équipement de base | T11 | 4h | P0 |
| T13 | Système de devises (Gold Coins) | Currency serveur, transactions sécurisées, affichage wallet | T11 | 3h | P0 |
| T14 | Sauvegarde DataStore | Sauvegarder : inventaire, coins, niveau, progression quêtes | T10, T13 | 5h | P0 |
| T15 | Système de quêtes — S1 | 3 quêtes tutoriel Zone 1 : miner X, vendre X, acheter pickaxe | T11, T13 | 5h | P1 |
| T16 | PNJ de base (Hub) | PNJ statiques avec bulles de dialogue, trigger de quêtes | T15 | 3h | P1 |
| T17 | Leaderboard | GUI leaderboard : top joueurs par coins/minerais, orderedDataStore | T13, T14 | 3h | P2 |
| T18 | XP & Niveaux | Gain XP au minage/vente, progression niveau 1–10, déblocage zones | T10, T13 | 4h | P1 |

**Total estimé S2 : ~37h**

---

## 🗓️ SEMAINE 3 — Enrichissements (25–31 mars)

> **Objectif** : Craft, Saloon, boss, Zone 3 jouable. La démo est feature-complete.

### Tâches S3

| # | Tâche | Description | Dépendances | Heures | Priorité |
|---|-------|-------------|-------------|--------|----------|
| T19 | Forge / Craft | GUI craft : recettes (minerai → lingot → outil), animations forge | T10, T12 | 6h | P0 |
| T20 | Recettes craft (3–5 recettes) | Définir les recettes : ex. 3 Cuivre → Lingot Cuivre → Pickaxe Bronze | T19 | 2h | P0 |
| T21 | Quêtes S2 & S3 | 3 quêtes Zone 2, 3 quêtes Zone 3 (dont 1 quête boss) | T15, T18 | 5h | P1 |
| T22 | Boss — Mine de Crow Creek | IA boss simple (charge + AOE), phases de vie, drops rares | T05, T18 | 8h | P1 |
| T23 | Saloon — Système simple | Mini-jeu ou tableau de paris, boissons = buff temporaire | T16 | 4h | P2 |
| T24 | Effets visuels & sons | Particules minage, sons pickaxe, musique ambiance par zone | T06 | 4h | P1 |
| T25 | Balancing S1–S2 | Ajuster prix, XP, spawn rates, durée tools après tests | T18, T11 | 3h | P1 |
| T26 | Équipement — slots visuels | Personnage affiche l'équipement (pickaxe visible), GUI équipement | T12, T10 | 3h | P2 |

**Total estimé S3 : ~35h**

---

## 🗓️ SEMAINE 4 — Polish & Soumission (1–6 avril)

> **Objectif** : Zéro bug bloquant. Vidéo prête. Soumission envoyée avant le 6 avril.

### Tâches S4

| # | Tâche | Description | Dépendances | Heures | Priorité |
|---|-------|-------------|-------------|--------|----------|
| T27 | Playtest complet (2 sessions) | Tester le core loop de A à Z, noter tous les bugs | Toutes S1–S3 | 4h | P0 |
| T28 | Fix bugs critiques | Résoudre tous les bugs P0 (crash, perte de données, blocages) | T27 | 6h | P0 |
| T29 | Polish UI/UX | Améliorer les GUIs (couleurs, icons, transitions), cohérence visuelle | T27 | 4h | P1 |
| T30 | Vidéo de démo (2–3 min) | Capturer : hub → mine → craft → boss. Monter avec voix off ou textes | T28 | 4h | P0 |
| T31 | Screenshots promo (5–10) | Captures des moments clés : hub, zones, boss, craft, leaderboard | T28 | 1h | P0 |
| T32 | Description projet Incubator | Rédiger le pitch (voir brief S5), game concept, mécaniques, cible | T28 | 2h | P0 |
| T33 | Soumission Incubator | Remplir le formulaire, uploader vidéo + screenshots + description | T30, T31, T32 | 1h | P0 |

**Total estimé S4 : ~22h**

---

## 📊 Dépendances — Ordre critique

```
T01 → T02 → T03/T04/T05 → T06 → T07/T08/T09
                              ↓
T06 → T10 → T11 → T12/T13 → T14 (sauvegarde)
                  ↓
              T15 → T16 → T21 → T22 (boss)
              T13 → T17 (leaderboard)
              T10 → T18 → T19 → T20 (craft)
                              ↓
                         T23 (saloon)
                         T24 (VFX)
```

**Chemin critique (ne peut pas être en retard) :**
T01 → T02 → T06 → T10 → T11 → T13 → T14 → T15 → T22 → T27 → T28 → T30/T33

---

## ✅ CHECKLISTS DE VALIDATION PAR SEMAINE

### ✅ Semaine 1 — La démo est OK si :
- [ ] Le jeu se lance sans erreur console
- [ ] Le joueur peut entrer dans les 3 zones depuis le Hub
- [ ] Il peut miner une roche et voir les minerais dans un inventaire temporaire
- [ ] Les ressources re-spawn après un délai
- [ ] Le HUD affiche les minerais ramassés

### ✅ Semaine 2 — La démo est OK si :
- [ ] L'inventaire persiste (sauvegarde DataStore fonctionnel)
- [ ] Le joueur peut vendre des minerais au Marchand et recevoir des Gold Coins
- [ ] Il peut acheter une pickaxe améliorée au Magasin
- [ ] 3 quêtes de la Zone 1 sont complétables de bout en bout
- [ ] Le Leaderboard affiche les scores en temps réel
- [ ] Un PNJ donne une quête en Zone 1

### ✅ Semaine 3 — La démo est OK si :
- [ ] Le joueur peut forger un lingot et crafter une pickaxe améliorée
- [ ] Le boss de Crow Creek peut être combattu et tué avec des drops
- [ ] 3 quêtes de Zone 2 et 3 quêtes de Zone 3 sont jouables
- [ ] Le Saloon offre au moins un buff ou interaction
- [ ] Les sons et effets visuels sont présents sur le minage
- [ ] La progression de niveau débloque l'accès aux zones

### ✅ Semaine 4 — La démo est OK si :
- [ ] Aucun crash ou perte de données sur 2 sessions de test complètes
- [ ] La vidéo de démo de 2–3 min est montée et uploadée
- [ ] 5 screenshots de qualité sont prêts
- [ ] Le formulaire Incubator est rempli et soumis avant le 6 avril 23:59

---

## ⚠️ RISQUES & MITIGATIONS

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|-----------|
| DataStore bugué (perte de données) | Haute | P0 | Tester DataStore dès T14, utiliser un wrapper fiable (ProfileService ou simple backup) |
| Boss IA trop complexe | Haute | P1 | Simplifier à max : boss stationnaire avec AOE + timer de phases. Pas de pathfinding complexe |
| UI/GUI prend trop de temps | Haute | P1 | Utiliser des templates Roblox existants, ne pas custom-coder les GUIs from scratch |
| Scope creep (trop de features) | Haute | P0 | Figer le scope après S2. Toute nouvelle feature = scoped pour V2 |
| Dev bloqué sur un bug (2h+) | Moyenne | P1 | Utiliser Claude Code pour le debug. Poser dans le canal Discord dédié. Timer de 2h max avant d'escalader |
| Performances basses (FPS drop) | Moyenne | P1 | Optimiser les spawners dès S1 (PoolObject), éviter les boucles while true trop fréquentes |
| Vidéo de démo pas prête | Basse | P0 | Commencer la capture dès que S3 est stable (pas attendre S4) |
| Rejet Incubator sur critères | Basse | P1 | Lire les guidelines Roblox Incubator avant S4, aligner la description sur leurs critères |

### 💡 Ressources pour dev junior

- **Roblox Learning Hub** : education.roblox.com (tutos officiels)
- **DevForum Roblox** : devforum.roblox.com (bugs, patterns)
- **ProfileService** : github.com/MadStudioRoblox/ProfileService (DataStore fiable)
- **Claude Code** : pour générer des scripts Luau, débugger, expliquer des patterns
- **MCP Roblox Studio** : pour automatiser le placement d'objets, configurations
- **YouTube** : AlvinBlox, TheDevKing — tutos vidéo en anglais pour les patterns courants

---

## 📋 BRIEF SOUMISSION ROBLOX INCUBATOR

### Deadlines
| Type | Date | Notes |
|------|------|-------|
| **Priority Deadline** | **6 avril 2026** | Priorité de review, meilleure visibilité |
| Rolling Deadline | 4 mai 2026 | Review continue, moins prioritaire |

### Ce qu'il faut préparer

#### 🎬 Vidéo de gameplay (OBLIGATOIRE)
- **Durée** : 2–3 minutes max
- **Contenu à capturer** :
  - [ ] Arrivée dans le Hub Central (vue de la ville)
  - [ ] Entrée dans Zone 1, minage avec tutoriel
  - [ ] Vente au Marchand, achat au Magasin
  - [ ] Craft d'un outil à la Forge
  - [ ] Combat du Boss dans Crow Creek
  - [ ] Affichage du Leaderboard
- **Format** : MP4, 1080p minimum
- **Montage** : Titres de section, voix off ou textes explicatifs

#### 📸 Screenshots (5–10 recommandés)
- [ ] Vue aérienne du Hub Central
- [ ] Gameplay de minage Zone 1 (tutoriel en action)
- [ ] Interface inventaire + GUI shop
- [ ] Scène de craft à la Forge
- [ ] Combat du Boss (Zone 3)
- [ ] Leaderboard affiché
- [ ] Vue Zone 2 et/ou Zone 3 (ambiance)

#### 📝 Description du projet
```
Titre : Gold Rush Legacy
Genre : Mining Tycoon / Adventure RPG
Cible : 10–16 ans, fans de tycoon et d'exploration

Concept court (2 phrases) :
"Gold Rush Legacy est un mining tycoon où tu explores 3 zones dangereuses, 
mines des ressources rares, craftes des outils légendaires et affrontes un boss 
pour devenir le plus riche de la ville."

Mécaniques clés à mentionner :
- Core loop : Minage → Vente → Craft → Zone suivante
- 3 zones progressives avec boss final
- Système de craft (Forge) avec recettes
- Quêtes PNJ et progression de niveau
- Leaderboard compétitif
- Sauvegarde complète de la progression

Points forts pour l'Incubator :
- Gameplay accessible + profondeur pour les veterans
- Boucle de progression claire et satisfaisante
- Univers western/frontier avec identité visuelle forte
- Solo ou multi-joueurs dans le même monde
```

#### 📌 Checklist finale avant soumission
- [ ] Jeu publié sur Roblox (pas en accès privé)
- [ ] Vidéo uploadée (YouTube unlisted ou Vimeo)
- [ ] Screenshots exportés en 1920x1080
- [ ] Description rédigée (concept + mécaniques + cible)
- [ ] Formulaire Incubator rempli complètement
- [ ] Relecture des Guidelines Incubator (conformité)
- [ ] **Soumis avant le 6 avril 23:59 UTC**

---

## 📊 Récap total des estimations

| Semaine | Heures estimées | Heures/jour (7 jours) |
|---------|----------------|----------------------|
| S1 | 31h | ~4.4h/jour |
| S2 | 37h | ~5.3h/jour |
| S3 | 35h | ~5h/jour |
| S4 | 22h | ~3.7h/jour (deadline le 6) |
| **TOTAL** | **~125h** | **~4.5h/jour en moyenne** |

> ⚡ **Note** : Ces estimations sont pour un dev junior avec Claude Code. Un senior ferait 2x plus vite. Avec Claude Code pour la génération de code Luau, les estimations sont réalistes si le dev reste focus et ne scope-creep pas.

---

*Généré par Soren — Sénéchal de la Guilde | 11 mars 2026*
