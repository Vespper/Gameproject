class_name Player
extends CharacterBody2D
## Personnage joué pendant les vagues : déplacement, tir à distance vers la souris, sort à recharge.
## Ses PV sont ceux du run : il en perd au contact des ennemis et quand un ennemi atteint la sortie.

signal health_changed(current: int, maximum: int)
signal died

@export var shot_scene: PackedScene

# Stats : copiées depuis le RunState par apply_stats() (base du personnage + objets).
# Les valeurs ci-dessous ne servent que si le personnage est utilisé sans run.
var speed: float = 240.0
var max_health: int = 20
var contact_invulnerability: float = 1.0
var pickup_radius: float = 90.0
var shot_damage: float = 8.0
var shot_cooldown: float = 0.3
var shot_speed: float = 750.0
var shot_range: float = 360.0
var spell_damage: float = 20.0
var spell_radius: float = 130.0
var spell_slow_factor: float = 0.4
var spell_slow_duration: float = 2.5
var spell_cooldown: float = 8.0

## Nœud qui reçoit les tirs et effets visuels (défini par la salle).
var effects_parent: Node
## Faux quand la salle utilise le clic gauche pour autre chose (pose d'une tour).
var can_shoot: bool = true
## Point visé. Suit la souris si mouse_aim est vrai.
var aim_position: Vector2 = Vector2.ZERO
var mouse_aim: bool = true
## Zone où le personnage peut se déplacer (définie par la salle).
var bounds := Rect2(16.0, 16.0, 1248.0, 688.0)
var health: int = 0
var spell_time_left: float = 0.0

var _shot_time_left: float = 0.0
var _invulnerable_left: float = 0.0
var _body_radius: float = 16.0



func _ready() -> void:
	health = max_health
	add_to_group("player")


## Reprend les stats finales du run (à rappeler après chaque objet) ainsi que ses PV.
func apply_stats(state: RunState) -> void:
	speed = state.stat(&"speed")
	max_health = state.max_health
	health = state.health
	contact_invulnerability = state.stat(&"contact_invulnerability")
	pickup_radius = state.stat(&"pickup_radius")
	shot_damage = state.stat(&"shot_damage")
	shot_cooldown = state.stat(&"shot_cooldown")
	shot_speed = state.stat(&"shot_speed")
	shot_range = state.stat(&"shot_range")
	spell_damage = state.stat(&"spell_damage")
	spell_radius = state.stat(&"spell_radius")
	spell_slow_factor = state.stat(&"spell_slow_factor")
	spell_slow_duration = state.stat(&"spell_slow_duration")
	spell_cooldown = state.stat(&"spell_cooldown")


func _physics_process(delta: float) -> void:
	if health <= 0:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	position = position.clamp(bounds.position, bounds.end)
	if mouse_aim:
		aim_position = get_global_mouse_position()

	_shot_time_left -= delta
	_invulnerable_left -= delta
	spell_time_left = maxf(spell_time_left - delta, 0.0)
	if can_shoot and Input.is_action_pressed("attack") and _shot_time_left <= 0.0:
		_shoot()
	if Input.is_action_just_pressed("spell") and spell_time_left <= 0.0:
		_cast_spell()
	_check_contacts()
	queue_redraw()


## Retire des PV. ignore_invulnerability : pour les ennemis qui atteignent la sortie.
func take_damage(amount: int, ignore_invulnerability: bool = false) -> void:
	if health <= 0:
		return
	if not ignore_invulnerability:
		if _invulnerable_left > 0.0:
			return
		_invulnerable_left = contact_invulnerability
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	if health == 0:
		died.emit()


func _shoot() -> void:
	_shot_time_left = shot_cooldown
	var direction: Vector2 = global_position.direction_to(aim_position)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	var shot := shot_scene.instantiate() as PlayerShot
	shot.direction = direction
	shot.damage = shot_damage
	shot.speed = shot_speed
	shot.max_distance = shot_range
	_effects().add_child(shot)
	shot.global_position = global_position + direction * (_body_radius + 4.0)


func _cast_spell() -> void:
	spell_time_left = spell_cooldown
	for enemy in _enemies_within(spell_radius):
		enemy.apply_slow(spell_slow_factor, spell_slow_duration)
		enemy.take_damage(spell_damage)
	RingEffect.spawn(_effects(), global_position, spell_radius, Color(0.55, 0.85, 1.0), 0.35)


func _check_contacts() -> void:
	if _invulnerable_left > 0.0:
		return
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or not enemy.is_alive():
			continue
		if enemy.global_position.distance_to(global_position) <= enemy.data.radius + _body_radius:
			take_damage(enemy.data.contact_damage)
			return


func _enemies_within(radius: float) -> Array[Enemy]:
	var result: Array[Enemy] = []
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy != null and enemy.is_alive() and enemy.global_position.distance_to(global_position) <= radius:
			result.append(enemy)
	return result


func _effects() -> Node:
	return effects_parent if effects_parent != null else get_parent()


func _draw() -> void:
	# Clignote pendant l'invulnérabilité
	if _invulnerable_left > 0.0 and fmod(_invulnerable_left, 0.2) < 0.1:
		return
	var aim: Vector2 = global_position.direction_to(aim_position)
	draw_circle(Vector2.ZERO, _body_radius, Color(0.95, 0.75, 0.3))
	draw_line(Vector2.ZERO, aim * 24.0, Color(1.0, 0.95, 0.8), 4.0)
