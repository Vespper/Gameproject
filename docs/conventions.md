# Conventions

## GDScript

- Suivre le [guide de style officiel](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) : tabulations, `snake_case` pour variables et fonctions, `PascalCase` pour classes et nœuds, `CONSTANT_CASE` pour constantes.
- **Typage statique partout** : `var speed: float = 120.0`, `func take_damage(amount: int) -> void:`.
- Ordre dans un script : `class_name`, `extends`, doc `##`, signaux, enums, constantes, `@export`, variables, `@onready`, fonctions du moteur (`_ready`, `_process`…), fonctions publiques, fonctions privées (`_prefixe`).
- Signaux au passé : `died`, `wave_finished`, `energy_changed`.
- Pas de chemins de nœuds en dur fragiles : `@onready var sprite: Sprite2D = $Sprite2D` ou `@export` pour les références.
- Identifiants en anglais, commentaires et docs en français.

## Fichiers

- `snake_case` partout : `archer_tower.tscn`, `archer_tower.gd`, `archer_tower.tres`.
- Une scène et son script côte à côte. Les Resources de données dans `data/<type>/`.
- Ne pas committer `.godot/`. Laisser Godot gérer les `.import` et `.uid` (les committer).

## Git

- Une branche et une PR par étape de la feuille de route.
- Messages de commit en français, à l'impératif : « Ajoute la tour de base ».
- Chaque PR dit : ce qui change, comment le tester (F5, quoi regarder), ce qui reste.
- Assets lourds (.blend, .wav, grosses textures) : activer Git LFS avant le premier ajout.
