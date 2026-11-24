extends Node2D
## Scène de départ : tient le run. Génère l'étage, charge la salle où se trouve le personnage
## et la remplace quand il passe une porte. Les PV et l'énergie restent dans run_state.

@export var room_scene: PackedScene
@export var floor_data: FloorData
## Personnage joué : stats de base, énergie et tours de départ.
@export var character: CharacterData
## Graine du run (0 = au hasard). La même graine redonne le même étage et les mêmes chemins.
@export var run_seed: int = 0

var run_state: RunState

var _room: Node2D

@onready var _minimap: Minimap = $MinimapLayer/Minimap


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	if run_seed != 0:
		rng.seed = run_seed
	else:
		rng.randomize()
	run_state = RunState.create(character)
	run_state.seed_value = int(rng.seed)
	var specials: Array[FloorRoom.Type] = []
	for i in floor_data.treasure_rooms:
		specials.append(FloorRoom.Type.TREASURE)
	for i in floor_data.shop_rooms:
		specials.append(FloorRoom.Type.SHOP)
	run_state.floor_map = FloorMap.generate(rng, floor_data.room_count, floor_data.grid_size, specials)
	run_state.floor_map.fill_rooms(rng, floor_data, run_state.tower_types)
	print("Graine du run : %d — %d salles" % [run_state.seed_value, run_state.floor_map.rooms.size()])
	enter_room(run_state.floor_map.start, Vector2i.ZERO)


func current_room() -> Node2D:
	return _room


## Remplace la salle actuelle par celle de la case donnée.
## entry_side : côté par lequel le personnage arrive (ZERO pour la salle de départ).
func enter_room(cell: Vector2i, entry_side: Vector2i) -> void:
	if _room != null:
		remove_child(_room)
		_room.queue_free()
	var floor_map: FloorMap = run_state.floor_map
	var info: FloorRoom = floor_map.room_at(cell)
	info.visited = true
	run_state.current = cell

	var room := room_scene.instantiate()
	room.set("run_state", run_state)
	room.set("room_info", info)
	room.set("entry_side", entry_side)
	var labels: Dictionary = {}
	for side in floor_map.doors_of(cell):
		var neighbor: FloorRoom = floor_map.room_at(cell + side)
		labels[side] = neighbor.door_label()
	room.set("door_labels", labels)
	room.connect("door_entered", func(side: Vector2i) -> void:
		enter_room.call_deferred(cell + side, -side)
	)
	_room = room
	add_child(room)
	_minimap.show_map(floor_map, cell)
	print("Salle %s (%s), portes : %d, PV %d, énergie %d" % [
		cell, info.display_name(), labels.size(), run_state.health, run_state.energy
	])
