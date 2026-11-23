class_name WaveSpawner
extends Node
## Lit une liste de WaveData et fait apparaître les ennemis sur le chemin.

signal wave_started(index: int)
signal wave_cleared(index: int)
signal all_waves_cleared
signal enemy_spawned(enemy: Enemy)

@export var waves: Array[WaveData] = []
@export var enemy_path: Path2D
@export var enemy_scene: PackedScene

## Index de la vague en cours ou terminée (-1 avant la première).
var current_wave: int = -1

var _queue: Array[Dictionary] = []
var _elapsed: float = 0.0
var _alive: int = 0
var _running: bool = false


func _process(delta: float) -> void:
	if not _running:
		return
	_elapsed += delta
	while not _queue.is_empty() and float(_queue[0]["time"]) <= _elapsed:
		var entry: Dictionary = _queue.pop_front()
		_spawn(entry["enemy"] as EnemyData)
	_check_cleared()


func is_wave_running() -> bool:
	return _running


func has_next_wave() -> bool:
	return current_wave + 1 < waves.size()


func start_next_wave() -> void:
	if _running or not has_next_wave():
		return
	current_wave += 1
	_queue.clear()
	for group: SpawnGroup in waves[current_wave].groups:
		for i in group.count:
			_queue.append({"time": group.start_delay + i * group.interval, "enemy": group.enemy})
	_queue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["time"]) < float(b["time"]))
	_elapsed = 0.0
	_running = true
	wave_started.emit(current_wave)


func _spawn(enemy_data: EnemyData) -> void:
	var enemy := enemy_scene.instantiate() as Enemy
	enemy.data = enemy_data
	enemy.removed.connect(_on_enemy_removed)
	enemy_path.add_child(enemy)
	_alive += 1
	enemy_spawned.emit(enemy)


func _on_enemy_removed() -> void:
	_alive -= 1


func _check_cleared() -> void:
	if not _queue.is_empty() or _alive > 0:
		return
	_running = false
	wave_cleared.emit(current_wave)
	if not has_next_wave():
		all_waves_cleared.emit()
