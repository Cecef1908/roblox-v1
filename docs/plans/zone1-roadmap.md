# ZONE 1 — Roadmap topographique

> Architecte: Claude | Date: 2026-03-12
> Sources: `docs/map-overview.html` (v3), `docs/map-zone1.html` (Dusthaven détail)
> Scope: **ZONE 1 UNIQUEMENT** — Dead Man's Shallows + Hub Dusthaven

---

## 1. Système de coordonnées

### Conversion SVG → Roblox

| Paramètre | Valeur |
|-----------|--------|
| Taille map totale | **1200 × 1200 studs** |
| Plage X | -600 à +600 |
| Plage Z | -600 à +600 |
| SVG (map-overview) | 800 × 800 px |
| Échelle | **1.5 studs/px** |
| Centre SVG (400, 400) | Centre Roblox (0, 0, 0) |

**Formules :**
```
X_roblox = svgX × 1.5 − 600
Z_roblox = svgY × 1.5 − 600
Y_roblox = hauteur (0 = sol)
```

**Axes :** Nord = −Z, Sud = +Z, Est = +X, Ouest = −X

### Conversion SVG → Roblox (map-zone1 — Dusthaven détail)

| Paramètre | Valeur |
|-----------|--------|
| SVG viewBox | 860 × 720 px |
| Échelle | **1 stud = 3.5 px** |
| Centre SVG (432, 310) | = Centre Dusthaven world |
| Orientation | **Rotation 180°** — le bas du SVG (vers pont) = Nord en world |

**Formule (offset depuis centre Dusthaven) :**
```
offset_X_world = −(svgX − 432) / 3.5
offset_Z_world = −(svgY − 310) / 3.5
```

---

## 2. Frontières de Zone 1

Dérivées des séparateurs SVG (vertical ~x=435, horizontal ~y=418) :

| Axe | Min | Max | Taille |
|-----|-----|-----|--------|
| X | −600 | +53 | 653 studs |
| Z | −600 | +27 | 627 studs |
| **Superficie** | | | **~409 000 studs²** |

---

## 3. Coordonnées — Éléments majeurs

### 3.1 Cabane du Grand-Père (SPAWN)

| Propriété | Valeur | Source |
|-----------|--------|--------|
| Position | **(−304, 0, −381)** | SVG overview (197.5, 146) |
| Build | `dusthaven/bivouac` | 31 parts |
| Footprint | ~13 × 9 studs | |
| Fonction | Spawn point + tutoriel narratif | |
| Éléments | SpawnLocation invisible, feu de camp, mot du grand-père | |

Le joueur apparaît ici. Il trouve une batée sur la table et un mot expliquant les bases.

### 3.2 Pont

| Propriété | Valeur | Source |
|-----------|--------|--------|
| Position | **(−176, 0, −378)** | SVG overview (283, 148) |
| Build | À générer | ~30 parts |
| Footprint | ~12 × 6 studs | |
| Rotation | **−15°** | Perpendiculaire à la rivière |
| Fonction | Connexion Cabane ↔ Dusthaven, enjambe la rivière | |

Le pont traverse la rivière au point R3 (−240, −323) — son axe est orienté ~NE-SW pour couper le méandre.

### 3.3 Dusthaven (Hub)

**Centre : (−75, 0, −240)** — dérivé du centre du rect SVG overview (350, 240)

#### Architecture (source : map-zone1.html)

Dusthaven est nichée dans une **clairière entre deux falaises**. Le joueur arrive par un **passage étroit** (~35 studs) entre les parois rocheuses, depuis le nord (côté pont). En débouchant dans la clairière, le **Saloon** apparaît en face — moment de révélation.

Les 4 bâtiments forment un **arc** qui s'ouvre vers le nord (entrée).

#### 3.3.1 Bâtiments

| # | Bâtiment | Position World | Footprint | Rotation | Build ID | Parts |
|---|----------|---------------|-----------|----------|----------|-------|
| 2 | **Saloon de Belle** | (−75, 0, −213) | 22 × 20 | 0° | `dusthaven/saloon` | 665 |
| 1 | **Magasin de Silas** | (−53, 0, −236) | 14 × 14 | +8° | `dusthaven/general_store` | 331 |
| 4 | **Bureau du Sheriff** | (−99, 0, −234) | 18 × 16 | −8° | `dusthaven/sheriff` | 413 |
| 3 | **Forge de Gustave** | (−96, 0, −261) | 18 × 16 | −5° | `dusthaven/forge` | 113 |

**Calcul positions (exemple Saloon) :**
- zone1 SVG : (432, 215), centre zone1 : (432, 310)
- offset SVG : (0, −95) px
- offset world (rotation 180°) : (0, +95/3.5) = (0, +27) studs
- world : (−75 + 0, −240 + 27) = **(−75, −213)**

Le Saloon (le plus gros, 22×20s) est au **fond de l'arc** (sud), face à l'entrée. Le Magasin est à l'**est** (gauche du joueur). Le Sheriff à l'**ouest**. La Forge au **nord-ouest**, la plus proche du passage.

#### 3.3.2 Props

| Prop | Position World | Source zone1 SVG | Build ID | Parts |
|------|---------------|-----------------|----------|-------|
| Barils (×3) | (−65, 0, −228) | (398, 267) | `dusthaven/barrels` | 8 |
| Poteau d'attache | (−96, 0, −246) | (507, 331) | code | 3 |
| Abreuvoir | (−106, 0, −251) | (539, 348) | `dusthaven/trough` | 11 |
| Caisses (×2) | (−108, 0, −269) | (548, 410) | `dusthaven/crates` | 4 |
| Enclume | (−89, 0, −272) | (482, 423) | code | 3 |
| Charrette/wagon | (−56, 0, −271) | (366, 420) | `dusthaven/wagon` | 55 |
| Feu de camp | (−75, 0, −235) | centre clairière | `dusthaven/fireplace` | 40 |
| Lanternes (×4) | coins de l'arc | — | `dusthaven/lantern` | 12 |
| Clôtures | pourtour clairière | — | `dusthaven/fence` | 62 |

#### 3.3.3 Falaises

Deux masses rocheuses enserrent la ville. Dimensions dérivées du plan zone1 (1 stud = 3.5px).

| Falaise | Position approx. | Taille approx. | Description |
|---------|-----------------|----------------|-------------|
| **Est** (droite du joueur) | X ∈ [−55, +100], Z ∈ [−320, −200] | 155 × 120 studs | Masse large, s'étend vers l'est |
| **Ouest** (gauche du joueur) | X ∈ [−250, −95], Z ∈ [−320, −200] | 155 × 120 studs | Masse large, s'étend vers l'ouest |
| **Arrière** (derrière Saloon) | X ∈ [−120, −30], Z ∈ [−200, −190] | 90 × 10 studs | Crête basse fermant le fond |

Hauteur des falaises : **30 à 50 studs** (impressionnant mais pas excessif).

#### 3.3.4 Passage

| Propriété | Valeur |
|-----------|--------|
| Entrée nord | (−75, 0, −343) |
| Sortie dans clairière | (−75, 0, −273) |
| Longueur | **70 studs** |
| Largeur | **35 studs** (au point le plus étroit) |
| Murs | Parts Rock, 30-40 studs de haut |

Le passage se rétrécit progressivement : ~50 studs d'ouverture au nord, ~35 studs au centre, puis s'évase en entrant dans la clairière.

**Mur est du passage :** X ≈ −57 (au plus étroit)
**Mur ouest du passage :** X ≈ −94 (au plus étroit)
**Point le plus étroit :** Z ≈ −310

#### 3.3.5 Clairière

| Propriété | Valeur |
|-----------|--------|
| Centre | (−75, 0, −240) |
| Rayon X | ~34 studs |
| Rayon Z | ~31 studs |
| Forme | Elliptique, ~68 × 62 studs |
| Sol | Terre battue (Ground material) |

### 3.4 Rivière — Waypoints Zone 1

La rivière entre par le **bord nord** de la map et serpente vers le sud-est avec de **grands méandres**. Tracé dérivé du path SVG cubic bezier de `map-overview.html`.

| # | X | Z | Largeur | Note |
|---|---|---|---------|------|
| **R1** | −510 | −600 | 12 | Entrée bord nord de la map |
| R1.5 | −467 | −546 | 14 | Coule vers le SE |
| **R2** | −360 | −488 | 18 | **Virage 1 → est** (large, près Batée 1) |
| R2.5 | −249 | −414 | 14 | Courbe vers l'est |
| **R3** | −240 | −323 | 16 | **Point est** — le plus proche du pont/Dusthaven |
| R3.5 | −354 | −244 | 14 | Retour vers l'ouest |
| **R4** | −503 | −195 | 18 | **Virage 2 → ouest** (large, point le plus ouest) |
| R4.5 | −554 | −123 | 14 | Courbe vers le sud-est |
| **R5** | −480 | −45 | 18 | **Virage 3** — approche frontière Z2, près Batée 3 |

**Total Z1 :** 9 waypoints, ~1200 studs de longueur de rivière

Largeur : **12 studs** aux coudes serrés, **18-20 studs** aux stations batée (zones larges et calmes pour l'orpaillage).

### 3.5 Batée Stations

Trois stations d'orpaillage positionnées sur les **berges intérieures** des méandres (zones calmes, peu profondes).

| Station | Position World | Near Waypoint | Description |
|---------|---------------|---------------|-------------|
| **Batée 1** | (−353, 0, −423) | R2 | Premier coude, le plus proche de la Cabane |
| **Batée 2** | (−428, 0, −150) | entre R3.5 et R4 | Deuxième coude, accès depuis sentier principal |
| **Batée 3** | (−405, 0, −23) | R5 | Dernier coude Z1, près frontière Z2 |

Chaque station : petit ponton en bois (8 × 8 studs), ~20 parts. Accès à la rivière avec zone peu profonde.

**4 spawn points par station** (12 total) : répartis en arc de cercle, rayon 8-15 studs autour de chaque station.

### 3.6 Sentiers

| ID | Nom | De → Vers | Waypoints world | Distance | Temps marche |
|----|-----|-----------|----------------|----------|-------------|
| **A** | Cabane → Rivière | (−304, −381) → (−340, −400) | direct, 2 points | ~40 studs | ~3s |
| **B** | Cabane → Pont | (−304, −381) → (−176, −378) | droit, 2 points | ~128 studs | ~8s |
| **C** | Pont → Dusthaven | (−176, −378) → (−75, −343) → passage → (−75, −273) | 3 points | ~175 studs | ~11s |
| **D** | Sentier principal | suit rive gauche de la rivière, de R2 au sud | ~6 points | ~500 studs | ~30s |

Sentiers : bandes de **6 studs de large**, Material = Ground, couleur terre battue.

Le **game loop triangle** :
```
Cabane (−304, −381) ←—40s/3s—→ Rivière
     ↓ 128s/8s
    Pont (−176, −378)
     ↓ 175s/11s
  Dusthaven (−75, −240)
```

Tout est à **<15 secondes** de marche entre deux points adjacents. ✓

---

## 4. NPCs — Nouvelles positions

Les 5 NPCs sont repositionnés **devant leurs bâtiments respectifs**, face au centre de la clairière.

| NPC | npcType | Bâtiment | Position | Facing |
|-----|---------|----------|----------|--------|
| Jake l'Outilleur | ToolShop | Magasin | (−50, 0, −240) | 250° (vers centre) |
| Marcel le Marchand | Merchant | près Magasin (barils) | (−62, 0, −230) | 200° (vers centre) |
| Gustave le Forgeron | Crafter | Forge | (−90, 0, −256) | 50° (vers centre) |
| Bill le Barman | Saloon | Saloon | (−75, 0, −220) | 0° (vers entrée/nord) |
| Tom le Guide | Tutor | Clairière | (−75, 0, −255) | 180° (vers Saloon/sud) |

---

## 5. ZoneConfig — Mise à jour

```lua
Zone1 = {
    Name = "Rivière Tranquille",
    DisplayName = "Zone 1 — Dead Man's Shallows",
    WorldPosition = Vector3.new(-395, 0, -199),
    -- centre géométrique des 3 batée stations
    -- (−353 + −428 + −405) / 3 = −395
    -- (−423 + −150 + −23) / 3 = −199
}
```

---

## 6. Budget Parts

| Catégorie | Parts estimées |
|-----------|---------------|
| Sol (ground, town square, sentiers) | 10 |
| Cabane (bivouac + fireplace) | 71 |
| Pont | 30 |
| Saloon | 665 |
| Magasin | 331 |
| Sheriff | 413 |
| Forge | 113 |
| Props hub (barils, wagon, abreuvoir…) | 200 |
| Clôtures + lanternes | 80 |
| Falaises (2 masses + crête arrière) | 120 |
| Passage (murs) | 40 |
| 3 Batée stations | 60 |
| Mining zone (12 SP + rochers déco) | 25 |
| Panneaux + NPCs | 30 |
| **TOTAL ZONE 1** | **~2 190 parts** |

✅ Confortablement sous les 10 000 parts (22% du budget total).

---

## 7. Stratégie d'implémentation

### Architecture hybride : Code + Builds MCP

| Quoi | Comment | Pourquoi |
|------|---------|----------|
| **Terrain** (sol, rivière) | MapBuilder code (Smooth Terrain API) | Dynamique, lightweight |
| **Bâtiments** (4 du hub + cabane) | `import_build` MCP → dans le .rbxlx | Trop complexes pour du code (665 parts pour le Saloon) |
| **Props** (barils, wagon…) | `import_build` MCP → dans le .rbxlx | Idem |
| **NPCs** | MapBuilder code (runtime) | Doivent être dynamiques (ProximityPrompt, animations) |
| **Spawn points** | MapBuilder code (runtime) | GoldSpawner les cherche dynamiquement |
| **Falaises + passage** | MapBuilder code (grosses Parts Rock) | Formes simples, mieux en code |
| **Sentiers** | MapBuilder code (Parts Ground) | Bandes simples |
| **Panneau zone** | MapBuilder code | SurfaceGui dynamique |

### Workflow par step

1. **Code d'abord** : MapBuilder crée terrain, spawn, falaises, sentiers, NPCs, spawn points
2. **MCP ensuite** : on importe les builds (bâtiments + props) aux positions exactes
3. **Playtest** : valider le tout

---

## 8. Steps d'exécution

### STEP 0 — Fondations

| # | Action | Fichier | Détail |
|---|--------|---------|--------|
| 0.1 | Terrain Smooth 1200×1200 (sable) | MapBuilder:`CreateWorld` | `Workspace.Terrain:FillBlock()` material Sand |
| 0.2 | SpawnLocation à (−304, 0, −381) | MapBuilder:`CreateWorld` | Invisible, CanCollide=false |
| 0.3 | StreamingEnabled = true | via `execute_luau` MCP | MinRadius=128, TargetRadius=1536 |
| 0.4 | ZoneConfig WorldPosition Z1 | `ZoneConfig.lua` | (−395, 0, −199) |
| 0.5 | Dossiers Map/Zone1 | MapBuilder:`CreateFolders` | + Zone1_RiviereTransquille |

### STEP 1 — Cabane du Grand-Père

| # | Action | Détail |
|---|--------|--------|
| 1.1 | Import `dusthaven/bivouac` | Position (−304, 0, −381) via MCP |
| 1.2 | Import `dusthaven/fireplace` | ~3 studs à côté de la cabane |
| 1.3 | SpawnLocation invisible par-dessus | Overlap avec le sol de la cabane |

### STEP 2 — Rivière

| # | Action | Détail |
|---|--------|--------|
| 2.1 | Terrain Water : 9 waypoints | R1→R5, interpolation cubique entre points |
| 2.2 | Berges surélevées | Terrain FillBlock +1 stud le long des rives |
| 2.3 | Zones peu profondes aux batée | Terrain Water minus 1-2 studs de profondeur |

Utiliser `Workspace.Terrain:FillRegion()` ou `:FillBlock()` avec material Water le long des 9 segments.

### STEP 3 — Pont

| # | Action | Détail |
|---|--------|--------|
| 3.1 | Générer pont en bois | Position (−176, 0, −378), rotation −15° |
| 3.2 | 12 × 6 studs, planches + rambardes | Material Wood, ~30 parts |
| 3.3 | Tester walkability | Le joueur doit pouvoir traverser sans tomber |

### STEP 4 — Falaises + Passage

| # | Action | Détail |
|---|--------|--------|
| 4.1 | Falaise Est | Cluster de grandes Parts Rock |
| | | X ∈ [−55, +100], Z ∈ [−320, −200], H = 30-50 studs |
| 4.2 | Falaise Ouest | Cluster de grandes Parts Rock |
| | | X ∈ [−250, −95], Z ∈ [−320, −200], H = 30-50 studs |
| 4.3 | Crête arrière | Derrière le Saloon, basse (~15 studs) |
| 4.4 | Passage — mur est | X ≈ −57, de Z=−343 à Z=−273, H = 35 studs |
| 4.5 | Passage — mur ouest | X ≈ −94, de Z=−343 à Z=−273, H = 35 studs |
| 4.6 | Sentier dans le passage | Part Ground 6 × 70 studs dans l'axe |

### STEP 5 — Dusthaven : Bâtiments

| # | Action | Position | Rotation |
|---|--------|----------|----------|
| 5.1 | Import `dusthaven/saloon` | (−75, 0, −213) | 0° |
| 5.2 | Import `dusthaven/general_store` | (−53, 0, −236) | +8° |
| 5.3 | Import `dusthaven/sheriff` | (−99, 0, −234) | −8° |
| 5.4 | Import `dusthaven/forge` | (−96, 0, −261) | −5° |
| 5.5 | Ajuster Y au terrain | raycast vers le bas pour chaque build |

### STEP 6 — Dusthaven : Props

| # | Action | Position |
|---|--------|----------|
| 6.1 | Import `dusthaven/barrels` | (−65, 0, −228) |
| 6.2 | Import `dusthaven/wagon` | (−56, 0, −271) |
| 6.3 | Import `dusthaven/trough` | (−106, 0, −251) |
| 6.4 | Import `dusthaven/crates` | (−108, 0, −269) |
| 6.5 | Import `dusthaven/fireplace` | (−75, 0, −235) |
| 6.6 | Import `dusthaven/fence` × 4-6 | pourtour de la clairière |
| 6.7 | Import `dusthaven/lantern` × 4 | aux 4 coins de l'arc |
| 6.8 | Code : poteau d'attache | (−96, 0, −246) |
| 6.9 | Code : enclume | (−89, 0, −272) |
| 6.10 | Sol clairière (terre battue) | ellipse 68 × 62 studs, Material Ground |

### STEP 7 — Sentiers

| # | Sentier | Waypoints |
|---|---------|-----------|
| 7.1 | A : Cabane → Rivière | (−304, −381) → (−340, −400) |
| 7.2 | B : Cabane → Pont | (−304, −381) → (−240, −380) → (−176, −378) |
| 7.3 | C : Pont → Passage nord | (−176, −378) → (−130, −360) → (−75, −343) |
| 7.4 | D : Sentier principal (rive gauche) | suit la rivière, de (−340, −400) vers le sud |

Chaque segment : Part Ground, 6 studs de large, couleur terre battue (130, 105, 65).

### STEP 8 — NPCs

| # | Action | Détail |
|---|--------|--------|
| 8.1 | Mettre à jour `NPC_DATA` | 5 nouvelles positions (voir §4) |
| 8.2 | Playtest NPCs | Vérifier ProximityPrompt, position correcte |

### STEP 9 — Zone de Minage

| # | Action | Détail |
|---|--------|--------|
| 9.1 | Dossier `Zone1_RiviereTransquille` | dans Workspace.Map |
| 9.2 | Batée Station 1 | Ponton bois à (−353, 0, −423), 4 spawn points |
| 9.3 | Batée Station 2 | Ponton bois à (−428, 0, −150), 4 spawn points |
| 9.4 | Batée Station 3 | Ponton bois à (−405, 0, −23), 4 spawn points |
| 9.5 | Panneau "Dead Man's Shallows" | poteau + sign à (−353, 0, −430) |
| 9.6 | Rochers décoratifs | 8-10 le long de la rivière |

### STEP 10 — Playtest complet

| # | Test | Validation |
|---|------|-----------|
| 10.1 | Spawn | Le joueur apparaît dans la Cabane |
| 10.2 | Game loop | Cabane → Rivière → Mine → Cabane → Pont → Dusthaven → Vendre → Retour |
| 10.3 | NPCs | 5 NPCs cliquables avec ProximityPrompt |
| 10.4 | Gold spawns | Paillettes apparaissent aux 12 spawn points |
| 10.5 | Achat outil | Jake vend des outils ✓ |
| 10.6 | Vente or | Marcel achète l'or ✓ |
| 10.7 | Passage | Le passage entre les falaises est walkable, effet de révélation |
| 10.8 | Console | Pas d'erreurs dans le Output |

---

## 9. Fichiers à modifier

| Fichier | Changement |
|---------|------------|
| **`MapBuilder.lua`** → `CreateWorld()` | Terrain Smooth 1200×1200 sable, spawn (−304, −381), sol clairière |
| **`MapBuilder.lua`** → `CreateWesternDecor()` | Réécrire : falaises, passage, sentiers, poteau, enclume |
| **`MapBuilder.lua`** → `CreateMiningZone()` | 3 batée stations, 12 SP aux nouvelles coords, panneau |
| **`MapBuilder.lua`** → `NPC_DATA` | 5 nouvelles positions (devant bâtiments) |
| **`ZoneConfig.lua`** | WorldPosition Z1 → (−395, 0, −199) |
| **`GoldSpawner.lua`** | Vérifier compatibilité avec les nouveaux spawn points |

---

## 10. Assets — Récapitulatif Zone 1

### Depuis build-library (import MCP)

| Build ID | Rôle | Parts | Quantité |
|----------|------|-------|----------|
| `dusthaven/bivouac` | Cabane spawn | 31 | ×1 |
| `dusthaven/saloon` | Saloon de Belle | 665 | ×1 |
| `dusthaven/general_store` | Magasin de Silas | 331 | ×1 |
| `dusthaven/sheriff` | Bureau du Sheriff | 413 | ×1 |
| `dusthaven/forge` | Forge de Gustave | 113 | ×1 |
| `dusthaven/wagon` | Charrette déco | 55 | ×1 |
| `dusthaven/barrels` | Barils déco | 8 | ×1 |
| `dusthaven/crates` | Caisses déco | 4 | ×1 |
| `dusthaven/trough` | Abreuvoir | 11 | ×1 |
| `dusthaven/fireplace` | Feu de camp | 40 | ×2 |
| `dusthaven/fence` | Clôtures | 62 | ×4-6 |
| `dusthaven/lantern` | Lanternes | 3 | ×4 |
| **Sous-total** | | | **~2 000 parts** |

### À générer (code ou MCP generate_build)

| Élément | Description | Parts estimées |
|---------|-------------|---------------|
| Pont en bois | 12 × 6 studs, planches + rambardes | ~30 |
| 3 Batée stations | Petits pontons 8 × 8 studs | ~60 |
| Panneau zone | Poteau + planche | ~5 |

### Créés par code (MapBuilder)

| Élément | Description |
|---------|-------------|
| Terrain sable | Smooth Terrain FillBlock |
| Rivière | Smooth Terrain Water, 9 segments |
| Falaises (×2) + crête | Grandes Parts Rock |
| Murs passage | Parts Rock |
| Sentiers (×4) | Parts Ground |
| Sol clairière | Part Ground elliptique |
| Poteau d'attache | 2 Parts Wood |
| Enclume | 1 Part Metal |
| Spawn points (×12) | Parts invisibles |
| Rochers déco | Parts Rock + SpecialMesh |

---

## 11. Vue schématique (ASCII)

```
Z = -600 (NORD)
                            R1(−510,−600) ← rivière entre
                              ↓
                        R1.5(−467,−546)
                              ↓
CABANE(−304,−381) ----→ PONT(−176,−378)
    ↓ (vers rivière)           ↓
  R2(−360,−488) ←←←    ↓ (sentier C)
    ↓ (batée 1)         ↓
  R2.5(−249,−414)       ↓
    ↓                   ↓
  R3(−240,−323) ←←← ↓
    ↓               passage(−75,−343 → −273)
  R3.5(−354,−244)     ↓
    ↓             CLAIRIÈRE
  R4(−503,−195)   [Forge]   [Magasin]
    ↓              [Sheriff]  [Barils]
  R4.5(−554,−123)    [Saloon - centre]
    ↓
  R5(−480,−45)  ← batée 3
    ↓
Z = +27 ═══ FRONTIÈRE Z1/Z2 ═══
```

---

## 12. Questions de validation

1. **Les positions calculées correspondent-elles bien aux plans SVG ?**
   (surtout le triangle Cabane–Pont–Dusthaven)

2. **4 bâtiments suffisent ?** L'overview montre 5 markers, mais le plan détaillé n'en a que 4. Marcel peut être devant le Magasin sans bâtiment dédié.

3. **Falaises en code (Parts Rock) ou en Terrain ?** Les Parts donnent un contrôle précis de la forme, le Terrain est plus organique. Recommandation : Parts pour le passage (murs nets), Terrain pour les masses arrière.

4. **Ordre de build validé ?**
   Fondations → Cabane → Rivière → Pont → Falaises → Bâtiments → Props → Sentiers → NPCs → Mining → Playtest

5. **Pont : générer via MCP ou coder en Parts simples ?** Un pont simple (planches + rambardes) peut être codé en ~15 Parts. Pas besoin d'un build library pour ça.
