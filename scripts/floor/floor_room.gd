class_name FloorRoom
extends RefCounted
## Une salle de la carte d'étage : sa case, son type, son état.

enum Type { START, COMBAT }

const TYPE_NAMES := {Type.START: "Départ", Type.COMBAT: "Combat"}

var coord: Vector2i
var type: Type = Type.COMBAT
## Graine du chemin des ennemis : le même chemin si on revient dans la salle.
var path_seed: int = 0
var visited: bool = false
var cleared: bool = false


func _init(at: Vector2i, room_type: Type, seed_value: int) -> void:
	coord = at
	type = room_type
	path_seed = seed_value
	# Une salle sans combat est nettoyée d'office
	cleared = room_type != Type.COMBAT


func has_combat() -> bool:
	return type == Type.COMBAT and not cleared


func display_name() -> String:
	return TYPE_NAMES[type]
