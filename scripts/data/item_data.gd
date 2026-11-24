class_name ItemData
extends Resource
## Un objet : une liste de modificateurs de stats. Une instance = un fichier .tres dans data/items/.

@export var display_name: String = "Objet"
## Effet en quelques mots, affiché sous l'objet (boutique, trésor).
@export var description: String = ""
## Prix en énergie à la boutique.
@export var price: int = 75
@export var color: Color = Color(0.95, 0.85, 0.4)
@export var modifiers: Array[StatModifier] = []
