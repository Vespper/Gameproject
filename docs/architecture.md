# Architecture

Cible : le prototype d'une salle, en gardant la porte ouverte aux objets et aux étages. Ne pas construire plus que l'étape en cours n'en demande.

## Dossiers

```
scenes/main/      scène de démarrage
scenes/rooms/     salles (une scène par gabarit de salle)
scenes/towers/    tours
scenes/enemies/   ennemis
scenes/ui/        HUD, menus
scripts/          classes sans scène (Resources, utilitaires)
scripts/autoload/ singletons globaux
data/             contenu de jeu en .tres (tours, ennemis, vagues, objets)
assets/           sprites, audio, polices, shaders, modèles .glb
```

## Principes

- **Données séparées du code** : chaque tour, ennemi, vague ou objet est une `Resource` (`class_name TowerData extends Resource`, etc.) enregistrée en `.tres` dans `data/`. Équilibrer = éditer un `.tres`.
- **Composition** : une tour ou un ennemi est une scène qui reçoit sa `Resource` (`@export var data: TowerData`). Comportements partagés en nœuds enfants réutilisables (ex. `Health`, `Hitbox`).
- **Signaux vers le haut, appels vers le bas** : un nœud appelle ses enfants directement et prévient son parent par signal. Pour ce qui traverse toute la partie (ennemi tué, vague terminée), passer par l'autoload `Events`.
- **Autoloads** (à créer au besoin, pas avant) :
  - `Events` : bus de signaux globaux.
  - `RunState` : état du run (PV de la base, or, énergie, tours et objets possédés).
- **Groupes** : `enemies`, `towers`, `player` pour les recherches de cibles.
- **Couches physiques** (à fixer dans `project.godot` quand on en a besoin) : 1 monde, 2 personnage, 3 ennemis, 4 tours, 5 projectiles, 6 butin.

## Run et étage (prototype)

```
Main (Node2D)                   tient le run : génère l'étage, remplace la salle quand on passe une porte
├── <salle actuelle>            instance de room_prototype.tscn
└── MinimapLayer/Minimap
```

- `RunState` (`scripts/run_state.gd`) : personnage (`CharacterData`), objets, types de tours possédés, PV, énergie, carte, case actuelle. `stat(nom)` donne une stat finale du personnage = (base + somme des `add`) × produit des `multiply` des objets ; `tower_stats(tour)` donne une copie de la tour avec les bonus d'objets. Le personnage (`Player.apply_stats`) recopie ces stats à l'entrée de chaque salle et après chaque objet. Un objet tenu par `Main` et donné à chaque salle ; il deviendra l'autoload `RunState` quand d'autres scènes (boutique, menus) en auront besoin.
- `FloorMap` / `FloorRoom` (`scripts/floor/`) : génération de l'étage façon Isaac, portes = côtés reliés, trésor et boutique dans les culs-de-sac, puis `fill_rooms` qui pose leurs articles (`RoomOffer`). Réglages dans `data/floors/*.tres` (`FloorData`).
- Données : `data/characters/` (`CharacterData`), `data/items/` (`ItemData` + `StatModifier`), `data/towers/`, `data/enemies/`, `data/waves/`, `data/floors/`.
- Trésor et boutique : la même scène de salle sans chemin ni vagues, avec des socles (`scenes/rooms/pedestal.tscn`) ; on prend un article en marchant dessus.
- `PathGenerator` (`scripts/floor/path_generator.gd`) : chemin des ennemis d'une salle, à partir de la graine de la salle (même chemin si on revient).
- Une salle lancée seule (F6 sur `room_prototype.tscn`) crée son propre `RunState` et n'a pas de portes.

## Salle (prototype)

```
Room (Node2D)
├── Floor / décor
├── EnemyPath (Path2D)          chemin généré au chargement (PathGenerator)
├── Doors                       portes (door.tscn), une par côté relié
├── BuildSlots (Node2D)         emplacements constructibles (Marker2D)
├── Base                        PV, perdue si un ennemi l'atteint
├── WaveSpawner                 lit une liste de WaveData et instancie les ennemis
├── Towers / Enemies / Projectiles (conteneurs)
├── Player (CharacterBody2D)
└── HUD (CanvasLayer)
```

Ennemis : `PathFollow2D` le long de `EnemyPath`. Les futurs volants ne suivront pas ce chemin (voir `docs/wiki/ennemis.md`).

## Pipeline de modificateurs (objets)

Prévu dès que les tours tirent, même avec un seul objet :

1. Une tour calcule ses stats finales = stats de base (`TowerData`) + modificateurs de statistiques (somme puis multiplication).
2. Au tir, elle construit un `ShotContext` (dégâts, nombre de projectiles, effets…) et le passe à chaque modificateur de comportement, dans l'ordre.
3. Un objet = une `Resource` qui porte une liste de modificateurs. L'ajouter ou le retirer ne touche jamais le code des tours.

## Tests

Tests rapides en ligne de commande avec Godot en mode sans interface (voir `docs/setup.md`). Pas de framework de test tant que le prototype n'en a pas besoin.
