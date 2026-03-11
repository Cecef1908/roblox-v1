Nregistre # 🏆 Gold Rush Legacy — Guide Ressources Dev Roblox

> Document de référence pour le développeur externe travaillant sur Gold Rush Legacy.
> Thème : Wild West / Gold Rush — Mining game, NPCs, économie, assets western.
> Mis à jour : 11 Mars 2026
>
> **Voir aussi les guides détaillés dans `docs/guides/` :**
> - [`3d-assets-guide.md`](guides/3d-assets-guide.md) — Guide complet création d'assets 3D (Meshy, Sloyd, Roblox Cube, Blender, specs import)
> - [`ai-dev-workflow-guide.md`](guides/ai-dev-workflow-guide.md) — Workflow Claude Code + MCP + Rojo pour dev Roblox
> - [`luau-best-practices.md`](guides/luau-best-practices.md) — Architecture code, patterns tycoon, sécurité, performance
> - [`publishing-monetization-guide.md`](guides/publishing-monetization-guide.md) — Creator Programs 2026, monétisation, SEO, marketing

---

## 📑 Table des Matières

1. [Animations](#1-animations)
2. [Outils & Systèmes Pré-construits](#2-outils--systèmes-pré-construits)
3. [Assets 3D Gratuits](#3-assets-3d-gratuits)
4. [Documentation Officielle Roblox](#4-documentation-officielle-roblox)
5. [Tutoriels Vidéo Recommandés](#5-tutoriels-vidéo-recommandés)
6. [Outils IA pour le Dev](#6-outils-ia-pour-le-dev)

---

## 1. ANIMATIONS

### 📦 Catalogue d'animations — Creator Store

| Lien | Description |
|------|-------------|
| [Creator Store — Animations (recherche libre)](https://create.roblox.com/store/models?keyword=animation) | Point d'entrée principal pour rechercher toutes les animations gratuites |
| [FREE ANIMATIONS Pack](https://create.roblox.com/store/asset/5451911125/FREE-ANIMATIONS) | Pack d'animations gratuites variées, téléchargeable directement |
| [Pickaxe (asset)](https://create.roblox.com/store/asset/11861768348/Pickaxe) | Modèle de pickaxe avec setup tool |
| [Pickaxe classique](https://create.roblox.com/store/asset/231473050) | Autre variante de pickaxe, gratuit |
| [Animations Pack](https://create.roblox.com/store/asset/13782675869/Animations) | Pack animations génériques |
| [Creator Store — Recherche "mining"](https://create.roblox.com/store/models?keyword=mining+animation) | Rechercher "mining animation" pour trouver des anims de minage |
| [Creator Store — Recherche "tool swing"](https://create.roblox.com/store/models?keyword=tool+swing+animation) | Rechercher des animations de swing d'outil |
| [Creator Store — Recherche "celebrating"](https://create.roblox.com/store/models?keyword=celebrating+animation) | Animations de célébration pour NPCs |
| [Creator Store — Recherche "NPC idle"](https://create.roblox.com/store/models?keyword=NPC+idle+animation) | Animations idle pour NPCs |

> 💡 **Tip** : Sur le Creator Store, filtrer par **Type = Animation** et **Prix = Gratuit** pour trier les résultats.

---

### 🎓 Tutoriels — Animation Editor (Officiel Roblox)

| Lien | Description |
|------|-------------|
| [Animation Editor — Doc officielle](https://create.roblox.com/docs/animation/editor) | Guide complet de l'Animation Editor intégré à Roblox Studio |
| [Créer une animation — Tutoriel officiel](https://create.roblox.com/docs/tutorials/use-case-tutorials/animation/create-an-animation) | Tutoriel pas-à-pas pour créer sa première animation |
| [Travailler avec l'Animation Editor](https://create.roblox.com/docs/tutorials/curriculums/animator/work-with-the-animation-editor) | Curriculum complet pour maîtriser l'Animation Editor |
| [Jouer une animation (script)](https://create.roblox.com/docs/tutorials/curriculums/animator/play-your-animation) | Comment déclencher une animation via script Luau |
| [Classe Animator — Référence](https://create.roblox.com/docs/reference/engine/classes/Animator) | Référence API complète de la classe Animator |
| [Classe AnimationTrack — Référence](https://create.roblox.com/docs/reference/engine/classes/AnimationTrack) | Référence API pour les tracks d'animation |

---

### 🔧 Tutoriels — Animer un outil / Weapon dans Roblox Studio

| Lien | Description |
|------|-------------|
| [How to animate Tool Parts (Guns, Knives) — DevForum](https://devforum.roblox.com/t/how-to-animate-tool-parts-guns-knifes-etc/359484) | Tutoriel de référence (par Headstackk, auteur du framework Weaponry) — Inclut armes + outils |
| [How to animate tools — the easiest way (melee) — DevForum](https://devforum.roblox.com/t/how-to-animate-tools-the-easiest-and-best-way-for-melees/1654589) | Approche simplifiée pour animer des outils de mêlée |
| [Animate tool with Motor6D — idle, attaques, inspect — DevForum](https://devforum.roblox.com/t/how-to-animate-your-tool-using-motor6d-fully-customizeable-idle-unsheathing-multiple-attacks-inspect-animations-and-sound-effects/3026706) | Tutoriel avancé 2024 : idle, dégainer, multi-attaques, sons |
| [How to Create Tools and Animate Them — DevForum](https://devforum.roblox.com/t/how-to-create-tools-and-animate-them-tutorial/1381513) | Tutoriel complet création + animation d'outil |

---

### 🔔 Tutoriels — ProximityPrompt (Interaction NPC)

| Lien | Description |
|------|-------------|
| [ProximityPrompt — Doc officielle](https://create.roblox.com/docs/ui/proximity-prompts) | Guide complet sur les ProximityPrompts pour les interactions NPC |
| [Adding Proximity Prompts — Tutoriel officiel](https://create.roblox.com/docs/tutorials/building/ui/proximity-prompts) | Tutoriel pas-à-pas pour ajouter des ProximityPrompts |
| [Classe ProximityPrompt — Référence API](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt) | Documentation API complète de la classe |

---

### 🧩 Frameworks d'animation populaires (DevForum)

| Lien | Description |
|------|-------------|
| [Weaponry Framework — DevForum (Headstackk)](https://devforum.roblox.com/t/how-to-animate-tool-parts-guns-knifes-etc/359484) | Framework weapon/tool le plus référencé — gère les animations d'outils avec Motor6D |
| [ReplicaService — Mad Studio](https://devforum.roblox.com/t/save-your-player-data-with-profileservice-datastore-module/667805) | Système de réplication d'état / animations entre server et client |
| [Knit Framework](https://sleitnick.github.io/Knit/) | Framework léger pour structurer le code — compatible avec les systèmes d'animation |

---

## 2. OUTILS & SYSTÈMES PRÉ-CONSTRUITS

### 🛠️ Tool Systems — Creator Store

| Lien | Description |
|------|-------------|
| [Creator Store — Recherche "tool system"](https://create.roblox.com/store/models?keyword=tool+system) | Systèmes d'outils gratuits disponibles |
| [Creator Store — Weapons](https://create.roblox.com/store/models/categories/weapons) | Catégorie armes & outils du Creator Store |
| [Tool — Documentation officielle](https://create.roblox.com/docs/players/tools) | Doc officielle sur le système Tool de Roblox |

---

### ⚔️ Weapon / Tool Frameworks

| Lien | Description |
|------|-------------|
| [Tutoriel Weaponry (Headstackk)](https://devforum.roblox.com/t/how-to-animate-tool-parts-guns-knifes-etc/359484) | Framework d'animation d'outils le plus populaire sur DevForum — référence absolue |
| [Knit Framework — GitHub Docs](https://sleitnick.github.io/Knit/) | Framework léger client/server pour structurer les systèmes d'outils |

---

### 🎒 Inventory Systems (Gratuits / Open Source)

| Lien | Description |
|------|-------------|
| [InventoryMaker — DevForum (2025)](https://devforum.roblox.com/t/inventorymaker-a-framework-to-help-you-create-your-own-inventory-system/3619173) | Framework open-source récent (2025) pour créer un système d'inventaire — PC & Mobile |
| [Open Source Advanced Inventory System — DevForum](https://devforum.roblox.com/t/open-source-advanced-inventory-system/511932) | Système complet avec DataStore save, équipement, hotbar |

---

### 🏪 Shop / Currency Systems

| Lien | Description |
|------|-------------|
| [Shop Model FREE — Creator Store](https://create.roblox.com/store/asset/2994923203/Shop-Model-FREE) | Modèle de shop gratuit, prêt à l'emploi |
| [SHOP asset — Creator Store](https://create.roblox.com/store/asset/7103679597/SHOP) | Autre variante de shop scriptée |
| [Creator Store — Recherche "currency system"](https://create.roblox.com/store/models?keyword=currency+system) | Systèmes de monnaie in-game disponibles |
| [Creator Store — Recherche "shop system"](https://create.roblox.com/store/models?keyword=shop+system) | Systèmes de boutique disponibles |

---

### 💾 DataStore Wrappers Populaires

| Lien | Description |
|------|-------------|
| [ProfileStore (successeur de ProfileService)](https://madstudioroblox.github.io/ProfileStore/) | **Recommandé 2025** — Wrapper DataStore session-locked, auto-save, par Mad Studio |
| [ProfileService — GitHub](https://github.com/MadStudioRoblox/ProfileService) | Version précédente (stable mais non maintenue) — encore très utilisée |
| [ProfileService — DevForum](https://devforum.roblox.com/t/save-your-player-data-with-profileservice-datastore-module/667805) | Thread DevForum avec documentation et exemples |
| [DataStore2 — Documentation](https://kampfkarren.github.io/Roblox/) | Wrapper DataStore classique avec backup auto |
| [DataStore2 — GitHub (Kampfkarren)](https://github.com/Kampfkarren/Roblox/tree/master/DataStore2) | Code source DataStore2 |

---

### 💬 NPC Dialogue Systems

| Lien | Description |
|------|-------------|
| [Advanced Dialogue System + Node Editor — DevForum](https://devforum.roblox.com/t/advanced-dialogue-system-node-editor/1526346) | Système de dialogue avancé avec éditeur visuel node-based |
| [Dialogue Kit V1/V2 — DevForum](https://devforum.roblox.com/t/dialogue-kit-v1-create-npc-dialogues-with-ease/2495891) | Kit de dialogue NPC facile à intégrer via ModuleScript |
| [Easy Dialogue System — Open Source — DevForum](https://devforum.roblox.com/t/open-source-easy-dialogue-system/3061677) | Système open-source de dialogue, régulièrement mis à jour (2024) |
| [NPC Dialogue System Tutorial — DevForum 2025](https://devforum.roblox.com/t/npc-dialogue-system/3784395) | Tutoriel récent inspiré de jeux comme Fisch et Grow a Garden |

---

### 🏆 Leaderboard Systems

| Lien | Description |
|------|-------------|
| [Leaderboards — Doc officielle Roblox](https://create.roblox.com/docs/players/leaderboards) | Guide officiel pour créer des leaderboards in-game |
| [Free Open Source Global Leaderboard — DevForum](https://devforum.roblox.com/t/free-open-source-global-leaderboard/2585053) | Module leaderboard global open-source |

---

## 3. ASSETS 3D GRATUITS

### ⛏️ Mining Equipment — Creator Store

| Lien | Description |
|------|-------------|
| [Creator Store — Recherche "mining"](https://create.roblox.com/store/models?keyword=mining) | Tous les assets de mining disponibles |
| [Creator Store — Recherche "pickaxe"](https://create.roblox.com/store/models?keyword=pickaxe) | Pickaxes 3D variées |
| [Creator Store — Recherche "mining equipment"](https://create.roblox.com/store/models?keyword=mining+equipment) | Équipements de minage (carts, drills, etc.) |
| [Creator Store — Recherche "ore rocks"](https://create.roblox.com/store/models?keyword=ore+rocks) | Rochers avec minerai |
| [Creator Store — Recherche "gold nugget"](https://create.roblox.com/store/models?keyword=gold+nugget) | Pépites d'or et gemmes |

---

### 🤠 Wild West / Gold Rush — Packs Recommandés

| Lien | Description |
|------|-------------|
| [Creator Store — Recherche "wild west"](https://create.roblox.com/store/models?keyword=the+wild+west) | Résultats direct pour le thème Wild West |
| [Creator Store — Recherche "western"](https://create.roblox.com/store/models?keyword=western+building) | Buildings western (saloon, sheriff, bank...) |
| [Creator Store — Recherche "saloon"](https://create.roblox.com/store/models?keyword=saloon) | Saloons 3D pour décor western |
| [Creator Store — Recherche "canyon"](https://create.roblox.com/store/models?keyword=canyon+rocks) | Canyons et rochers style désert |
| [Creator Store — Recherche "river"](https://create.roblox.com/store/models?keyword=river) | Rivières et cours d'eau |
| [Creator Store — Recherche "trees nature"](https://create.roblox.com/store/models?keyword=western+trees) | Arbres style western/désert |
| [Sketchfab — Wild West Asset Pack (free)](https://sketchfab.com/3d-models/wild-west-asset-pack-eb461d88fae04ff6a5bfbb00839380fb) | Pack gratuit Sketchfab : barrel, crate, poker table, bar, cowboy hat, etc. — importable dans Studio |

> ⚠️ **Note** : Pour les packs payants Wild West haute qualité, consulter [BuiltByBit — Wild West](https://builtbybit.com/tags/wild-west/) (modèles Roblox premium).

---

### 🌿 Rocks, Trees, Nature

| Lien | Description |
|------|-------------|
| [Creator Store — Recherche "rocks"](https://create.roblox.com/store/models?keyword=rocks) | Rochers variés |
| [Creator Store — Recherche "trees"](https://create.roblox.com/store/models?keyword=low+poly+trees) | Arbres low poly |
| [Free Stylized Assets (orcaenvironments) — DevForum](https://devforum.roblox.com/t/free-stylized-assets-by-orcaenvironments/2737986) | Pack gratuit de rochers et arbres stylisés |

---

### 🤖 Outils IA pour Génération 3D — Vue d'ensemble

> **Guide complet :** voir [`docs/guides/3d-assets-guide.md`](guides/3d-assets-guide.md) pour les détails, prompts, pricing, et workflows.

| Outil | Prix | Points forts | Idéal pour |
|-------|------|-------------|------------|
| **Roblox Cube** | Gratuit (natif Studio) | Zero friction, tapez `/generate` dans Studio | Prototypage rapide, props basiques |
| **Sloyd** | $15/mois | Plugin natif Studio, génération illimitée, presets Roblox | Props en masse, production |
| **Meshy.ai** | $20/mois (Pro) | Textures riches, preset Roblox, remesh | Hero assets, modèles texturés |
| **Blender** | Gratuit | Contrôle total, cleanup post-IA | Retouches, optimisation |

**Pipeline recommandé (~$35/mois) :**
1. **Prototype** → Roblox Cube (gratuit, dans Studio)
2. **Props en masse** → Sloyd ($15/mo, plugin Studio)
3. **Hero assets** → Meshy Pro ($20/mo, textures riches)
4. **Cleanup** → Blender (gratuit, réduction poly, UV)

**Specs import Roblox :** Max 10,000 triangles/MeshPart, FBX/OBJ, textures ≤1024x1024 sur mesh (4096x4096 séparément)

---

## 4. DOCUMENTATION OFFICIELLE ROBLOX

### 📚 Liens Essentiels — create.roblox.com/docs

| Sujet | Lien | Description |
|-------|------|-------------|
| **Animation System** | [create.roblox.com/docs/animation](https://create.roblox.com/docs/animation) | Vue d'ensemble du système d'animation Roblox |
| **Animation Editor** | [create.roblox.com/docs/animation/editor](https://create.roblox.com/docs/animation/editor) | Documentation de l'éditeur d'animation intégré |
| **Tool System** | [create.roblox.com/docs/players/tools](https://create.roblox.com/docs/players/tools) | Système d'outils Roblox (Tool class) |
| **Tool (API Ref)** | [create.roblox.com/docs/reference/engine/classes/Tool](https://create.roblox.com/docs/reference/engine/classes/Tool) | Référence API complète de la classe Tool |
| **ProximityPrompt** | [create.roblox.com/docs/ui/proximity-prompts](https://create.roblox.com/docs/ui/proximity-prompts) | Système de prompts d'interaction avec les NPCs |
| **DataStore** | [create.roblox.com/docs/scripting/data/data-stores](https://create.roblox.com/docs/scripting/data/data-stores) | Système de sauvegarde de données joueurs |
| **DataStoreService (API)** | [create.roblox.com/docs/reference/engine/classes/DataStoreService](https://create.roblox.com/docs/reference/engine/classes/DataStoreService) | Référence API DataStoreService |
| **RemoteEvents** | [create.roblox.com/docs/scripting/events/remote](https://create.roblox.com/docs/scripting/events/remote) | Communication client ↔ server via RemoteEvents |
| **RemoteEvents & Functions** | [create.roblox.com/docs/scripting/events/remote-events-and-functions](https://create.roblox.com/docs/scripting/events/remote-events-and-functions) | Guide complet RemoteEvents + RemoteFunctions |
| **Terrain Editor** | [create.roblox.com/docs/studio/terrain-editor](https://create.roblox.com/docs/studio/terrain-editor) | Outil de création de terrain dans Studio |
| **Terrain (Parts)** | [create.roblox.com/docs/parts/terrain](https://create.roblox.com/docs/parts/terrain) | Documentation Terrain environnemental |
| **Lighting & Effects** | [create.roblox.com/docs/environment](https://create.roblox.com/docs/environment) | Vue d'ensemble Lighting & effets visuels |
| **Atmosphere** | [create.roblox.com/docs/building-and-visuals/lighting-and-effects/atmospheric-effects](https://create.roblox.com/docs/building-and-visuals/lighting-and-effects/atmospheric-effects) | Effets atmosphériques (brume, haze...) — parfait pour ambiance western |
| **Atmosphere (API)** | [create.roblox.com/docs/reference/engine/classes/Atmosphere](https://create.roblox.com/docs/reference/engine/classes/Atmosphere) | Référence API classe Atmosphere |
| **Leaderboards** | [create.roblox.com/docs/players/leaderboards](https://create.roblox.com/docs/players/leaderboards) | Système de classement in-game |
| **MCP Server (built-in)** | [devforum.roblox.com — MCP Server Built-in](https://devforum.roblox.com/t/assistant-updates-studio-built-in-mcp-server-and-playtest-automation/4474643) | Annonce officielle du MCP Server intégré dans Roblox Studio |
| **Roblox Assistant** | [create.roblox.com/docs/assistant/guide](https://create.roblox.com/docs/assistant/guide) | Guide de l'assistant IA intégré dans Studio |

---

## 5. TUTORIELS VIDÉO RECOMMANDÉS

### 📺 Chaînes YouTube de Référence

| Chaîne | Lien | Spécialité |
|--------|------|------------|
| **AlvinBlox** | [youtube.com/c/alvinblox](https://www.youtube.com/c/alvinblox) | Tutoriels scripting complets, idéal débutants et intermédiaires — 10+ ans d'expérience Roblox |
| **TheDevKing** | [Playlist Scripting Avancé](https://www.youtube.com/playlist?list=PLhieaQmOk7nIoGnFoACf33M3o0BOqB38a) | Scripting avancé Roblox Studio |
| **Roblox Official** | [Roblox Education YouTube](https://www.youtube.com/@RobloxDeveloper) | Tutoriels officiels Roblox |

---

### 🎮 Tutoriels Spécifiques — Tycoon Game

| Lien | Description |
|------|-------------|
| [How To Make A TYCOON On Roblox — 2024 (Playlist)](https://www.youtube.com/playlist?list=PLsbxI7NIoTtgsjWxJt34TaQd5vDwpbL3V) | Série complète 2024 — tycoon de A à Z |
| [Roblox Tycoon Scripting Tutorial (Part 1)](https://www.youtube.com/watch?v=m-fN3ww_PzU) | Cash system, items achetables, save functionality |
| [How To MAKE A Tycoon Game — Part 1 Setup (AlvinBlox)](https://www.youtube.com/watch?v=5pKD2PdWLP8) | Série tycoon par AlvinBlox — très bien expliquée |

---

### ⛏️ Tutoriels Spécifiques — Mining Game

| Lien | Description |
|------|-------------|
| [How to Make a MINING GAME in ROBLOX](https://www.youtube.com/watch?v=ESKlqExIA84) | Mining game complet — démo du système |
| [Roblox Studio Tutorial: Mining Game (Making the Tool)](https://www.youtube.com/watch?v=iwIm4pG_b8w) | Créer l'outil de minage + script |
| [How to make a MINING SIMULATOR GAME](https://www.youtube.com/watch?v=ndRm6tl3Gtk) | Mining simulator avec modèles |
| [Roblox Studio Mining System (Playlist complète)](https://www.youtube.com/playlist?list=PLB6uqJrVxufvb0Jt_YKUP5U6rC11xpMOy) | Playlist dédiée au système de minage |
| [Infinite Mining Game — ber.gg](https://www.youtube.com/watch?v=_wBfwupqmt8) | Mining game infini type Azure Mines |

---

### 🤖 Tutoriels Spécifiques — NPC System

| Lien | Description |
|------|-------------|
| [How to Make NPC in Roblox Studio 2025](https://www.youtube.com/watch?v=LfHHxYUpfto) | Créer un NPC avec clothing et accessories |
| [How to make NPC Dialogues — 2024](https://www.youtube.com/watch?v=N66pf5jCirc) | Dialogues NPC setup complet 2024 |
| [How to Make an Enemy NPC — 2024](https://www.youtube.com/watch?v=S73ssg7PwHQ) | NPC ennemi qui chasse et attaque |
| [Working NPC with Animation & Chat System](https://www.youtube.com/watch?v=qSzLJ4Hy4Ko) | NPC avec animation + système de chat |
| [How to Make Idle Animation for NPCs](https://www.youtube.com/watch?v=twUs3rE-eIw) | Animation idle pour NPCs en 2024 |

---

## 6. OUTILS IA POUR LE DEV

> **Guide complet :** voir [`docs/guides/ai-dev-workflow-guide.md`](guides/ai-dev-workflow-guide.md) pour le setup détaillé, configs, et workflow recommandé.

### 🤖 MCP Servers — Vue d'ensemble

| Option | Type | Setup | Points forts |
|--------|------|-------|-------------|
| **Studio Built-in** | Natif | Zero config (Studio settings) | Recommandé, toujours à jour, playtest automation |
| **Rust officiel** | Open-source | `cargo run` ([GitHub](https://github.com/Roblox/studio-rust-mcp-server)) | Customizable, 6 tools |
| **boshyxd** | Communautaire | Plugin + serveur ([GitHub](https://github.com/boshyxd/robloxstudio-mcp)) | 50+ tools, read/write scripts, grep |

**Workflow recommandé :** 2 terminaux (Rojo serve + Claude Code) + Studio ouvert pour le visuel/playtest.

### 🧠 Autres outils IA

| Outil | Usage |
|-------|-------|
| **Roblox Assistant** ([doc](https://create.roblox.com/docs/assistant/guide)) | IA built-in Studio — quick edits, debug, explication code |
| **Roblox Cube** | Générateur 3D natif Studio — `/generate` dans la command bar |
| **Sloyd** ([site](https://www.sloyd.ai/)) | Plugin Studio natif, génération 3D illimitée ($15/mo) |
| **Meshy.ai** ([site](https://www.meshy.ai/)) | Text/Image-to-3D, preset Roblox, textures PBR ($20/mo Pro) |

---

## 📌 Ressources Bonus

### DevForum Roblox — À bookmarker
- [DevForum — Community Resources](https://devforum.roblox.com/c/resources/community-resources/61) — Tous les modules et outils open-source de la communauté
- [DevForum — Community Tutorials](https://devforum.roblox.com/c/resources/community-tutorials/55) — Tutoriels rédigés par la communauté
- [DevForum — Scripting Support](https://devforum.roblox.com/c/help-and-feedback/scripting-support/6) — Aide scripting

### Creator Store — Point d'entrée principal
- [create.roblox.com/store/models](https://create.roblox.com/store/models) — Tous les modèles
- [create.roblox.com/store](https://create.roblox.com/store) — Store complet (audio, plugins, images, meshes)

---

*Document compilé pour Gold Rush Legacy — Hawk / La Guilde*
