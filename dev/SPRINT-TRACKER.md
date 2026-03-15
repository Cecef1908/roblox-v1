# Gold Rush Legacy — Sprint Tracker

> Suivi en temps reel. Cocher au fur et a mesure.

---

## PHASE 1 — VALIDATION

### Sprint 1 : Smoke Test Initial
- [x] Rojo serve OK
- [x] MapBuilder:Init() en edit mode
- [x] Screenshot map
- [x] Playtest lance
- [x] Console lue — 57 messages, 0 erreurs
- [x] Problemes listes — 3 fixes appliques (CreateWorld, Zone2/3 spawns, cleanup doublons)
**Status** : DONE (14 mars 2026)

### Sprint 2 : Fix Erreurs de Boot + Setup
- [x] Fix DataManager auto-save bypass ProfileStore
- [x] Fix BateeMinigameResult anti-exploit (PendingMinigames tracking)
- [x] Fix MapBuilder CreateWorld() — appelle terrain, riviere, zones, decor
- [x] Fix Zone 2/3 spawn points (CreateMiningZone2, CreateMiningZone3)
- [x] Fix cleanup doublons dans MapBuilder:Init()
- [x] Calibration coordonnees 2D↔3D (formule: X=1084-10.76*mx, Z=1033-10*my)
- [x] Connexion Team Create (map final z1 — Mehdi, playda888)
- [x] DevTools: Sprint(Shift), Turbo(V), Fly(F), /tp [lieu]
- [x] 33 pins places et valides visuellement
- [x] 6 nouveaux spots de collecte ajoutes
- [x] map.html mis a jour et push GitHub
**Status** : DONE (15 mars 2026)

### Sprint 3 : Test Mining
- [x] Gold deposits visibles (ProximityPrompt)
- [x] Mine → drops dans inventaire (Paillettes + XP)
- [x] BateeMinigame se lance en Zone 1 (scores 0.4-1.0)
- [x] HUD mis a jour (Batee en Bois visible)
- [x] Deposit respawn apres destruction
- [x] Fix: spawn points recalibres avec coordonnees 2D (6 spots Zone 1)
- [x] Fix: RequestMine instantane (animation en parallele)
- [x] Fix: hauteur deposits h+1 (visible, pas flottant)
**Status** : DONE (15 mars 2026)

### Sprint 4 : Test Economy
- [x] Vente fonctionne (Topaze vendue 40$)
- [x] Achat outil fonctionne (Tapis + Pioche achetees)
- [x] Craft fonctionne (4x craft: REFINE_PEPITES, REFINE_OR_PUR)
- [x] Saloon fonctionne (Whiskey SpeedBoost 15$)
- [x] /give dev command fonctionne (via RemoteEvent)
- [x] Switch outils (Batee/Tapis/Pioche) fonctionne
**Status** : DONE (15 mars 2026)

### Sprint 5 : Test Persistence + Quests
- [x] Quetes assignees (3 quotidiennes visibles)
- [x] Quest tracker permanent (style WoW, haut droite)
- [x] Badge "!" supprime (remplace par tracker)
- [x] Progression quete visible en temps reel
- [x] Level up fonctionne
- [ ] Save/load — non testable en Studio (DataStore bloque)
**Status** : DONE (15 mars 2026)

---

## PHASE 2 — COMPLETUDE

### Sprint 6 : Day/Night Cycle
- [ ] Active dans GameManager
- [ ] Cycle visible
- [ ] Lumieres toggle
- [ ] Rabais nuit saloon
**Status** : NOT STARTED

### Sprint 7 : BossManager — Serveur
- [ ] BossManager.lua ecrit
- [ ] RemoteEvents crees
- [ ] Boss spawn en Zone 3
- [ ] AI basique (aggro, attaque)
- [ ] Peut etre tue → rewards
- [ ] Respawn timer
**Status** : NOT STARTED

### Sprint 8 : Boss — Client UI
- [ ] Barre de vie
- [ ] Indicateur degats
- [ ] Mecanisme attaque
- [ ] Notification victoire
**Status** : NOT STARTED

### Sprint 9 : Tutoriel
- [ ] 5-6 etapes implementees
- [ ] Guide le joueur
- [ ] Marque complete dans data
- [ ] Ne re-montre pas
**Status** : NOT STARTED

### Sprint 10 : DetecteurSystem
- [ ] Radar Zone 2
- [ ] Signal selon distance
- [ ] Feedback visuel/sonore
**Status** : NOT STARTED

### Sprint 11 : Test Integration
- [ ] Playthrough complet
- [ ] 10 etapes validees
- [ ] Bugs logges
**Status** : NOT STARTED

---

## PHASE 3 — POLISH

### Sprint 12 : Sons
- [ ] Musique ambient
- [ ] Sons actions
- [ ] Crossfade par zone
**Status** : NOT STARTED

### Sprint 13 : VFX
- [ ] Particules ameliorees
- [ ] Effets vente/craft
- [ ] Trail outils
**Status** : NOT STARTED

### Sprint 14 : Map Polish
- [ ] Vegetation ajoutee
- [ ] Details hub
- [ ] Panneaux zones
- [ ] Eclairage interieur
**Status** : NOT STARTED

### Sprint 15 : Balancing
- [ ] 3 playthroughs chronometres
- [ ] Ajustements configs
- [ ] Re-test
**Status** : NOT STARTED

### Sprint 16 : UI Polish
- [ ] Coherence visuelle
- [ ] Mobile responsive
- [ ] Boutons cliquables
- [ ] Textes francais OK
**Status** : NOT STARTED

### Sprint 17 : Anti-Exploit Audit
- [ ] Validations serveur verifiees
- [ ] Boss distance check ajoute
- [ ] Rate limiting
**Status** : NOT STARTED

---

## PHASE 4 — SUBMISSION

### Sprint 18 : Playtest Final
- [ ] Test complet
- [ ] Testeurs externes
- [ ] Bugs P0 fixes
- [ ] 30 min sans crash
**Status** : NOT STARTED

### Sprint 19 : Monetization + Icon
- [ ] Game icon 512x512
- [ ] Thumbnail 1920x1080
- [ ] Game passes (optionnel)
- [ ] Description du jeu
**Status** : NOT STARTED

### Sprint 20 : Publication
- [ ] Jeu publie sur Roblox
- [ ] 10 screenshots
- [ ] Video gameplay
- [ ] Formulaire Incubator
- [ ] SOUMIS
**Status** : NOT STARTED

---

## COMPTEUR

| Phase | Sprints | Fait | Reste |
|-------|---------|------|-------|
| Validation | 1-5 | 0/5 | 5 |
| Completude | 6-11 | 0/6 | 6 |
| Polish | 12-17 | 0/6 | 6 |
| Submission | 18-20 | 0/3 | 3 |
| **TOTAL** | **20** | **0/20** | **20** |
