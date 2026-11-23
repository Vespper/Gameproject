extends SceneTree
## Partie automatique du prototype de salle, sans interface.
## Lancer : godot --headless --path . --fixed-fps 60 -s res://tests/test_room_prototype.gd
## Option : ajouter « -- passive » pour que le personnage ne fasse rien (doit mener à la défaite).

const ROOM_SCENE := preload("res://scenes/rooms/room_prototype.tscn")
const MAX_SECONDS := 600.0
## Ordre de construction du « joueur automatique » : [position, type de tour].
const BUILD_ORDER := [
	[Vector2(420, 240), 0], [Vector2(420, 420), 0], [Vector2(530, 320), 1], [Vector2(750, 300), 2],
	[Vector2(530, 460), 0], [Vector2(750, 440), 0], [Vector2(1080, 420), 1], [Vector2(200, 460), 2],
	[Vector2(180, 220), 0], [Vector2(850, 110), 0], [Vector2(1180, 400), 1], [Vector2(860, 620), 0],
]
## Point de repli du personnage quand il n'a rien à ramasser.
const SAFE_SPOT := Vector2(480, 380)

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
	_player.mouse_aim = false
	print("Test salle (%s)" % ("personnage passif" if _passive else "joueur automatique"))


func _process(delta: float) -> bool:
	_elapsed += delta
	if paused or _elapsed > MAX_SECONDS:
		_report()
		return true
	_build()
	_room.call("_start_waves")
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
	var placed: bool = _room.call("try_build", step[1], step[0])
	print("%6.1f s  tour %s %s en %s" % [_elapsed, tower.display_name, "posée" if placed else "REFUSÉE", step[0]])
	_build_step += 1


## Ramasse l'énergie, sinon revient au point de repli ; tire sur l'ennemi le plus avancé.
func _play_player() -> void:
	var destination: Vector2 = SAFE_SPOT
	var pickups: Array[Node] = _room.get_node("Pickups").get_children()
	if not pickups.is_empty():
		destination = (pickups[0] as Node2D).global_position
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)
	var to: Vector2 = destination - _player.global_position
	if to.length() > 12.0:
		if to.x < -6.0: Input.action_press("move_left")
		if to.x > 6.0: Input.action_press("move_right")
		if to.y < -6.0: Input.action_press("move_up")
		if to.y > 6.0: Input.action_press("move_down")

	var target: Enemy = null
	for node in get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy.global_position.distance_to(_player.global_position) > _player.shot_range:
			continue
		if target == null or enemy.progress > target.progress:
			target = enemy
	if target != null:
		_player.aim_position = target.global_position
		Input.action_press("attack")
		if _player.spell_time_left <= 0.0 and target.global_position.distance_to(_player.global_position) < _player.spell_radius:
			Input.action_press("spell")
		else:
			Input.action_release("spell")
	else:
		Input.action_release("attack")


func _report() -> void:
	var spawner: WaveSpawner = _room.get_node("WaveSpawner")
	var result: String = "VICTOIRE" if _player.health > 0 else "DÉFAITE"
	if _elapsed > MAX_SECONDS:
		result = "TEMPS ÉCOULÉ"
	print("Résultat : %s après %.0f s — PV %d/%d, vague %d/%d, énergie %d, %d tours" % [
		result, _elapsed, _player.health, _player.max_health, spawner.current_wave + 1, spawner.waves.size(),
		int(_room.get("energy")), _room.get_node("Towers").get_child_count()
	])
