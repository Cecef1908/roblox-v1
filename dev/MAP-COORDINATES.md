# Mapping Coordonnees 2D → Roblox 3D

## Terrain
- Taille : 1000 x 1000 studs
- Bounds : X=[0, 1000], Z=[0, 1000]
- Le terrain est le MEME entre notre .rbxlx et le projet partage Team Create
- Projet partage : "map final z1" (Team Create avec playda888, MehdiMM8888)

## Formule de conversion (2D map % → Roblox studs)

```
Roblox_X = 1084 - (map_x_percent * 10.76)
Roblox_Z = 1033 - (map_y_percent * 10)
```

Les axes sont INVERSES : x=0% sur la carte 2D = X elevé dans Roblox.

## Points de calibration confirmes

| Point | Map 2D (x%, y%) | Roblox (X, Z) | Confirme |
|-------|-----------------|---------------|----------|
| Meteorite (centre cratere) | (55.7, 54.8) | (484, 485) | OUI |
| Pont Nord (riviere) | (30.6, 52.2) | (754, 511) | OUI |

## Reperes cles du projet partage

| Element | Roblox (X, Y, Z) |
|---------|-------------------|
| SpawnLocation | (713, 34, 513) |
| CraterEntrance | (573, 45, 489) |
| CRATER_CENTER (NPCs) | (500, ?, 500) |

## Points cles de la carte 2D (a convertir)

| Element | Map 2D (x%, y%) | Roblox estime (X, Z) |
|---------|-----------------|---------------------|
| Cabane d'Eli | (28, 8) | (700, 930) |
| Spot Tutoriel | (32, 14) | (660, 870) |
| Meteorite | (48, 51) | (500, 500) |
| Jed (Marchand) | (44, 46) | (540, 550) |
| Saloon | (52, 45) | (460, 560) |
| Forge | (47, 53) | (510, 480) |
| Sheriff | (51, 52) | (470, 490) |
| Leaderboard | (48, 49) | (500, 520) |
| Gate Z2 | (10, 18) | (880, 830) |

## Remarques
- Precision actuelle : ~±20 studs (1 point de calibration)
- Besoin d'un 2e point pour precision exacte
- La carte 2D est `map.html` a la racine du repo
- L'image source est `map-z1.webp`
