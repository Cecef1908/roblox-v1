# Story Quest Chain — Spec Technique

## Architecture

### 2 fichiers
- **Server** : `ServerScriptService/Systems/StoryManager.lua` — logique, validation, progression
- **Client** : integration dans UIManager (quest tracker montre aussi la quete principale)

### Donnees joueur (deja dans PlayerData)
```lua
Tutorial = { Completed = false, Step = 1 }
```

### RemoteEvents (deja crees)
- `StartTutorial` — serveur → client (trigger un step)
- `NotifyPlayer` — serveur → client (message/objectif)

---

## Les 8 Steps du chemin critique

### Step 1 : ARRIVE_CABIN
- **Trigger** : joueur spawn (OnPlayerAdded, si Tutorial.Step == 1)
- **Action** : message "Bienvenue... La cabane de ton grand-pere Eli."
- **Objectif** : "Prends la batee au mur" (la batee est deja donnee automatiquement)
- **Completion** : automatique apres 5 secondes (le joueur a deja la batee)
- **Next** : Step 2

### Step 2 : FIRST_PAN
- **Trigger** : Step 1 complete
- **Action** : objectif "Va au ruisseau et utilise ta batee (E)"
- **UI** : fleche/indicateur vers le spot tutoriel (pin 3, coords 868,566)
- **Completion** : joueur mine un deposit (callback MiningSystem:OnMineGold)
- **Next** : Step 3

### Step 3 : FIND_LETTER
- **Trigger** : premier minage reussi
- **Action** : message "Bien joue ! Retourne a la cabane..."
- **Objectif** : "Retourne a la cabane d'Eli"
- **Completion** : joueur entre dans un rayon de 30 studs de la cabane (868, 566 → 944, 562)
- **Next** : Step 4

### Step 4 : READ_LETTER
- **Trigger** : arrive a la cabane
- **Action** : dialogue Fragment #1 — la lettre d'Eli
  "Mon cher petit-fils... j'ai trouve quelque chose...
   les ombres s'allongent... Ne cherche pas la richesse.
   Cherche la..."
- **Objectif** : "Lis la lettre" (auto apres le dialogue)
- **Completion** : apres lecture du dialogue
- **Next** : Step 5

### Step 5 : COYOTE_APPEARS
- **Trigger** : lettre lue
- **Action** : message "Un coyote t'observe depuis un rocher..."
- **Objectif** : "Suis le Coyote vers la ville"
- **UI** : indicateur direction vers Dusthaven (cratere 484, 485)
- **Completion** : joueur entre dans un rayon de 60 studs du cratere
- **Next** : Step 6

### Step 6 : DISCOVER_DUSTHAVEN
- **Trigger** : arrive au cratere
- **Action** : grand titre "DUSTHAVEN" + message "Le village des chercheurs d'or"
- **Objectif** : "Parle a Marcel le Marchand (E)"
- **Completion** : joueur vend un item (callback EconomyManager:OnSell)
- **Next** : Step 7

### Step 7 : FIRST_TOOL
- **Trigger** : premiere vente
- **Action** : message "Bien ! Ameliore tes outils chez Jacques"
- **Objectif** : "Achete un outil chez Jacques l'Outilleur (E)"
- **Completion** : joueur achete un outil (callback EconomyManager:OnBuyTool)
- **Next** : Step 8

### Step 8 : FREE_ROAM
- **Trigger** : premier achat outil
- **Action** : message "Tu es pret ! Explore, mine, et decouvre les secrets de Dusthaven..."
- **Completion** : Tutorial.Completed = true
- **Objectif** : quetes quotidiennes prennent le relais

---

## Integration Quest Tracker

Le tracker affiche en PREMIER la quete principale (si pas completee) :
```
QUETE PRINCIPALE
> Suis le Coyote vers la ville     [fleche]

QUETES QUOTIDIENNES
L'Or de la Riviere     2/10
Apprenti Forgeron      0/5
Le Commerce d'Abord    0/3
```

## Callbacks necessaires

Le StoryManager ecoute ces events pour detecter la completion :
- `MiningSystem` → OnMineGold (Step 2)
- `EconomyManager` → OnSell (Step 6)
- `EconomyManager` → OnBuyTool (Step 7)
- Proximity check via Heartbeat (Steps 3, 5)

## Ce qu'on NE fait PAS (v1)
- Pas de modele Coyote (juste un message texte)
- Pas de fleche 3D (juste texte dans le tracker)
- Pas de cutscene
- Pas de dialogue complexe (juste des messages texte)
- Fragments 2+ reportes a plus tard
