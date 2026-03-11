# Tutoriel Animation Batée — Gold Rush Legacy

## Pré-requis
- Roblox Studio installé et ouvert
- Un compte Roblox (pour publier les animations)

---

## 1. Créer un espace de travail propre

1. Ouvre **Roblox Studio**
2. Sur l'écran d'accueil, clique sur le template **"Baseplate"** (place vide avec un sol)
3. Tu arrives dans un place vide — parfait pour animer

---

## 2. Insérer un mannequin (Rig)

1. En haut, clique sur l'onglet **"Avatar"**
2. Clique sur **"Rig Builder"** (icône de bonhomme)
3. Un panneau s'ouvre à droite :
   - Rig Type : **R15**
   - Body Shape : **Masculine**
4. Clique sur **"Block Avatar"**
5. Un bonhomme blanc (le rig) apparaît au centre de la map

> **Astuce caméra (Mac) :**
> - Clic droit maintenu + souris = tourner la caméra
> - Scroll = zoom
> - Clic molette maintenu + souris = déplacer la caméra

---

## 3. Ouvrir l'Animation Editor

1. En haut, reste sur l'onglet **"Avatar"**
2. Clique sur **"Animation"** (icône de bonhomme qui bouge, dans la barre d'outils)
3. L'**Animation Editor** s'ouvre en bas de l'écran
4. **Clique sur le rig** (le bonhomme) dans la vue 3D
5. L'Animation Editor te demande de créer une animation → tape le nom **"batee-collect"** → clique **Create**

Tu vois maintenant :
- En bas à gauche : le nom "batee-collect", le numéro de frame (commence à 0), et des boutons play/pause
- En bas au centre : la **timeline** (graduations 0:1, 0:2, 0:3...)
- À gauche : la liste des body parts (vide pour l'instant, elles apparaîtront quand tu bouges un os)

---

## 4. Anatomie du rig R15

Le rig est composé de blocs. Voici les parties importantes :

```
        [Head]              ← la tête
     [UpperTorso]           ← le torse (bloc du haut)
     [LowerTorso]           ← le bassin (bloc du bas du torse)

[LeftUpperArm] [RightUpperArm]   ← les épaules (blocs collés au torse)
[LeftLowerArm] [RightLowerArm]   ← les avant-bras (blocs du milieu)
[LeftHand]     [RightHand]       ← les mains (petits blocs en bas des bras)

[LeftUpperLeg] [RightUpperLeg]   ← les cuisses (blocs collés au bassin)
[LeftLowerLeg] [RightLowerLeg]   ← les mollets (blocs du milieu)
[LeftFoot]     [RightFoot]       ← les pieds (blocs en bas)
```

> **Important :** Pour cette animation, on utilise surtout :
> - **UpperTorso** (pencher le corps)
> - **RightUpperArm** et **LeftUpperArm** (bouger les bras)
> - **RightUpperLeg** et **LeftUpperLeg** (plier les genoux)

---

## 5. Comment poser un keyframe

Pour chaque pose, le processus est toujours le même :

1. **Va à la bonne frame** : clique sur le chiffre de frame en haut à gauche de l'Animation Editor (à côté du "/ 1"), efface-le, tape le numéro voulu, appuie **Entrée**
2. **Clique sur la partie du corps** directement sur le rig dans la vue 3D
3. Appuie sur **R** (pour activer le mode Rotation) — tu vois 3 cercles/anneaux colorés apparaître :
   - 🔴 **Cercle rouge** = rotation avant/arrière (pencher en avant, lever le bras devant/derrière)
   - 🟢 **Cercle vert** = rotation twist (tourner sur soi-même)
   - 🔵 **Cercle bleu** = rotation latérale (pencher à gauche/droite)
4. **Attrape un cercle** avec la souris et **tire** pour tourner la partie du corps
5. Un **losange (◆)** apparaît automatiquement sur la timeline → c'est ton keyframe

> **Annuler :** Si tu fais une erreur, **Cmd+Z** (Mac) ou **Ctrl+Z** (Windows) pour annuler. Si ça marche pas, clic droit sur le losange dans la timeline → Delete.

---

## 6. L'animation : Tamisage à la batée (orpaillage)

L'animation simule un orpailleur qui s'accroupit au bord de la rivière et secoue sa batée de gauche à droite pour séparer l'or du sable.

### FRAME 0 — Position accroupie, bras devant (pose de base)

Le perso s'accroupit et tend les bras devant lui comme s'il tient la batée au-dessus de l'eau.

**A) Pencher le torse :**
1. Vérifie que tu es à la frame **0** (le chiffre affiche 0)
2. Clique sur **UpperTorso** (le bloc du torse, au milieu du corps du rig)
3. Appuie **R**
4. Attrape le **cercle rouge** → tire pour pencher le torse **vers l'avant** d'environ **30 degrés**

**B) Bras droit devant :**
1. Clique sur **RightUpperArm** (le bloc en haut du bras droit, collé à l'épaule droite)
2. Appuie **R**
3. Attrape le **cercle rouge** → tire pour lever le bras **vers l'avant** d'environ **45 degrés**

**C) Bras gauche devant :**
1. Clique sur **LeftUpperArm** (le bloc en haut du bras gauche, collé à l'épaule gauche)
2. Appuie **R**
3. Attrape le **cercle rouge** → tire pour lever le bras **vers l'avant** d'environ **45 degrés**

**D) Plier la jambe droite :**
1. Clique sur **RightUpperLeg** (le bloc en haut de la jambe droite, collé au bassin)
2. Appuie **R**
3. Attrape le **cercle rouge** → tire pour plier **vers l'avant** d'environ **40 degrés**

**E) Plier la jambe gauche :**
1. Clique sur **LeftUpperLeg** (le bloc en haut de la jambe gauche, collé au bassin)
2. Appuie **R**
3. Attrape le **cercle rouge** → tire pour plier **vers l'avant** d'environ **40 degrés**

> **Résultat :** Le personnage est accroupi avec les bras tendus devant lui. Il est prêt à tamiser.

---

### FRAME 3 — Secouer la batée vers la gauche

1. Clique sur le chiffre de frame → tape **3** → **Entrée**
2. **RightUpperArm** → **R** → attrape le **cercle bleu** → tire pour **rapprocher le bras du corps** d'environ **30 degrés**
3. **LeftUpperArm** → **R** → attrape le **cercle bleu** → tire pour **écarter le bras du corps** d'environ **30 degrés**
4. **UpperTorso** → **R** → attrape le **cercle bleu** → penche légèrement **à gauche** d'environ **15 degrés**

> **Résultat :** Le personnage penche la batée vers sa gauche, comme pour faire couler l'eau d'un côté.

---

### FRAME 5 — Secouer la batée vers la droite

1. Clique sur le chiffre de frame → tape **5** → **Entrée**
2. **RightUpperArm** → **R** → attrape le **cercle bleu** → tire pour **écarter le bras du corps** d'environ **30 degrés**
3. **LeftUpperArm** → **R** → attrape le **cercle bleu** → tire pour **rapprocher le bras du corps** d'environ **30 degrés**
4. **UpperTorso** → **R** → attrape le **cercle bleu** → penche légèrement **à droite** d'environ **15 degrés**

> **Résultat :** Le personnage penche la batée vers sa droite. C'est le mouvement inverse de la frame 3.

---

### FRAME 7 — Secouer la batée vers la gauche (encore)

1. Clique sur le chiffre de frame → tape **7** → **Entrée**
2. Fais **exactement la même chose que la frame 3** :
   - **RightUpperArm** → R → cercle bleu → rapprocher du corps ~30°
   - **LeftUpperArm** → R → cercle bleu → écarter du corps ~30°
   - **UpperTorso** → R → cercle bleu → pencher à gauche ~15°

---

### FRAME 9 — Retour au centre

1. Clique sur le chiffre de frame → tape **9** → **Entrée**
2. **RightUpperArm** → **R** → attrape le **cercle bleu** → remets le bras **droit/au centre** (défais le penchement)
3. **LeftUpperArm** → **R** → attrape le **cercle bleu** → remets le bras **droit/au centre**
4. **UpperTorso** → **R** → attrape le **cercle bleu** → remets le torse **droit/au centre**

> **Résultat :** Le personnage revient à la position accroupie de base, prêt pour un nouveau cycle.

---

## 7. Tester l'animation

1. Clique le bouton **Play ▶** dans l'Animation Editor (en bas à gauche)
2. L'animation joue en boucle — tu vois le perso secouer de gauche à droite en position accroupie
3. Si c'est trop rapide ou trop lent, tu peux :
   - **Espacer les frames** pour ralentir (ex: frame 0, 5, 10, 15, 20 au lieu de 0, 3, 5, 7, 9)
   - **Rapprocher les frames** pour accélérer
4. Clique **Stop ⏹** pour arrêter la preview

---

## 8. Ajuster (optionnel)

- **Ajouter des LowerArms** : pour un effet plus naturel, tu peux aussi plier les avant-bras (RightLowerArm, LeftLowerArm) légèrement avec le cercle rouge
- **Ajouter la tête** : faire regarder le personnage vers le bas (Head → R → cercle rouge → penche vers le bas ~20°) à la frame 0
- **Ajouter les LowerLegs** : plier les mollets vers l'arrière pour un accroupissement plus réaliste

---

## 9. Publier l'animation

1. Dans l'Animation Editor, clique les **"..."** (trois points) à côté du nom de l'animation ("batee-collect")
2. Clique **"Publish to Roblox"**
3. Remplis le nom : **"batee-collect"**
4. Clique **Submit**
5. Studio te donne un **ID** (un nombre). Note-le précieusement !
6. L'ID complet à utiliser dans le code sera : `rbxassetid://[LE NOMBRE]`

> **Exemple :** Si Studio te donne l'ID `123456789`, l'ID à mettre dans le code est `rbxassetid://123456789`

---

## 10. Mettre l'ID dans le code

Ouvre le fichier `ReplicatedStorage/Modules/Config/AnimationConfig.lua` et remplace le `rbxassetid://0` de la Batee par ton ID :

```lua
AnimationConfig.Tools = {
    Batee = {
        Idle = "rbxassetid://0",           -- (optionnel, à faire plus tard)
        Equip = "rbxassetid://0",          -- (optionnel, à faire plus tard)
        Mine = "rbxassetid://123456789",   -- ← TON ID ICI
    },
}
```

---

## 11. Animations supplémentaires à créer

Répète le processus (étapes 2 à 9) pour les autres outils :

### Pioche — "pioche-mine" (swing de pioche)
- **Frame 0** : debout, bras le long du corps
- **Frame 3** : les deux bras levés au-dessus de la tête (cercle rouge vers l'arrière ~120°)
- **Frame 6** : les deux bras frappent vers le bas devant (cercle rouge vers l'avant ~60°)
- **Frame 9** : retour position debout

### Batée — "batee-idle" (pose au repos avec batée)
- **Frame 0** : un bras le long du corps, l'autre tient la batée sur la hanche (léger angle)
- C'est une pose statique, juste 1 frame suffit. Cocher "Looped" dans les propriétés.

### Pioche — "pioche-idle" (pose au repos avec pioche)
- **Frame 0** : pioche sur l'épaule (bras droit levé à ~90°, avant-bras plié derrière la tête)
- Pose statique, 1 frame, "Looped" activé.

---

## Raccourcis utiles

| Action | Raccourci |
|--------|-----------|
| Mode Rotation | **R** |
| Mode Déplacement | **W** (ne pas utiliser pour les animations, toujours utiliser R) |
| Annuler | **Cmd+Z** (Mac) / **Ctrl+Z** (Windows) |
| Refaire | **Cmd+Shift+Z** (Mac) / **Ctrl+Y** (Windows) |
| Play animation | **Bouton ▶ dans l'Animation Editor** |
| Supprimer un keyframe | **Clic droit sur le losange ◆ → Delete** |

---

## Résumé des IDs à collecter

Après avoir publié toutes les animations, tu auras ces IDs à mettre dans `AnimationConfig.lua` :

| Animation | Nom dans Studio | ID |
|-----------|----------------|-----|
| Batée — tamisage | batee-collect | `rbxassetid://________` |
| Batée — idle | batee-idle | `rbxassetid://________` |
| Pioche — swing | pioche-mine | `rbxassetid://________` |
| Pioche — idle | pioche-idle | `rbxassetid://________` |
