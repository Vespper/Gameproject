class_name FloorRoom
extends RefCounted
## Une salle de la carte d'étage : sa case, son type, son état, ses articles (trésor, boutique).

enum Type { START, COMBAT, TREASURE, SHOP }

const TYPE_NAMES := {
	Type.START: "Départ", Type.COMBAT: "Combat", Type.TREASURE: "Trésor", Type.SHOP: "Boutique",
}
## Lettre sur la mini-carte.
const TYPE_LETTERS := {Type.START: "D", Type.TREASURE: "T", Type.SHOP: "$"}

var coord: Vector2i
var type: Type = Type.COMBAT
## Graine du chemin des ennemis : le même chemin si on revient dans la salle.
var path_seed: int = 0
var visited: bool = false
var cleared: bool = false
## Articles posés dans la salle (trésor : un objet gratuit, boutique : articles payants).
var offers: Array[RoomOffer] = []


func _init(at: Vector2i, room_type: Type, seed_value: int) -> void:
	coord = at
	path_seed = seed_value
	set_type(room_type)


func set_type(room_type: Type) -> void:
	type = room_type
	# Une salle sans combat est nettoyée d'office
	cleared = room_type != Type.COMBAT


func has_combat() -> bool:
	return type == Type.COMBAT and not cleared


func display_name() -> String:
	return TYPE_NAMES[type]


## Texte de la porte qui mène à cette salle.
func door_label() -> String:
	if not visited:
		return display_name()
	if type == Type.COMBAT and cleared:
		return display_name() + " (nettoyée)"
	if type in [Type.TREASURE, Type.SHOP] and offers.all(func(o: RoomOffer) -> bool: return o.taken):
		return display_name() + " (vide)"
	return display_name()
