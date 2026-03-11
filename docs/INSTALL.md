# Gold Rush Legacy - Installation dans Roblox Studio

## Structure des fichiers

```
roblox/
├── ReplicatedStorage/
│   └── Config.lua                    → Configuration partagée (outils, zones, gemmes, prix)
├── ServerScriptService/
│   └── PlayerData.server.lua         → Économie, inventaire, progression, DataStore
├── StarterPlayerScripts/
│   └── GameClient.client.lua         → UI complète (HUD, shop, vente, loot popup, notifications)
├── Workspace/
│   ├── MapBuilder.server.lua         → Génère le monde (ville, rivière, 4 zones, NPCs)
│   └── MiningHandler.server.lua      → Gère les interactions de minage (ProximityPrompts)
└── INSTALL.md
```

## Installation rapide

1. **Ouvrir Roblox Studio** → Nouveau projet (Baseplate)

2. **Supprimer la Baseplate** existante dans Workspace

3. **Créer le module Config** :
   - Dans **ReplicatedStorage**, créer un ModuleScript nommé `Config`
   - Coller le contenu de `Config.lua`

4. **Importer les scripts serveur** :
   - `PlayerData.server.lua` → créer un Script dans **ServerScriptService**
   - `MapBuilder.server.lua` → créer un Script dans **ServerScriptService**
   - `MiningHandler.server.lua` → créer un Script dans **ServerScriptService**

5. **Importer le script client** :
   - `GameClient.client.lua` → créer un LocalScript dans **StarterPlayer > StarterPlayerScripts**

6. **Activer l'API** : Game Settings > Security > **Enable Studio Access to API Services** (pour DataStore)

7. **Tester** : cliquer sur ▶️ Play

## Gameplay (Core Loop)

```
🔍 PROSPECTER → ⛏️ EXTRAIRE → 💰 VENDRE → 🔄 RÉINVESTIR
```

1. Tu spawn sur la **place de la ville** (hub central)
2. Va vers la **Rivière Tranquille** (droite du spawn) — les spots dorés brillent
3. Approche-toi d'un spot et appuie sur **E** pour miner
4. Tu récoltes de l'or (paillettes, pépites...) et parfois des gemmes rares !
5. Retourne en ville chez **Marcel le Marchand** → vends ton or
6. Passe chez **Jake le Forgeron** → achète de meilleurs outils
7. Monte en niveau pour débloquer de nouvelles zones !

## Zones de minage

| Zone | Niveau | Richesse | Gemmes |
|------|--------|----------|--------|
| Rivière Tranquille | 1 | ⭐ | 5% |
| Ruisseau Doré | 2 | ⭐⭐ | 10% |
| Collines Ambrées | 3 | ⭐⭐⭐ | 20% |
| Grottes Cristallines | 4 | ⭐⭐⭐⭐ | 40% |

## Outils

| Outil | Prix | Rendement | Niveau |
|-------|------|-----------|--------|
| Batée | Gratuit | x1.0 | 1 |
| Batée Pro | $500 | x1.5 | 2 |
| Tapis d'orpaillage | $2,000 | x2.0 | 3 |
| Détecteur d'or | $8,000 | x3.0 | 4 |
| Foreuse industrielle | $25,000 | x5.0 | 5 |

## Progression

| Niveau | Titre | XP requis |
|--------|-------|-----------|
| 1 | 🥉 Amateur | 0 |
| 2 | 🥈 Orpailleur | 500 |
| 3 | 🥇 Prospecteur | 2,000 |
| 4 | 💎 Exploitant | 8,000 |
| 5 | 👑 Industriel | 25,000 |
