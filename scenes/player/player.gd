class_name Player
extends CharacterBody2D
## Personnage joué pendant les vagues : déplacement, attaque de mêlée, sort à recharge.

@export var speed: float = 260.0

@export_group("Mêlée")
@export var melee_damage: float = 15.0
@export var melee_radius: float = 60.0
@export var melee_cooldown: float = 0.35

@export_group("Sort : onde de givre")
@export var spell_damage: float = 25.0
@export var spell_radius: float = 150.0
@export_range(0.0, 1.0) var spell_slow_factor: float = 0.4
@export var spell_slow_duration: float = 2.5
@export var spell_cooldown: float = 6.0

@export_group("Butin")
## Distance à laquelle l'énergie est aspirée vers le personnage.
@export var pickup_radius: float = 90.0

## Nœud qui reçoit les effets visuels (défini par la salle).
var effects_parent: Node
var spell_time_left: float = 0.0

var _melee_time_left: float = 0.0
var _facing: Vector2 = Vector2.RIGHT
var _bounds := Rect2(16.0, 16.0, 1248.0, 688.0)


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		_facing = direction
	velocity = direction * speed
	move_and_slide()
	position = position.clamp(_bounds.position, _bounds.end)

	_melee_time_left -= delta
	spell_time_left = maxf(spell_time_left - delta, 0.0)
	if Input.is_action_pressed("attack") and _melee_time_left <= 0.0:
		_melee()
	if Input.is_action_just_pressed("spell") and spell_time_left <= 0.0:
		_cast_spell()
	queue_redraw()


func _melee() -> void:
	_melee_time_left = melee_cooldown
	for enemy in _enemies_within(melee_radius):
		enemy.take_damage(melee_damage)
	RingEffect.spawn(_effects(), global_position, melee_radius, Color(1.0, 0.95, 0.8), 0.12)


func _cast_spell() -> void:
	spell_time_left = spell_cooldown
	for enemy in _enemies_within(spell_radius):
		enemy.apply_slow(spell_slow_factor, spell_slow_duration)
		enemy.take_damage(spell_damage)
	RingEffect.spawn(_effects(), global_position, spell_radius, Color(0.55, 0.85, 1.0), 0.35)


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
	draw_circle(Vector2.ZERO, 16.0, Color(0.95, 0.75, 0.3))
	draw_line(Vector2.ZERO, _facing * 22.0, Color(1.0, 0.95, 0.8), 4.0)
	# Rayon de mêlée en pointillé discret
	draw_arc(Vector2.ZERO, melee_radius, 0.0, TAU, 40, Color(1.0, 1.0, 1.0, 0.08), 1.0)
