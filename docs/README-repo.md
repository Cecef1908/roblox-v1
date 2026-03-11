# Gold Rush Legacy — Documentation Projet

> Par **Aurum Works** (Moncef · Playda · Mehdi)

## Projet
Jeu Roblox d'orpaillage et mining tycoon. De prospecteur amateur à industriel milliardaire.

## Structure Documentation

```
docs/
├── README-repo.md                         # Ce fichier — index de toute la doc
├── ROADMAP-repo.md                        # Roadmap projet (source de vérité)
├── specs/
│   └── gold-rush-v1-tech-spec.md          # Architecture technique V1
├── plans/
│   ├── gold-rush-v1-enriched-gdd.md       # GDD enrichi V1 (analyse Dave the Diver)
│   └── gold-rush-v1-roadmap.md            # Roadmap détaillée Phase 1→4
├── briefs/
│   └── gold-rush-legacy-demo-spec.md      # Spec démo V1 jouable
├── guides/                                # ⬇️ NOUVEAUX — Guides de référence dev
│   ├── 3d-assets-guide.md                 # Création assets 3D (Meshy, Sloyd, Roblox Cube, Blender)
│   ├── ai-dev-workflow-guide.md           # Workflow Claude Code + MCP + Rojo
│   ├── luau-best-practices.md             # Architecture code, patterns tycoon, sécurité, perf
│   └── publishing-monetization-guide.md   # Creator Programs 2026, monétisation, SEO, marketing
roblox/
├── dev-resources-guide.md                 # Liens et ressources dev (animations, assets, tutos)
├── INSTALL.md                             # Guide d'installation dans Roblox Studio
└── map-2d-goldrush.png                    # Map 2D concept
```

**Fichiers Rojo à la racine du projet :**
```
roblox-v1/
├── default.project.json              # Rojo project config (rojo serve ici)
├── ReplicatedStorage/                # Modules partagés
├── ServerScriptService/              # Scripts serveur
├── StarterPlayerScripts/             # Scripts client
├── StarterGui/                       # GUI client
└── GoldRushLegacy.rbxlx              # Place file Studio
```

## Documents — Descriptions

### Specs
| Fichier | Description |
|---------|-------------|
| `specs/gold-rush-v1-tech-spec.md` | Architecture technique complète : stack Roblox/Luau, modules, systèmes de données, performance targets |

### Plans & GDD
| Fichier | Description |
|---------|-------------|
| `plans/gold-rush-v1-enriched-gdd.md` | **GDD enrichi V1** — analyse comparative Dave the Diver appliquée à GRL, features avancées |
| `plans/gold-rush-v1-roadmap.md` | Roadmap détaillée Phase 1→4 avec milestones, tâches et owners |

### Briefs
| Fichier | Description |
|---------|-------------|
| `briefs/gold-rush-legacy-demo-spec.md` | Spec fonctionnelle de la démo V1 jouable : features minimales, flow joueur |

### Guides de Référence (NEW)
| Fichier | Description |
|---------|-------------|
| `guides/3d-assets-guide.md` | **Guide complet assets 3D** — Meshy.ai (workflow, prompts, pricing), Sloyd (plugin Studio), Roblox Cube (IA native), Blender→Roblox, specs d'import mesh, optimisation, pipeline recommandé (~$35/mois) |
| `guides/ai-dev-workflow-guide.md` | **Workflow dev avec IA** — 3 MCP Servers (built-in, Rust, boshyxd), Claude Code + CLAUDE.md, Rojo toolchain (Rokit/Wally/Selene/StyLua), playtest automation, loop de debug IA |
| `guides/luau-best-practices.md` | **Best practices Luau** — Architecture services/controllers, ProfileStore, networking/sécurité, perf (object pooling, `--!native`), typed Luau, patterns tycoon/simulator complets avec code |
| `guides/publishing-monetization-guide.md` | **Publishing & monétisation** — Creator Programs 2026 (Incubator deadline 6 avril, Jumpstart rolling), Game Passes, Rewarded Video Ads, Regional Pricing, DevEx ($0.0038/Robux), SEO, marketing, analytics, live ops |

### Ressources Dev (dans `roblox/`)
| Fichier | Description |
|---------|-------------|
| `roblox/dev-resources-guide.md` | Index de liens : animations, outils, assets 3D Creator Store, doc officielle Roblox, tutos vidéo, outils IA |
| `roblox/INSTALL.md` | Guide d'installation des scripts dans Roblox Studio |

## Le Jeu
- **Nom** : Gold Rush Legacy
- **Genre** : Mining Tycoon / Simulator
- **Core Loop** : Prospecter → Extraire → Traiter → Vendre → Réinvestir
- **Plateforme** : Roblox (cross-platform auto)
- **Stack** : Roblox Studio (Luau) + Midjourney V7 + Meshy.ai + Sloyd + ElevenLabs

## Le Squad
- **Moncef** — Dev principal (Roblox Studio, Luau)
- **Mehdi** — Game Designer + QA
- **Playda** — Business Dev + Marketing

## Objectifs
- Publier un jeu Roblox jouable et rentable
- Candidater au programme Jumpstart de Roblox (+ Incubator si éligible)
- Générer des revenus via Game Passes, Creator Rewards, et Rewarded Video Ads

## Timeline
- **Phase 0** : Exploration ✅ (mars 2026)
- **Phase 1** : Pré-production (~fin mars 2026)
- **Phase 2** : Démo V1 (~fin avril 2026)
- **Phase 3** : Alpha (~juin 2026)
- **Phase 4** : Lancement (~juillet 2026)

## Deadlines importantes
- **6 avril 2026** — Deadline prioritaire Incubator Program Roblox
- **30 mars 2026** — Regional Pricing activé par défaut

---

*Documentation mise à jour — 11 Mars 2026.*
