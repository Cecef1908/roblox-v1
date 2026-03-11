# Setup Rojo + MCP pour Gold Rush Legacy (Windows)

Ce fichier est un prompt pour Claude Code. Colle-le dans ton terminal Claude Code ou suis les étapes.

---

## Prérequis

- **Roblox Studio** installé et ouvert
- **VS Code** avec Claude Code
- **Node.js** installé (pour le serveur MCP)

---

## Étape 1 — Installer Rokit (gestionnaire d'outils Roblox)

```powershell
# Télécharger et installer Rokit depuis https://github.com/rojo-rbx/rokit/releases
# Puis dans le dossier du projet :
rokit install
```

Ça installe automatiquement `rojo` et `wally` (définis dans `rokit.toml`).

Si Rokit ne marche pas, installe manuellement :
```powershell
# Rojo
cargo install rojo
# OU télécharge depuis https://github.com/rojo-rbx/rojo/releases

# Wally (package manager)
cargo install wally-cli
# OU télécharge depuis https://github.com/UpliftGames/wally/releases
```

---

## Étape 2 — Installer les packages Wally

```powershell
cd C:\chemin\vers\roblox-v1
wally install
```

Ça crée les dossiers `Packages/` et `ServerPackages/` avec les dépendances (Matter, ProfileStore, SimplePath).

---

## Étape 3 — Installer le plugin Rojo dans Roblox Studio

1. Ouvre Roblox Studio
2. Va dans **Plugins** > **Plugin Manager** > **Find Plugins**
3. Cherche **"Rojo"** (par LPGHatGuy)
4. Installe-le
5. Tu verras un bouton **Rojo** dans l'onglet Plugins

---

## Étape 4 — Lancer Rojo

```powershell
cd C:\chemin\vers\roblox-v1
rojo serve
```

Tu devrais voir :
```
Rojo server listening on port 34872
```

Puis dans Roblox Studio :
1. Clique sur le bouton **Rojo** dans l'onglet Plugins
2. Clique **Connect**
3. Les fichiers du filesystem se synchronisent en temps réel avec Studio

> **IMPORTANT** : Garde `rojo serve` lancé dans un terminal. Chaque modification de fichier `.lua` se reflète dans Studio en temps réel.

---

## Étape 5 — Installer le plugin MCP (Roblox Studio ↔ Claude Code)

Le plugin MCP permet à Claude Code de contrôler Roblox Studio (playtest, console, scripts, etc.).

### 5a. Installer le serveur MCP

```powershell
npm install -g robloxstudio-mcp
```

### 5b. Configurer Claude Code

Ajoute dans ton fichier `.mcp.json` à la racine du projet :

```json
{
  "mcpServers": {
    "robloxstudio-mcp": {
      "command": "npx",
      "args": ["-y", "robloxstudio-mcp"]
    }
  }
}
```

> Si le fichier `.mcp.json` existe déjà, ajoute juste l'entrée `robloxstudio-mcp` dans `mcpServers`.

### 5c. Installer le plugin Studio

1. Dans Roblox Studio, va dans **Plugins** > **Plugin Manager** > **Find Plugins**
2. Cherche **"MCP Plugin"** ou **"robloxstudio-mcp"**
3. Installe-le
4. Tu verras un widget **MCP** dans Studio — assure-toi qu'il est **activé** (vert)

> **Alternative** : Le plugin se trouve aussi sur le Creator Store. Cherche "Model Context Protocol" ou id `139020407630498`.

### 5d. Vérifier la connexion

Relance Claude Code (ou `/mcp` pour rafraîchir les serveurs MCP).
Claude Code devrait pouvoir utiliser les outils :
- `start_playtest` — lancer le jeu (F5)
- `stop_playtest` — arrêter
- `get_playtest_output` — lire la console (prints, errors)
- `execute_luau` — exécuter du code
- `get_instance_children` — explorer le workspace
- `capture_screenshot` — screenshot du viewport

---

## Étape 6 — Workflow de dev

```
1. Modifie un fichier .lua dans VS Code
2. Rojo sync automatiquement vers Studio
3. Claude Code lance le playtest via MCP : start_playtest
4. Claude Code lit la console : get_playtest_output
5. Si erreur → fix → re-playtest
```

---

## Vérification rapide

Tout est prêt quand :
- [ ] `rojo serve` tourne dans un terminal
- [ ] Le bouton Rojo dans Studio est **connecté** (vert)
- [ ] Le widget MCP dans Studio est **activé** (vert)
- [ ] Claude Code voit les outils MCP (`start_playtest`, etc.)

---

## Troubleshooting

| Problème | Solution |
|----------|----------|
| Rojo ne se connecte pas | Vérifie que `rojo serve` tourne. Clique Disconnect puis Reconnect dans Studio |
| MCP timeout | Vérifie que le widget MCP est activé dans Studio. Relance Studio si besoin |
| Plugin MCP pas trouvé | Installe manuellement depuis le Creator Store (id `139020407630498`) |
| `wally install` échoue | Vérifie que `wally` est dans ton PATH. Relance le terminal |
| Les changements ne se synchro pas | Vérifie que `default.project.json` existe et que Rojo pointe dessus |
