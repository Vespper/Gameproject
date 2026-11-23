# Direction artistique

**Grim dark mais lisible.** Ce qui rend un jeu lisible, c'est le contraste, pas la gaieté (preuve : *The Binding of Isaac*).

## Règles

- **Deux couches de valeurs** : décor sombre, désaturé, peu contrasté (pierre, os, boue). Tout ce qui sert au jeu (ennemis, projectiles, tours, butin, personnage) est plus clair, plus saturé, avec un contour net.
- **Silhouettes uniques** : chaque ennemi se reconnaît à sa forme seule. Test : le remplir en noir.
- **Une couleur par effet** : poison vert, feu orange, glace bleue, malédiction violette.
- **L'étrange plutôt que le gore** : formes bizarres et lore cryptique (esprit *Vermis*), pas de réalisme.

## Références

Vermis, Queen's Domain (ambiance, rendu rétro granuleux), The Binding of Isaac, Darkest Dungeon, Cult of the Lamb, Hellboy (Mignola), Blasphemous.

## Pistes de ton

Donjon ou ruines vivantes ; tours en totems, statues ou créatures enchaînées plutôt que tourelles. Interface en « faux manuel » pour les descriptions d'objets.

## Technique (pas encore tranché)

- **3D low-poly + filtre rétro, vue isométrique** (recommandé pour l'ambiance) : modèles Blender simples, textures 64 à 256 px, rendu basse résolution + tramage par shader dans Godot.
- **2D vue du dessus** : plus proche du côté « cartoon lisible » d'Isaac, mais chaque animation se dessine.
- Prototype : formes simples (gris), aucun asset final. Le style se teste à part sur un ennemi et une tour.

## Pipeline Blender

Low-poly, export **glTF (.glb)** dans `assets/`. Animations (marche, attaque, mort) sur un squelette partagé entre ennemis de même forme. Le look rétro se règle dans Godot (shader), pas dans Blender. Fichiers lourds (.blend, textures, sons) : prévoir Git LFS avant d'en ajouter.
