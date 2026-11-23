extends SceneTree
## Partie automatique du prototype de salle, sans interface.
## Lancer : godot --headless --path . --fixed-fps 60 -s res://tests/test_room_prototype.gd
## Option : ajouter « -- passive » pour que le personnage ne fasse rien (doit mener à la défaite).

const ROOM_SCENE := preload("res://scenes/rooms/room_prototype.tscn")
const MAX_SECONDS := 400.0
## Ordre de construction du « joueur automatique » : [emplacement, type de tour].
const BUILD_ORDER := [[1, 0], [2, 0], [5, 1], [6, 2], [4, 0], [7, 0], [9, 1], [3, 2], [0, 0], [8, 0]]

var _room: Node2D
var _player: Player
var _passive: bool = false
var _elapsed: float = 0.0
var _build_step: int = 0


func _initialize() -> void:
	_passive = OS.get_cmdline_user_args().has("passive")
	_room = ROOM_SCENE.instantiate()
	root.add_child(_room)
	_player = _room.get_node("Player")
	print("Test salle (%s)" % ("personnage passif" if _passive else "joueur automatique"))


func _process(delta: float) -> bool:
	_elapsed += delta
	if paused or _elapsed > MAX_SECONDS:
		_report()
		return true
	_build()
	var spawner: WaveSpawner = _room.get_node("WaveSpawner")
	if not spawner.is_wave_running() and spawner.has_next_wave():
		_room.call("_start_wave")
	if not _passive:
		_play_player()
	return false


func _build() -> void:
	if _build_step >= BUILD_ORDER.size():
		return
	var step: Array = BUILD_ORDER[_build_step]
	var tower_types: Array[TowerData] = _room.get("tower_types")
	var tower: TowerData = tower_types[step[1]]
	if int(_room.get("energy")) < tower.cost:
		return
	_room.set("selected_tower", step[1])
	var slot: Marker2D = _room.get_node("BuildSlots").get_child(step[0])
	_room.call("_try_build", slot.global_position)
	print("%6.1f s  tour %s posée (emplacement %d)" % [_elapsed, tower.display_name, step[0] + 1])
	_build_step += 1


## Va vers l'énergie au sol en priorité, sinon vers l'ennemi le plus avancé, et frappe.
func _play_player() -> void:
	var target_position: Variant = null
	var pickups: Array[Node] = _room.get_node("Pickups").get_children()
	if not pickups.is_empty():
		target_position = (pickups[0] as Node2D).global_position
	else:
		var best: Enemy = null
		for node in get_nodes_in_group("enemies"):
			var enemy := node as Enemy
			if best == null or enemy.progress > best.progress:
				best = enemy
		if best != null:
			target_position = best.global_position
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)
	if target_position != null:
		var to: Vector2 = (target_position as Vector2) - _player.global_position
		if to.length() > 12.0:
			if to.x < -6.0: Input.action_press("move_left")
			if to.x > 6.0: Input.action_press("move_right")
			if to.y < -6.0: Input.action_press("move_up")
			if to.y > 6.0: Input.action_press("move_down")
	Input.action_press("attack")
	if _player.spell_time_left <= 0.0 and not get_nodes_in_group("enemies").is_empty():
		Input.action_press("spell")
	else:
		Input.action_release("spell")


func _report() -> void:
	var base: Base = _room.get_node("Base")
	var spawner: WaveSpawner = _room.get_node("WaveSpawner")
	var result: String = "VICTOIRE" if base.health > 0 and not spawner.has_next_wave() and not spawner.is_wave_running() else "DÉFAITE"
	if _elapsed > MAX_SECONDS:
		result = "TEMPS ÉCOULÉ"
	print("Résultat : %s après %.0f s — base %d/%d PV, vague %d/%d, énergie %d, %d tours" % [
		result, _elapsed, base.health, base.max_health, spawner.current_wave + 1, spawner.waves.size(),
		int(_room.get("energy")), _room.get_node("Towers").get_child_count()
	])
