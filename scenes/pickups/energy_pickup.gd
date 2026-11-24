class_name EnergyPickup
extends Node2D
## Énergie lâchée par un ennemi. Le personnage doit aller la chercher avant qu'elle disparaisse.

signal collected(amount: int)

## Secondes avant disparition : court, pour obliger à aller la chercher pendant le combat.
@export var lifetime: float = 6.0
## Clignote pendant ces dernières secondes.
@export var blink_time: float = 2.0
@export var magnet_speed: float = 520.0

var amount: int = 5

var _time_left: float = 0.0


func _ready() -> void:
	_time_left = lifetime


func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		var distance: float = global_position.distance_to(player.global_position)
		if distance <= 18.0:
			collected.emit(amount)
			queue_free()
			return
		if distance <= player.pickup_radius:
			global_position = global_position.move_toward(player.global_position, magnet_speed * delta)
	queue_redraw()


func _draw() -> void:
	if _time_left < blink_time and fmod(_time_left, 0.3) < 0.15:
		return
	var size: float = 6.0 + minf(amount, 25) * 0.2
	var points := PackedVector2Array([
		Vector2(0.0, -size), Vector2(size * 0.7, 0.0), Vector2(0.0, size), Vector2(-size * 0.7, 0.0)
	])
	draw_colored_polygon(points, Color(0.4, 1.0, 0.85))
