class_name FloorMap
extends RefCounted
## Carte d'un étage, générée façon Isaac (voir docs/design/map.md) :
## on part du centre et on ajoute des salles une par une, seulement sur des cases
## qui n'auraient qu'un seul voisin. Donne des branches et des culs-de-sac.
## Pour l'instant : une salle de départ, tout le reste en combat.

## Haut, droite, bas, gauche.
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const MAX_ATTEMPTS := 2000

var grid_size := Vector2i(9, 8)
var start: Vector2i
## Vector2i -> FloorRoom
var rooms: Dictionary = {}


## Génère un étage de room_count salles (départ compris). Reproductible avec la même graine.
static func generate(rng: RandomNumberGenerator, room_count: int, size: Vector2i) -> FloorMap:
	var count: int = clampi(room_count, 1, size.x * size.y)
	while true:
		var map := FloorMap.new()
		map.grid_size = size
		map.start = Vector2i(size.x / 2, size.y / 2)
		map._add(map.start, FloorRoom.Type.START, rng)
		var attempts: int = 0
		while map.rooms.size() < count and attempts < MAX_ATTEMPTS:
			attempts += 1
			var keys: Array = map.rooms.keys()
			var from: Vector2i = keys[rng.randi_range(0, keys.size() - 1)]
			var cell: Vector2i = from + DIRECTIONS[rng.randi_range(0, 3)]
			if map.can_add(cell):
				map._add(cell, FloorRoom.Type.COMBAT, rng)
		if map.rooms.size() == count:
			return map
	return null


## Vrai si la case est libre, dans la grille, et n'a qu'une seule salle voisine.
func can_add(cell: Vector2i) -> bool:
	if rooms.has(cell) or not Rect2i(Vector2i.ZERO, grid_size).has_point(cell):
		return false
	return neighbor_count(cell) == 1


func neighbor_count(cell: Vector2i) -> int:
	var total: int = 0
	for direction in DIRECTIONS:
		if rooms.has(cell + direction):
			total += 1
	return total


## Côtés de la salle qui donnent sur une autre salle : ce sont ses portes (1 à 4).
func doors_of(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for direction in DIRECTIONS:
		if rooms.has(cell + direction):
			result.append(direction)
	return result


func room_at(cell: Vector2i) -> FloorRoom:
	return rooms.get(cell) as FloorRoom


func _add(cell: Vector2i, type: FloorRoom.Type, rng: RandomNumberGenerator) -> void:
	rooms[cell] = FloorRoom.new(cell, type, rng.randi())
