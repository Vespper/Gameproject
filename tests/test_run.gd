extends SceneTree
## Run automatique sur deux salles de combat : départ → porte → combat 1 → porte → combat 2.
## Vérifie que les PV et l'énergie passent d'une salle à l'autre et que les portes
## sont fermées pendant le combat, ouvertes après.
## Lancer : tools/test.sh tests/test_run.gd   (option « -- seed=1234 »)

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const AutoPilot := preload("res://tests/autopilot.gd")
const MAX_SECONDS := 900.0
## Nombre de salles de combat à nettoyer avant de s'arrêter.
const COMBATS_TO_CLEAR := 2

var _main: Node2D
var _room: Node2D
var _pilot: AutoPilot
var _elapsed: float = 0.0
var _cleared: int = 0
var _errors: PackedStringArray = []
## État noté juste avant de passer une porte, comparé à l'arrivée.
var _expected_health: int = -1
var _expected_energy: int = -1
var _visited: Dictionary = {}


func _initialize() -> void:
	_main = MAIN_SCENE.instantiate()
	_main.set("run_seed", 4242)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("seed="):
			_main.set("run_seed", int(arg.trim_prefix("seed=")))
	root.add_child(_main)


func _process(delta: float) -> bool:
	_elapsed += delta
	var room: Node2D = _main.call("current_room")
	if room != _room:
		_on_room_changed(room)
	if room.call("is_game_over") or _elapsed > MAX_SECONDS:
		_report("DÉFAITE" if room.call("is_game_over") else "TEMPS ÉCOULÉ")
		return true

	if not room.call("is_cleared"):
		_check_doors_closed(room)
		_pilot.step(_elapsed)
		return false

	if _room_was_combat and not _counted:
		_counted = true
		_cleared += 1
	if _cleared >= COMBATS_TO_CLEAR:
		_report("VICTOIRE")
		return true
	_walk_to_next_door(room)
	return false


var _room_was_combat: bool = false
var _counted: bool = false


func _on_room_changed(room: Node2D) -> void:
	_room = room
	_counted = false
	_pilot = AutoPilot.new(room)
	_pilot.log_builds = false
	_pilot.release_all()
	_room_was_combat = room.call("has_combat")
	var state: RunState = _main.get("run_state")
	var player: Player = room.get_node("Player")
	_visited[state.current] = true
	print("%6.1f s  salle %s, %d portes, PV %d, énergie %d%s" % [
		_elapsed, state.current, room.call("get_doors").size(), player.health, state.energy,
		"  (combat)" if _room_was_combat else ""
	])
	if _expected_health >= 0:
		if player.health != _expected_health:
			_errors.append("PV non conservés : %d avant la porte, %d après" % [_expected_health, player.health])
		if state.energy != _expected_energy:
			_errors.append("Énergie non conservée : %d avant la porte, %d après" % [_expected_energy, state.energy])
	var doors: Array = room.call("get_doors")
	if doors.size() != state.floor_map.doors_of(state.current).size():
		_errors.append("Salle %s : %d portes affichées pour %d côtés reliés" % [
			state.current, doors.size(), state.floor_map.doors_of(state.current).size()
		])


func _check_doors_closed(room: Node2D) -> void:
	for door: Door in room.call("get_doors"):
		if door.is_open:
			_errors.append("Porte ouverte pendant le combat")
			return


## Va vers une porte qui mène à une salle pas encore visitée (sinon la première).
func _walk_to_next_door(room: Node2D) -> void:
	var state: RunState = _main.get("run_state")
	var doors: Array = room.call("get_doors")
	var target: Door = doors[0]
	for door: Door in doors:
		if not _visited.has(state.current + door.direction):
			target = door
			break
	if not target.is_open:
		_errors.append("Porte fermée après la salle nettoyée")
	var player: Player = room.get_node("Player")
	_expected_health = player.health
	_expected_energy = state.energy
	# Viser un peu au-delà du mur pour entrer dans l'embrasure
	_pilot.walk_to(target.global_position + Vector2(target.direction) * 20.0)


func _report(result: String) -> void:
	_pilot.release_all()
	var state: RunState = _main.get("run_state")
	for e in _errors.slice(0, 10):
		printerr("ERROR: " + e)
	if not _errors.is_empty():
		result = "ÉCHEC (%d problèmes)" % _errors.size()
	print("Résultat : %s après %.0f s — %d combats nettoyés, graine %d, PV %d/%d, énergie %d" % [
		result, _elapsed, _cleared, state.seed_value, state.health, state.max_health, state.energy
	])
