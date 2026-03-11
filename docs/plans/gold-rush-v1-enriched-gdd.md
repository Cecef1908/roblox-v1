# GOLD RUSH LEGACY — GDD V1 ENRICHI

> **Version** : 1.0 Enrichi  
> **Plateforme** : Roblox (Luau)  
> **Genre** : Mining Tycoon + Gestion d'établissement  
> **Date** : 11 mars 2026  
> **Auteur original des fondations** : Mehdi  
> **Enrichissements** : Inspirés de Dave the Diver, adaptés au thème Gold Rush  

---

## TABLE DES MATIÈRES

1. [Vision du jeu](#1-vision-du-jeu)
2. [Core Loop](#2-core-loop)
3. [Dual Gameplay Loop — Jour/Nuit](#3-dual-gameplay-loop--journuit)
4. [Progression du joueur](#4-progression-du-joueur)
5. [Zones d'extraction](#5-zones-dextraction)
6. [Arbres de compétences](#6-arbres-de-compétences)
7. [Système de gemmes](#7-système-de-gemmes)
8. [Le Saloon — Gestion d'établissement](#8-le-saloon--gestion-détablissement)
9. [Système de craft](#9-système-de-craft)
10. [PNJ acheteurs](#10-pnj-acheteurs)
11. [PNJ récurrents et quêtes narratives](#11-pnj-récurrents-et-quêtes-narratives)
12. [Boss Encounters](#12-boss-encounters)
13. [Mini-jeux](#13-mini-jeux)
14. [Événements dynamiques](#14-événements-dynamiques)
15. [Progression non-linéaire — Spécialisations](#15-progression-non-linéaire--spécialisations)
16. [Layer social](#16-layer-social)
17. [Monétisation](#17-monétisation)
18. [Résumé des enrichissements](#18-résumé-des-enrichissements)

---

## 1. VISION DU JEU

**Gold Rush Legacy** est un mining tycoon sur Roblox situé dans l'univers de la ruée vers l'or du Far West américain. Le joueur incarne un prospecteur arrivant dans une ville minière en plein essor. Il devra bâtir son empire minier en prospectant, extrayant, traitant et vendant des ressources, tout en gérant son propre saloon pour maximiser ses revenus.

**Pitch enrichi** : Le jour, tu descends dans la mine. La nuit, tu gères ton saloon. Les ressources que tu extrais alimentent ton commerce. Ton commerce finance tes expéditions. Les deux boucles se nourrissent mutuellement.

> *[NOUVEAU - Inspiré DtD]* L'ajout de la boucle saloon transforme le jeu d'un mining tycoon linéaire en une expérience dual-loop où chaque activité renforce l'autre.

---

## 2. CORE LOOP

> ⚠️ **FONDATION MEHDI — INTACTE**

Le core loop fondamental reste inchangé :

```
PROSPECTER → EXTRAIRE → TRAITER → VENDRE → RÉINVESTIR
```

| Étape | Description |
|-------|-------------|
| **Prospecter** | Explorer les zones, détecter les gisements, évaluer la qualité des filons |
| **Extraire** | Miner les ressources avec les outils appropriés au niveau de progression |
| **Traiter** | Raffiner les matériaux bruts pour augmenter leur valeur |
| **Vendre** | Écouler les ressources via les PNJ acheteurs ou le marché joueur |
| **Réinvestir** | Améliorer outils, débloquer zones, upgrader compétences |

### [NOUVEAU - Inspiré DtD] Extension du core loop

Le core loop est **étendu** (pas remplacé) avec une branche optionnelle :

```
PROSPECTER → EXTRAIRE → TRAITER → VENDRE → RÉINVESTIR
                            ↓
                     CRAFTER (optionnel)
                            ↓
                  SERVIR AU SALOON (optionnel)
                            ↓
                    REVENUS BONUS → RÉINVESTIR
```

Le joueur peut toujours suivre le core loop classique. Le saloon et le craft sont des **amplificateurs de revenus**, pas des prérequis.

---

## 3. DUAL GAMEPLAY LOOP — JOUR/NUIT

> *[NOUVEAU - Inspiré DtD]*

### Concept

Le jeu alterne entre deux phases distinctes qui se complètent :

| Phase | Activité | Durée (temps réel) |
|-------|----------|--------------------|
| **JOUR** | Mining — exploration, extraction, traitement | ~8-10 min |
| **NUIT** | Saloon — gestion, service, craft, socialisation | ~5-7 min |

### Cycle jour/nuit

- Le cycle est **visuel** : le ciel change, les lumières s'allument en ville, l'ambiance sonore évolue.
- La transition est **douce** : le joueur reçoit une notification "Le soleil se couche..." 1 minute avant la nuit.
- Le joueur peut **ignorer** le saloon et rester dans la mine 24/7 s'il le souhaite (pas de blocage).
- La nuit, la mine reste accessible mais la visibilité est réduite et certains événements nocturnes se déclenchent (bandits, créatures).

### Lien entre les deux boucles

| Ressource minée | Utilisation au saloon |
|------------------|-----------------------|
| Or raffiné | Paiement des améliorations, décoration |
| Charbon | Combustible pour la cuisine/forge |
| Gemmes rares | Ingrédients de cocktails spéciaux, décor prestige |
| Fer / Cuivre | Craft d'ustensiles, meubles, outils à revendre |
| Pierre | Construction et agrandissement du saloon |

### Faisabilité Roblox

- Le cycle jour/nuit utilise `Lighting.ClockTime` avec interpolation.
- Les deux zones (mine / ville) sont des régions du même monde, pas des téléportations.
- Le passage jour/nuit est synchronisé entre tous les joueurs du serveur.

---

## 4. PROGRESSION DU JOUEUR

> ⚠️ **FONDATION MEHDI — INTACTE**

### 5 Niveaux de progression

| Niveau | Nom | Déblocage |
|--------|-----|-----------|
| 1 | **Amateur** | Outils basiques, zone de départ, pioche en bois |
| 2 | **Chercheur** | Outils intermédiaires, nouvelles zones, détecteur de métaux |
| 3 | **Prospecteur** | Équipement avancé, dynamite, accès aux mines profondes |
| 4 | **Magnat** | Machines automatisées, employés, trading avancé |
| 5 | **Industriel** | Empire complet, technologies ultimes, influence sur le marché |

### [NOUVEAU - Inspiré DtD] Progression parallèle du saloon

Chaque niveau de progression du joueur débloque aussi des paliers pour le saloon :

| Niveau minier | Palier saloon |
|---------------|---------------|
| Amateur | **Baraque** — Stand de boissons basique, 2 places assises |
| Chercheur | **Taverne** — Comptoir, 6 places, menu élargi, 1 employé |
| Prospecteur | **Saloon** — Salle complète, scène de spectacle, 12 places, 3 employés |
| Magnat | **Grand Saloon** — 2 étages, salle VIP, 20 places, 5 employés, jeux |
| Industriel | **Palace** — Établissement légendaire, événements exclusifs, 30+ places |

---

## 5. ZONES D'EXTRACTION

> ⚠️ **FONDATION MEHDI — INTACTE**

### 7 Zones

| # | Zone | Niveau requis | Ressources principales | Difficulté |
|---|------|---------------|------------------------|------------|
| 1 | **Ruisseau du Pionnier** | Amateur | Pépites d'or, sable, cailloux | ★☆☆☆☆ |
| 2 | **Collines Rouges** | Amateur+ | Cuivre, fer, quartz | ★★☆☆☆ |
| 3 | **Mine Abandonnée** | Chercheur | Argent, charbon, améthyste | ★★★☆☆ |
| 4 | **Canyon du Serpent** | Prospecteur | Or pur, rubis, émeraude | ★★★☆☆ |
| 5 | **Cavernes Profondes** | Prospecteur+ | Diamant, saphir, platine | ★★★★☆ |
| 6 | **Abîme Volcanique** | Magnat | Obsidienne, opale de feu, iridium | ★★★★★ |
| 7 | **Cœur de la Montagne** | Industriel | Ressources légendaires, minerai d'étoile | ★★★★★ |

### [NOUVEAU - Inspiré DtD] Gardiens de zone (Boss encounters)

Chaque zone (sauf la première) possède un **gardien** qui bloque l'accès à une section secrète contenant les meilleurs filons. Voir section [Boss Encounters](#12-boss-encounters).

### [NOUVEAU - Inspiré DtD] Événements de zone

Chaque zone a des événements dynamiques spécifiques. Voir section [Événements dynamiques](#14-événements-dynamiques).

---

## 6. ARBRES DE COMPÉTENCES

> ⚠️ **FONDATION MEHDI — INTACTE**

### 6 Arbres

| Arbre | Focus | Exemples de compétences |
|-------|-------|------------------------|
| 1. **Extraction** | Efficacité de minage | Vitesse de pioche +, double drop, auto-mine |
| 2. **Prospection** | Détection des filons | Radar étendu, détection de gemmes, carte des filons |
| 3. **Traitement** | Raffinage des matériaux | Rendement +, raffinage rapide, qualité supérieure |
| 4. **Commerce** | Vente et négociation | Prix +, négociation PNJ, accès marchés premium |
| 5. **Ingénierie** | Machines et automatisation | Convoyeurs, foreuses auto, systèmes de tri |
| 6. **Exploration** | Survie et mobilité | Endurance +, escalade, résistance aux dangers |

### [NOUVEAU - Inspiré DtD] 2 Arbres supplémentaires (optionnels)

> Ces arbres s'ajoutent aux 6 existants et sont liés aux nouvelles mécaniques.

| Arbre | Focus | Exemples de compétences |
|-------|-------|------------------------|
| 7. **Hospitalité** | Gestion du saloon | Service rapide, satisfaction client +, pourboires +, menu élargi |
| 8. **Artisanat** | Craft d'objets et recettes | Recettes rares, craft rapide, qualité craft +, matériaux économisés |

**Points de compétence** : Les mêmes points XP alimentent tous les arbres. Le joueur choisit où investir, créant naturellement des spécialisations.

---

## 7. SYSTÈME DE GEMMES

> ⚠️ **FONDATION MEHDI — INTACTE**

### Types de gemmes

| Gemme | Rareté | Zone principale | Valeur base |
|-------|--------|-----------------|-------------|
| Quartz | Commun | Collines Rouges | 10 |
| Améthyste | Peu commun | Mine Abandonnée | 25 |
| Rubis | Rare | Canyon du Serpent | 75 |
| Émeraude | Rare | Canyon du Serpent | 80 |
| Saphir | Très rare | Cavernes Profondes | 150 |
| Diamant | Très rare | Cavernes Profondes | 200 |
| Opale de feu | Épique | Abîme Volcanique | 500 |
| Minerai d'étoile | Légendaire | Cœur de la Montagne | 1000 |

### Utilisation des gemmes
- Vente directe aux PNJ acheteurs
- Trading entre joueurs
- Sertissage d'outils (bonus stats)
- Quêtes de collection

### [NOUVEAU - Inspiré DtD] Utilisation étendue des gemmes

| Utilisation | Description |
|-------------|-------------|
| **Cocktails de gemmes** | Les gemmes pilées servent d'ingrédients pour des boissons spéciales au saloon (bonus temporaires aux clients) |
| **Bijouterie** | Crafter des bijoux à vendre au saloon ou à porter (cosmétiques + stats) |
| **Offrandes aux gardiens** | Certains boss peuvent être apaisés avec des gemmes spécifiques (chemin alternatif au combat) |
| **Décoration prestige** | Incruster des gemmes dans le mobilier du saloon pour augmenter sa réputation |

---

## 8. LE SALOON — GESTION D'ÉTABLISSEMENT

> *[NOUVEAU - Inspiré DtD]*

### Vue d'ensemble

Le saloon est l'établissement personnel du joueur situé en ville. C'est le pendant nocturne de la mine : un lieu de gestion, de socialisation et de revenus complémentaires.

### Fonctionnement

#### Phase de service (gameplay actif)

Pendant la nuit, le joueur gère son saloon en temps réel :

1. **Accueillir les clients** — Les PNJ arrivent et s'installent.
2. **Prendre les commandes** — Le joueur interagit pour noter la commande.
3. **Préparer/servir** — Mini-jeu de préparation (simple, pas de micro-gestion excessive).
4. **Encaisser** — Le client paie, laisse un pourboire selon la satisfaction.

#### Satisfaction client

| Facteur | Impact |
|---------|--------|
| Temps d'attente | -10% satisfaction par tranche de 30s |
| Qualité du plat/boisson | +5% à +30% selon la recette |
| Ambiance (décor, musique) | +5% à +15% bonus passif |
| Personnel (employés) | Réduit les temps, gère les tables auto |
| Propreté | -20% si non entretenu |

#### Revenus du saloon

```
Revenu = (Prix de base × Multiplicateur qualité) + Pourboire
Pourboire = Prix de base × (Satisfaction% / 100)
```

### Upgrades du saloon

| Catégorie | Exemples |
|-----------|----------|
| **Mobilier** | Tables, chaises, comptoir, lustres → capacité + ambiance |
| **Cuisine** | Four, grill, tonneau, alambic → recettes débloquées |
| **Décor** | Tableaux, trophées de mine, peaux d'animaux → ambiance + |
| **Staff** | Serveur, cuisinier, barman, videur → automatisation |
| **Divertissement** | Piano, scène, table de poker → clients spéciaux + revenus |

### Employés

| Employé | Rôle | Coût/jour | Effet |
|---------|------|-----------|-------|
| Serveur | Prend les commandes | 50 | -30% temps d'attente |
| Cuisinier | Prépare les plats | 80 | Permet les plats complexes |
| Barman | Sert les boissons | 60 | Cocktails spéciaux |
| Musicien | Joue de la musique | 40 | +15% ambiance |
| Videur | Sécurité | 70 | Empêche les bagarres |

### Clients spéciaux (PNJ narratifs)

Certains clients du saloon donnent des quêtes, des indices sur des filons cachés ou des recettes secrètes. Voir section [Quêtes narratives](#11-pnj-récurrents-et-quêtes-narratives).

### Faisabilité Roblox

- Le saloon est une zone buildable dans l'espace du joueur (comme les tycoons classiques Roblox).
- Le service utilise des ProximityPrompts pour l'interaction.
- Les PNJ clients sont gérés côté serveur avec des waypoints prédéfinis.
- Le système de satisfaction est un calcul simple côté serveur.
- Aucune mécanique ne nécessite de physique complexe — tout est basé sur des timers et des interactions UI.

---

## 9. SYSTÈME DE CRAFT

> *[NOUVEAU - Inspiré DtD]*

### Concept

Les ressources extraites de la mine peuvent être transformées en **produits finis** via un système de recettes. Les produits finis ont plus de valeur que les matériaux bruts et sont nécessaires pour le saloon.

### Stations de craft

| Station | Localisation | Fonction |
|---------|-------------|----------|
| **Forge** | Atelier (ville) | Outils, armes, pièces mécaniques |
| **Cuisine** | Saloon | Plats, boissons, cocktails |
| **Atelier bijoutier** | Saloon (upgrade) | Bijoux, gemmes serties |
| **Menuiserie** | Atelier (ville) | Meubles, structures, décorations |
| **Alchimiste** | Déblocable (niveau 3+) | Potions, explosifs spéciaux, teintures |

### Exemples de recettes

#### Forge

| Recette | Ingrédients | Résultat | Valeur |
|---------|-------------|----------|--------|
| Pioche renforcée | 5 Fer + 2 Charbon | Pioche +20% vitesse | Usage personnel |
| Fer à cheval doré | 3 Or + 1 Fer | Décoration / vente | 120 |
| Lanterne de mine | 2 Cuivre + 1 Charbon + 1 Verre | Éclairage mine | Usage / 45 |
| Coffre-fort | 10 Fer + 5 Cuivre + 2 Or | Stockage sécurisé | Usage / 300 |

#### Cuisine (Saloon)

| Recette | Ingrédients | Résultat | Prix au saloon |
|---------|-------------|----------|----------------|
| Ragoût du mineur | 1 Viande + 1 Pomme de terre + 1 Charbon | Plat populaire | 15 |
| Steak grillé | 2 Viande + 1 Sel | Plat premium | 30 |
| Whiskey maison | 3 Blé + 1 Eau + 1 Charbon | Boisson signature | 25 |
| Cocktail Pépite d'Or | 1 Whiskey + 1 Poudre d'or + 1 Miel | Boisson légendaire | 100 |
| Gâteau Gemstone | 2 Farine + 1 Sucre + 1 Améthyste pilée | Dessert rare | 75 |

### Déblocage de recettes

Les recettes se débloquent via :
- **Progression** : nouvelles recettes à chaque niveau
- **Quêtes** : PNJ qui enseignent des recettes secrètes
- **Exploration** : pages de recettes trouvées dans la mine
- **Expérimentation** : combiner des ingrédients au hasard (petite chance de découverte)

### Faisabilité Roblox

- Le craft est un système d'inventaire classique (vérifier les ingrédients, produire le résultat).
- Les recettes sont des tables Luau simples : `{inputs = {...}, output = "item_id", time = 5}`.
- L'animation de craft est un timer + barre de progression.
- Pas de physique ni de simulation complexe.

---

## 10. PNJ ACHETEURS

> ⚠️ **FONDATION MEHDI — INTACTE**

### 4 Types de PNJ acheteurs

| Type | Spécialité | Prix | Particularité |
|------|-----------|------|---------------|
| **Marchand général** | Tout | Prix de base (×1.0) | Achète tout, toujours disponible |
| **Bijoutier** | Gemmes | Prix premium gemmes (×1.5) | N'achète que les gemmes et bijoux |
| **Industriel** | Métaux | Prix premium métaux (×1.3) | Achète en gros, commandes spéciales |
| **Collectionneur** | Raretés | Prix premium raretés (×2.0) | N'apparaît que périodiquement, achète les items légendaires |

### [NOUVEAU - Inspiré DtD] Clients du saloon comme acheteurs indirects

Les clients du saloon constituent un **5ème canal de vente** indirect :
- Les plats et boissons craftés avec les ressources minées génèrent des revenus.
- Un plat utilisant des ingrédients rares vaut beaucoup plus.
- Les clients VIP (débloqués aux niveaux supérieurs) paient jusqu'à ×3 le prix normal.
- Certains clients passent des **commandes spéciales** : "Je veux un cocktail avec du rubis pilé" → bonus ×2 si satisfait.

---

## 11. PNJ RÉCURRENTS ET QUÊTES NARRATIVES

> *[NOUVEAU - Inspiré DtD]*

### Concept

Une galerie de personnages récurrents donne vie à la ville et tisse une **histoire fil rouge**. Chaque PNJ a sa personnalité, ses motivations et une chaîne de quêtes.

### PNJ principaux

| PNJ | Rôle | Personnalité | Chaîne de quêtes |
|-----|------|-------------|------------------|
| **Old Pete** | Vieux prospecteur | Sage, mystérieux, connaît tous les secrets de la mine | Révèle progressivement la légende du "Filon Mère" |
| **Sheriff Morgan** | Loi et ordre | Strict mais juste, protège la ville | Missions anti-bandits, sécurisation des routes |
| **Rosa** | Tenancière rivale | Compétitive mais fair-play | Concurrence amicale de saloons, défis de cuisine |
| **Doc Hartley** | Médecin/Alchimiste | Excentrique, passionné de science | Quêtes de collecte d'ingrédients, recettes spéciales |
| **Dynamite Dan** | Expert en explosifs | Imprudent, enthousiaste | Tutoriel dynamite, missions de démolition |
| **Maria Blackwood** | Journaliste | Curieuse, tenace | Enquêtes sur les mystères de la mine |
| **Le Fantôme du Col** | ??? | Apparition nocturne, énigmatique | Chaîne de quêtes secrètes menant au boss final |

### Fil rouge narratif : La Légende du Filon Mère

> Histoire principale qui se dévoile au fil de la progression :

**Acte 1 — L'arrivée** (Niveaux Amateur-Chercheur)
- Le joueur arrive dans la ville de **Goldhaven**.
- Old Pete lui raconte la légende d'un filon d'or légendaire caché au cœur de la montagne.
- Premiers indices trouvés dans la Mine Abandonnée.

**Acte 2 — La conspiration** (Niveaux Chercheur-Prospecteur)
- Des bandits organisés cherchent aussi le Filon Mère.
- Le Sheriff demande de l'aide pour protéger la ville.
- Maria Blackwood découvre que quelqu'un au sein de la ville trahit les prospecteurs.

**Acte 3 — Les profondeurs** (Niveaux Prospecteur-Magnat)
- Les gardiens des mines profondes gardent les indices.
- Doc Hartley crée des outils spéciaux pour explorer les zones interdites.
- Le Fantôme du Col révèle des passages secrets.

**Acte 4 — Le Filon Mère** (Niveau Industriel)
- Accès au Cœur de la Montagne.
- Confrontation avec le boss final.
- Le Filon Mère est découvert — récompenses légendaires.

### Système de quêtes

| Type de quête | Exemple | Récompense |
|---------------|---------|------------|
| **Principale** | "Trouve le premier indice dans la Mine Abandonnée" | Déblocage histoire, gros XP |
| **Secondaire** | "Livre 10 plats au campement des mineurs" | Or, recettes, réputation |
| **Quotidienne** | "Extrais 50 unités de cuivre aujourd'hui" | XP, petites récompenses |
| **Répétable** | "Sers 20 clients au saloon ce soir" | Or, pourboires bonus |
| **Secrète** | "Trouve les 5 pages du journal de l'ancien prospecteur" | Item légendaire, lore |

### Choix narratifs

À certains moments clés, le joueur fait des choix :
- Aider le Sheriff OU négocier avec les bandits → affecte la réputation et les prix
- Partager une découverte avec Old Pete OU la garder secrète → affecte les quêtes disponibles
- Les choix ne bloquent pas la progression mais changent les récompenses et certaines interactions

### Faisabilité Roblox

- Les quêtes utilisent un système de flags/états stockés dans les DataStores.
- Les dialogues sont des UI séquentiels (pas de voix — texte avec portraits).
- Les choix sont binaires (A ou B) pour simplifier l'arbre.
- Le fil rouge est linéaire avec des branches mineures — pas de ramification complexe.

---

## 12. BOSS ENCOUNTERS

> *[NOUVEAU - Inspiré DtD]*

### Concept

Des **gardiens de mine**, des **chefs bandits** et des **créatures souterraines** protègent les zones les plus riches. Les vaincre débloque des sections secrètes et des récompenses exclusives.

### Liste des boss

| Boss | Zone | Type | Mécanique |
|------|------|------|-----------|
| **Grizzly de la Mine** | Mine Abandonnée | Créature | Esquiver ses charges, frapper quand il est étourdi |
| **El Capitán** | Canyon du Serpent | Chef bandit | Combat avec couvertures, désarmer ses sbires d'abord |
| **La Veuve Noire** | Cavernes Profondes | Araignée géante | Détruire ses toiles, éviter le poison, frapper les points faibles |
| **Le Golem de Lave** | Abîme Volcanique | Créature élémentaire | Utiliser l'eau pour refroidir ses parties, miner ses cristaux |
| **Le Gardien Ancestral** | Cœur de la Montagne | Boss final | Multi-phases, utilise tous les éléments appris |
| **Black Bart** | Événement — Raid de bandits | Chef bandit | Défense de la ville, phases de poursuite |

### Mécanique de combat

Le combat n'est **pas** un système d'armes classique (pas de FPS). Il utilise les **outils du mineur** :

| Action | Outil | Effet |
|--------|-------|-------|
| Frapper | Pioche | Dégâts de base |
| Exploser | Dynamite | Gros dégâts, zone d'effet, cooldown long |
| Étourdir | Marteau | Stun 3 secondes |
| Protéger | Bouclier de mine | Bloque une attaque |
| Piéger | TNT posée | Zone de dégâts au sol |

### Récompenses de boss

| Boss | Récompense |
|------|------------|
| Grizzly de la Mine | Accès à la salle secrète (gemmes rares), recette "Ragoût de Grizzly" |
| El Capitán | Trésor bandit (gros or), chapeau cosmétique "Sombrero del Capitán" |
| La Veuve Noire | Soie de la Veuve (matériau craft unique), accès puits profonds |
| Le Golem de Lave | Cœur de Lave (craft légendaire), pioche volcanique |
| Le Gardien Ancestral | Accès au Filon Mère, titre "Maître de la Montagne" |
| Black Bart | Or volé récupéré, réputation +, déco saloon "Wanted" |

### Modes de boss

- **Solo** : Difficulté adaptée, rewards normaux
- **Guilde** : Boss renforcé, rewards ×2, nécessite coordination

### Faisabilité Roblox

- Les boss sont des NPC avec une state machine simple (idle → aggro → pattern → vulnérable → repeat).
- Les patterns d'attaque utilisent des hitboxes et des timers, pas de physique de ragdoll.
- La difficulté adaptée vérifie le nombre de joueurs et ajuste les HP/dégâts.
- Des exemples de boss fights existent déjà sur Roblox (Dungeon Quest, World // Zero).

---

## 13. MINI-JEUX

> *[NOUVEAU - Inspiré DtD]*

### Concept

Au-delà du minage, des mini-jeux variés enrichissent l'expérience et offrent des récompenses alternatives. Ils sont accessibles en ville ou déclenchés par des événements.

### Liste des mini-jeux

| Mini-jeu | Lieu | Mécanique | Récompense |
|----------|------|-----------|------------|
| **Course de chariots** | Route de la mine | Course d'obstacles sur rail (type obby/runner) | Or, XP, cosmétiques |
| **Poker** | Saloon | Texas Hold'em simplifié contre PNJ ou joueurs | Or (mise/gain), réputation saloon |
| **Duel au soleil** | Rue principale | Quick-draw : appuyer au bon timing | Réputation, titre "As de la gâchette" |
| **Rodéo** | Enclos (événement) | Rester sur le taureau le plus longtemps (QTE) | Or, cosmétique "Cowboy" |
| **Concours de minage** | Mine (événement) | Miner le plus de ressources en temps limité | XP ×2, ressources bonus |
| **Bras de fer** | Saloon | QTE (appuyer au bon moment) | Petites mises, fun social |
| **Tir aux pigeons** | Extérieur ville | Précision (cliquer sur les cibles) | Munitions spéciales, cosmétiques |
| **Panning (orpaillage)** | Ruisseau du Pionnier | Tamiser le sable (mini-jeu de timing) | Pépites bonus, gemmes rares |

### Intégration

- Chaque mini-jeu a un **PNJ hôte** qui le propose.
- Les mini-jeux de saloon (poker, bras de fer) attirent des clients → revenus bonus.
- Certains mini-jeux sont liés à des **quêtes** ("Bats le champion local au bras de fer").
- Les mini-jeux événementiels (rodéo, concours) ne sont disponibles que pendant les événements.

### Faisabilité Roblox

- Course de chariots : système de rail + obby classique.
- Poker : UI + logique serveur, pas de physics.
- Duel : simple timing UI (cercle qui se réduit → cliquer).
- Rodéo : QTE (séquence de touches).
- Tous ces patterns existent déjà en exemples sur Roblox. Aucun ne nécessite de mécanique inédite.

---

## 14. ÉVÉNEMENTS DYNAMIQUES

> *[NOUVEAU - Inspiré DtD]*

### Concept

Des événements aléatoires et programmés perturbent le gameplay normal, créant des moments mémorables et forçant l'adaptation.

### Événements aléatoires (in-game)

| Événement | Zone | Effet | Durée | Récompense |
|-----------|------|-------|-------|------------|
| **Tremblement de terre** | Mine (toute zone) | Éboulements, nouveaux passages révélés, filons cachés exposés | 30 sec | Accès temporaire à des ressources rares |
| **Inondation** | Mines profondes | L'eau monte — évacuer ou trouver un passage surélevé | 2 min | Gemmes aquatiques spéciales |
| **Raid de bandits** | Ville / saloon | Bandits attaquent — défendre le saloon/la mine | 3 min | Or récupéré, réputation + |
| **Filon miracle** | Mine (toute zone) | Un filon exceptionnel apparaît — course entre joueurs | 1 min | Ressources ×5 |
| **Tempête de sable** | Zones extérieures | Visibilité réduite, navigation difficile | 2 min | Objets enfouis révélés après la tempête |
| **Client mystérieux** | Saloon | Un client masqué demande un plat impossible → défi | 5 min | Recette secrète, gros pourboire |
| **Fantôme de la mine** | Mine (nuit) | Apparition fantomatique qui guide vers un trésor | 2 min | Trésor caché |

### Événements saisonniers (programmés)

| Événement | Fréquence | Thème | Contenu |
|-----------|-----------|-------|---------|
| **La Grande Course** | Mensuel | Course de chariots | Tournoi serveur, prix pour le top 3 |
| **Festival du Prospecteur** | Bimensuel | Célébration | Mini-jeux, PNJ spéciaux, items exclusifs |
| **Nuit des Bandits** | Hebdo (vendredi soir) | Raid boss | Black Bart attaque avec son gang |
| **Marché Noir** | Aléatoire | Trading | Marchand spécial avec items exclusifs, prix en gemmes |
| **Saison des Pluies** | Trimestriel | Changement de monde | Rivières gonflées, nouvelles zones d'orpaillage, inondations fréquentes |

### Système de notification

- Les événements sont annoncés 30 secondes avant via une bannière en haut de l'écran.
- Un son distinctif (cloche, sirène, trompette) accompagne l'annonce.
- Les événements sont visibles sur une horloge/calendrier in-game.

### Faisabilité Roblox

- Les événements aléatoires utilisent un timer serveur + RNG.
- Les effets visuels (tremblement, inondation) sont des animations/tweens sur les éléments du décor.
- Les événements saisonniers sont gérés par le calendrier serveur (os.time()).
- Le système de notification utilise des RemoteEvents + UI.

---

## 15. PROGRESSION NON-LINÉAIRE — SPÉCIALISATIONS

> *[NOUVEAU - Inspiré DtD]*

### Concept

Au lieu d'une progression purement linéaire, le joueur peut se **spécialiser** dans un ou plusieurs chemins, chacun offrant des avantages uniques et un style de jeu différent.

### 4 Voies de spécialisation

| Voie | Focus | Style de jeu | Avantage principal |
|------|-------|-------------|-------------------|
| **Le Prospecteur** | Mine pure | Exploration, extraction maximale | +50% rendement minier, accès zones secrètes |
| **Le Commerçant** | Saloon + trading | Gestion, vente, négociation | +50% revenus saloon, prix d'achat réduits |
| **L'Artisan** | Craft + forge | Création d'objets, recettes | Recettes exclusives, craft plus rapide et meilleur |
| **L'Aventurier** | Quêtes + boss | Combat, exploration, histoire | +50% XP quêtes, avantages en combat, lore exclusif |

### Fonctionnement

- À partir du niveau **Chercheur** (niveau 2), le joueur choisit une **voie principale**.
- Au niveau **Prospecteur** (niveau 3), il choisit une **voie secondaire**.
- La voie principale donne des bonus majeurs (+50%).
- La voie secondaire donne des bonus mineurs (+20%).
- Le joueur peut **respec** sa spécialisation une fois par semaine (ou via game pass).

### Synergie des voies

| Combinaison | Synergie |
|-------------|----------|
| Prospecteur + Artisan | Mine des matériaux rares ET les craft en objets de valeur |
| Commerçant + Artisan | Vend des produits craftés au meilleur prix |
| Aventurier + Prospecteur | Accès aux zones secrètes des boss + rendement minier |
| Commerçant + Aventurier | Les quêtes donnent des récompenses commerciales |

### Impact sur le saloon

La spécialisation affecte aussi le saloon :

| Voie principale | Bonus saloon |
|-----------------|-------------|
| Prospecteur | Le saloon attire des mineurs (demande de plats robustes) |
| Commerçant | Le saloon génère +50% de revenus |
| Artisan | Le saloon sert des plats craftés exclusifs |
| Aventurier | Le saloon attire des aventuriers (quêtes bonus) |

### Faisabilité Roblox

- Les spécialisations sont des flags/enums dans le DataStore du joueur.
- Les bonus sont des multiplicateurs appliqués aux calculs existants.
- Le respec est un bouton dans l'UI de progression.
- Pas de code complexe : c'est essentiellement de la data.

---

## 16. LAYER SOCIAL

> ⚠️ **FONDATION MEHDI — INTACTE**

### Guildes

| Feature | Description |
|---------|-------------|
| Création | Nom, blason, description. Fondateur = chef de guilde |
| Membres | Max 20 membres (extensible avec upgrades) |
| Niveaux de guilde | La guilde gagne de l'XP collective → déblocage d'avantages |
| Base de guilde | Espace partagé avec stockage commun et tableaux de bord |
| Missions de guilde | Objectifs collectifs (miner X ressources ensemble) |

### Trading

| Feature | Description |
|---------|-------------|
| Marché joueur | Vente/achat d'items entre joueurs |
| Enchères | Items rares mis aux enchères |
| Trading direct | Échange face-à-face sécurisé |
| Prix dynamiques | L'offre et la demande influencent les prix |

### Leaderboards

| Classement | Métrique |
|------------|----------|
| Top mineurs | Ressources totales extraites |
| Top richesse | Or total accumulé |
| Top guildes | XP de guilde |
| Top explorateurs | Zones découvertes, secrets trouvés |

### [NOUVEAU - Inspiré DtD] Extensions sociales

| Feature | Description |
|---------|-------------|
| **Visiter les saloons** | Les joueurs peuvent visiter le saloon des autres et y consommer → revenus pour le propriétaire |
| **Classement saloon** | Top des saloons par réputation, revenus, nombre de clients |
| **Coopération boss** | Combattre les boss en groupe (guilde ou matchmaking) |
| **Concours de craft** | Événements communautaires : meilleur plat, plus beau saloon |
| **Commandes de guilde** | La guilde passe des commandes groupées à un membre artisan |

---

## 17. MONÉTISATION

> ⚠️ **FONDATION MEHDI — INTACTE**

### Game Passes

| Game Pass | Prix (Robux) | Effet |
|-----------|-------------|-------|
| VIP Mineur | 399 | +25% XP permanent, badge VIP |
| Double Drop | 199 | ×2 drops de ressources |
| Radar Premium | 149 | Détection de filons étendue |
| Sac à dos XXL | 99 | ×3 capacité d'inventaire |
| Accès anticipé zones | 499 | Déblocage des zones 1 niveau avant |

### Cosmétiques

| Type | Exemples |
|------|----------|
| Skins de pioche | Pioche en or, pioche de lave, pioche cristal |
| Tenues | Cowboy classique, prospecteur steampunk, bandit masqué |
| Effets | Particules en minant, traînée de pas, aura |
| Emotes | Danses, saluts, taunts |
| Titres | "Baron de l'Or", "Roi de la Mine", etc. |

### Season Pass

| Tier | Contenu |
|------|---------|
| Gratuit | Récompenses basiques tous les 5 niveaux (XP, petits cosmétiques) |
| Premium (449 Robux) | Récompenses à chaque niveau, cosmétiques exclusifs, boost XP |
| Saison | Durée de 30 jours, nouveau thème à chaque saison |

### [NOUVEAU - Inspiré DtD] Extensions monétisation

| Ajout | Type | Prix | Effet |
|-------|------|------|-------|
| **Pack Saloon Starter** | Game Pass | 299 | Débloque le saloon dès le niveau 1, mobilier de départ |
| **Recettes Premium** | Game Pass | 149 | 5 recettes exclusives pour le saloon |
| **Déco Saloon** | Cosmétique | 49-199 | Thèmes de décoration (Far West luxe, Mexicain, Steampunk) |
| **Respec illimité** | Game Pass | 99 | Changer de spécialisation sans cooldown |
| **Skin de saloon** | Cosmétique | 149 | Apparence extérieure du bâtiment |

> ⚠️ Tous les ajouts de monétisation sont **cosmétiques ou confort**. Aucun pay-to-win.

---

## 18. RÉSUMÉ DES ENRICHISSEMENTS

### Tableau récapitulatif

| # | Enrichissement | Inspiré de (DtD) | Impact gameplay | Complexité dev |
|---|---------------|-------------------|-----------------|----------------|
| 1 | **Dual Loop Jour/Nuit** | Plongée/Restaurant | Transforme le game loop, double le contenu | Moyenne |
| 2 | **Saloon (gestion)** | Restaurant Bancho | Nouvelle boucle de gameplay complète | Haute |
| 3 | **Système de craft** | Recettes culinaires | Valorise les ressources, lien mine→saloon | Moyenne |
| 4 | **Boss encounters** | Boss marins | Moments forts, progression gatée | Moyenne |
| 5 | **Quêtes narratives** | Histoire de DtD | Rétention, engagement, lore | Moyenne |
| 6 | **Mini-jeux** | Mini-jeux variés de DtD | Variété, anti-monotonie | Basse-Moyenne |
| 7 | **Événements dynamiques** | Événements sous-marins | Imprévisibilité, rejouabilité | Basse |
| 8 | **Spécialisations** | Progression non-linéaire | Rejouabilité, identité joueur | Basse |
| 9 | **Arbres de compétences +2** | — | Profondeur progression | Basse |
| 10 | **Extensions sociales** | — | Engagement communautaire | Moyenne |
| 11 | **Extensions monétisation** | — | Revenus supplémentaires | Basse |

### Priorité d'implémentation recommandée

| Phase | Features | Justification |
|-------|----------|---------------|
| **Phase 1 — MVP** | Core loop original + Zones + Progression + Compétences (6 arbres) | Fondations jouables |
| **Phase 2 — Saloon** | Dual loop + Saloon basique + Craft (forge + cuisine) | Différenciation DtD |
| **Phase 3 — Contenu** | Boss (3 premiers) + Quêtes (Acte 1-2) + Mini-jeux (3 premiers) | Profondeur |
| **Phase 4 — Social** | Guildes + Trading + Leaderboards + Visites saloon | Rétention |
| **Phase 5 — Polish** | Événements dynamiques + Spécialisations + Quêtes (Acte 3-4) + Boss restants | Endgame |
| **Phase 6 — Live** | Season Pass + Événements saisonniers + Contenu continu | Monétisation long-terme |

---

## ANNEXE A — GLOSSAIRE

| Terme | Définition |
|-------|------------|
| **Core loop** | Boucle de gameplay principale (Prospecter → Extraire → Traiter → Vendre → Réinvestir) |
| **Dual loop** | Double boucle de gameplay (Mine le jour, Saloon la nuit) |
| **Filon** | Gisement de ressources à extraire |
| **Gardien** | Boss protégeant une section de mine |
| **Goldhaven** | Nom de la ville principale |
| **Filon Mère** | Objectif narratif ultime — le plus grand gisement d'or jamais découvert |
| **Respec** | Réinitialisation des choix de spécialisation |
| **QTE** | Quick Time Event — séquence de touches à réussir dans un timing |

---

## ANNEXE B — RÉFÉRENCES TECHNIQUES ROBLOX

| Système | Service Roblox | Notes |
|---------|---------------|-------|
| Sauvegarde joueur | DataStoreService | Progression, inventaire, quêtes, saloon |
| Cycle jour/nuit | Lighting.ClockTime | Interpolation avec TweenService |
| PNJ | Humanoid + PathfindingService | Waypoints prédéfinis pour les clients |
| Interactions | ProximityPromptService | Minage, service au saloon, dialogue |
| Events dynamiques | ServerScriptService (timers) | RNG + spawn d'éléments |
| UI | StarterGui + RemoteEvents | HUD, menus, dialogues |
| Inventaire | Table Luau + DataStore | Pas de Marketplace — système custom |
| Combat boss | State machine serveur | Hitboxes + patterns + phases |

---

> **Document produit pour le projet Gold Rush Legacy — GDD V1 Enrichi**  
> **Fondations** : Mehdi (intactes)  
> **Enrichissements** : Inspirés de Dave the Diver  
> **Statut** : V1 — Prêt pour review  
