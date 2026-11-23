extends Node2D
## Prototype gris d'une salle : chemin fixe, base, emplacements de tours, vagues, énergie.
## La salle relie les systèmes entre eux et gère l'état de la partie.

@export var tower_types: Array[TowerData] = []
@export var tower_scene: PackedScene
@export var pickup_scene: PackedScene
@export var start_energy: int = 100
## Distance max entre le clic et un emplacement pour le sélectionner.
@export var slot_pick_radius: float = 28.0

var energy: int = 0
var selected_tower: int = 0

var _slots: Array[Marker2D] = []
var _occupied: Dictionary = {}
var _game_over: bool = false

@onready var _enemy_path: Path2D = $EnemyPath
@onready var _path_line: Line2D = $EnemyPath/PathLine
@onready var _overlay: Node2D = $Overlay
@onready var _base: Base = $Base
@onready var _spawner: WaveSpawner = $WaveSpawner
@onready var _towers: Node2D = $Towers
@onready var _pickups: Node2D = $Pickups
@onready var _projectiles: Node2D = $Projectiles
@onready var _effects: Node2D = $Effects
@onready var _player: Player = $Player
@onready var _hud: Hud = $Hud


func _ready() -> void:
	energy = start_energy
	for child in $BuildSlots.get_children():
		if child is Marker2D:
			_slots.append(child)

	var curve: Curve2D = _enemy_path.curve
	_path_line.points = curve.get_baked_points()
	_base.global_position = _enemy_path.to_global(curve.get_point_position(curve.point_count - 1))
	_player.effects_parent = _effects

	_spawner.enemy_spawned.connect(_on_enemy_spawned)
	_spawner.wave_started.connect(_on_wave_started)
	_spawner.wave_cleared.connect(_on_wave_cleared)
	_spawner.all_waves_cleared.connect(_on_all_waves_cleared)
	_base.health_changed.connect(func(_current: int, _maximum: int) -> void: _refresh_hud())
	_base.destroyed.connect(_on_base_destroyed)
	_hud.start_wave_pressed.connect(_start_wave)
	_overlay.draw.connect(_draw_overlay)

	_hud.show_message("Pose tes tours, puis lance la vague")
	_refresh_hud()


func _process(_delta: float) -> void:
	_hud.set_spell(_player.spell_time_left)
	_overlay.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _game_over:
		return
	for i in tower_types.size():
		if event.is_action_pressed("select_tower_%d" % (i + 1)):
			selected_tower = i
			_refresh_hud()
	if event.is_action_pressed("start_wave"):
		_start_wave()
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_try_build(get_global_mouse_position())


func _start_wave() -> void:
	if _game_over or _spawner.is_wave_running() or not _spawner.has_next_wave():
		return
	_spawner.start_next_wave()


func _try_build(at: Vector2) -> void:
	var slot_index := _slot_at(at)
	if slot_index < 0 or _occupied.has(slot_index) or tower_types.is_empty():
		return
	var tower_data: TowerData = tower_types[selected_tower]
	if energy < tower_data.cost:
		return
	energy -= tower_data.cost
	var tower := tower_scene.instantiate() as Tower
	tower.data = tower_data
	tower.projectile_parent = _projectiles
	_towers.add_child(tower)
	tower.global_position = _slots[slot_index].global_position
	_occupied[slot_index] = tower
	_refresh_hud()


func _slot_at(at: Vector2) -> int:
	for i in _slots.size():
		if _slots[i].global_position.distance_to(at) <= slot_pick_radius:
			return i
	return -1


func _add_energy(amount: int) -> void:
	energy += amount
	_refresh_hud()


func _refresh_hud() -> void:
	var wave_number: int = _spawner.current_wave + 1
	_hud.set_stats(_base.health, _base.max_health, energy, wave_number, _spawner.waves.size())
	_hud.set_towers(tower_types, selected_tower, energy)
	var can_start: bool = not _game_over and not _spawner.is_wave_running() and _spawner.has_next_wave()
	_hud.set_wave_button(can_start, "Lancer la vague %d" % (wave_number + 1))


func _on_enemy_spawned(enemy: Enemy) -> void:
	enemy.died.connect(_on_enemy_died)
	enemy.reached_end.connect(_on_enemy_reached_end)


func _on_enemy_died(enemy: Enemy) -> void:
	var pickup := pickup_scene.instantiate() as EnergyPickup
	pickup.amount = enemy.data.energy_drop
	pickup.collected.connect(_add_energy)
	_pickups.add_child(pickup)
	pickup.global_position = enemy.global_position


func _on_enemy_reached_end(enemy: Enemy) -> void:
	_base.take_damage(enemy.data.base_damage)


func _on_wave_started(index: int) -> void:
	_hud.show_message("")
	_refresh_hud()
	print("Vague %d lancée" % (index + 1))


func _on_wave_cleared(index: int) -> void:
	if _game_over:
		return
	if _spawner.has_next_wave():
		_hud.show_message("Vague %d repoussée !" % (index + 1))
	_refresh_hud()


func _on_all_waves_cleared() -> void:
	if _game_over:
		return
	_end_game("Victoire !  (R pour recommencer)")


func _on_base_destroyed() -> void:
	_end_game("Défaite… la base est tombée  (R pour recommencer)")


func _end_game(message: String) -> void:
	_game_over = true
	_hud.show_message(message)
	_refresh_hud()
	print(message)
	get_tree().paused = true


func _draw_overlay() -> void:
	# Entrée des ennemis
	var start: Vector2 = _enemy_path.to_global(_enemy_path.curve.get_point_position(0))
	_overlay.draw_circle(start + Vector2(24.0, 0.0), 14.0, Color(0.8, 0.2, 0.2, 0.6))

	# Emplacements de tours
	var hovered := _slot_at(get_global_mouse_position())
	for i in _slots.size():
		if _occupied.has(i):
			continue
		var center: Vector2 = _slots[i].global_position
		var rect := Rect2(center - Vector2(20.0, 20.0), Vector2(40.0, 40.0))
		var outline := Color(1.0, 1.0, 1.0, 0.6 if i == hovered else 0.25)
		_overlay.draw_rect(rect, Color(1.0, 1.0, 1.0, 0.05))
		_overlay.draw_rect(rect, outline, false, 2.0)

	# Aperçu de portée de la tour sélectionnée
	if _game_over or hovered < 0 or _occupied.has(hovered) or tower_types.is_empty():
		return
	var tower_data: TowerData = tower_types[selected_tower]
	var ok: bool = energy >= tower_data.cost
	var tint := Color(0.4, 1.0, 0.5) if ok else Color(1.0, 0.35, 0.35)
	var center: Vector2 = _slots[hovered].global_position
	_overlay.draw_circle(center, tower_data.attack_range, Color(tint, 0.08))
	_overlay.draw_arc(center, tower_data.attack_range, 0.0, TAU, 64, Color(tint, 0.6), 2.0)
