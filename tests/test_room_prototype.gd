extends SceneTree
## Partie automatique du prototype de salle, sans interface (salle lancée seule, sans portes).
## Lancer : tools/test.sh tests/test_room_prototype.gd
## Options après « -- » : « passive » pour que le personnage ne fasse rien (doit mener à la défaite),
## « seed=1234 » pour fixer le chemin.

const ROOM_SCENE := preload("res://scenes/rooms/room_prototype.tscn")
const AutoPilot := preload("res://tests/autopilot.gd")
const MAX_SECONDS := 600.0

var _room: Node2D
var _pilot: AutoPilot
var _elapsed: float = 0.0
var _passive: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var passive: bool = args.has("passive")
	_room = ROOM_SCENE.instantiate()
	_room.set("path_seed", 1234)
	for arg in args:
		if arg.begins_with("seed="):
			_room.set("path_seed", int(arg.trim_prefix("seed=")))
	root.add_child(_room)
	_passive = passive
	print("Test salle (%s), graine du chemin %d" % [
		"personnage passif" if passive else "joueur automatique", _room.get("path_seed")
	])


func _process(delta: float) -> bool:
	_elapsed += delta
	if _pilot == null:
		# Créé à la première image : la salle a fini son _ready (chemin généré)
		_pilot = AutoPilot.new(_room, _passive)
	if _room.call("is_cleared") or _room.call("is_game_over") or _elapsed > MAX_SECONDS:
		_report()
		return true
	_pilot.step(_elapsed)
	return false


func _report() -> void:
	var player: Player = _room.get_node("Player")
	var spawner: WaveSpawner = _room.get_node("WaveSpawner")
	var result: String = "VICTOIRE" if player.health > 0 else "DÉFAITE"
	if _elapsed > MAX_SECONDS:
		result = "TEMPS ÉCOULÉ"
	print("Résultat : %s après %.0f s — PV %d/%d, vague %d/%d, énergie %d, %d tours" % [
		result, _elapsed, player.health, player.max_health, spawner.current_wave + 1, spawner.waves.size(),
		int(_room.get("energy")), _room.get_node("Towers").get_child_count()
	])
