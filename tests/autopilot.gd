extends RefCounted
## « Joueur automatique » partagé par les tests : pose des tours aux meilleurs endroits
## autour du chemin (généré au hasard), ramasse l'énergie et tire sur l'ennemi le plus avancé.

## Ordre des types de tours à poser (index dans tower_types).
const BUILD_TYPES := [0, 0, 1, 2, 0, 0, 1, 2, 0, 0, 1, 0]

var room: Node2D
var player: Player
var passive: bool = false
var log_builds: bool = true

var _build_step: int = 0
var _candidates: Array[Vector2] = []
var _safe_spot: Vector2


func _init(target_room: Node2D, is_passive: bool = false) -> void:
	room = target_room
	passive = is_passive
	player = room.get_node("Player")
	player.mouse_aim = false
	_rank_candidates()


## À appeler à chaque image tant que la salle est en combat.
func step(elapsed: float) -> void:
	_build(elapsed)
	room.call("_start_waves")
	if not passive:
		_play_player()


## Lâche toutes les touches simulées.
func release_all() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "attack", "spell"]:
		Input.action_release(action)


## Déplace le personnage vers un point (touches de direction simulées). Vrai si arrivé.
func walk_to(destination: Vector2) -> bool:
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)
	var to: Vector2 = destination - player.global_position
	if to.length() <= 12.0:
		return true
	if to.x < -6.0: Input.action_press("move_left")
	if to.x > 6.0: Input.action_press("move_right")
	if to.y < -6.0: Input.action_press("move_up")
	if to.y > 6.0: Input.action_press("move_down")
	return false


## Classe les endroits constructibles par longueur de chemin couverte par une tour.
func _rank_candidates() -> void:
	var path: Path2D = room.get_node("EnemyPath")
	var baked: PackedVector2Array = path.curve.get_baked_points()
	var rect: Rect2 = room.get("room_rect")
	var scored: Array = []
	var best_spot_score: float = -1.0
	for x in range(int(rect.position.x) + 40, int(rect.end.x) - 30, 30):
		for y in range(int(rect.position.y) + 40, int(rect.end.y) - 30, 30):
			var at := Vector2(x, y)
			if not room.call("can_build_at", at):
				continue
			var covered: int = 0
			for p in baked:
				if path.to_global(p).distance_to(at) < 160.0:
					covered += 1
			scored.append([covered, at])
			if covered > best_spot_score:
				best_spot_score = covered
				_safe_spot = at
	scored.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
	for entry in scored:
		_candidates.append(entry[1])


func _build(elapsed: float) -> void:
	if _build_step >= BUILD_TYPES.size():
		return
	var type_index: int = BUILD_TYPES[_build_step]
	var tower_types: Array[TowerData] = room.get("tower_types")
	var tower: TowerData = tower_types[type_index]
	if int(room.get("energy")) < tower.cost:
		return
	for at in _candidates:
		if room.call("try_build", type_index, at):
			if log_builds:
				print("%6.1f s  tour %s posée en %s" % [elapsed, tower.display_name, at])
			break
	_build_step += 1


func _play_player() -> void:
	var destination: Vector2 = _safe_spot
	var pickups: Array[Node] = room.get_node("Pickups").get_children()
	if not pickups.is_empty():
		destination = (pickups[0] as Node2D).global_position
	walk_to(destination)

	var target: Enemy = null
	for node in room.get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy.global_position.distance_to(player.global_position) > player.shot_range:
			continue
		if target == null or enemy.progress > target.progress:
			target = enemy
	if target != null:
		player.aim_position = target.global_position
		Input.action_press("attack")
		if player.spell_time_left <= 0.0 and target.global_position.distance_to(player.global_position) < player.spell_radius:
			Input.action_press("spell")
		else:
			Input.action_release("spell")
	else:
		Input.action_release("attack")
