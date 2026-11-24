class_name StatModifier
extends Resource
## Modifie une stat du personnage (nom d'une variable de CharacterData).
## Stat finale = (base + somme des add) × produit des multiply.

@export var stat: StringName = &"shot_damage"
@export var add: float = 0.0
@export var multiply: float = 1.0
