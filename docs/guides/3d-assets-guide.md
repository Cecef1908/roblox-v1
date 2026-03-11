# Guide Complet : Creation d'Assets 3D pour Roblox (2025-2026)

> Recherche effectuee le 11 mars 2026. Focus sur les outils, workflows et specs actuels.

---

## Table des matieres

1. [Meshy.ai Workflow](#1-meshyai-workflow)
2. [Outils AI 3D Alternatifs](#2-outils-ai-3d-alternatifs)
3. [Outils 3D Traditionnels (Blender)](#3-outils-3d-traditionnels-blender)
4. [Specs d'Import Mesh Roblox](#4-specs-dimport-mesh-roblox)
5. [Roblox Creator Store](#5-roblox-creator-store)
6. [Optimisation des Assets](#6-optimisation-des-assets)
7. [Pipeline Recommande pour Petite Equipe (Mining/Tycoon)](#7-pipeline-recommande-pour-petite-equipe)

---

## 1. Meshy.ai Workflow

### Est-ce que ca marche pour Roblox ?

**Oui, tres bien.** Meshy propose meme un preset "Roblox" dans son interface. C'est l'un des outils AI 3D les plus matures avec des plugins Blender, Unity, et Unreal.

### Fonctionnalites cles

| Feature | Description |
|---------|-------------|
| **Text to 3D** | Genere un mesh 3D a partir d'un prompt texte |
| **Image to 3D** | Genere a partir d'une image/concept art |
| **AI Texturing** | Re-texture un mesh existant (5 credits) |
| **Remesh** | Ajuste le polycount (100 a 300,000 sur Pro) |
| **Rigging & Animation** | Auto-rigging + presets d'animation |
| **Art Styles** | Realistic, Cartoon, Low Poly, Voxel |

### Pricing (Mars 2026)

| Plan | Prix | Credits/mois | Downloads | Polycount Max | Queue |
|------|------|-------------|-----------|--------------|-------|
| **Free** | $0 | 100 | 10/mois (Meshy-4 only) | 10,000 | 1 task, low priority |
| **Pro** | $20/mois ($192/an) | 1,000 (~100 assets) | Illimite | 100-300,000 custom | 10 tasks, high priority |
| **Studio** | $60/mois ($720/an) | 4,000 (~400 assets) | Illimite | 100-300,000 custom | 20 tasks |
| **Enterprise** | Custom | Custom | Illimite | Custom | 50+ tasks |

**Cout par credit :** Text-to-3D = 10 credits, AI Texturing = 5 credits. Donc ~$0.20/model sur Pro.

### Best Prompts pour Roblox

**Structure d'un bon prompt :** `[Object] + [Modifiers] + [Style]`

**Exemples concrets pour un mining/tycoon game :**

```
"Low poly mining pickaxe, stylized, vibrant colors, flat shading, game asset"
"Cartoon treasure chest filled with gems, simple shapes, Roblox style"
"Low poly ore cart on rails, metallic texture, geometric, game prop"
"Stylized mining cave entrance, rock formation, low poly, flat shading"
"Simple conveyor belt machine, industrial, cartoon style, clean geometry"
"Low poly crystal cluster, glowing purple, gem, Roblox game asset"
```

**Tips pour de meilleurs resultats :**
- Garder 3-5 descripteurs forts, pas plus
- Toujours inclure "low poly" ou "stylized" pour du Roblox
- Utiliser des references familieres ("like a Minecraft pickaxe but smoother")
- Iterer : changer l'ordre des mots peut donner des resultats tres differents
- Eviter les descriptions trop abstraites ou contradictoires
- Eviter les details fins (cheveux individuels, texte sur surfaces)

**Tools de post-processing Meshy :**
- **Texture Healing** : repare les imperfections mineures
- **Smart Healing** : corrige les artefacts de texture automatiquement

### Export Settings pour Roblox

1. **Format :** FBX pour les modeles animes/rigges, OBJ pour les modeles statiques
2. **Polycount :** Rester sous 10,000 triangles (limite Roblox). Utiliser le Remesh de Meshy pour reduire si necessaire
3. **Textures :** S'assurer que les textures sont < 1024x1024 pour les mesh textures (max 4096x4096 pour les textures uploadees separement)
4. Verifier le scale avant export (Roblox utilise des studs, 1 stud ~ 28cm)

### Limites de Meshy

- La qualite des textures peut etre inconsistante, surtout sur Free
- Un seul modele AI (pas de choix entre plusieurs moteurs)
- Les modeles complexes (personnages detailles, vehicules) necessitent du cleanup dans Blender
- Le tier Free est tres limite (100 credits = ~10 modeles/mois, downloads limites)
- Les generations Meshy 5 et 6 Preview ne sont telechargeables que si deja generes sur un plan paye

---

## 2. Outils AI 3D Alternatifs

### Comparatif Complet

| Outil | Prix depart | Credits Free | Qualite | Roblox Ready | Forces |
|-------|------------|-------------|---------|-------------|--------|
| **[Meshy](https://www.meshy.ai)** | $20/mo | 100/mo (~10 models) | Bon | Oui (preset) | Maturite, plugins, iteration rapide |
| **[Tripo3D](https://www.tripo3d.ai)** | ~$16/mo | Limite | Tres bon | Oui (FBX/OBJ) | Topologie quad clean, PBR ready, rapide |
| **[Sloyd](https://www.sloyd.ai)** | $15/mo | Oui (illimite preview) | Bon | **Oui (plugin natif)** | **Specialise Roblox**, pas de credits, illimite |
| **[Rodin/Hyper3D](https://hyper3d.ai)** | $15/mo (edu) | Quelques credits | Excellent | Oui (FBX) | Ultra-photorealiste, 4K PBR, 10B params |
| **[Luma AI Genie](https://lumalabs.ai)** | $9.99/mo | 30 gen/mo | Bon | Oui (quad mesh) | Rapide (<10s), quad mesh a tout polycount |
| **[Kaedim](https://www.kaedim3d.com)** | $29/mo | Non (trial only) | Excellent | Oui (FBX) | Production-ready, auto UV, style transfer |
| **[Roblox Cube](https://github.com/Roblox/cube)** | **Gratuit** | **Illimite** | Moyen | **Natif** | **Integre dans Studio**, open-source |
| **[3DAI Studio](https://www.3daistudio.com)** | $14/mo | Non | Variable | Oui | **Aggregateur** : acces a tous les AI models |

### Details par outil

#### Sloyd - Le Meilleur pour Roblox

Sloyd merite une attention speciale car il a un **plugin natif Roblox Studio** et des **presets de style Roblox**. Pas de systeme de credits -- genere autant que tu veux. Le systeme parametrique permet d'ajuster forme, style, et polycount en temps reel. Export direct .fbx/.obj optimise pour Roblox.

#### Roblox Cube - Outil Natif Gratuit

Lance en mars 2025, Cube est le modele AI 3D de Roblox (1.8B parametres, entraine sur 1.5M assets). Utilisable directement dans Studio via `/generate a motorcycle`. Avantages :
- Zero friction : genere directement dans Studio
- Gratuit et illimite
- Open-source (GitHub + HuggingFace)
- Les modeles sont natifs Roblox, pas de conversion

Limites : qualite inferieure aux outils dedies, pas encore d'image-to-3D (prevu), textures basiques.

#### Tripo3D - Meilleur Rapport Qualite/Topologie

Topologie quad clean, PBR ready, ideal pour les hero assets qui doivent etre beaux. Bon pour le prototypage rapide avec upgrade vers la qualite production.

#### Rodin/Hyper3D - Premium Quality

Modele 10B parametres, qualite quasi-manuelle. Ideal pour les assets hero (boss, batiments principaux). Cher mais la qualite est la. Clean quad mesh avec 85-95% de precision pour les objets hard-surface.

#### 3DAI Studio - L'Aggregateur

Pour $14/mois, acces a Meshy, Rodin, Tripo, et d'autres en un seul abonnement. 1,000 credits/mois. Ideal si tu veux tester plusieurs moteurs sans prendre plusieurs abonnements.

### Recommandation

Pour un jeu Roblox mining/tycoon :
1. **Sloyd** (plugin Roblox natif, illimite, $15/mo) pour les props et environnements
2. **Roblox Cube** (gratuit) pour le prototypage rapide dans Studio
3. **Meshy Pro** ($20/mo) pour les assets necessitant plus de controle artistique
4. **Blender** (gratuit) pour le cleanup et les assets custom

---

## 3. Outils 3D Traditionnels (Blender)

### Blender vers Roblox - Workflow Complet

#### Configuration initiale Blender

1. **Unit System :** Scene Properties > Units > Length = **Centimeters**
2. **Unit Scale :** Mettre a **0.01**
3. Cela garantit un scale 1:1 avec Roblox Studio

#### Export FBX - Settings Critiques

```
File > Export > FBX (.fbx)

Onglet Principal:
  - Path Mode: Copy + Toggle "Embed Textures" (icone boite)
  - Forward: -Z Forward (default)
  - Up: Y Up (default)

Transform:
  - Scale: 0.01 (CRITIQUE si le scene unit n'est pas deja a 0.01)
  - Apply Scalings: "FBX Units Scale" (ou "All Local" selon le contexte)

Armature:
  - [ ] Add Leaf Bones -> DECOCHER
  - [ ] Bake Animation -> DECOCHER (sauf si tu exportes des animations)

Geometry:
  - Smoothing: Face (recommande)
  - [x] Apply Modifiers
```

#### Checklist avant export

- [ ] Appliquer toutes les transformations (Ctrl+A > All Transforms)
- [ ] Verifier que le mesh est < 10,000 triangles (ou < 20,000 avec downscale auto)
- [ ] Normales orientees vers l'exterieur (Mesh > Normals > Recalculate Outside)
- [ ] UV unwrap propre (pas de UV stretching)
- [ ] Textures en 1024x1024 max (ou 512x512 pour les petits objets)
- [ ] Pas de N-gons (que des tris et quads)
- [ ] Origine du mesh au centre/base de l'objet
- [ ] Pas de geometry cachee ou dupliquee

#### Import dans Roblox Studio

1. **Mesh Import :** Explorer > Workspace > clic droit > Import from File (ou drag & drop .fbx)
2. Le 3D Importer s'ouvre : verifier le preview
3. Si le scale est mauvais, ajuster dans les proprietes du MeshPart

#### Textures PBR (SurfaceAppearance)

Roblox supporte 4 maps PBR via `SurfaceAppearance` :

| Map | Format | Description |
|-----|--------|-------------|
| **ColorMap** (Albedo) | RGB 24-bit | Couleur de base |
| **NormalMap** | RGB 24-bit | Relief/details (OpenGL format, Tangent Space uniquement) |
| **RoughnessMap** | Grayscale 8-bit | Brillance de surface |
| **MetalnessMap** | Grayscale 8-bit | Zones metalliques |

**Workflow PBR actuel :**
1. Importer le mesh
2. Importer chaque texture separement comme Image
3. Creer un objet SurfaceAppearance sous le MeshPart
4. Assigner les asset IDs de chaque texture aux proprietes correspondantes

### Autres outils traditionnels

| Outil | Prix | Utilite pour Roblox |
|-------|------|-------------------|
| **Blender** | Gratuit | Standard, meilleur workflow Roblox |
| **Substance Painter** | ~$20/mo | Texturing PBR pro, export direct pour Roblox SurfaceAppearance |
| **MagicaVoxel** | Gratuit | Voxel art, exporte OBJ, parfait pour le style low-poly |
| **Blockbench** | Gratuit | Modeles style Minecraft/voxel, export OBJ |
| **Maya** | $225/mo | Industrie standard, overkill pour Roblox |
| **3ds Max** | $225/mo | Idem Maya, pas necessaire |

---

## 4. Specs d'Import Mesh Roblox

### Limites Techniques Officielles

| Spec | Limite | Notes |
|------|--------|-------|
| **Formats acceptes** | .FBX, .OBJ | Convertis en format mesh interne Roblox |
| **Max triangles** | **10,000 par MeshPart** | Hard limit a l'import. L'importeur downscale auto au-dela de 20K |
| **Max taille fichier mesh** | ~10 MB | Variable selon la complexite |
| **Texture (sur mesh)** | 1024x1024 px | Texture embeddee dans le FBX |
| **Texture (uploadee)** | Jusqu'a 4096x4096 px | Upload separee via SurfaceAppearance |
| **Formats texture** | .png, .jpg, .tga, .bmp | PNG recommande pour la qualite |
| **Normal Map** | OpenGL format uniquement | Tangent Space. **PAS** DirectX (inverser le canal vert si besoin) |
| **UV Space** | 0-1 range | Pas d'UV hors du 0-1 space |
| **Max MeshParts/experience** | Pas de hard limit | Mais impact performance |

### Problemes Courants a l'Import

1. **Scale incorrect** : Le mesh apparait gigantesque ou minuscule. **Fix :** Exporter avec scale 0.01 depuis Blender, ou ajuster dans les proprietes MeshPart.

2. **Mesh noir/sans texture** : Les normales sont inversees. **Fix :** Dans Blender, selectionner tout > Mesh > Normals > Recalculate Outside.

3. **Import qui ne finit jamais** : Le mesh est trop complexe (trop de triangles ou geometry cachee). **Fix :** Decimate dans Blender avant export.

4. **Mesh distordu/blocky** : Probleme de format ou de triangulation. **Fix :** Trianguler dans Blender avant export (Ctrl+T), exporter en FBX au lieu d'OBJ.

5. **Textures manquantes** : Les textures ne s'embarquent pas dans le FBX. **Fix :** Activer "Copy" + "Embed Textures" dans les settings d'export Blender.

6. **Normal map inversee** : Roblox utilise OpenGL, pas DirectX. **Fix :** Inverser le canal vert (G) de la normal map dans Photoshop/GIMP.

7. **Collisions etranges** : Le collision mesh auto-genere ne correspond pas a la forme. **Fix :** Utiliser CollisionFidelity = PreciseConvexDecomposition, ou creer un mesh de collision separe.

8. **UV bleeding sur texture atlas** : Les textures saignent entre les elements. **Fix :** Ajouter du padding (2-4px minimum) entre les UV islands.

---

## 5. Roblox Creator Store

### Ou trouver des assets gratuits de qualite

1. **[Creator Store officiel](https://create.roblox.com/store/models)** : Accessible via Creator Hub. Categories : Models, Plugins, Audio, Fonts, Decals, Mesh Parts, Videos. Tout est gratuit sauf certains plugins.

2. **[DevForum Community Resources](https://devforum.roblox.com/c/resources/community-resources/)** : Section du forum officiel ou les createurs partagent des packs gratuits.

3. **Toolbox dans Studio** : Acces direct dans Roblox Studio (View > Toolbox).

### Best Asset Packs Gratuits

| Pack | Description | Lien |
|------|------------|------|
| **Synty Asset Packs** | Packs stylises professionnels, partnership officiel Roblox. Multiple themes (fantasy, sci-fi, nature) | [DevForum](https://devforum.roblox.com/t/free-synty-asset-packs-released-in-the-marketplace/1283755) |
| **Inno's Stylized Asset Pack** | Pack haute qualite stylise, tres populaire | [DevForum](https://devforum.roblox.com/t/free-innos-stylized-asset-pack/3107492) |
| **The Ultimate Low Poly Asset Pack** | Vegetation, rues, batiments, donjon, interieur | [DevForum](https://devforum.roblox.com/t/free-the-ultimate-low-poly-asset-pack-added-more-assets/1772603) |
| **Roblox Default Templates** | Baseplate, Obby, Racing, etc. | Via Studio > New > Templates |

### Comment evaluer la qualite d'un asset

- **Polycount** : Verifier dans les proprietes. < 5K tris = optimal, < 10K = acceptable
- **Style consistant** : L'asset doit matcher ton art style (low poly, realistic, cartoon)
- **UV propres** : Pas de stretching visible sur les textures
- **Anchored correctement** : L'origine doit etre au bon endroit
- **Collisions** : Tester les collisions en playtest
- **License** : Verifier que l'asset est libre d'utilisation commerciale
- **Popularite/Reviews** : Nombre d'utilisations et commentaires positifs

### Tips pour le Creator Store

- Chercher par mots-cles specifiques ("low poly mine", "tycoon machine", "crystal ore")
- Filtrer par "Models" et "Mesh Parts"
- Verifier la date : les assets recents sont souvent mieux optimises
- Tester en playtest avant d'integrer dans le jeu final
- Modifier les couleurs/materiaux pour matcher ton style

---

## 6. Optimisation des Assets

### Principes generaux

Une etude Gamasutra 2025 montre qu'une reduction de 60% des polygones ameliore les FPS de 25% sur hardware mid-tier. Le texture atlasing peut reduire les draw calls de 50%.

### Reduction de Polycount

| Technique | Outil | Quand l'utiliser |
|-----------|-------|-----------------|
| **Decimate Modifier** | Blender | Reduire un mesh trop detaille (ratio 0.3-0.5) |
| **Remesh** | Meshy AI | Ajuster le polycount directement dans Meshy |
| **Manual retopology** | Blender | Pour les hero assets qui doivent etre parfaits |
| **InstantMeshes** | Standalone (gratuit) | Retopologie automatique rapide |

**Budgets polycount recommandes pour Roblox :**

| Type d'asset | Triangles recommandes | Max absolu |
|--------------|----------------------|------------|
| Props simples (pickaxe, gem) | 100-500 | 2,000 |
| Props moyens (machine, cart) | 500-2,000 | 5,000 |
| Batiments/structures | 1,000-5,000 | 10,000 |
| Personnages/NPCs | 1,000-4,000 | 8,000 |
| Vehicules | 1,000-5,000 | 10,000 |
| Environment pieces | 200-2,000 | 5,000 |

### Texture Atlasing

Le texture atlasing consiste a combiner plusieurs textures en une seule image pour reduire les draw calls GPU.

**Workflow :**
1. UV-unwrap tous les assets qui partagent un style
2. Packer les UVs dans une seule image (1024x1024 ou 2048x2048)
3. Ajouter du padding (2-4px) entre les UV islands pour eviter le bleeding
4. Utiliser des dimensions power-of-two (256, 512, 1024, 2048, 4096)
5. Uploader comme une seule texture partagee via SurfaceAppearance

**Impact :** Une atlas 2048x2048 combinant plusieurs surfaces 512x512 peut diviser les draw calls par 2.

### Level of Detail (LOD)

Roblox gere les LOD automatiquement via la propriete `RenderFidelity` des MeshParts :

| Setting | Comportement |
|---------|-------------|
| **Automatic** | Roblox ajuste le LOD dynamiquement selon la distance et le device |
| **Precise** | Toujours le mesh complet (plus couteux) |
| **Performance** | Simplifie agressivement (meilleur FPS) |

**Recommandation :** Utiliser `Automatic` pour la majorite des assets, `Precise` uniquement pour les assets hero proches de la camera.

### SLIM Technology (Nouveau 2025)

Roblox a lance SLIM (Scalable Lightweight Interactive Models) fin 2025 :
- Genere automatiquement des versions LOD multiples
- Inclut le **texture re-atlassing** intelligent
- Reduit la taille des textures automatiquement
- Fonctionne au niveau du runtime, pas besoin d'action manuelle

### Tips Performance pour un Mining/Tycoon

1. **StreamingEnabled = true** : Active le streaming d'instances pour ne charger que ce qui est visible
2. **Eviter la micro-geometrie** : Pas de details geometriques < 0.1 stud, utiliser des textures
3. **MeshPart.CollisionFidelity = Box** pour les props non-interactifs
4. **Fusionner les petits meshes** en un seul quand possible (moins de draw calls)
5. **Limiter les MeshParts uniques** : Reutiliser les memes meshes avec des couleurs/textures differentes
6. **Textures :** 512x512 pour les petits props, 1024x1024 pour les grands. Jamais 4096 sauf hero assets
7. **Materials Roblox natifs** : Utiliser les built-in materials (SmoothPlastic, Metal, etc.) quand possible, ils sont plus performants que les textures custom

---

## 7. Pipeline Recommande pour Petite Equipe (Mining/Tycoon)

### Equipe de 3 personnes - Roles

| Role | Responsabilites | Outils principaux |
|------|----------------|------------------|
| **Game Designer / Scripter** | Gameplay, systemes, UI, scripting Luau | Roblox Studio, VS Code |
| **3D Artist / Builder** | Assets 3D, level design, textures | Sloyd, Meshy, Blender, Roblox Studio |
| **Generalist / QA** | Gameplay support, testing, polish, SFX | Roblox Studio, Audacity, outils AI |

### Pipeline Recommande

```
Phase 1: Prototypage Rapide (Semaine 1-2)
================================================
1. Blockout dans Roblox Studio avec des Parts basiques
   -> Definir les dimensions, le flow du gameplay

2. Generer les premiers assets avec Roblox Cube (gratuit)
   -> /generate mining pickaxe
   -> /generate ore cart
   -> /generate conveyor belt

3. Tester le gameplay avec ces placeholders

Phase 2: Assets de Production (Semaine 3-6)
================================================
4. Generer les props en batch avec Sloyd ($15/mo)
   -> Plugin Roblox natif, illimite
   -> Presets style Roblox, export FBX direct
   -> Ideal pour : props, machines, environnement

5. Assets hero avec Meshy Pro ($20/mo)
   -> Minerais/cristaux avec des textures riches
   -> Machines principales du tycoon
   -> Utiliser les prompts low-poly optimises

6. Cleanup dans Blender (gratuit)
   -> Reduire le polycount si > 10K
   -> Corriger les UV
   -> Ajouter les textures PBR si necessaire
   -> Exporter en FBX avec les bons settings

Phase 3: Polish (Semaine 7-8)
================================================
7. Texture atlasing dans Blender
   -> Grouper les assets par zone (mine, factory, shop)
   -> Une atlas par zone = moins de draw calls

8. Creator Store pour les fillers
   -> Arbres, rochers, herbe (Synty packs)
   -> Props generiques (barrels, crates)

9. SurfaceAppearance pour les hero assets
   -> PBR textures pour les machines principales
   -> Normal maps pour le relief des rochers

10. Test performance sur mobile
    -> StreamingEnabled = true
    -> RenderFidelity = Automatic
    -> Micro Profiler pour identifier les bottlenecks
```

### Budget Outils Mensuel

| Outil | Cout | Usage |
|-------|------|-------|
| Roblox Studio | Gratuit | Development environment |
| Roblox Cube | Gratuit | Prototypage rapide |
| Blender | Gratuit | Cleanup, retopo, UV, export |
| Sloyd Plus | $15/mo | Props en masse, illimite |
| Meshy Pro | $20/mo | Hero assets, textures riches |
| **Total** | **~$35/mo** | |

**Alternative budget zero :** Roblox Cube + Blender + Creator Store = $0/mo (qualite moindre mais fonctionnel).

**Alternative premium :** Ajouter 3DAI Studio ($14/mo) pour tester Rodin/Tripo sur les hero assets = ~$49/mo total.

### Conseils Specifiques Mining/Tycoon

1. **Minerais et cristaux** : Parfait pour l'AI -- les formes geometriques/organiques sont le point fort de Meshy. Prompt : `"Glowing [color] crystal ore chunk, low poly, stylized, game asset"`

2. **Machines de traitement** : Utiliser Sloyd pour les formes de base (conveyors, furnaces), puis customiser les couleurs dans Studio pour differentes tiers.

3. **Upgrades visuels** : Un meme mesh avec differents Materials/Colors pour les tiers (Tier 1 = bois, Tier 2 = metal, Tier 3 = or). Economise des meshes.

4. **Map mining** : Generer des sections de tunnel/cave modulaires reutilisables. 5-6 pieces qui s'emboitent = variete infinie.

5. **Particules > Meshes** : Pour les effets (poussiere, etincelles, lueur des minerais), utiliser les ParticleEmitters plutot que des meshes supplementaires.

6. **Tycoon buildings** : Utiliser des Parts basiques Roblox pour les structures principales (walls, floors) + MeshParts uniquement pour les details (machines, decorations). Les Parts sont plus performantes.

---

## Ressources et Liens Utiles

### Documentation Officielle Roblox
- [Mesh Specifications](https://create.roblox.com/docs/art/modeling/specifications)
- [Export Requirements](https://create.roblox.com/docs/art/modeling/export-requirements)
- [Texture Specifications](https://create.roblox.com/docs/art/modeling/texture-specifications)
- [SurfaceAppearance](https://create.roblox.com/docs/art/modeling/surface-appearance)
- [Creator Store](https://create.roblox.com/store/models)
- [Roblox Cube (GitHub)](https://github.com/Roblox/cube)
- [Cube Beta Announcement](https://devforum.roblox.com/t/beta-cube-3d-generation-tools-and-apis-for-creators/3558947)

### Outils AI 3D
- [Meshy.ai](https://www.meshy.ai) | [Meshy Roblox Guide](https://www.meshy.ai/blog/roblox-3d-model) | [Meshy Pricing](https://www.meshy.ai/pricing)
- [Sloyd](https://www.sloyd.ai) | [Sloyd for Roblox](https://www.sloyd.ai/sdk/sloyd-for-roblox) | [Sloyd Pricing](https://app.sloyd.ai/pricing)
- [Tripo3D](https://www.tripo3d.ai) | [Tripo Pricing](https://www.tripo3d.ai/pricing)
- [Rodin/Hyper3D](https://hyper3d.ai) | [Hyper3D Pricing](https://hyper3d.ai/subscribe)
- [Luma AI](https://lumalabs.ai) | [Luma Pricing](https://lumalabs.ai/pricing)
- [Kaedim](https://www.kaedim3d.com)
- [3DAI Studio](https://www.3daistudio.com) (aggregateur multi-moteurs)

### Community Resources
- [Synty Free Packs](https://devforum.roblox.com/t/free-synty-asset-packs-released-in-the-marketplace/1283755)
- [Inno's Stylized Pack](https://devforum.roblox.com/t/free-innos-stylized-asset-pack/3107492)
- [Ultimate Low Poly Pack](https://devforum.roblox.com/t/free-the-ultimate-low-poly-asset-pack-added-more-assets/1772603)
- [3D AI Pricing Comparison (Sloyd)](https://www.sloyd.ai/blog/3d-ai-price-comparison)

### Blender + Roblox
- [Blender FBX Scale for Roblox](https://www.katsbits.com/codex/fbx-scale-roblox/)
- [1:1 Scale Export Tutorial](https://devforum.roblox.com/t/exporting-11-scale-models-from-blender-to-roblox-studio/3679265)

### Performance
- [Roblox SLIM Technology](https://corp.roblox.com/newsroom/2025/12/introducing-roblox-slim-scalable-lightweight-interactive-models)
- [Roblox Texture Optimization](https://www.alivegames.io/posts/roblox-texture-optimization-best-practices)
- [Environment Optimization Guide](https://devforum.roblox.com/t/optimization-for-roblox-environments/3844846)
