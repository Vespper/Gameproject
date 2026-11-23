extends Node2D
## Prototype gris d'une salle : chemin fixe, sortie, tours posées librement hors du chemin,
## vagues enchaînées, énergie. La salle relie les systèmes et gère l'état de la partie.

@export var tower_types: Array[TowerData] = []
@export var tower_scene: PackedScene
@export var pickup_scene: PackedScene
@export var start_energy: int = 100

@export_group("Pose des tours")
## Distance minimale entre le centre d'une tour et le milieu du chemin.
@export var min_distance_to_path: float = 44.0
## Distance minimale entre deux tours.
@export var min_distance_between_towers: float = 40.0
## Zone où l'on peut construire (évite les bords et le bandeau du haut).
@export var build_area := Rect2(24.0, 80.0, 1232.0, 616.0)

var energy: int = 0
## Type de tour en cours de pose, ou -1 si le personnage est en mode tir.
var build_selection: int = -1

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
	var curve: Curve2D = _enemy_path.curve
	_path_line.points = curve.get_baked_points()
	_base.global_position = _enemy_path.to_global(curve.get_point_position(curve.point_count - 1))
	_player.effects_parent = _effects

	_spawner.enemy_spawned.connect(_on_enemy_spawned)
	_spawner.wave_started.connect(_on_wave_started)
	_spawner.all_waves_cleared.connect(_on_all_waves_cleared)
	_player.health_changed.connect(func(_current: int, _maximum: int) -> void: _refresh_hud())
	_player.died.connect(_on_player_died)
	_hud.start_wave_pressed.connect(_start_waves)
	_overlay.draw.connect(_draw_overlay)

	_hud.show_message("Pose tes tours (1, 2, 3), puis lance les vagues")
	_refresh_hud()


func _process(_delta: float) -> void:
	_hud.set_spell(_player.spell_time_left)
	_hud.set_next_wave(_spawner.time_until_next_wave(), _spawner.current_wave + 2)
	_overlay.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _game_over:
		return
	for i in tower_types.size():
		if event.is_action_pressed("select_tower_%d" % (i + 1)):
			_set_build_selection(-1 if build_selection == i else i)
	if event.is_action_pressed("cancel_build"):
		_set_build_selection(-1)
	if event.is_action_pressed("start_wave"):
		_start_waves()
	if build_selection >= 0 and event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if try_build(build_selection, get_global_mouse_position()):
				_set_build_selection(-1)
			get_viewport().set_input_as_handled()


## Pose une tour du type donné. Renvoie vrai si elle a été posée.
func try_build(type_index: int, at: Vector2) -> bool:
	if type_index < 0 or type_index >= tower_types.size():
		return false
	var tower_data: TowerData = tower_types[type_index]
	if energy < tower_data.cost or not can_build_at(at):
		return false
	energy -= tower_data.cost
	var tower := tower_scene.instantiate() as Tower
	tower.data = tower_data
	tower.projectile_parent = _projectiles
	_towers.add_child(tower)
	tower.global_position = at
	_refresh_hud()
	return true


## Vrai si l'endroit est hors du chemin, dans la zone constructible et libre.
func can_build_at(at: Vector2) -> bool:
	if not build_area.has_point(at):
		return false
	var local: Vector2 = _enemy_path.to_local(at)
	if local.distance_to(_enemy_path.curve.get_closest_point(local)) < min_distance_to_path:
		return false
	if at.distance_to(_base.global_position) < 60.0:
		return false
	for tower in _towers.get_children():
		if (tower as Node2D).global_position.distance_to(at) < min_distance_between_towers:
			return false
	return true


func _set_build_selection(index: int) -> void:
	build_selection = index
	# Le clic gauche sert à poser la tour : le personnage arrête de tirer
	_player.can_shoot = build_selection < 0
	_refresh_hud()


func _start_waves() -> void:
	if _game_over or _spawner.has_started():
		return
	_spawner.start()


func _add_energy(amount: int) -> void:
	energy += amount
	_refresh_hud()


func _refresh_hud() -> void:
	_hud.set_stats(_player.health, _player.max_health, energy, _spawner.current_wave + 1, _spawner.waves.size())
	_hud.set_towers(tower_types, build_selection, energy)
	_hud.set_wave_button(not _game_over and not _spawner.has_started())


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
	_base.flash()
	_player.take_damage(enemy.data.base_damage, true)


func _on_wave_started(index: int) -> void:
	_hud.show_message("Vague %d" % (index + 1))
	get_tree().create_timer(1.5).timeout.connect(func() -> void:
		if not _game_over:
			_hud.show_message("")
	)
	_refresh_hud()
	print("Vague %d lancée" % (index + 1))


func _on_all_waves_cleared() -> void:
	if _game_over:
		return
	_end_game("Victoire !  (R pour recommencer)")


func _on_player_died() -> void:
	_end_game("Défaite… tu n'as plus de PV  (R pour recommencer)")


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

	# Aperçu de la tour en cours de pose : vert si possible, rouge sinon
	if _game_over or build_selection < 0:
		return
	var tower_data: TowerData = tower_types[build_selection]
	var at: Vector2 = get_global_mouse_position()
	var ok: bool = energy >= tower_data.cost and can_build_at(at)
	var tint := Color(0.4, 1.0, 0.5) if ok else Color(1.0, 0.35, 0.35)
	_overlay.draw_circle(at, tower_data.attack_range, Color(tint, 0.08))
	_overlay.draw_arc(at, tower_data.attack_range, 0.0, TAU, 64, Color(tint, 0.6), 2.0)
	_overlay.draw_rect(Rect2(at - Vector2(18.0, 18.0), Vector2(36.0, 36.0)), Color(tint, 0.5))
