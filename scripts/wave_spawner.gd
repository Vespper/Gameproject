class_name WaveSpawner
extends Node
## Lit une liste de WaveData et fait apparaître les ennemis sur le chemin.
## Un seul lancement : les vagues s'enchaînent ensuite seules, avec une pause fixe
## après la dernière apparition de chaque vague (les ennemis restants ne la bloquent pas).

signal wave_started(index: int)
signal all_waves_cleared
signal enemy_spawned(enemy: Enemy)

@export var waves: Array[WaveData] = []
@export var enemy_path: Path2D
@export var enemy_scene: PackedScene
## Secondes entre la dernière apparition d'une vague et le début de la suivante.
@export var pause_between_waves: float = 5.0

## Index de la vague en cours (-1 avant le lancement).
var current_wave: int = -1

var _queue: Array[Dictionary] = []
var _elapsed: float = 0.0
var _alive: int = 0
var _pause_left: float = 0.0
var _finished: bool = false


func _process(delta: float) -> void:
	if current_wave < 0 or _finished:
		return
	if not _queue.is_empty():
		_elapsed += delta
		while not _queue.is_empty() and float(_queue[0]["time"]) <= _elapsed:
			var entry: Dictionary = _queue.pop_front()
			_spawn(entry["enemy"] as EnemyData)
		if _queue.is_empty():
			_pause_left = pause_between_waves
		return
	if has_next_wave():
		_pause_left -= delta
		if _pause_left <= 0.0:
			_begin_wave(current_wave + 1)
	elif _alive == 0:
		_finished = true
		all_waves_cleared.emit()


func has_started() -> bool:
	return current_wave >= 0


func has_next_wave() -> bool:
	return current_wave + 1 < waves.size()


## Secondes avant la prochaine vague, ou -1 si aucune n'est en attente.
func time_until_next_wave() -> float:
	if current_wave < 0 or not _queue.is_empty() or not has_next_wave():
		return -1.0
	return maxf(_pause_left, 0.0)


## Lance la première vague. Les suivantes s'enchaînent seules.
func start() -> void:
	if has_started() or waves.is_empty():
		return
	_begin_wave(0)


func _begin_wave(index: int) -> void:
	current_wave = index
	_queue.clear()
	for group: SpawnGroup in waves[index].groups:
		for i in group.count:
			_queue.append({"time": group.start_delay + i * group.interval, "enemy": group.enemy})
	_queue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["time"]) < float(b["time"]))
	_elapsed = 0.0
	wave_started.emit(index)


func _spawn(enemy_data: EnemyData) -> void:
	var enemy := enemy_scene.instantiate() as Enemy
	enemy.data = enemy_data
	enemy.removed.connect(_on_enemy_removed)
	enemy_path.add_child(enemy)
	_alive += 1
	enemy_spawned.emit(enemy)


func _on_enemy_removed() -> void:
	_alive -= 1
