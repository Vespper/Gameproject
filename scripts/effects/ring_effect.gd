class_name RingEffect
extends Node2D
## Cercle qui s'estompe : retour visuel des coups, sorts et explosions.

var radius: float = 40.0
var color: Color = Color.WHITE
var duration: float = 0.2

var _time_left: float = 0.0


## Crée un cercle à la position donnée, dans le parent donné.
static func spawn(parent: Node, at: Vector2, ring_radius: float, ring_color: Color, ring_duration: float = 0.2) -> void:
	var effect := RingEffect.new()
	effect.radius = ring_radius
	effect.color = ring_color
	effect.duration = ring_duration
	parent.add_child(effect)
	effect.global_position = at


func _ready() -> void:
	_time_left = duration


func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t: float = clampf(_time_left / duration, 0.0, 1.0)
	var fill := Color(color, 0.25 * t)
	draw_circle(Vector2.ZERO, radius, fill)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(color, t), 3.0)
