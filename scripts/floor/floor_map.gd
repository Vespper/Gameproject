class_name FloorMap
extends RefCounted
## Carte d'un étage, générée façon Isaac (voir docs/design/map.md) :
## on part du centre et on ajoute des salles une par une, seulement sur des cases
## qui n'auraient qu'un seul voisin. Donne des branches et des culs-de-sac.
## Les salles spéciales (trésor, boutique) vont dans les culs-de-sac ; le plus éloigné du départ
## reste un combat, c'est la place du futur boss. Le reste : combats.

## Haut, droite, bas, gauche.
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
const MAX_ATTEMPTS := 2000

var grid_size := Vector2i(9, 8)
var start: Vector2i
## Vector2i -> FloorRoom
var rooms: Dictionary = {}


## Génère un étage de room_count salles (départ compris). Reproductible avec la même graine.
## specials : types de salles à placer dans les culs-de-sac (on recommence s'il en manque).
static func generate(
		rng: RandomNumberGenerator, room_count: int, size: Vector2i,
		specials: Array[FloorRoom.Type] = []) -> FloorMap:
	var count: int = clampi(room_count, 1, size.x * size.y)
	for _try in MAX_ATTEMPTS:
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
		if map.rooms.size() == count and map._place_specials(rng, specials):
			return map
	return null


## Culs-de-sac (une seule porte, hors départ), du plus éloigné au plus proche du départ.
func dead_ends() -> Array[Vector2i]:
	var distances: Dictionary = distances_from_start()
	var result: Array[Vector2i] = []
	for cell: Vector2i in rooms:
		if cell != start and neighbor_count(cell) == 1:
			result.append(cell)
	result.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return distances[a] > distances[b])
	return result


## Nombre de salles entre le départ et chaque case (parcours en largeur).
func distances_from_start() -> Dictionary:
	var distances: Dictionary = {start: 0}
	var todo: Array[Vector2i] = [start]
	while not todo.is_empty():
		var cell: Vector2i = todo.pop_front()
		for direction in doors_of(cell):
			if not distances.has(cell + direction):
				distances[cell + direction] = distances[cell] + 1
				todo.append(cell + direction)
	return distances


## Remplit les salles spéciales : un objet gratuit au trésor, des articles payants en boutique.
## Chaque objet du pool sort au plus une fois dans l'étage.
func fill_rooms(rng: RandomNumberGenerator, data: FloorData, owned_towers: Array[TowerData]) -> void:
	var pool: Array[ItemData] = data.item_pool.duplicate()
	for cell: Vector2i in rooms:
		var room: FloorRoom = rooms[cell]
		match room.type:
			FloorRoom.Type.TREASURE:
				var item: ItemData = _draw_item(rng, pool)
				if item != null:
					room.offers.append(RoomOffer.for_item(item, 0))
			FloorRoom.Type.SHOP:
				for i in data.shop_item_count:
					var item: ItemData = _draw_item(rng, pool)
					if item != null:
						room.offers.append(RoomOffer.for_item(item, item.price))
				var towers: Array[TowerData] = []
				for tower in data.shop_tower_pool:
					if not tower in owned_towers:
						towers.append(tower)
				if not towers.is_empty():
					var tower: TowerData = towers[rng.randi_range(0, towers.size() - 1)]
					room.offers.append(RoomOffer.for_tower(tower, tower.shop_price))
				room.offers.append(RoomOffer.for_heal(data.shop_heal_amount, data.shop_heal_price))


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


## Place les salles spéciales dans les culs-de-sac, au hasard, sauf le plus éloigné (futur boss).
## Faux s'il n'y a pas assez de culs-de-sac.
func _place_specials(rng: RandomNumberGenerator, specials: Array[FloorRoom.Type]) -> bool:
	if specials.is_empty():
		return true
	var ends: Array[Vector2i] = dead_ends()
	if ends.size() < specials.size() + 1:
		return false
	var choices: Array[Vector2i] = ends.slice(1)
	# Mélange avec rng (et non shuffle()) pour que la graine reproduise l'étage
	for i in range(choices.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var swap: Vector2i = choices[i]
		choices[i] = choices[j]
		choices[j] = swap
	for i in specials.size():
		room_at(choices[i]).set_type(specials[i])
	return true


static func _draw_item(rng: RandomNumberGenerator, pool: Array[ItemData]) -> ItemData:
	if pool.is_empty():
		return null
	return pool.pop_at(rng.randi_range(0, pool.size() - 1))
