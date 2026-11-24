extends SceneTree
## Vérifie les stats du personnage, les objets, et les salles du trésor et de la boutique :
## placement dans l'étage, contenu, achat en marchant sur un socle.
## Lancer : tools/test.sh tests/test_shop_and_treasure.gd

const ROOM_SCENE := preload("res://scenes/rooms/room_prototype.tscn")
const BASE := preload("res://data/characters/base.tres")
const FLOOR := preload("res://data/floors/floor_01.tres")
const SHARP_TIP := preload("res://data/items/sharp_tip.tres")
const HEART := preload("res://data/items/sturdy_heart.tres")
const TRIGGER := preload("res://data/items/quick_trigger.tres")
const QUIVER := preload("res://data/items/quiver.tres")
const ARCHER := preload("res://data/towers/archer.tres")
const SEEDS := 300

var _errors: PackedStringArray = []
var _step: int = 0
var _room: Node2D
var _state: RunState
var _frames: int = 0


func _initialize() -> void:
	_check_stats()
	_check_floors()


func _process(_delta: float) -> bool:
	_frames += 1
	# Une étape par image, pour laisser la salle traiter le contact avec le socle
	match _step:
		0:
			_open_room(FloorRoom.Type.SHOP, 200)
		1:
			_put_player_on(0)
		2:
			_expect_bought(0)
			_state.energy = 0
			_put_player_on(0)
		3:
			# Pas assez d'énergie : rien n'est pris
			if (_room.get("_pedestals") as Array).size() != 3:
				_errors.append("Boutique : article pris sans assez d'énergie")
			_room.queue_free()
			_open_room(FloorRoom.Type.TREASURE, 0)
		4:
			_put_player_on(0)
		5:
			if _state.items.size() != 1 or _state.energy != 0:
				_errors.append("Trésor : objet gratuit non pris (%d objets, énergie %d)" % [_state.items.size(), _state.energy])
			_report()
			return true
	_step += 1
	return false


func _check_stats() -> void:
	var state := RunState.create(BASE)
	if state.tower_types.size() != 1 or state.tower_types[0] != ARCHER:
		_errors.append("Départ : l'Archer doit être le seul type de tour")
	if state.health != 20 or state.max_health != 20 or state.energy != 100:
		_errors.append("Départ : PV %d/%d, énergie %d" % [state.health, state.max_health, state.energy])
	state.add_item(SHARP_TIP)
	if not is_equal_approx(state.stat(&"shot_damage"), 11.0):
		_errors.append("Pointe affûtée : dégâts %.1f au lieu de 11" % state.stat(&"shot_damage"))
	state.health = 10
	state.add_item(HEART)
	if state.max_health != 24 or state.health != 14:
		_errors.append("Cœur robuste : PV %d/%d au lieu de 14/24" % [state.health, state.max_health])
	state.add_item(TRIGGER)
	if not is_equal_approx(state.stat(&"shot_cooldown"), 0.24) or state.stat_trend(&"shot_cooldown") != 1:
		_errors.append("Gâchette rapide : recharge %.2f" % state.stat(&"shot_cooldown"))
	state.add_item(QUIVER)
	if not is_equal_approx(state.tower_stats(ARCHER).fire_rate, ARCHER.fire_rate * 1.2):
		_errors.append("Carquois : cadence des tours non modifiée")
	if not is_equal_approx(ARCHER.fire_rate, 1.5):
		_errors.append("Carquois : la donnée de base de l'Archer a été modifiée")
	if BASE.shot_damage != 8.0:
		_errors.append("Les objets ont modifié les stats de base du personnage")


func _check_floors() -> void:
	var specials: Array[FloorRoom.Type] = [FloorRoom.Type.TREASURE, FloorRoom.Type.SHOP]
	for s in range(1, SEEDS + 1):
		var rng := RandomNumberGenerator.new()
		rng.seed = s
		var map: FloorMap = FloorMap.generate(rng, FLOOR.room_count, FLOOR.grid_size, specials)
		if map == null:
			_errors.append("graine %d : étage impossible à générer" % s)
			continue
		map.fill_rooms(rng, FLOOR, [ARCHER] as Array[TowerData])
		var ends: Array[Vector2i] = map.dead_ends()
		var counts: Dictionary = {}
		var seen_items: Dictionary = {}
		for cell: Vector2i in map.rooms:
			var room: FloorRoom = map.room_at(cell)
			counts[room.type] = counts.get(room.type, 0) + 1
			if room.type in [FloorRoom.Type.TREASURE, FloorRoom.Type.SHOP]:
				if not cell in ends or cell == ends[0]:
					_errors.append("graine %d : %s hors d'un cul-de-sac (ou à la place du boss)" % [s, room.display_name()])
			for offer in room.offers:
				if offer.kind == RoomOffer.Kind.ITEM:
					if seen_items.has(offer.item):
						_errors.append("graine %d : objet %s en double" % [s, offer.item.display_name])
					seen_items[offer.item] = true
				if offer.kind == RoomOffer.Kind.TOWER and offer.tower == ARCHER:
					_errors.append("graine %d : la boutique vend l'Archer déjà possédé" % s)
			if room.type == FloorRoom.Type.TREASURE and (room.offers.size() != 1 or room.offers[0].price != 0):
				_errors.append("graine %d : trésor sans objet gratuit" % s)
			if room.type == FloorRoom.Type.SHOP and room.offers.size() != FLOOR.shop_item_count + 2:
				_errors.append("graine %d : boutique avec %d articles" % [s, room.offers.size()])
		if counts.get(FloorRoom.Type.TREASURE, 0) != 1 or counts.get(FloorRoom.Type.SHOP, 0) != 1:
			_errors.append("graine %d : il faut 1 trésor et 1 boutique" % s)
		if map.rooms.size() != FLOOR.room_count:
			_errors.append("graine %d : %d salles" % [s, map.rooms.size()])


func _open_room(type: FloorRoom.Type, energy: int) -> void:
	_state = RunState.create(BASE)
	_state.energy = energy
	var info := FloorRoom.new(Vector2i.ZERO, type, 1)
	if type == FloorRoom.Type.SHOP:
		info.offers.append(RoomOffer.for_item(SHARP_TIP, SHARP_TIP.price))
		info.offers.append(RoomOffer.for_item(HEART, HEART.price))
		info.offers.append(RoomOffer.for_heal(5, 35))
		info.offers.append(RoomOffer.for_item(TRIGGER, TRIGGER.price))
	else:
		info.offers.append(RoomOffer.for_item(SHARP_TIP, 0))
	_room = ROOM_SCENE.instantiate()
	_room.set("run_state", _state)
	_room.set("room_info", info)
	root.add_child(_room)


func _put_player_on(index: int) -> void:
	var pedestals: Array = _room.get("_pedestals")
	var player: Player = _room.get_node("Player")
	player.global_position = (pedestals[index] as Node2D).global_position


func _expect_bought(index: int) -> void:
	var player: Player = _room.get_node("Player")
	if _state.items.size() != 1 or _state.items[0] != SHARP_TIP or _state.energy != 200 - SHARP_TIP.price:
		_errors.append("Boutique : achat raté (%d objets, énergie %d)" % [_state.items.size(), _state.energy])
	if not is_equal_approx(player.shot_damage, 11.0):
		_errors.append("Boutique : le personnage n'a pas reçu le bonus (%.1f)" % player.shot_damage)
	if (_room.get("_pedestals") as Array).size() != 3:
		_errors.append("Boutique : le socle acheté est resté")


func _report() -> void:
	for e in _errors.slice(0, 10):
		printerr("ERROR: " + e)
	if _errors.is_empty():
		print("Résultat : OK — stats, objets, %d étages avec trésor et boutique, achat et trésor" % SEEDS)
	else:
		print("Résultat : ÉCHEC — %d problèmes" % _errors.size())
