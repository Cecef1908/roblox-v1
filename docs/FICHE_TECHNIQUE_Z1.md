# DUSTHAVEN — Fiche Technique Zone 1 (Demo)
# Dead Man's Shallows — Prologue + Acte I

> **Version** : 1.0
> **Date** : 15 mars 2026
> **Auteur** : Arken (Commandant)
> **Statut** : RÉFÉRENTIEL TECHNIQUE — Document de production pour la démo
> **Sources** : Lore V2 (Thorn), Map Z1 V2, Sound Index Z1

---

## TABLE DES MATIÈRES

1. [Vue d'Ensemble](#1-vue-densemble)
2. [Layout & Terrain](#2-layout--terrain)
3. [Structures & Bâtiments](#3-structures--bâtiments)
4. [PNJ — Fiches Complètes](#4-pnj--fiches-complètes)
5. [Spots d'Orpaillage](#5-spots-dorpaillage)
6. [Fragments de la Lettre](#6-fragments-de-la-lettre)
7. [Événements Scriptés](#7-événements-scriptés)
8. [Flux Joueur Minute par Minute](#8-flux-joueur-minute-par-minute)
9. [Système de Réputation](#9-système-de-réputation)
10. [Craft & Économie](#10-craft--économie)
11. [Ambiance Sonore par Zone](#11-ambiance-sonore-par-zone)
12. [Gate Z1 → Z2](#12-gate-z1--z2)
13. [Checklist d'Implémentation](#13-checklist-dimplémentation)

---

## 1. VUE D'ENSEMBLE

### Identité de la Zone

| Champ | Valeur |
|-------|--------|
| **Nom interne** | Zone 1 — Dead Man's Shallows |
| **Nom affiché** | Dead Man's Shallows |
| **Actes couverts** | Prologue (Cabane d'Eli) + Acte I |
| **Durée estimée** | 2-3 heures de gameplay |
| **Thèmes** | Découverte, méfiance, premiers indices, orpaillage |
| **Date in-game** | Été 1852 |
| **Éclairage** | Cycle jour/nuit. Lumière dorée dominante (golden hour western) |
| **Palette couleur** | Ocres, bruns, sable, touches de vert (végétation éparse), bleu (rivière) |
| **Direction artistique** | Stylized PBR — Sea of Thieves × Red Dead Redemption |

### Objectifs du joueur (Acte I)

| # | Objectif | Type | Condition de complétion |
|---|----------|------|------------------------|
| 1 | Prendre la batée dans la cabane d'Eli | Principal | Interagir avec la batée au mur |
| 2 | Orpailler pour la première fois (tutoriel) | Principal | Réussir 1 session d'orpaillage au ruisseau |
| 3 | Trouver le Fragment #1 | Principal | Revenir dans la cabane, interagir avec la table |
| 4 | Descendre à Dusthaven | Principal | Atteindre le village |
| 5 | Rencontrer Jed Bramwell | Principal | Entrer dans le magasin, dialoguer |
| 6 | Vendre du premier or | Principal | Transaction chez Jed |
| 7 | Rencontrer le Sheriff Dawson | Principal | Se faire aborder par le Sheriff dans la rue |
| 8 | Explorer Dead Man's Shallows | Principal | Visiter au moins 2 spots d'orpaillage |
| 9 | Trouver le Fragment #2 | Principal | Ouvrir le coffre abandonné en Z1 |
| 10 | Atteindre la réputation suffisante avec Jed | Principal | Vendre assez d'or / faire ses quêtes |
| 11 | Recevoir le carnet d'Eli de Jed | Principal (fin Acte I) | Réputation Jed = haute |
| 12 | Fabriquer/trouver le kayak | Principal (Gate) | Obtenir le kayak pour passer en Z2 |
| OPT-1 | Découvrir le spot secret sous la cascade | Optionnel | Explorer sous la cascade (B3) |
| OPT-2 | Trouver l'inscription Nahak'a | Optionnel | Explorer la paroi près de D4 |
| OPT-3 | Voir la première apparition de Coyote | Semi-auto | Se déclenche en sortant de la cabane |
| OPT-4 | Trouver le panneau RATTNER CO. | Semi-auto | Visible en explorant Z1 |

---

## 2. LAYOUT & TERRAIN

### Grille de Référence (Map V2)

La map utilise une grille **A-J (colonnes) × 1-10 (lignes)**. Nord = haut.

### Biomes

| Biome | Coordonnées grille | Matériaux terrain Roblox | Description |
|-------|--------------------|--------------------------|-------------|
| **Whitepine** (montagne enneigée) | A1-C2 | Snow, Rock, Glacier | Pics enneigés, roche gris-brun, altitude élevée. Transition nette vers le désert. |
| **Dead Man's Shallows** (zone de transition) | C2-E3 | Sand, Mud, Grass, Rock | Zone entre montagne et désert. Rivière qui serpente. Végétation plus dense près de l'eau. |
| **Dusthaven** (cratère central / village) | E5-H6 | Sand, Sandstone, Ground | Grand cratère circulaire (impact de météorite). Terrain plat au centre, parois en pente douce. 4 bâtiments. |
| **Désert / badlands** | D1-J10 (tout le reste) | Sand, Sandstone, Rock | Terrain aride, mesas, plateaux, végétation éparse (cactus, arbustes). Palette beige-ocre-brun. |

### Rivière

| Segment | Tracé | Caractéristiques |
|---------|-------|------------------|
| Source | A2-B2 (Whitepine) | Eau froide, claire, début du débit |
| Cascade | B2-C2 | Chute d'eau principale. Spot secret derrière (B3) |
| Méandre nord | C2-D3 | Ruisseau qui serpente. Berges accessibles. Zone tutoriel orpaillage |
| Coude principal | D4-E4 | Courbe prononcée. Spot d'orpaillage "Courbe rivière" |
| Traversée village | E5-F5 | Passe près de Dusthaven. Pont nord (D2) et Pont sud (F7) |
| Sortie sud | F7-B10 / J7 | Se divise. Sort de la map |

### Élévation

| Zone | Altitude relative | Notes |
|------|-------------------|-------|
| Whitepine (pics) | Très haute | Sommet de la map, neige |
| Cabane d'Eli | Haute | Pied de Copper Canyon, au-dessus du village |
| Dead Man's Shallows | Moyenne | Zone de la rivière, en pente douce vers le village |
| Dusthaven (cratère) | Basse | Fond du cratère, zone la plus basse |
| Berges rivière | Basse | Au niveau de l'eau |

---

## 3. STRUCTURES & BÂTIMENTS

### 3.1 — Cabane d'Eli (Spawn)

| Champ | Valeur |
|-------|--------|
| **ID Map** | (1) |
| **Coordonnées** | C1 |
| **Fonction** | Point de spawn du joueur + Prologue narratif |
| **Extérieur** | Cabane en bois rustique, petite, porte entrouverte. Entourée de pins. Ruisseau derrière. |
| **Intérieur** | Une pièce. Table, lit, mur avec batée accrochée. Objets interactifs (voir ci-dessous). |

**Objets interactifs dans la cabane :**

| Objet | Position | Interaction | Info-bulle | Son | Conséquence |
|-------|----------|-------------|------------|-----|-------------|
| Batée (gold pan) | Accrochée au mur | Clic = prendre | — | SFX-013 | Le joueur obtient la batée. Tutoriel orpaillage activé. |
| Tasse en étain | Sur la table | Clic = examiner | *"Tiède. Quelqu'un était là il n'y a pas longtemps."* | — | Lore flavor. Humanise Eli. |
| Photo floue | Cadre sur le mur/meuble | Clic = examiner | *"Une famille. Les visages sont effacés par le temps."* | — | Lore flavor. Connexion émotionnelle. |
| Journal ouvert | Sur le lit | Clic = examiner | *"Des notes. Beaucoup de notes. L'encre est fraîche sur certaines pages."* | — | Lore flavor. Eli est actif. |
| Bout de papier (Fragment #1) | Sous la tasse, sur la table | Clic = prendre | — | SFX-011 | **Fragment #1** récupéré. Disponible SEULEMENT après la 1ère session d'orpaillage. |

**Ruisseau derrière la cabane :**
- Position : immédiatement derrière la cabane (C1, vers C2)
- Fonction : spot tutoriel d'orpaillage
- Le joueur y va naturellement après avoir pris la batée
- Premier grain d'or = premier feedback haptique

---

### 3.2 — Pont Nord

| Champ | Valeur |
|-------|--------|
| **ID Map** | (4) |
| **Coordonnées** | D2 |
| **Fonction** | Pont en bois traversant la rivière — connecte zone nord (Whitepine/cabane) à la zone centrale |
| **Matériaux** | Bois brut, cordes, planches usées |
| **Interaction** | Traversable. Pas de ProximityPrompt. |
| **Son** | SFX-016 (planches qui craquent) |

---

### 3.3 — Magasin de Jed

| Champ | Valeur |
|-------|--------|
| **ID Map** | (17) |
| **Coordonnées** | E5 (dans Dusthaven) |
| **Fonction** | Commerce — vente d'or, achat de matériel et outils |
| **Extérieur** | Bâtiment en bois, enseigne "GENERAL STORE". Le plus grand bâtiment du village. |
| **Intérieur** | Comptoir central (Jed est TOUJOURS derrière). Étagères avec outils, provisions. |
| **PNJ** | Jed Bramwell (voir section 4.1) |
| **Mécaniques** | Shop UI : vendre or → pièces, acheter outils/provisions |

**Inventaire du magasin :**

| Item | Prix | Catégorie | Notes |
|------|------|-----------|-------|
| Batée améliorée | 50 coins | Outil | +rendement orpaillage |
| Pioche basique | 30 coins | Outil | Pour dégager éboulements |
| Provisions (nourriture) | 10 coins | Consommable | Restaure endurance |
| Corde | 15 coins | Matériau | Craft kayak |
| Lampe à huile | 25 coins | Outil | Éclairage grottes (utile Z2-Z3) |
| Fil de cuivre | 8 coins | Matériau | Craft divers |

---

### 3.4 — Belle's Saloon

| Champ | Valeur |
|-------|--------|
| **ID Map** | (18) |
| **Coordonnées** | F5 (dans Dusthaven) |
| **Fonction** | Social hub + info lore + rencontre Rattler (Acte II) |
| **Extérieur** | Porte battante western. Enseigne "BELLE'S". Le seul bâtiment avec de la lumière chaude qui sort des fenêtres. |
| **Intérieur** | Bar, tables, piano (pas de pianiste — juste quelques notes éparses), ambiance tamisée. |
| **PNJ** | Belle Fontaine (barkeep) — PNJ secondaire dans la démo |
| **Son** | VOX-005 (ambiance saloon) |
| **Note Acte II** | C'est ICI que le Rattler apparaît pour la première fois — seul à une table, en costume. |

---

### 3.5 — Bureau du Sheriff

| Champ | Valeur |
|-------|--------|
| **ID Map** | (26) |
| **Coordonnées** | F6 (dans Dusthaven) |
| **Fonction** | Bureau de Dawson — lore + quête piège |
| **Extérieur** | Bâtiment sombre, étoile de sheriff peinte sur la porte. Porche avec chaise. |
| **Intérieur** | Bureau austère, cellule vide, dossiers. Documents de concession visibles sur le bureau (foreshadowing). |
| **PNJ** | Sheriff Buck Dawson — mais il n'est PAS dans le bureau (il patrouille). Le joueur le rencontre dans la rue. |

---

### 3.6 — Forge de Gustave

| Champ | Valeur |
|-------|--------|
| **ID Map** | (21) |
| **Coordonnées** | F6 (dans Dusthaven, près du bureau du Sheriff) |
| **Fonction** | Forge — craft d'outils, upgrade d'équipement + lore Gustave |
| **Extérieur** | Forge ouverte, fumée, enclume visible depuis la rue. Le son du marteau guide le joueur. |
| **Intérieur** | Enclume, foyer, outils accrochés, établi avec tiroir (Fragment #5 — Acte II). |
| **PNJ** | Gustave Moreau (voir section 4.3) |
| **Son** | VOX-001 (marteau forge — PERMANENT quand Gustave est actif) |
| **Mécaniques** | Craft UI (si implémenté) : apporter matériaux → Gustave forge des outils |

---

### 3.7 — Leaderboard

| Champ | Valeur |
|-------|--------|
| **ID Map** | (25) |
| **Coordonnées** | F5 (dans Dusthaven) |
| **Fonction** | Classement des joueurs (or total trouvé) |
| **Forme** | Panneau en bois avec tableau noir / ardoise. Affichage dynamique. |
| **Interaction** | ProximityPrompt → ouvre le leaderboard UI |
| **Son** | UI-005 quand le joueur monte |

---

### 3.8 — Pont Sud

| Champ | Valeur |
|-------|--------|
| **ID Map** | (28) |
| **Coordonnées** | F7 |
| **Fonction** | Pont traversant la rivière au sud du village |
| **Matériaux** | Identique au Pont nord — bois brut, planches |
| **Son** | SFX-016 |

---

## 4. PNJ — FICHES COMPLÈTES

### 4.1 — Jed Bramwell (Le Marchand)

| Champ | Valeur |
|-------|--------|
| **ID Map PNJ** | (10) |
| **Coordonnées** | E5 (dans le magasin, TOUJOURS derrière le comptoir) |
| **Rôle** | Marchand + gardien du carnet d'Eli |
| **Apparence** | Homme trapu, 58 ans, moustache blanche, tablier beige, lunettes rondes en fil de fer. Calvitie, crâne bronzé. |
| **Signal sensoriel** | Toujours derrière le comptoir. Jamais devant, jamais dehors. |
| **Tic** | Essuie ses lunettes avec son tablier quand il réfléchit ou quand un sujet le met mal à l'aise. |

**Dialogues par niveau de réputation :**

| Réputation | Dialogue | Comportement |
|------------|----------|------------|
| **Basse** (première visite) | *"New customer. Good. Gold's weighed fair here, supplies are on the wall. You look like you walked a long way to get here. ...That pan you're carrying — where'd you get it?"* | Transactionnel. Vend, achète. Regarde la batée une demi-seconde de trop. |
| **Moyenne** (après quelques ventes) | *"Three nuggets, forty cents. Fair price. ...That's a Henderson pan, ain't it?"* / *"Copper wire's in the back. You know, your granddad used to buy the same gauge."* | Reconnaît la batée. Pose des questions personnelles. Change de sujet si le joueur insiste sur Eli. |
| **Haute** (condition Gate Acte I) | *"I keep things for people. Sometimes for a long time. You a patient sort?"* → Donne le **carnet d'Eli**. | Donne le carnet. Parle d'Eli au passé puis se corrige au présent — il sait qu'Eli est vivant. |

**Quêtes données par Jed :**

| Quête | Description | Récompense | Réputation |
|-------|-------------|------------|------------|
| Quartz bleu | *"Ramène du quartz bleu de la rivière — j'ai un client spécial."* | 20 coins + objet gratuit | +1 Jed |
| Cuivre de canyon | *"Il me manque du cuivre pour une commande. Copper Canyon devrait avoir ce qu'il faut."* (Z2) | 30 coins | +1 Jed |

**Réaction au nom "Rattner" :** Pose sa main à plat sur le comptoir. *"Pas ce nom ici."* — Fermeture immédiate.

---

### 4.2 — Sheriff Buck Dawson

| Champ | Valeur |
|-------|--------|
| **ID Map PNJ** | (13) |
| **Coordonnées** | Patrouille dans Dusthaven (F5-F6, rues). PAS dans son bureau. |
| **Rôle** | Antagoniste passif — informateur de Rattner |
| **Apparence** | Grand (1m85), sec, yeux gris pâle. Chapeau de sheriff marron, étoile en laiton ternie, gilet cuir noir. Cicatrice sur l'arête du nez. Bottes cirées. |
| **Signal sensoriel** | **Se déplace VERS le joueur.** Seul PNJ qui fait ça. Bottes qui claquent sur les planches. |
| **Tic** | Ajuste l'étoile sur sa poitrine quand il ment ou jauge le joueur. Geste lent, délibéré. |

**Dialogues par niveau de réputation :**

| Réputation | Dialogue | Comportement |
|------------|----------|------------|
| **Basse** (première rencontre) | *"Well now. Don't think I've seen your face around here before. I make it my business to know everyone in Dusthaven. Name's Dawson. And yours?"* | Faussement amical. Questions déguisées en conversation. Surveillance passive. |
| **Moyenne** | *"Henderson, you said? Hm. Name rings a bell. Faint one."* / *"Friendly advice: some trails in this valley don't lead anywhere good. I'd hate to see you lost."* | Plus direct. Suggestions de quitter la vallée. |
| **Haute** (Acte II+) | Masque tombe. Admet travailler pour Rattner. Possible retournement. | Le Sheriff suit parfois le joueur à distance dans le village. |

**Comportement unique :** Dawson se déplace VERS le joueur dès qu'il le repère en ville. C'est le SEUL PNJ qui fait ça. Les autres attendent qu'on leur parle.

**Fausse quête :** *"Si tu vois quelque chose de suspect dans les mines, viens me le dire. C'est pour la sécurité de tous."* → En réalité, il transmet les infos au Rattler. Le joueur peut ne jamais s'en rendre compte dans la démo.

**Son :** VOX-003 (bottes qui claquent) — annonce sa présence avant qu'il soit visible.

---

### 4.3 — Gustave Moreau (Le Forgeron)

| Champ | Valeur |
|-------|--------|
| **ID Map PNJ** | (12) |
| **Coordonnées** | F6 (à la forge, TOUJOURS à son enclume) |
| **Rôle** | Forgeron + gardien moral + Fragments #5 et #8 |
| **Apparence** | Massif, épaules larges, peau sombre, crâne rasé, barbe grise. Tablier cuir noir de suie. Tatouage marteau/enclume sur avant-bras gauche. |
| **Signal sensoriel** | **Son de la forge PERMANENT.** Marteau sur enclume. Quand le son s'arrête = événement important. |
| **Tic** | 3 coups secs sur l'enclume quand il met fin à une conversation. |

**Dialogues par niveau de réputation :**

| Réputation | Dialogue | Comportement |
|------------|----------|------------|
| **Basse** | *(Silence. Il ne lève pas les yeux. Le marteau continue.)* | Ne regarde pas le joueur. Forge. |
| **Moyenne** (reconnaît la batée) | Le joueur montre la batée ou un outil marqué du symbole du Serpent. Gustave **se fige**. Regarde la batée 3 secondes en silence. Se retourne vers l'enclume. *"...Good steel."* | Un mot de temps en temps. Accepte les commandes de craft. |
| **Haute** (Acte II) | *"A man's tools tell his story. These... told a good one."* / Donne Fragment #5. Forge un outil spécial sans rien demander. | Parle d'Eli au présent. *"He talks about you. He's proud."* |

**Sons :** VOX-001 (marteau loop), VOX-002 (3 coups finaux).

---

### 4.4 — Old Pete (Prospecteur)

| Champ | Valeur |
|-------|--------|
| **ID Map PNJ** | (14) |
| **Coordonnées** | D3 (dans Dead Man's Shallows, près des spots d'orpaillage) |
| **Rôle** | PNJ secondaire — exposition sur le Rattler |
| **Apparence** | Vieux prospecteur maigre, barbe sale, chapeau troué, vêtements usés. |
| **Fonction narrative** | Explique que Rattner rachète les concessions. *"Il m'a donné le choix : vendre ou être 'relocalisé'. J'ai pris l'argent."* |

**Dialogues :**
- *"Had a claim here for two years. Two years! Rattner bought it for nothing. Said it was 'fair market value.' Nothing fair about it."*
- *"You're Henderson's kin? ...Be careful who you tell that to."*

**Note Acte II :** Old Pete **disparaît** du village. Personne ne sait où il est. Sous-entendu : intimidé/déplacé par Rattner.

---

### 4.5 — Coyote (Guide Silencieux)

| Champ | Valeur |
|-------|--------|
| **Coordonnées** | Variables — jamais au même endroit |
| **Rôle** | Guide non-verbal, fil d'Ariane émotionnel |
| **Apparence** | Coyote fauve-gris, yeux ambrés, cicatrice oreille droite. Plus propre qu'un coyote sauvage. |
| **Signal sensoriel** | Jamais là où on l'attend. Toits, rochers, tonneaux, branches. Toujours en hauteur ou en périphérie. |

**Apparitions scriptées Zone 1 :**

| Moment | Lieu | Action | Son |
|--------|------|--------|-----|
| Sortie cabane (Prologue) | Rocher à 5m de la cabane | S'assied, penche la tête, trace un cercle dans la poussière, trottine vers Dusthaven | VOX-006, VOX-007, MUS-004 |
| Après Fragment #2 (Acte I) | Près du coffre abandonné | Réapparaît quand le joueur lit le fragment. Guide vers inscription murale. | VOX-006 |
| Village (random) | Toit du magasin / muret saloon | Observe le joueur. Parfois fixe un tiroir chez Jed (indice carnet). | — |
| Guide vers Z1 | Chemin vers Dead Man's Shallows | Se déplace dans la direction de Z1 | — |

**Arc de réputation Coyote :**
- **Basse** : Apparaît brièvement, s'enfuit quand le joueur s'approche.
- **Moyenne** : Se laisse approcher. Guide vers des lieux clés.
- **Haute** : Marche à côté du joueur. S'assied à ses pieds dans les moments de calme.

---

## 5. SPOTS D'ORPAILLAGE

> **Rappel fondamental** : C'est de l'ORPAILLAGE (gold panning en rivière), PAS du mining avec pioches.
> Le joueur utilise une **batée** (pan) dans l'eau pour tamiser le gravier et trouver de l'or.

### Carte des spots

| ID Map | Nom | Coordonnées | Difficulté | Récompense moy. | Type | Notes |
|--------|-----|-------------|------------|------------------|------|-------|
| (5) | **Spot Tutoriel** | C2 | ★☆☆ | 1-2 grains | Guidé | Premier spot. Derrière la cabane. Tutoriel mécanique. |
| (6) | **Cascade** | B2 | ★★☆ | 2-4 grains | Standard | Au pied de la cascade. Plus de débit = plus de rendement. |
| (7) | **Secret sous cascade** | B3 | ★★★ | 5-8 grains + quartz | Caché | **Spot secret.** Accessible en passant DERRIÈRE la cascade. Bassin isolé, or concentré. MUS-007 se déclenche. Moment de calme. |
| (8) | **Berge facile** | C3 | ★☆☆ | 1-3 grains | Standard | Berge calme, accès facile. Bon pour les débutants. |
| (13) | **Courbe rivière** | D5 | ★★☆ | 3-5 grains | Standard | Au coude de la rivière. Dépôt naturel — plus de sédiments = plus d'or. |
| (15) | **Bassin isolé** | G8 | ★★★ | 4-7 grains + rare nugget | Éloigné | Petit bassin circulaire au sud de Dusthaven. Isolé. Bonne récompense pour l'exploration. |
| (19-24) | **Spots cratère** | E5-G6 | ★★☆ | 2-4 grains | Standard | Plusieurs petits spots dans le cratère de Dusthaven. Pratiques mais pas les plus riches. |

### Mécanique d'orpaillage

| Étape | Action joueur | Feedback | Son |
|-------|---------------|----------|-----|
| 1. S'approcher d'un spot | ProximityPrompt apparaît | Icône batée | SFX-015 |
| 2. Activer | Clic sur le prompt | Animation : joueur s'accroupit, plonge la batée | SFX-001 |
| 3. Tamiser | Mini-game ou auto | Animation : mouvement circulaire de la batée | SFX-002 (loop) |
| 4a. Résultat — or | Grain/pépite apparaît | Flash doré + UI notification | SFX-003 ou SFX-004 |
| 4b. Résultat — vide | Rien | Gravier retombe | SFX-005 |
| 4c. Résultat — quartz | Quartz apparaît | Flash cristallin | SFX-006 |
| 5. Poser la batée | Fin de session | Joueur se relève | SFX-007 |

### Cooldown et farming

| Paramètre | Valeur recommandée |
|-----------|-------------------|
| Cooldown par spot | 60-90 secondes |
| Rendement dégressif | Après 5 sessions sur le même spot, rendement baisse de 50% pendant 5 min |
| Gros nugget (rare) | 5% de chance par session (spots ★★★ : 10%) |
| Quartz | 15% de chance sur spots ★★+ |

---

## 6. FRAGMENTS DE LA LETTRE

### Fragment #1 — La Lettre (morceau 1)

| Champ | Valeur |
|-------|--------|
| **Localisation** | Cabane d'Eli (C1), sous la tasse sur la table |
| **Condition** | Disponible SEULEMENT après que le joueur ait fait sa 1ère session d'orpaillage |
| **Acte** | Prologue |
| **Obligatoire** | ✅ Oui |
| **Contenu** | *"...forgive me... I found something... beautiful and terrible... couldn't leave it... couldn't let them..."* |
| **Son** | SFX-011 (papier ancien qu'on déplie) + MUS-003 (stinger découverte) |
| **Conséquence** | Le journal de quête s'active. Objectif "Trouver Eli Henderson" apparaît. |

### Fragment #2 — La Lettre (morceau 2)

| Champ | Valeur |
|-------|--------|
| **Localisation** | Coffre abandonné au bord du ruisseau principal de Z1 (Dead Man's Shallows) |
| **Condition** | Le coffre est trouvable dès l'arrivée en Z1 |
| **Acte** | Acte I |
| **Obligatoire** | ✅ Oui |
| **Contenu** | *"...under the water, under the stone, there is a place that... the earth made for no one to own. Three streams meet... and the gold runs through it like veins in a living thing..."* |
| **Son** | SFX-010 (coffre) + SFX-011 (fragment) + MUS-003 (stinger) |
| **Conséquence** | Coyote réapparaît et guide vers inscription murale partiellement cachée par la mousse. Nouvelle entrée journal. |

### Fragment #3 (Acte II — référence)

Localisé dans une fissure de Copper Canyon (Z2). **Pas dans Z1**, mais déclenche un effet retour au hub : un nouveau panneau "RATTNER CO." apparaît devant la forge de Gustave.

---

## 7. ÉVÉNEMENTS SCRIPTÉS

### Ordre chronologique des événements Zone 1

| # | Événement | Déclencheur | Lieu | PNJ | Sons | Notes |
|---|-----------|-------------|------|-----|------|-------|
| E01 | **Arrivée cabane** | Spawn | C1 | — | AMB-005 | Porte entrouverte. Le joueur entre librement. |
| E02 | **Prise de la batée** | Interaction mur | C1 | — | SFX-013 | Action fondatrice. Tutoriel orpaillage se déclenche. |
| E03 | **Tutoriel orpaillage** | Joueur va au ruisseau derrière | C1-C2 | — | SFX-001/002/003 | Premier grain d'or. Premier feedback. |
| E04 | **Fragment #1** | Retour cabane post-orpaillage | C1 | — | SFX-011, MUS-003 | Bout de papier sous la tasse. Journal de quête activé. |
| E05 | **1ère apparition Coyote** | Sortie de la cabane avec batée | C1 extérieur | Coyote | VOX-006/007, MUS-004 | Cercle dans la poussière. Trottine vers Dusthaven. ~minute 8. |
| E06 | **Descente vers Dusthaven** | Navigation libre | C1 → E5 | — | AMB-001 → AMB-004 (transition) | Le joueur suit Coyote ou explore librement. |
| E07 | **Arrivée à Dusthaven** | Entrer dans le périmètre du village | E5-G6 | — | AMB-004, VOX-001 (forge) | Première impression : village western tendu. |
| E08 | **Rencontre Jed** | Entrer dans le magasin | E5 | Jed | — | Dialogue intro Jed. Il remarque la batée. |
| E09 | **Sheriff s'approche** | Le joueur sort du magasin / marche dans la rue | F5-F6 | Dawson | VOX-003 | Dawson marche VERS le joueur. Dialogue intro. |
| E10 | **1ère apparition Coyote village** | Random après E08 | Toit/muret | Coyote | — | Observe. Guide vers Z1 si le joueur ne l'a pas encore exploré. |
| E11 | **Exploration Dead Man's Shallows** | Le joueur explore vers D3-D5 | DMS | Old Pete | AMB-002 | Rencontre Old Pete. Panneaux "RATTNER CO." visibles. |
| E12 | **Panneau RATTNER CO.** | Le joueur passe devant | D3 (ou spot en Z1) | — | MUS-006 (stinger tension) | Premier signe de la menace. Panneau en bois neuf sur une concession. |
| E13 | **1ère rencontre Old Pete** | S'approcher d'Old Pete | D3 | Old Pete | — | Explique que Rattner rachète les concessions. |
| E14 | **Gros nugget** | Session orpaillage (random) | N'importe quel spot | — | SFX-004 | ~minute 16. Feedback satisfaisant. |
| E15 | **Fragment #2** | Ouvrir le coffre abandonné | Z1 (bord ruisseau) | — | SFX-010/011, MUS-003 | Coyote réapparaît. Guide vers inscription. |
| E16 | **Jed offre un objet** | Ramener du quartz à Jed | E5 | Jed | UI-002 | ~minute 24. Relation building. |
| E17 | **Spot secret cascade** | Le joueur explore derrière la cascade | B3 | — | AMB-008, MUS-007 | ~minute 32. Bassin secret. Calme, lumière dorée. |
| E18 | **Inscription Nahak'a** | Le joueur explore les parois | D4 (ou B4) | — | SFX-017 | ~minute 40. Symbole incompréhensible. S'enregistre dans le journal. |
| E19 | **Jed donne le carnet** | Réputation Jed = haute | E5 | Jed | SFX-011, MUS-003 | **FIN DE L'ACTE I.** Carnet d'Eli en cuir usé. Première mention de "Kaya". |
| E20 | **Gate — Kayak** | Le joueur fabrique ou trouve le kayak | A2 / C2 | — | SFX-030 | Transition vers Z2. Le joueur remonte le ruisseau vers Copper Canyon. |

---

## 8. FLUX JOUEUR MINUTE PAR MINUTE

> Basé sur les micro-récompenses émotionnelles toutes les ~8 minutes (design doc).

| Minute | Événement | Émotion cible | Feedback |
|--------|-----------|---------------|----------|
| **0-2** | Spawn dans la cabane. Exploration des objets. | Curiosité, intimité | Objets interactifs, info-bulles |
| **2-4** | Prend la batée. Sort derrière la cabane. | Anticipation | — |
| **4-6** | Premier orpaillage. Premier grain d'or. | Satisfaction, accroche gameplay | SFX-003, vibration |
| **6-8** | Retour cabane. Trouve le Fragment #1. | Émotion narrative, mystère | SFX-011, MUS-003 |
| **~8** | Sort de la cabane. **1ère apparition Coyote.** | Surprise, émerveillement | VOX-006, MUS-004, cercle dans la poussière |
| **8-14** | Descente vers Dusthaven. Découverte du village. | Exploration, immersion | Transition ambiance AMB-001 → AMB-004 |
| **14-16** | Rencontre Jed + Sheriff. | Tension, méfiance | Dialogues, VOX-003 |
| **~16** | **Premier gros nugget** (session orpaillage). | Satisfaction, dopamine | SFX-004, flash doré |
| **16-22** | Exploration Dead Man's Shallows. Old Pete. Panneaux Rattner. | Intrigue, menace | MUS-006 |
| **~24** | **Jed offre un objet** (quête quartz complétée). | Relation, récompense | UI-002, dialogue |
| **24-30** | Plus d'orpaillage. Exploration poussée. | Flow, rythme de jeu |  |
| **~32** | **Spot secret sous la cascade.** | Émerveillement, découverte | AMB-008, MUS-007, lumière dorée |
| **32-38** | Continuation exploration. Fragment #2. | Progression narrative | SFX-010/011, MUS-003, Coyote réapparaît |
| **~40** | **Inscription Nahak'a.** | Mystère profond | SFX-017 |
| **40-60** | Grind orpaillage, quêtes Jed, montée réputation. | Rythme, progression | Boucle gameplay principale |
| **60-90** | Réputation Jed haute → **Carnet d'Eli.** | Climax émotionnel Acte I | SFX-011, MUS-003, premier nom "Kaya" |
| **90-120** | Préparation Gate. Craft/acquisition kayak. | Transition, anticipation Z2 | — |
| **120+** | **Gate → Z2 (Kayak).** | Excitation, nouveau chapitre | SFX-030/031 |

---

## 9. SYSTÈME DE RÉPUTATION

### Mécanique globale

Chaque PNJ a un **niveau de réputation** indépendant : Basse → Moyenne → Haute.
La réputation monte via : transactions, quêtes complétées, interactions positives, temps passé.

| PNJ | Basse → Moyenne | Moyenne → Haute | Effet |
|-----|-----------------|-----------------|-------|
| **Jed** | 5 ventes d'or OU 1 quête complétée | 15 ventes OU 3 quêtes | Basse: transactionnel. Moyenne: reconnaît batée. Haute: donne le carnet. |
| **Dawson** | Automatique (il vient vers toi) | Progression narrative (Acte II) | Basse: faux ami. Moyenne: pression. Haute: masque tombe. |
| **Gustave** | Montrer la batée d'Eli | Quêtes matériaux + temps | Basse: silence. Moyenne: "Good steel." Haute: fragments + outil unique. |
| **Coyote** | Temps passé en jeu | Suivre ses indices | Basse: fuit. Moyenne: se laisse approcher. Haute: marche avec le joueur. |
| **Kaya** | (Z2+) | (Z2+) | Non présente en Z1. |

### Conditions Gate Acte I

Pour passer de l'Acte I à l'Acte II (Gate kayak), le joueur doit avoir :
1. ✅ Fragment #1 et #2 trouvés
2. ✅ Réputation Jed = Haute (carnet obtenu)
3. ✅ Kayak fabriqué ou trouvé

---

## 10. CRAFT & ÉCONOMIE

### Monnaie

| Unité | Description |
|-------|-------------|
| **Gold grains** | Unité de ressource brute (orpaillage) |
| **Coins** | Monnaie d'échange (grains vendus chez Jed) |

### Taux de conversion

| Or | Valeur en coins |
|----|----------------|
| 1 grain standard | 10 coins |
| 1 gros nugget | 50 coins |
| 1 quartz | 5 coins |

### Craft — Kayak (Gate Z1→Z2)

| Composant | Quantité | Source |
|-----------|----------|--------|
| Bois | 10 | Récolte (arbres Dead Man's Shallows) |
| Corde | 2 | Achat chez Jed (15 coins chacune) |
| Toile | 1 | Trouvable dans un coffre OU achat chez Jed (20 coins) |

**Alternative** : Un kayak pré-fabriqué peut être trouvé caché près de la Gate (A2) si le joueur explore suffisamment. Cela évite le craft obligatoire.

---

## 11. AMBIANCE SONORE PAR ZONE

> Référence complète : `SOUND_INDEX_Z1.md`

### Mapping sons × zones

| Zone | Ambiance base (loop) | Sons additionnels | Musique |
|------|---------------------|--------------------|---------| 
| **Cabane d'Eli** | AMB-005 (intérieur cabane) | — | — |
| **Extérieur cabane / chemin** | AMB-001 (vent désert) | AMB-002 si près de la rivière | — |
| **Whitepine** | AMB-007 (vent froid, neige) | — | — |
| **Rivière / spots orpaillage** | AMB-002 (rivière) | SFX-001 à SFX-007 quand orpaillage | MUS-002 (guitare picking fond) |
| **Cascade** | AMB-003 (cascade) | AMB-008 si sous la cascade | MUS-007 si spot secret |
| **Dusthaven village** | AMB-004 (village) | VOX-001 (forge), VOX-005 (saloon) | MUS-001 (1ère arrivée) |
| **Magasin Jed** | AMB-004 (atténué) | — | — |
| **Saloon Belle** | VOX-005 (ambiance saloon) | — | — |
| **Forge Gustave** | VOX-001 (marteau forge) | VOX-002 (3 coups fin conversation) | — |
| **Dead Man's Shallows** | AMB-001 (vent) + AMB-002 (rivière) | — | — |
| **Nuit (partout)** | AMB-006 (nuit) | — | MUS-005 (guitare lente) |

### Transitions sonores

| De → Vers | Type | Notes |
|-----------|------|-------|
| Cabane → Extérieur | Crossfade 2s | AMB-005 fade out, AMB-001 fade in |
| Extérieur → Village | Crossfade 3s | AMB-001 fade, AMB-004 fade in. VOX-001 (forge) volume monte progressivement. |
| Village → Saloon | Crossfade 1s | AMB-004 atténué, VOX-005 fade in |
| Terre → Rivière | Spatial 3D | AMB-002 volume croît avec la proximité |
| Jour → Nuit | Crossfade 5s | AMB jour fade, AMB-006 fade in |

---

## 12. GATE Z1 → Z2

### Le Kayak

| Champ | Valeur |
|-------|--------|
| **ID Map** | (16) |
| **Coordonnées** | A2 (bord de rivière, zone Whitepine) |
| **Type** | Gate de zone — transition vers Copper Canyon (Z2) |
| **Condition** | Fragment #1 + #2 trouvés + Carnet d'Eli obtenu (Jed haute réputation) + Kayak en inventaire |
| **Mécanique** | Le joueur pose le kayak sur l'eau. ProximityPrompt "Remonter la rivière". Cinématique courte de navigation. |
| **Sons** | SFX-030 (mise à l'eau) + SFX-031 (pagaie) |
| **Direction** | Le joueur remonte le ruisseau vers le nord-ouest → Copper Canyon |

### Signaux que le joueur est prêt

Le jeu guide subtilement le joueur vers la Gate :
1. Coyote commence à apparaître près de la rivière nord
2. Jed mentionne *"J'ai entendu dire qu'il y avait du cuivre dans le canyon au nord"*
3. Le carnet d'Eli contient un croquis de Copper Canyon

---

## 13. CHECKLIST D'IMPLÉMENTATION

### Terrain & Environnement

| # | Tâche | Responsable | Statut | Notes |
|---|-------|-------------|--------|-------|
| T01 | Terrain de base Z1 (désert, rivière, montagne) | Playda/Walid | 🔲 | Matériaux Roblox : Sand, Rock, Snow, Grass, Mud |
| T02 | Rivière avec eau Roblox native | Moncef | ✅ | Refaite le 11/03 |
| T03 | Cascade (B2-C2) | 🔲 | | Terrain creusé + particle effect eau |
| T04 | Spot secret sous cascade (B3) | 🔲 | | Espace caché derrière le rideau d'eau |
| T05 | Cratère Dusthaven (E5-H6) | 🔲 | | Forme circulaire, terrain plat au centre |
| T06 | Zone Whitepine (A1-C2) neige | 🔲 | | Snow terrain material |
| T07 | Végétation éparse (cactus, arbustes) | 🔲 | | Placement sur desert terrain |
| T08 | Cycle jour/nuit | 🔲 | | Lighting Roblox natif |

### Structures

| # | Tâche | Responsable | Statut | Notes |
|---|-------|-------------|--------|-------|
| S01 | Cabane d'Eli (intérieur interactif) | 🔲 | | 4 objets interactifs (batée, tasse, photo, journal) |
| S02 | Magasin de Jed | 🔲 | | Comptoir central, étagères |
| S03 | Belle's Saloon | 🔲 | | Porte battante, tables, bar |
| S04 | Bureau du Sheriff | 🔲 | | Bureau, cellule, documents |
| S05 | Forge de Gustave | 🔲 | | Enclume, foyer, ouverte sur la rue |
| S06 | Pont nord (D2) | 🔲 | | Bois brut, traversable |
| S07 | Pont sud (F7) | 🔲 | | Identique au nord |
| S08 | Leaderboard (F5) | 🔲 | | Panneau bois + UI dynamique |
| S09 | Panneaux "RATTNER CO." | 🔲 | | Au moins 2 visibles en Z1 |

### PNJ

| # | Tâche | Responsable | Statut | Notes |
|---|-------|-------------|--------|-------|
| N01 | Jed Bramwell — modèle + position | 🔲 | | Derrière comptoir, TOUJOURS |
| N02 | Jed — dialogues (3 niveaux rep) | 🔲 | | Voir section 4.1 |
| N03 | Jed — shop UI (vente/achat) | 🔲 | | Inventaire section 3.3 |
| N04 | Sheriff Dawson — modèle + patrouille | 🔲 | | Marche VERS le joueur (unique) |
| N05 | Dawson — dialogues | 🔲 | | Voir section 4.2 |
| N06 | Gustave — modèle + position | 🔲 | | À l'enclume, TOUJOURS |
| N07 | Gustave — animation forge | 🔲 | | Loop marteau + 3 coups finaux |
| N08 | Old Pete — modèle + position | 🔲 | | D3, Dead Man's Shallows |
| N09 | Old Pete — dialogues | 🔲 | | Voir section 4.4 |
| N10 | Coyote — modèle + AI déplacement | 🔲 | | Apparitions scriptées (voir 4.5) |
| N11 | Belle Fontaine — modèle basique | 🔲 | | PNJ secondaire, derrière le bar |

### Gameplay

| # | Tâche | Responsable | Statut | Notes |
|---|-------|-------------|--------|-------|
| G01 | Mécanique orpaillage (batée + mini-game) | 🔲 | | 5 étapes (voir section 5) |
| G02 | Spots d'orpaillage (7+ spots) | 🔲 | | Positions grille section 5 |
| G03 | Système de loot (grains, nuggets, quartz) | 🔲 | | Probabilités section 5 |
| G04 | Système de réputation (par PNJ) | 🔲 | | 3 niveaux (section 9) |
| G05 | Journal de quête | 🔲 | | Se déclenche au Fragment #1 |
| G06 | Inventaire joueur | 🔲 | | Batée, fragments, or, outils, matériaux |
| G07 | Craft kayak | 🔲 | | Recette section 10 |
| G08 | Leaderboard dynamique | 🔲 | | Or total trouvé |
| G09 | ProximityPrompt sur tous les interactifs | 🔲 | | Spots, objets, PNJ |

### Narration

| # | Tâche | Responsable | Statut | Notes |
|---|-------|-------------|--------|-------|
| R01 | Fragment #1 — trigger post-orpaillage | 🔲 | | Cabane, sous la tasse |
| R02 | Fragment #2 — coffre Z1 | 🔲 | | Bord de ruisseau |
| R03 | Inscription Nahak'a — paroi | 🔲 | | D4 ou B4, mousse partielle |
| R04 | Séquence Coyote prologue | 🔲 | | Cercle poussière, guide |
| R05 | Événements scriptés (E01-E20) | 🔲 | | Ordre section 7 |

### Audio

| # | Tâche | Responsable | Statut | Notes |
|---|-------|-------------|--------|-------|
| A01 | Générer les 18 sons P0 (NLML Labs) | 🔲 | | **ATTENTE VALIDATION MONCEF** |
| A02 | Générer les 24 sons P1 | 🔲 | | Après P0 validés |
| A03 | Intégrer ambiances spatiales 3D | 🔲 | | Volume par distance (rivière, forge) |
| A04 | Transitions sonores entre zones | 🔲 | | Crossfade mapping (section 11) |

---

> **FIN DE LA FICHE TECHNIQUE — ZONE 1 DUSTHAVEN**
> Ce document est le référentiel de production pour la démo.
> Toute question → Arken. Tout conflit avec le Lore V2 → le Lore V2 fait autorité.
