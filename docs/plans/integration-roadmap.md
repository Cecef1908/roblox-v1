# Integration Roadmap — Gold Rush Legacy

## Decisions techniques

| Paramètre | Valeur | Source |
|-----------|--------|--------|
| Taille map | **1200×1200 studs** (-600 à +600 sur X et Z) |
| Sol | **Smooth Terrain** (sable) + Parts pour accents |
| StreamingEnabled | **true** — MinRadius=128, TargetRadius=1536 |
| Part count | **<10 000 total**, <500/bâtiment |
| Single place | **OUI** — pas de teleport entre places |
| NPCs | Runtime (comme actuellement) — repositionnés par building |

---

## Coordonnées — Master Grid

### Spawn + Hub
| Élément | X | Z | Footprint | Build ID |
|---------|---|---|-----------|----------|
| SPAWN | -450 | -450 | 20×20 | Code |
| Pont (bridge) | -320 | -380 | 16×40 | À générer |
| **DUSTHAVEN center** | **0** | **-200** | **200×200** | — |
| General Store (Silas) | -60 | -250 | 47×76 | `dusthaven/general_store` |
| Saloon (Belle) | 60 | -160 | 61×76 | `dusthaven/saloon` |
| Forge (Gustave) | -60 | -160 | 45×43 | `dusthaven/forge` |
| Sheriff (quêtes) | 0 | -280 | 96×73 | `dusthaven/sheriff` |
| Bivouac (spawn camp) | -450 | -430 | 15×15 | `dusthaven/bivouac` |

### Zone 1 — Dead Man's Shallows
| Élément | X | Z | Build ID |
|---------|---|---|----------|
| Z1 Center | -100 | -50 | — |
| Z1 Sign | -100 | -130 | `dusthaven/signpost` / généré |
| Batée Station 1 | -180 | -80 | À générer |
| Batée Station 2 | -100 | -20 | À générer |
| Batée Station 3 | -30 | 40 | À générer |

### Zone 2 — Copper Canyon
| Élément | X | Z | Build ID |
|---------|---|---|----------|
| Z2 Center | -350 | 200 | — |
| Camp Rattler | -380 | 150 | `dusthaven/bivouac` + barils |
| Abri prospection | -300 | 250 | `dusthaven/dh_tradingpost` |

### Zone 3 — Crow Creek Mine
| Élément | X | Z | Build ID |
|---------|---|---|----------|
| Mine Entrance | 200 | 50 | À générer + `dusthaven/mine_rails` |
| Rail Tracks | 200→350 | 50→200 | `dusthaven/mine_rails` |
| Boss Arena | 350 | 250 | À générer |
| Filon Room | 400 | 350 | À générer |

### Eau
| Élément | X | Z | Type |
|---------|---|---|------|
| Grotte entrance | -100 | 300 | Terrain + Parts |
| Lac | -50 | 400 | Terrain Water 120×80 |

### River Waypoints
| # | X | Z | Note |
|---|---|---|------|
| R1 | -420 | -480 | Source (spawn) |
| R2 | -380 | -420 | SE flow |
| R3 | -320 | -380 | Sous le pont |
| R4 | -260 | -300 | Courbe vers hub |
| R5 | -200 | -200 | Passe ouest de Dusthaven |
| R6 | -180 | -80 | Batée Station 1 |
| R7 | -100 | -20 | Batée Station 2 |
| R8 | -30 | 40 | Batée Station 3 |
| R9 | -50 | 150 | Vers grotte |
| R10 | -80 | 280 | Approche grotte |
| R11 | -100 | 300 | Grotte |
| R12 | -50 | 400 | Alimente lac |

Largeur rivière : 12-20 studs (étroite aux coudes, large aux stations batée).

---

## Phases d'intégration

### PHASE 0 — Fondations (pas jouable)
> Objectif : poser le monde, pas de gameplay.

| Step | Action | Fichier impacté |
|------|--------|-----------------|
| 0.1 | Terrain 1200×1200 (sable désertique) | MapBuilder:CreateWorld |
| 0.2 | SpawnLocation à (-450, 0, -450) | MapBuilder:CreateWorld |
| 0.3 | StreamingEnabled=true | GoldRushLegacy.rbxlx (ou via script) |
| 0.4 | Mettre à jour ZoneConfig.WorldPosition (Z1→-100,-50 / Z2→-350,200 / Z3→300,150) | ZoneConfig.lua |
| 0.5 | Structure dossiers Map/ (Zone1, Zone2, Zone3) | MapBuilder:CreateFolders |

---

### PHASE 1 — Hub + Rivière + Zone 1 (CORE LOOP JOUABLE)
> Objectif : Spawn → marcher → ville → acheter outil → miner or → vendre. Boucle complète.

| Step | Action | Asset / Build |
|------|--------|---------------|
| 1.1 | Bivouac au spawn + feu de camp | `dusthaven/bivouac` + `dusthaven/fireplace` |
| 1.2 | Rivière (Terrain Water, 12 waypoints) | Terrain API |
| 1.3 | Pont en bois | À générer |
| 1.4 | **5 bâtiments Dusthaven** positionnés | `dusthaven/general_store`, `saloon`, `forge`, `sheriff` + bivouac |
| 1.5 | NPCs repositionnés devant leurs bâtiments | NPC_DATA positions update |
| 1.6 | Décor hub : barils, caisses, wagon, lanternes, clôtures | `dusthaven/wagon`, `barrels`, `crates`, `fence`, `lantern` |
| 1.7 | Sentiers : Spawn→Pont→Hub→Z1 | Terrain/Parts |
| 1.8 | Zone 1 : terrain + 3 batée stations + 12 spawn points | Code + props |
| 1.9 | Panneau Z1 "Dead Man's Shallows" | Généré |
| 1.10 | **PLAYTEST COMPLET** — valider le core loop | — |

**Estimation : 4-6 sessions de travail**

---

### PHASE 2 — Zone 2 + Lac + Grotte
> Objectif : contenu level 2, étendre la durée de jeu.

| Step | Action |
|------|--------|
| 2.1 | Canyon walls (grandes parts roche, 40-60 studs haut) |
| 2.2 | Camp Rattler (bivouac + feu + PNJ rival) |
| 2.3 | Spawn points filon/pépite + detector zones |
| 2.4 | Lac (Terrain Water 120×80) + plage sable |
| 2.5 | Entrée grotte (arche roche) |
| 2.6 | Sentiers Z1→Z2, Z2→Grotte, Grotte→Lac |
| 2.7 | PLAYTEST — valider Z2 gameplay |

---

### PHASE 3 — Zone 3 Mine + Boss
> Objectif : endgame, boss fight, loot rare.

| Step | Action |
|------|--------|
| 3.1 | Mine entrance (cadre bois + enseigne) |
| 3.2 | Rails + locomotive décorative | `dusthaven/mine_rails` + `dusthaven/locomotive` |
| 3.3 | Tunnels intérieurs (corridors en roche) |
| 3.4 | Torches/bougies dans la mine | `dusthaven/wall_candle`, `dusthaven/lantern_wall` |
| 3.5 | Boss Arena (60×60, caverne ouverte) |
| 3.6 | Filon Room (récompense post-boss) |
| 3.7 | PLAYTEST — valider Z3 + boss |

---

### PHASE 4 — Polish (en parallèle)
- Cycle jour/nuit
- Sons ambiants par zone
- Particules météo (poussière désert, gouttes dans mine)
- Panneaux directionnels entre zones
- Murs invisibles aux bords de la map
- Minimap

---

## Assets — Inventaire final

### PRÊTS (31 builds dans library)
**Bâtiments hub :** general_store, saloon, forge, sheriff, bivouac
**Props :** wagon, barrels, crates, fence, lantern, lantern_wall, hay_bale, trough, fireplace, fire_escape, graves, grave_steps, wall_candle
**Mine :** mine_rails, locomotive
**Réserve :** hotel, dh_tradingpost, dh_church, dh_clocktower, dh_barracks, dh_warehouse, dh_shoprow, dh_mansion, dh_grandplaza, dh_logfort, dh_smokefactory

### À GÉNÉRER
- Pont en bois (bridge)
- Batée stations (3x petits pontons)
- Panneaux / enseignes zones
- Entrée grotte (arche roche)
- Tunnels mine (corridors)
- Boss arena
- Filon room
- Canyon walls

---

## Fichiers à modifier (Phase 1)

| Fichier | Changement |
|---------|------------|
| `ZoneConfig.lua` | WorldPosition Z1→(-100,0,-50), Z2→(-350,0,200), Z3→(300,0,150) |
| `MapBuilder:CreateWorld()` | Terrain 1200×1200, spawn à (-450,-450), import buildings |
| `MapBuilder:CreateWesternDecor()` | Repositionner décor dans Dusthaven |
| `MapBuilder:CreateMiningZone()` | Repositionner Z1 center, ajouter Z2/Z3 spawn points |
| `NPC_DATA` | Nouvelles positions devant les bâtiments |
| `GoldSpawner:GetZoneFolder()` | Ajouter mapping Zone2/Zone3 folder names |
