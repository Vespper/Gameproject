extends Node2D
## Prototype gris d'une salle : chemin généré, sortie, tours posées librement hors du chemin,
## vagues enchaînées, énergie, portes. La salle relie les systèmes et gère l'état de la salle.
## Les salles sans combat (départ, trésor, boutique) n'ont ni chemin ni vagues ; le trésor et
## la boutique posent leurs articles sur des socles.
## Lancée seule (F6), elle se suffit à elle-même ; dans un run, la scène principale lui donne
## l'état du run (personnage, PV, énergie), sa place sur la carte et ses portes.

## Le personnage passe une porte ouverte. direction : côté de la salle (Vector2i.LEFT…).
signal door_entered(direction: Vector2i)

## Personnage utilisé quand la salle est lancée seule (dans un run, il vient du RunState).
@export var character: CharacterData
@export var tower_scene: PackedScene
@export var pickup_scene: PackedScene
@export var door_scene: PackedScene
@export var pedestal_scene: PackedScene
## Hausse du coût pour chaque tour déjà posée dans la salle (0,35 = +35 % par tour).
## Le compteur repart à zéro dans chaque salle.
@export var tower_cost_increase: float = 0.35

@export_group("Pose des tours")
## Distance minimale entre le centre d'une tour et le milieu du chemin.
@export var min_distance_to_path: float = 44.0
## Distance minimale entre deux tours.
@export var min_distance_between_towers: float = 40.0
## Contour de la salle : sol, zone de déplacement du personnage et zone constructible.
@export var room_rect := Rect2(160.0, 80.0, 960.0, 520.0)

@export_group("Chemin")
## Graine du chemin quand la salle est lancée seule (0 = au hasard).
@export var path_seed: int = 0
## Taille d'une case de la grille du chemin.
@export var path_cell: float = 80.0
@export var path_min_length: float = 1400.0
@export var path_max_length: float = 2000.0

## État du run (donné par la scène principale avant l'ajout à l'arbre). Créé si la salle est seule.
var run_state: RunState
## Place de la salle sur la carte, ou null si la salle est lancée seule.
var room_info: FloorRoom
## Portes : côté (Vector2i) -> texte affiché devant la porte.
var door_labels: Dictionary = {}
## Côté par lequel le personnage arrive (Vector2i.ZERO : position de départ de la scène).
var entry_side: Vector2i = Vector2i.ZERO

var energy: int:
	get:
		return run_state.energy
	set(value):
		run_state.energy = value
## Types de tours possédés (ceux du run).
var tower_types: Array[TowerData]:
	get:
		return run_state.tower_types
## Type de tour en cours de pose, ou -1 si le personnage est en mode tir.
var build_selection: int = -1
## Tours posées dans cette salle (fait monter le coût des suivantes).
var towers_built: int = 0

var _game_over: bool = false
var _cleared: bool = false
var _leaving: bool = false
var _doors: Array[Door] = []
var _pedestals: Array[Pedestal] = []
## Socles touchés à l'image précédente : on n'achète qu'en arrivant dessus.
var _touching: Dictionary = {}

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
@onready var _door_parent: Node2D = $Doors


func _ready() -> void:
	if run_state == null:
		run_state = RunState.create(character)
	_generate_path()
	var curve: Curve2D = _enemy_path.curve
	_path_line.points = curve.get_baked_points()
	_base.global_position = _enemy_path.to_global(curve.get_point_position(curve.point_count - 1))
	_player.effects_parent = _effects
	_player.bounds = room_rect.grow(-16.0)
	$Floor.position = room_rect.position
	$Floor.size = room_rect.size
	_setup_player_health()
	_create_doors()

	_spawner.enemy_spawned.connect(_on_enemy_spawned)
	_spawner.wave_started.connect(_on_wave_started)
	_spawner.all_waves_cleared.connect(_on_all_waves_cleared)
	_player.health_changed.connect(func(_current: int, _maximum: int) -> void: _refresh_hud())
	_player.died.connect(_on_player_died)
	_hud.start_wave_pressed.connect(_start_waves)
	_overlay.draw.connect(_draw_overlay)

	if has_combat():
		_hud.show_message("Pose tes tours (1, 2, 3), puis lance les vagues")
	else:
		_cleared = true
		_set_doors_open(true)
		if room_info.type != FloorRoom.Type.COMBAT:
			# Salle sans combat : ni chemin ni sortie
			_enemy_path.visible = false
			_base.visible = false
		_create_pedestals()
		_hud.show_message(_welcome_message())
		get_tree().create_timer(2.5).timeout.connect(func() -> void:
			if not _leaving:
				_hud.show_message("")
		)
	_refresh_hud()


func _process(_delta: float) -> void:
	_hud.set_spell(_player.spell_time_left)
	_hud.set_next_wave(_spawner.time_until_next_wave(), _spawner.current_wave + 2)
	_overlay.queue_redraw()
	_check_pedestals()
	_check_doors()


func _unhandled_input(event: InputEvent) -> void:
	if _game_over or _cleared:
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


## Vrai si la salle a des vagues à jouer (pas une salle de départ ni une salle déjà nettoyée).
func has_combat() -> bool:
	return room_info == null or room_info.has_combat()


## Vrai une fois les vagues battues (ou d'office pour une salle sans combat).
func is_cleared() -> bool:
	return _cleared


func is_game_over() -> bool:
	return _game_over


func get_doors() -> Array[Door]:
	return _doors


## Pose une tour du type donné. Renvoie vrai si elle a été posée.
func try_build(type_index: int, at: Vector2) -> bool:
	if _cleared or type_index < 0 or type_index >= tower_types.size():
		return false
	var tower_data: TowerData = tower_types[type_index]
	var cost: int = tower_cost(type_index)
	if energy < cost or not can_build_at(at):
		return false
	energy -= cost
	towers_built += 1
	var tower := tower_scene.instantiate() as Tower
	tower.data = run_state.tower_stats(tower_data)
	tower.paid_cost = cost
	tower.projectile_parent = _projectiles
	_towers.add_child(tower)
	tower.global_position = at
	_refresh_hud()
	return true


## Coût actuel d'un type de tour : coût de base, +tower_cost_increase par tour déjà posée ici.
func tower_cost(type_index: int) -> int:
	var base: int = tower_types[type_index].cost
	return roundi(base * (1.0 + tower_cost_increase * towers_built))


## Vrai si l'endroit est hors du chemin, dans la zone constructible et libre.
func can_build_at(at: Vector2) -> bool:
	if not room_rect.grow(-20.0).has_point(at):
		return false
	var local: Vector2 = _enemy_path.to_local(at)
	if local.distance_to(_enemy_path.curve.get_closest_point(local)) < min_distance_to_path:
		return false
	if at.distance_to(_base.global_position) < 60.0:
		return false
	for door in _doors:
		if at.distance_to(door.global_position) < 80.0:
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
	if _game_over or _cleared or _spawner.has_started():
		return
	_spawner.start()


func _add_energy(amount: int) -> void:
	energy += amount
	_refresh_hud()


func _refresh_hud() -> void:
	_hud.set_character(run_state)
	var wave_total: int = _spawner.waves.size() if has_combat() else 0
	_hud.set_stats(_player.health, _player.max_health, energy, _spawner.current_wave + 1, wave_total)
	var costs: Array[int] = []
	for i in tower_types.size():
		costs.append(tower_cost(i))
	_hud.set_towers(tower_types, costs, build_selection, energy)
	_hud.set_wave_button(not _game_over and not _cleared and not _spawner.has_started())


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
	var refund := _dismantle_towers()
	_cleared = true
	_set_build_selection(-1)
	if room_info != null:
		room_info.cleared = true
	_set_doors_open(true)
	var next_step: String = "Passe une porte" if not _doors.is_empty() else "R pour recommencer"
	_hud.show_message("Salle nettoyée !  Tours démontées : +%d énergie\n%s" % [refund, next_step])
	get_tree().create_timer(3.0).timeout.connect(func() -> void:
		if not _game_over and not _leaving:
			_hud.show_message("")
	)
	print("Salle nettoyée, tours démontées : +%d énergie" % refund)
	_refresh_hud()


## Détruit toutes les tours et rend une part de leur coût. Renvoie l'énergie rendue.
func _dismantle_towers() -> int:
	var refund: int = 0
	for node in _towers.get_children():
		var tower := node as Tower
		refund += floori(tower.paid_cost * run_state.stat(&"tower_refund"))
		RingEffect.spawn(_effects, tower.global_position, 30.0, tower.data.color, 0.5)
		tower.queue_free()
	_add_energy(refund)
	print("Tours démontées : +%d énergie" % refund)
	return refund


func _on_player_died() -> void:
	_end_game("Défaite… tu n'as plus de PV  (R pour recommencer un run)")


func _end_game(message: String) -> void:
	_game_over = true
	_hud.show_message(message)
	_refresh_hud()
	print(message)
	get_tree().paused = true


func _generate_path() -> void:
	var rng := RandomNumberGenerator.new()
	if room_info != null:
		rng.seed = room_info.path_seed
	elif path_seed != 0:
		rng.seed = path_seed
	else:
		rng.randomize()
	var points: PackedVector2Array = PathGenerator.generate(
		rng, room_rect, path_cell, path_min_length, path_max_length)
	var curve := Curve2D.new()
	for point in points:
		curve.add_point(_enemy_path.to_local(point))
	_enemy_path.curve = curve


func _setup_player_health() -> void:
	_player.apply_stats(run_state)
	_player.health_changed.connect(func(current: int, _maximum: int) -> void: run_state.health = current)
	if entry_side != Vector2i.ZERO:
		_player.global_position = _door_position(entry_side) - Vector2(entry_side) * 72.0


func _create_doors() -> void:
	for side: Vector2i in door_labels:
		var door := door_scene.instantiate() as Door
		door.direction = side
		door.label = door_labels[side]
		_door_parent.add_child(door)
		door.global_position = _door_position(side)
		_doors.append(door)
	_set_doors_open(false)


## Milieu du mur de ce côté de la salle.
func _door_position(side: Vector2i) -> Vector2:
	var center: Vector2 = room_rect.get_center()
	var half: Vector2 = room_rect.size / 2.0
	return center + Vector2(side) * half


func _set_doors_open(value: bool) -> void:
	for door in _doors:
		door.set_open(value)


func _check_doors() -> void:
	if _leaving or not _cleared or _game_over:
		return
	for door in _doors:
		if door.is_open and door.contains(_player.global_position):
			_leaving = true
			door_entered.emit(door.direction)
			return


func _welcome_message() -> String:
	match room_info.type:
		FloorRoom.Type.START:
			return "Choisis une porte"
		FloorRoom.Type.TREASURE:
			return "Trésor : marche sur l'objet pour le prendre" if _pedestals.size() > 0 else "Trésor (vide)"
		FloorRoom.Type.SHOP:
			return "Boutique : marche sur un article pour l'acheter"
	return "Salle déjà nettoyée"


## Pose les articles pas encore pris de la salle (trésor, boutique), en ligne au centre.
func _create_pedestals() -> void:
	var remaining: Array[RoomOffer] = []
	for offer in room_info.offers:
		if not offer.taken:
			remaining.append(offer)
	var spacing: float = 210.0
	# Au-dessus du milieu : on peut traverser la salle d'une porte latérale à l'autre sans rien acheter
	var center: Vector2 = room_rect.get_center() + Vector2(0.0, -110.0)
	for i in remaining.size():
		var pedestal := pedestal_scene.instantiate() as Pedestal
		pedestal.offer = remaining[i]
		add_child(pedestal)
		pedestal.global_position = center + Vector2((i - (remaining.size() - 1) / 2.0) * spacing, 0.0)
		_pedestals.append(pedestal)


func _check_pedestals() -> void:
	if _game_over:
		return
	for pedestal in _pedestals.duplicate():
		var touching: bool = pedestal.touches(_player.global_position)
		if touching and not _touching.get(pedestal, false):
			_take_offer(pedestal)
		_touching[pedestal] = touching


## Prend l'article du socle si le prix est payable. Renvoie vrai s'il a été pris.
func _take_offer(pedestal: Pedestal) -> bool:
	var offer: RoomOffer = pedestal.offer
	if energy < offer.price:
		_flash_message("Pas assez d'énergie (%d)" % offer.price)
		return false
	match offer.kind:
		RoomOffer.Kind.ITEM:
			run_state.add_item(offer.item)
		RoomOffer.Kind.TOWER:
			if not run_state.add_tower_type(offer.tower):
				_flash_message("Plus d'emplacement de tour libre")
				return false
		RoomOffer.Kind.HEAL:
			if run_state.health >= run_state.max_health:
				_flash_message("PV déjà au maximum")
				return false
			run_state.heal(offer.heal_amount)
	energy -= offer.price
	offer.taken = true
	_pedestals.erase(pedestal)
	_touching.erase(pedestal)
	RingEffect.spawn(_effects, pedestal.global_position, 40.0, offer.color(), 0.4)
	pedestal.queue_free()
	_player.apply_stats(run_state)
	_refresh_hud()
	_flash_message("%s : %s" % [offer.title(), offer.description()])
	print("Article pris : %s (%d énergie)" % [offer.title(), offer.price])
	return true


func _flash_message(text: String) -> void:
	_hud.show_message(text)
	get_tree().create_timer(2.0).timeout.connect(func() -> void:
		if not _game_over and not _leaving and _hud.get_message() == text:
			_hud.show_message("")
	)


func _draw_overlay() -> void:
	# Entrée des ennemis
	if not _enemy_path.visible:
		return
	var curve: Curve2D = _enemy_path.curve
	var start: Vector2 = _enemy_path.to_global(curve.get_point_position(0))
	var inward: Vector2 = start.direction_to(_enemy_path.to_global(curve.get_point_position(1)))
	_overlay.draw_circle(start + inward * 24.0, 14.0, Color(0.8, 0.2, 0.2, 0.6))

	# Aperçu de la tour en cours de pose : vert si possible, rouge sinon
	if _game_over or build_selection < 0:
		return
	var tower_data: TowerData = run_state.tower_stats(tower_types[build_selection])
	var at: Vector2 = get_global_mouse_position()
	var ok: bool = energy >= tower_cost(build_selection) and can_build_at(at)
	var tint := Color(0.4, 1.0, 0.5) if ok else Color(1.0, 0.35, 0.35)
	_overlay.draw_circle(at, tower_data.attack_range, Color(tint, 0.08))
	_overlay.draw_arc(at, tower_data.attack_range, 0.0, TAU, 64, Color(tint, 0.6), 2.0)
	_overlay.draw_rect(Rect2(at - Vector2(18.0, 18.0), Vector2(36.0, 36.0)), Color(tint, 0.5))
