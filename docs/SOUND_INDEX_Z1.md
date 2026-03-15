# DUSTHAVEN — Index des Sons — Zone 1 (Demo)

> **Version** : 2.0
> **Date** : 15 mars 2026
> **Statut** : INDEX DE RÉFÉRENCE — À valider avec Moncef avant génération NLML Labs
> **Scope** : Tous les sons nécessaires pour la démo Zone 1 (Prologue + Acte I)
> **⚠️ AUCUNE GÉNÉRATION NLML LABS NE SERA LANCÉE SANS VALIDATION DE MONCEF.**

---

## SPECS TECHNIQUES ROBLOX — À RESPECTER POUR CHAQUE SON

> **Ces specs sont OBLIGATOIRES. Chaque son généré DOIT les respecter.**
> **Copier-coller ce bloc dans chaque session de génération NLML Labs.**

```
══════════════════════════════════════════════════════════
  SPECS OBLIGATOIRES — ROBLOX AUDIO (copier à chaque gen)
══════════════════════════════════════════════════════════

FORMAT         : .ogg (Vorbis)
SAMPLE RATE    : 44 100 Hz
BITRATE        : 128-192 kbps
PEAK LEVEL     : Normalisé à -12 dB peak
TAILLE MAX     : < 20 MB (viser < 2 MB)
DURÉE MAX      : < 7 min

CANAUX         : MONO (sauf MUS-001 = stéréo)
  → Tout son spatial 3D DOIT être mono.
  → Roblox ignore le 2e canal pour le spatial audio.
  → Seul le thème musical global (MUS-001) peut être stéréo.

SI LOOP        : 
  → Début ET fin à amplitude zéro (zero-crossing)
  → Micro fade in/out de 10-20ms intégré dans le fichier
  → Écouter 3x d'affilée : le raccord doit être INAUDIBLE
  → Pas de clic, pas de pop, pas de gap

SI ONESHOT     :
  → Laisser la reverb/tail mourir naturellement
  → Ne PAS couper sec à la fin
  → Micro fade out 10ms pour éviter les artefacts

STYLE GLOBAL   : Western réaliste 1852. Pas de synthé.
                  Pas de son moderne. Organique, naturel, brut.
══════════════════════════════════════════════════════════
```

---

## ARCHITECTURE SOUNDGROUP ROBLOX

```
SoundService
├── SG_Ambiance   (Volume: 0.4)  → Sons d'environnement, fond
├── SG_Gameplay   (Volume: 0.7)  → Actions joueur, orpaillage, interactions
├── SG_PNJ        (Volume: 0.7)  → Signaux sonores des PNJ
├── SG_UI         (Volume: 0.5)  → Notifications, feedback interface
└── SG_Music      (Volume: 0.3)  → Musique, stingers
```

Chaque son est assigné à son SoundGroup. Le mixage se fait via les Volumes des groupes, PAS dans les fichiers audio.

---

## SPATIAL AUDIO — PROPRIÉTÉS ROBLOX PAR TYPE

| Type | Parent Roblox | RollOffMode | MinDistance | MaxDistance |
|------|---------------|-------------|-------------|-------------|
| Ambiance zone | Part dans le monde | InverseTapered | 10 studs | 80-120 studs |
| SFX gameplay | Personnage joueur | InverseTapered | 5 studs | 30 studs |
| PNJ signal | Part du PNJ | InverseTapered | 10 studs | 60-100 studs |
| UI | SoundService (global) | — | — | — |
| Musique | SoundService (global) | — | — | — |

---

## CHECKLIST AVANT UPLOAD (pour CHAQUE son)

```
☐ Format .ogg Vorbis
☐ 44 100 Hz sample rate  
☐ MONO (sauf MUS-001 = stéréo)
☐ Normalisé à -12 dB peak
☐ Si loop : zero-crossing début/fin + micro fade 10-20ms
☐ Si loop : écouté 3x d'affilée sans clic/pop
☐ Si oneshot : tail naturelle, pas de cut sec
☐ Durée conforme à la fiche du son
☐ < 2 MB
☐ Style western organique 1852, pas de synthé
```

---

## LÉGENDE

| Colonne | Description |
|---------|-------------|
| **ID** | Identifiant unique du son |
| **Cat** | AMB / SFX / VOX / UI / MUS |
| **Nom** | Nom descriptif |
| **Contexte** | Où et quand le son joue dans le jeu |
| **Type** | Loop / OneShot / Transition |
| **Durée** | Durée cible du fichier à générer |
| **Canaux** | Mono / Stéréo |
| **SoundGroup** | Groupe Roblox auquel assigner le son |
| **Spatial** | Oui (3D, attaché à un Part) / Non (global) |
| **RollOff** | MinDistance → MaxDistance en studs |
| **Volume Roblox** | Volume recommandé (propriété Sound.Volume) |
| **Priorité** | P0 (bloquant) / P1 (important) / P2 (nice-to-have) |
| **Prompt NLML** | Description EXACTE à utiliser pour la génération |

---

## 1. AMBIANCES (AMB)

---

### AMB-001 — Vent désert général

| Champ | Valeur |
|-------|--------|
| **ID** | AMB-001 |
| **Priorité** | P0 |
| **Type** | Loop |
| **Durée fichier** | 60s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Ambiance |
| **Spatial** | Oui — Part couvrant toute la zone extérieure |
| **RollOff** | Min 20 / Max 120 studs |
| **Volume Roblox** | 0.35 |
| **Contexte** | Partout en extérieur Zone 1. Fond sonore permanent du désert. |
| **Prompt NLML** | `Dry desert wind ambience, 1850s American West. Gentle breeze with occasional subtle gusts. No music, no voices, no modern sounds. Sandy terrain, sparse vegetation rustling. Arid, desolate, peaceful. Natural outdoor recording feel. 60 seconds, seamless loop, zero-crossing start and end.` |

---

### AMB-002 — Rivière / ruisseau

| Champ | Valeur |
|-------|--------|
| **ID** | AMB-002 |
| **Priorité** | P0 |
| **Type** | Loop |
| **Durée fichier** | 60s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Ambiance |
| **Spatial** | Oui — Part le long de la rivière |
| **RollOff** | Min 10 / Max 80 studs |
| **Volume Roblox** | 0.45 |
| **Contexte** | Proche de la rivière et des spots d'orpaillage. Volume augmente en s'approchant (spatial 3D). |
| **Prompt NLML** | `Gentle creek and river water flowing over pebbles and rocks. Medium flow rate, not torrential. Natural stream sounds with occasional small splashes. No waterfall, no music, no voices. Calm, soothing, organic. 60 seconds, seamless loop, zero-crossing start and end.` |

---

### AMB-003 — Cascade

| Champ | Valeur |
|-------|--------|
| **ID** | AMB-003 |
| **Priorité** | P0 |
| **Type** | Loop |
| **Durée fichier** | 45s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Ambiance |
| **Spatial** | Oui — Part à la cascade (B2-C2) |
| **RollOff** | Min 10 / Max 100 studs |
| **Volume Roblox** | 0.5 |
| **Contexte** | Près de la cascade principale. Chute d'eau puissante mais pas assourdissante. |
| **Prompt NLML** | `Medium waterfall, water crashing on rocks below. Powerful but not deafening. Mist and splash sounds. Natural outdoor waterfall, not industrial. No music, no voices. 45 seconds, seamless loop, zero-crossing start and end.` |

---

### AMB-004 — Village Dusthaven

| Champ | Valeur |
|-------|--------|
| **ID** | AMB-004 |
| **Priorité** | P0 |
| **Type** | Loop |
| **Durée fichier** | 60s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Ambiance |
| **Spatial** | Oui — Part couvrant le périmètre du village (E5-G6) |
| **RollOff** | Min 15 / Max 100 studs |
| **Volume Roblox** | 0.35 |
| **Contexte** | Ambiance du village western. Bruit de fond humain lointain. |
| **Prompt NLML** | `1850s small western frontier village ambience. Distant wooden planks creaking, faint murmurs of people, a chicken clucking occasionally, a horse snorting or shuffling hooves. Dusty, quiet, tense atmosphere. No music, no modern sounds, no loud voices. Everything is distant and subdued. 60 seconds, seamless loop, zero-crossing start and end.` |

---

### AMB-005 — Intérieur cabane Eli

| Champ | Valeur |
|-------|--------|
| **ID** | AMB-005 |
| **Priorité** | P1 |
| **Type** | Loop |
| **Durée fichier** | 45s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Ambiance |
| **Spatial** | Oui — Part dans la cabane (C1) |
| **RollOff** | Min 5 / Max 20 studs |
| **Volume Roblox** | 0.25 |
| **Contexte** | Intérieur de la cabane du grand-père. Silence quasi-total, intimité. |
| **Prompt NLML** | `Interior of an old wooden cabin. Near silence. Very subtle wood creaking, faint wind whistling through cracks in the walls. Dust settling. Intimate, isolated, slightly eerie. No music, no voices, no modern sounds. 45 seconds, seamless loop, zero-crossing start and end.` |

---

### AMB-006 — Nuit / crépuscule

| Champ | Valeur |
|-------|--------|
| **ID** | AMB-006 |
| **Priorité** | P1 |
| **Type** | Loop |
| **Durée fichier** | 60s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Ambiance |
| **Spatial** | Non — SoundService global (cycle jour/nuit) |
| **RollOff** | — |
| **Volume Roblox** | 0.3 |
| **Contexte** | Quand le cycle jour/nuit passe en nuit. Remplace les ambiances jour. |
| **Prompt NLML** | `American West desert nighttime ambience. Crickets chirping steadily, a distant owl hooting occasionally, very distant coyote howl (subtle, not scary). Cool night air feel. Peaceful but lonely. No music, no voices, no modern sounds. 60 seconds, seamless loop, zero-crossing start and end.` |

---

### AMB-007 — Zone montagneuse / Whitepine

| Champ | Valeur |
|-------|--------|
| **ID** | AMB-007 |
| **Priorité** | P1 |
| **Type** | Loop |
| **Durée fichier** | 45s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Ambiance |
| **Spatial** | Oui — Part zone Whitepine (A1-C2) |
| **RollOff** | Min 15 / Max 100 studs |
| **Volume Roblox** | 0.35 |
| **Contexte** | Secteur montagneux enneigé au nord-ouest. |
| **Prompt NLML** | `High altitude mountain ambience with snow. Cold sharp wind, higher pitched than desert wind. Occasional snow crunch or ice cracking subtly in distance. Mountain silence — vast, open, cold. No music, no voices. 45 seconds, seamless loop, zero-crossing start and end.` |

---

### AMB-008 — Sous la cascade (secret)

| Champ | Valeur |
|-------|--------|
| **ID** | AMB-008 |
| **Priorité** | P2 |
| **Type** | Loop |
| **Durée fichier** | 30s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Ambiance |
| **Spatial** | Oui — Part derrière la cascade (B3) |
| **RollOff** | Min 5 / Max 15 studs |
| **Volume Roblox** | 0.4 |
| **Contexte** | Spot secret derrière la cascade. Son étouffé, gouttes, écho de grotte naturelle. |
| **Prompt NLML** | `Behind a waterfall in a small natural cave. Muffled waterfall sound overhead, individual water droplets falling into a calm pool. Light echo. Sheltered, intimate, hidden sanctuary feel. No music, no voices. 30 seconds, seamless loop, zero-crossing start and end.` |

---

## 2. GAMEPLAY — ORPAILLAGE (SFX)

---

### SFX-001 — Batée — plonger dans l'eau

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-001 |
| **Priorité** | P0 |
| **Type** | OneShot |
| **Durée fichier** | 1.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 5 / Max 30 studs |
| **Volume Roblox** | 0.7 |
| **Contexte** | Le joueur commence à orpailler — plonge la batée dans l'eau. |
| **Prompt NLML** | `Metal pan being carefully submerged into shallow river water. Controlled splash, not a big plunge. Metal scraping slightly on pebbles underwater. Short, precise, satisfying. 1.5 seconds, one-shot with natural tail decay.` |

---

### SFX-002 — Batée — tamiser/secouer

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-002 |
| **Priorité** | P0 |
| **Type** | Loop (court) |
| **Durée fichier** | 3s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 5 / Max 30 studs |
| **Volume Roblox** | 0.6 |
| **Contexte** | Le joueur agite la batée en mouvement circulaire pour séparer l'or du gravier. |
| **Prompt NLML** | `Gold panning: gravel and small stones swirling in a metal pan with water. Circular sifting motion. Rhythmic, steady, wet gravel scraping metal. Water trickling through. Satisfying repetitive texture. 3 seconds, seamless loop, zero-crossing start and end.` |

---

### SFX-003 — Pépite trouvée (normal)

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-003 |
| **Priorité** | P0 |
| **Type** | OneShot |
| **Durée fichier** | 1s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 5 / Max 20 studs |
| **Volume Roblox** | 0.7 |
| **Contexte** | Le joueur trouve un grain d'or ou une petite pépite. Feedback positif. |
| **Prompt NLML** | `Small gold nugget hitting a metal pan. Soft metallic "tink" sound with a subtle shimmer resonance. Satisfying but understated — not a jackpot, just a small find. Organic metal on metal. 1 second, one-shot with very short natural decay.` |

---

### SFX-004 — Gros nugget trouvé

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-004 |
| **Priorité** | P0 |
| **Type** | OneShot |
| **Durée fichier** | 2s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 5 / Max 30 studs |
| **Volume Roblox** | 0.8 |
| **Contexte** | Le joueur trouve un gros nugget (rare). Moment "wow". Feedback fort. |
| **Prompt NLML** | `Large gold nugget clinking heavily in a metal pan. Solid, weighty metallic "CLING" with rich golden resonance that rings out. A rewarding, exciting discovery sound. Heavier and more resonant than a small nugget. 2 seconds, one-shot with natural ring-out decay.` |

---

### SFX-005 — Gravier vide

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-005 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 1s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 5 / Max 20 studs |
| **Volume Roblox** | 0.5 |
| **Contexte** | Le joueur tamise et ne trouve rien. Feedback neutre/décevant. |
| **Prompt NLML** | `Wet gravel and sand sliding off a metal pan back into water. Anticlimactic, flat. No metallic ring — just dull wet earth. Neutral, slightly disappointing feedback. 1 second, one-shot with natural tail.` |

---

### SFX-006 — Quartz trouvé

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-006 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 1s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 5 / Max 20 studs |
| **Volume Roblox** | 0.6 |
| **Contexte** | Le joueur trouve du quartz (ressource craft). Différent de l'or. |
| **Prompt NLML** | `Crystal or quartz stone clinking on metal pan. Bright, crystalline "tink" — distinctly different from gold. Lighter, sharper, glassy quality. A find, but not gold. 1 second, one-shot with short natural decay.` |

---

### SFX-007 — Batée — poser/ranger

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-007 |
| **Priorité** | P2 |
| **Type** | OneShot |
| **Durée fichier** | 0.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 3 / Max 15 studs |
| **Volume Roblox** | 0.4 |
| **Contexte** | Le joueur pose ou range la batée. Fin de session d'orpaillage. |
| **Prompt NLML** | `Metal pan being set down on rocky ground. Dull metallic thud on earth and gravel. Brief, simple, functional. 0.5 seconds, one-shot.` |

---

## 3. GAMEPLAY — INTERACTIONS (SFX)

---

### SFX-010 — Coffre — ouvrir

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-010 |
| **Priorité** | P0 |
| **Type** | OneShot |
| **Durée fichier** | 1.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Part du coffre |
| **RollOff** | Min 5 / Max 25 studs |
| **Volume Roblox** | 0.7 |
| **Contexte** | Le joueur ouvre un coffre abandonné (Fragment #2, etc.). |
| **Prompt NLML** | `Old rusty wooden chest being opened. Creaky rusted metal hinges groaning, then a solid clunk as the lid opens fully. Aged, weathered, frontier feel. 1.5 seconds, one-shot with natural tail.` |

---

### SFX-011 — Fragment trouvé

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-011 |
| **Priorité** | P0 |
| **Type** | OneShot |
| **Durée fichier** | 2.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Non — SoundService global (moment narratif important) |
| **RollOff** | — |
| **Volume Roblox** | 0.7 |
| **Contexte** | Le joueur trouve un fragment de la lettre d'Eli. Moment émotionnel solennel. |
| **Prompt NLML** | `Old paper being carefully unfolded. Delicate, aged parchment crackling softly. A gentle breath of wind accompanies the unfolding. Solemn, emotional, intimate moment. No fanfare — respect and gravity. 2.5 seconds, one-shot with natural silence tail.` |

---

### SFX-012 — Lettre — lire

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-012 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 1.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.5 |
| **Contexte** | Quand le joueur consulte un fragment dans l'inventaire. |
| **Prompt NLML** | `Paper being carefully handled and unrolled. Aged document, dry and delicate. Subtle, quiet. 1.5 seconds, one-shot with natural tail.` |

---

### SFX-013 — Objet ramassé (générique)

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-013 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 0.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 3 / Max 15 studs |
| **Volume Roblox** | 0.5 |
| **Contexte** | Ramasser un item standard (bois, pierre, cuivre, batée). |
| **Prompt NLML** | `Quick item pickup sound. A light rustle and soft thud — cloth bag receiving an object. Simple, neutral, functional confirmation. No fanfare. 0.5 seconds, one-shot.` |

---

### SFX-014 — Porte — ouvrir/fermer

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-014 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 1s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Part de la porte |
| **RollOff** | Min 5 / Max 30 studs |
| **Volume Roblox** | 0.6 |
| **Contexte** | Portes du Saloon (battante), magasin, etc. |
| **Prompt NLML** | `Western saloon swinging doors. Wood creaking on hinges, door swinging open and flapping back once. Classic frontier saloon entrance. 1 second, one-shot with natural swing decay.` |

---

### SFX-015 — ProximityPrompt — activation

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-015 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 0.3s |
| **Canaux** | Mono |
| **SoundGroup** | SG_UI |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.4 |
| **Contexte** | Quand le joueur entre dans la zone d'interaction d'un PNJ/objet. Feedback subtil. |
| **Prompt NLML** | `Very subtle soft click or gentle tone. Like a quiet wooden latch lifting. Non-intrusive, almost subliminal UI feedback. Warm, organic, not electronic. 0.3 seconds, one-shot.` |

---

### SFX-016 — Pont — marcher

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-016 |
| **Priorité** | P2 |
| **Type** | Loop (court) |
| **Durée fichier** | 1.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Part du pont |
| **RollOff** | Min 5 / Max 20 studs |
| **Volume Roblox** | 0.5 |
| **Contexte** | Le joueur traverse le Pont nord (D2) ou Pont sud (F7). |
| **Prompt NLML** | `Footsteps on an old wooden plank bridge. Hollow creaking wood, slight bounce. Single step cycle that can loop. No water, just the bridge itself. 1.5 seconds, seamless loop, zero-crossing start and end.` |

---

### SFX-017 — Inscription Nahak'a — découverte

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-017 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 2.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Part de l'inscription |
| **RollOff** | Min 5 / Max 20 studs |
| **Volume Roblox** | 0.6 |
| **Contexte** | Le joueur découvre une inscription gravée du Peuple du Serpent sur une paroi. |
| **Prompt NLML** | `Deep stone resonance, as if a large rock surface is vibrating very subtly. Ancient, geological, profound — NOT mystical or magical. Like running your hand across carved stone and hearing the cavity behind it resonate. A sense of age and weight. 2.5 seconds, one-shot with slow natural decay.` |

---

## 4. PNJ — SIGNAUX SONORES (VOX / SFX)

---

### VOX-001 — Forge de Gustave — marteau

| Champ | Valeur |
|-------|--------|
| **ID** | VOX-001 |
| **Priorité** | P0 |
| **Type** | Loop |
| **Durée fichier** | 8s |
| **Canaux** | Mono |
| **SoundGroup** | SG_PNJ |
| **Spatial** | Oui — Part de la forge (F6) |
| **RollOff** | Min 10 / Max 100 studs |
| **Volume Roblox** | 0.65 |
| **Contexte** | Ambiance PERMANENTE autour de la forge. LE signal de Gustave. Quand ça s'arrête = événement. |
| **Prompt NLML** | `Blacksmith hammer striking an anvil. Steady, powerful rhythm: 3-4 heavy iron strikes, then a brief pause (1-2 seconds), then another set of strikes. Raw iron on iron. Each hit resonant and weighty. Real forge workshop sound. No music, no other sounds. 8 seconds, seamless loop, zero-crossing start and end. The pattern must repeat naturally.` |

---

### VOX-002 — Gustave — 3 coups finaux

| Champ | Valeur |
|-------|--------|
| **ID** | VOX-002 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 2s |
| **Canaux** | Mono |
| **SoundGroup** | SG_PNJ |
| **Spatial** | Oui — Part de la forge (F6) |
| **RollOff** | Min 10 / Max 60 studs |
| **Volume Roblox** | 0.7 |
| **Contexte** | Gustave met fin à une conversation. 3 coups distinctement différents du loop normal — plus rapides et décisifs. |
| **Prompt NLML** | `Three quick, sharp, decisive hammer strikes on an anvil in rapid succession. Faster and more forceful than normal forging rhythm. A deliberate "conversation is over" signal. Iron on iron, final and authoritative. 2 seconds, one-shot with natural ring-out.` |

---

### VOX-003 — Sheriff — bottes

| Champ | Valeur |
|-------|--------|
| **ID** | VOX-003 |
| **Priorité** | P0 |
| **Type** | Loop (court) |
| **Durée fichier** | 2s |
| **Canaux** | Mono |
| **SoundGroup** | SG_PNJ |
| **Spatial** | Oui — Part du Sheriff (patrouille) |
| **RollOff** | Min 10 / Max 60 studs |
| **Volume Roblox** | 0.6 |
| **Contexte** | Le Sheriff se déplace VERS le joueur. Bottes qui claquent sur des planches. Annonce sa présence AVANT qu'il soit visible. Rythme lent, délibéré. |
| **Prompt NLML** | `Heavy leather cowboy boots walking slowly on wooden planks. Deliberate, unhurried pace. Each step has weight and authority — heel strike then sole. Two steps cycle. Intimidating, measured. Wood creaking slightly under each step. 2 seconds, seamless loop, zero-crossing start and end.` |

---

### VOX-004 — Jed — lunettes

| Champ | Valeur |
|-------|--------|
| **ID** | VOX-004 |
| **Priorité** | P2 |
| **Type** | OneShot |
| **Durée fichier** | 1s |
| **Canaux** | Mono |
| **SoundGroup** | SG_PNJ |
| **Spatial** | Oui — Part de Jed (E5 magasin) |
| **RollOff** | Min 3 / Max 10 studs |
| **Volume Roblox** | 0.3 |
| **Contexte** | Jed essuie ses lunettes avec un coin de son tablier. Tic nerveux quand il réfléchit. Très intime, très subtil. |
| **Prompt NLML** | `Cloth wiping glass lenses. Very soft, intimate sound. Fabric rubbing on glass gently, 2-3 small circular motions. Barely audible, personal. 1 second, one-shot.` |

---

### VOX-005 — Saloon Belle — ambiance

| Champ | Valeur |
|-------|--------|
| **ID** | VOX-005 |
| **Priorité** | P1 |
| **Type** | Loop |
| **Durée fichier** | 45s |
| **Canaux** | Mono |
| **SoundGroup** | SG_PNJ |
| **Spatial** | Oui — Part du Saloon (F5) |
| **RollOff** | Min 10 / Max 40 studs |
| **Volume Roblox** | 0.4 |
| **Contexte** | Intérieur du Saloon. Pas de musique live — juste ambiance. |
| **Prompt NLML** | `Interior of a quiet 1850s western saloon. A few scattered piano notes (not a melody, just idle plinking). Glasses clinking occasionally. Low murmurs of conversation. Wooden chair scraping on floor once. Not lively — subdued, tense. No full music, no singing, no modern sounds. 45 seconds, seamless loop, zero-crossing start and end.` |

---

### VOX-006 — Coyote — jappement

| Champ | Valeur |
|-------|--------|
| **ID** | VOX-006 |
| **Priorité** | P0 |
| **Type** | OneShot |
| **Durée fichier** | 1s |
| **Canaux** | Mono |
| **SoundGroup** | SG_PNJ |
| **Spatial** | Oui — Part de Coyote (position variable) |
| **RollOff** | Min 10 / Max 60 studs |
| **Volume Roblox** | 0.65 |
| **Contexte** | Coyote attire l'attention du joueur. Jappement court, curieux, espiègle — PAS menaçant. |
| **Prompt NLML** | `Single short coyote yip. Curious, playful, not aggressive or threatening. Like a young coyote trying to get attention. Bright, quick, endearing. Outdoor natural acoustics. 1 second, one-shot with natural outdoor decay.` |

---

### VOX-007 — Coyote — grattement sol

| Champ | Valeur |
|-------|--------|
| **ID** | VOX-007 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 2s |
| **Canaux** | Mono |
| **SoundGroup** | SG_PNJ |
| **Spatial** | Oui — Part de Coyote (position variable) |
| **RollOff** | Min 5 / Max 30 studs |
| **Volume Roblox** | 0.5 |
| **Contexte** | Coyote trace le cercle du Serpent dans la poussière / gratte la terre. |
| **Prompt NLML** | `Animal paw scratching dry dusty ground in a deliberate circular motion. Dirt and small pebbles being displaced. Slow, purposeful scratching — not frantic. Outdoor desert ground. 2 seconds, one-shot with natural tail.` |

---

### VOX-008 — Rattler — canne

| Champ | Valeur |
|-------|--------|
| **ID** | VOX-008 |
| **Priorité** | P2 |
| **Type** | OneShot |
| **Durée fichier** | 0.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_PNJ |
| **Spatial** | Oui — Part du Rattler (Acte II, Saloon) |
| **RollOff** | Min 5 / Max 20 studs |
| **Volume Roblox** | 0.5 |
| **Contexte** | Le Rattler tapote la tête de sa canne argentée avec son index. Tic de patience/menace. Rythme lent, métronome. |
| **Prompt NLML** | `Single tap of a finger on a silver-topped walking cane. Sharp, precise metallic tap on polished silver. Elegant, patient, slightly menacing. Like a slow metronome tick. 0.5 seconds, one-shot with minimal decay.` |

---

## 5. UI / FEEDBACK (UI)

---

### UI-001 — Notification quête

| Champ | Valeur |
|-------|--------|
| **ID** | UI-001 |
| **Priorité** | P0 |
| **Type** | OneShot |
| **Durée fichier** | 1s |
| **Canaux** | Mono |
| **SoundGroup** | SG_UI |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.55 |
| **Contexte** | Nouvelle quête reçue / objectif mis à jour. Feedback clair. |
| **Prompt NLML** | `Warm, clear notification chime. A single struck note — like a small bell or tuning fork with western character. Satisfying but not flashy. Organic, not electronic. Feels like a frontier telegraph ping. 1 second, one-shot with natural ring decay.` |

---

### UI-002 — Transaction — vente d'or

| Champ | Valeur |
|-------|--------|
| **ID** | UI-002 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 1s |
| **Canaux** | Mono |
| **SoundGroup** | SG_UI |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.5 |
| **Contexte** | Le joueur vend de l'or chez Jed. Argent qui change de mains. |
| **Prompt NLML** | `Coins dropping onto a wooden counter. 3-4 metal coins falling and settling on wood. 1850s currency — heavy, chunky coins. Satisfying commercial transaction sound. 1 second, one-shot.` |

---

### UI-003 — Transaction — achat

| Champ | Valeur |
|-------|--------|
| **ID** | UI-003 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 0.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_UI |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.5 |
| **Contexte** | Le joueur achète un objet chez un marchand. |
| **Prompt NLML** | `Quick exchange sound: a coin sliding across wood and a soft thud of an item being placed on the counter. Brief, functional, satisfying. 0.5 seconds, one-shot.` |

---

### UI-004 — Inventaire — ouvrir/fermer

| Champ | Valeur |
|-------|--------|
| **ID** | UI-004 |
| **Priorité** | P2 |
| **Type** | OneShot |
| **Durée fichier** | 0.3s |
| **Canaux** | Mono |
| **SoundGroup** | SG_UI |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.4 |
| **Contexte** | Le joueur ouvre ou ferme l'inventaire. |
| **Prompt NLML** | `Leather satchel buckle being opened — soft click and leather flap. Like opening a worn leather bag. Quiet, functional. 0.3 seconds, one-shot.` |

---

### UI-005 — Leaderboard — monter

| Champ | Valeur |
|-------|--------|
| **ID** | UI-005 |
| **Priorité** | P2 |
| **Type** | OneShot |
| **Durée fichier** | 1s |
| **Canaux** | Mono |
| **SoundGroup** | SG_UI |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.5 |
| **Contexte** | Le joueur monte dans le classement. Feedback positif. |
| **Prompt NLML** | `Small celebratory chime — like a distant church bell or a prospector's triangle being struck once. Positive, encouraging, not over-the-top. Western-flavored achievement. 1 second, one-shot with ring decay.` |

---

### UI-006 — Level up / compétence

| Champ | Valeur |
|-------|--------|
| **ID** | UI-006 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 1.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_UI |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.6 |
| **Contexte** | Le joueur améliore une compétence d'orpaillage. Progression satisfaisante. |
| **Prompt NLML** | `Ascending two-note progression — like two strikes on a small anvil, the second higher in pitch. Satisfying skill-up sound with frontier character. Not a jingle — just two clear metallic notes ascending. 1.5 seconds, one-shot with natural decay.` |

---

## 6. MUSIQUE / STINGERS (MUS)

---

### MUS-001 — Thème principal Dusthaven

| Champ | Valeur |
|-------|--------|
| **ID** | MUS-001 |
| **Priorité** | P0 |
| **Type** | OneShot → fade out |
| **Durée fichier** | 45s |
| **Canaux** | ⚠️ **STÉRÉO** (seul son stéréo du jeu) |
| **SoundGroup** | SG_Music |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.3 |
| **Contexte** | Menu / première arrivée au village de Dusthaven. Définit le ton du jeu. |
| **Prompt NLML** | `Solo acoustic guitar, melancholic western theme. Slow fingerpicking, minor key, sparse and intimate. Think Ennio Morricone meets Gustavo Santaolalla — lonely, beautiful, weathered. No drums, no orchestra, no choir. Just one guitar telling a story of loss and hope in the American frontier. Stereo recording. 45 seconds, plays once then fades naturally.` |

---

### MUS-002 — Ambiance orpaillage

| Champ | Valeur |
|-------|--------|
| **ID** | MUS-002 |
| **Priorité** | P1 |
| **Type** | Loop |
| **Durée fichier** | 90s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Music |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.15 |
| **Contexte** | Pendant les sessions d'orpaillage actives. Presque imperceptible — ne doit PAS couvrir les SFX. |
| **Prompt NLML** | `Very quiet, minimal acoustic guitar picking. Simple repeating pattern in a major key, gentle and unhurried. Background texture only — must sit far behind other sounds. Like distant guitar heard from across a valley. No melody that demands attention. Understated, warm, meditative. Mono. 90 seconds, seamless loop, zero-crossing start and end.` |

---

### MUS-003 — Stinger — découverte fragment

| Champ | Valeur |
|-------|--------|
| **ID** | MUS-003 |
| **Priorité** | P0 |
| **Type** | OneShot |
| **Durée fichier** | 6s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Music |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.5 |
| **Contexte** | Quand un fragment de la lettre est trouvé. Moment de gravité émotionnelle. |
| **Prompt NLML** | `Short emotional musical phrase — solo cello or low guitar playing 4-5 notes in a descending minor progression. Solemn, heavy, intimate. A moment of realization and gravity. Not triumphant — contemplative. The sound of discovering something important from the past. 6 seconds, one-shot with natural decay into silence.` |

---

### MUS-004 — Stinger — premier Coyote

| Champ | Valeur |
|-------|--------|
| **ID** | MUS-004 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 4s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Music |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.4 |
| **Contexte** | Première apparition de Coyote (prologue). Mystère + curiosité. |
| **Prompt NLML** | `A single low breathy flute or harmonica phrase — 3-4 notes, rising then trailing off. Mysterious, curious, slightly playful. Like a question asked by the wind. Native American wooden flute character but not stereotypical. Natural, organic. 4 seconds, one-shot with natural breath decay.` |

---

### MUS-005 — Ambiance nuit

| Champ | Valeur |
|-------|--------|
| **ID** | MUS-005 |
| **Priorité** | P2 |
| **Type** | Loop |
| **Durée fichier** | 60s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Music |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.15 |
| **Contexte** | Complète AMB-006 pendant la nuit. Guitare ultra-lente. |
| **Prompt NLML** | `Extremely sparse, slow acoustic guitar. Single notes with long silences between them. Almost more silence than music. Like a lonesome cowboy playing one note every 8-10 seconds, staring at stars. Contemplative, vast, lonely. Barely there. Mono. 60 seconds, seamless loop, zero-crossing start and end.` |

---

### MUS-006 — Stinger — panneau Rattner

| Champ | Valeur |
|-------|--------|
| **ID** | MUS-006 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 2.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Music |
| **Spatial** | Non — SoundService global |
| **RollOff** | — |
| **Volume Roblox** | 0.5 |
| **Contexte** | Le joueur voit un panneau "RATTNER CO." pour la première fois. Tension, malaise. |
| **Prompt NLML** | `Short dissonant musical sting — a low bowed string or detuned guitar chord that creates immediate unease. Not a jump scare — a slow creeping dread. One sustained dissonant note that fades. Tension, threat, something wrong. 2.5 seconds, one-shot with slow decay.` |

---

### MUS-007 — Spot secret cascade

| Champ | Valeur |
|-------|--------|
| **ID** | MUS-007 |
| **Priorité** | P1 |
| **Type** | OneShot → short loop |
| **Durée fichier** | 20s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Music |
| **Spatial** | Oui — Part du spot secret (B3) |
| **RollOff** | Min 5 / Max 20 studs |
| **Volume Roblox** | 0.4 |
| **Contexte** | Le joueur découvre le bassin secret sous la cascade. Moment de récompense et d'émerveillement. |
| **Prompt NLML** | `Gentle, luminous acoustic guitar melody. Fingerpicked, major key, warm and golden. Like sunlight breaking through water. A reward moment — the player found something beautiful and hidden. Calm, magical but naturalistic (not fantasy-magical). 20 seconds, the first 8 seconds as an intro then transitions into a gentle loopable section. Zero-crossing at loop point.` |

---

## 7. PAS / DÉPLACEMENT (SFX)

---

### SFX-020 — Pas — terre/sable

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-020 |
| **Priorité** | P0 |
| **Type** | OneShot (déclenché par pas) |
| **Durée fichier** | 0.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 3 / Max 15 studs |
| **Volume Roblox** | 0.4 |
| **Contexte** | Déplacement sur terrain standard (désert, chemin de terre, sable). Le son le plus fréquent du jeu. |
| **Prompt NLML** | `Single footstep on dry sandy dirt ground. Boot on dusty earth with small pebbles. Dry, crunchy. Not heavy — medium weight. Natural outdoor acoustics. 0.5 seconds, one-shot. Generate 3 slight variations to avoid repetition.` |

---

### SFX-021 — Pas — bois/plancher

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-021 |
| **Priorité** | P1 |
| **Type** | OneShot (déclenché par pas) |
| **Durée fichier** | 0.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 3 / Max 15 studs |
| **Volume Roblox** | 0.45 |
| **Contexte** | Déplacement dans les bâtiments ou sur les ponts. |
| **Prompt NLML** | `Single footstep on old wooden floorboards. Hollow wood creak, slight flex. Boot heel on aged timber planks. Indoor acoustics with slight room resonance. 0.5 seconds, one-shot. Generate 3 slight variations.` |

---

### SFX-022 — Pas — eau peu profonde

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-022 |
| **Priorité** | P1 |
| **Type** | OneShot (déclenché par pas) |
| **Durée fichier** | 0.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 3 / Max 15 studs |
| **Volume Roblox** | 0.45 |
| **Contexte** | Déplacement dans la rivière (berge, eau peu profonde). |
| **Prompt NLML** | `Single footstep splashing in shallow water over river stones. Ankle-deep water. Splash and wet stone underfoot. Outdoor natural stream acoustics. 0.5 seconds, one-shot. Generate 3 slight variations.` |

---

### SFX-023 — Pas — neige

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-023 |
| **Priorité** | P1 |
| **Type** | OneShot (déclenché par pas) |
| **Durée fichier** | 0.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 3 / Max 15 studs |
| **Volume Roblox** | 0.4 |
| **Contexte** | Déplacement dans la zone Whitepine (neige). |
| **Prompt NLML** | `Single footstep on compacted snow. Characteristic snow crunch — crisp, cold, satisfying. Boot pressing into frozen snow surface. Quiet mountain acoustics. 0.5 seconds, one-shot. Generate 3 slight variations.` |

---

### SFX-024 — Pas — pierre/roche

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-024 |
| **Priorité** | P2 |
| **Type** | OneShot (déclenché par pas) |
| **Durée fichier** | 0.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 3 / Max 15 studs |
| **Volume Roblox** | 0.45 |
| **Contexte** | Déplacement dans les zones rocheuses / canyon. |
| **Prompt NLML** | `Single footstep on hard rocky surface. Boot on solid stone with slight scrape. Hard, dry, with a brief echo suggesting canyon or rocky terrain. 0.5 seconds, one-shot. Generate 3 slight variations.` |

---

## 8. ÉVÉNEMENTS SPÉCIAUX (SFX)

---

### SFX-030 — Kayak — mise à l'eau

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-030 |
| **Priorité** | P1 |
| **Type** | OneShot |
| **Durée fichier** | 2s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Part du kayak / berge |
| **RollOff** | Min 5 / Max 30 studs |
| **Volume Roblox** | 0.6 |
| **Contexte** | Le joueur lance le kayak sur la rivière (Gate Z1→Z2). |
| **Prompt NLML** | `Small wooden canoe or kayak sliding from pebble riverbank into water. Wood scraping on gravel, then a splash as it enters the water. The hull settling into the current. 2 seconds, one-shot with natural water settle.` |

---

### SFX-031 — Kayak — pagaie

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-031 |
| **Priorité** | P1 |
| **Type** | Loop (court) |
| **Durée fichier** | 1.5s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Part du kayak |
| **RollOff** | Min 5 / Max 25 studs |
| **Volume Roblox** | 0.5 |
| **Contexte** | Le joueur pagaie sur la rivière. |
| **Prompt NLML** | `Single paddle stroke in river water. Wooden paddle entering water, pulling through, lifting out with drips. One complete stroke cycle. Rhythmic, natural. 1.5 seconds, seamless loop, zero-crossing start and end.` |

---

### SFX-032 — Détecteur métaux — bip normal

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-032 |
| **Priorité** | P2 |
| **Type** | OneShot |
| **Durée fichier** | 0.3s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 3 / Max 10 studs |
| **Volume Roblox** | 0.4 |
| **Contexte** | Le détecteur passe sur un objet banal. Signal faible standard. |
| **Prompt NLML** | `Weak, low-pitched metal detector beep. Single short tone, nothing exciting. Standard detection signal. Not electronic-sounding — more like a dull resonant ping. 0.3 seconds, one-shot.` |

---

### SFX-033 — Détecteur métaux — signal fort (météorite)

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-033 |
| **Priorité** | P2 |
| **Type** | OneShot |
| **Durée fichier** | 2s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Personnage joueur |
| **RollOff** | Min 5 / Max 20 studs |
| **Volume Roblox** | 0.7 |
| **Contexte** | Le détecteur trouve la météorite enfouie. Signal intense, unique — le joueur SAIT que c'est spécial. |
| **Prompt NLML** | `Intense, vibrating metal detector signal — rapid pulsing that builds in urgency. Much louder and more insistent than a normal beep. The sound of finding something extraordinary underground. Builds over 2 seconds to a sustained high tone. One-shot.` |

---

### SFX-034 — Éboulement léger

| Champ | Valeur |
|-------|--------|
| **ID** | SFX-034 |
| **Priorité** | P2 |
| **Type** | OneShot |
| **Durée fichier** | 2s |
| **Canaux** | Mono |
| **SoundGroup** | SG_Gameplay |
| **Spatial** | Oui — Part de l'éboulement |
| **RollOff** | Min 10 / Max 50 studs |
| **Volume Roblox** | 0.6 |
| **Contexte** | Petits cailloux qui tombent. Ambiance grottes / transition entre zones. |
| **Prompt NLML** | `Small rockfall — loose gravel and small stones tumbling down a rocky slope. Pebbles bouncing and settling. Dust-like quality. Not a major collapse — just a minor shift. Cave or canyon acoustics with slight echo. 2 seconds, one-shot with natural settle.` |

---

## RÉCAPITULATIF FINAL

| Catégorie | Nb | P0 | P1 | P2 | Format | Canaux |
|-----------|:---:|:---:|:---:|:---:|--------|--------|
| AMB — Ambiances | 8 | 4 | 3 | 1 | .ogg 44.1kHz | Mono |
| SFX — Orpaillage | 7 | 4 | 2 | 1 | .ogg 44.1kHz | Mono |
| SFX — Interactions | 8 | 3 | 4 | 1 | .ogg 44.1kHz | Mono |
| VOX — Signaux PNJ | 8 | 3 | 3 | 2 | .ogg 44.1kHz | Mono |
| UI — Feedback | 6 | 1 | 3 | 2 | .ogg 44.1kHz | Mono |
| MUS — Musique/Stingers | 7 | 2 | 4 | 1 | .ogg 44.1kHz | **MUS-001 = Stéréo**, reste Mono |
| SFX — Pas | 5 | 1 | 3 | 1 | .ogg 44.1kHz | Mono |
| SFX — Événements | 5 | 0 | 2 | 3 | .ogg 44.1kHz | Mono |
| **TOTAL** | **54** | **18** | **24** | **12** | | |

### Ordre de génération recommandé :
1. **Batch 1 (P0)** — 18 sons bloquants pour la démo
2. **Batch 2 (P1)** — 24 sons polish
3. **Batch 3 (P2)** — 12 sons finitions

---

> **⚠️ RAPPEL : AUCUNE GÉNÉRATION NLML LABS SANS VALIDATION DE MONCEF.**
> **Pour chaque son : copier le bloc SPECS OBLIGATOIRES + le Prompt NLML de la fiche.**
> **Vérifier la CHECKLIST AVANT UPLOAD après chaque génération.**
