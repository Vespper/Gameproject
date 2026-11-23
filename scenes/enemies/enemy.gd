class_name Enemy
extends PathFollow2D
## Ennemi qui suit le chemin de la salle. Ses stats viennent d'un EnemyData.

signal died(enemy: Enemy)
signal reached_end(enemy: Enemy)
## Émis une seule fois quand l'ennemi quitte la partie (mort ou arrivé à la base).
signal removed

@export var data: EnemyData

var health: float = 0.0

var _slow_factor: float = 1.0
var _slow_time: float = 0.0
var _hit_flash: float = 0.0
var _is_removed: bool = false


func _ready() -> void:
	loop = false
	rotates = false
	health = data.max_health
	add_to_group("enemies")


func _process(delta: float) -> void:
	if _slow_time > 0.0:
		_slow_time -= delta
		if _slow_time <= 0.0:
			_slow_factor = 1.0
	if _hit_flash > 0.0:
		_hit_flash -= delta
	progress += data.speed * _slow_factor * delta
	queue_redraw()
	if progress_ratio >= 1.0:
		reached_end.emit(self)
		_remove()


func is_alive() -> bool:
	return not _is_removed


func take_damage(amount: float) -> void:
	if _is_removed:
		return
	health -= amount
	_hit_flash = 0.08
	if health <= 0.0:
		died.emit(self)
		_remove()


## Ralentit l'ennemi. Le ralentissement le plus fort et le plus long l'emporte.
func apply_slow(factor: float, duration: float) -> void:
	_slow_factor = minf(_slow_factor, factor)
	_slow_time = maxf(_slow_time, duration)


func _remove() -> void:
	if _is_removed:
		return
	_is_removed = true
	remove_from_group("enemies")
	removed.emit()
	queue_free()


func _draw() -> void:
	var body_color: Color = data.color
	if _slow_time > 0.0:
		body_color = body_color.lerp(Color(0.55, 0.85, 1.0), 0.5)
	if _hit_flash > 0.0:
		body_color = Color.WHITE
	if data.shape_sides >= 3:
		var points := PackedVector2Array()
		for i in data.shape_sides:
			var angle: float = TAU * i / data.shape_sides - PI / 2.0
			points.append(Vector2.from_angle(angle) * data.radius)
		draw_colored_polygon(points, body_color)
	else:
		draw_circle(Vector2.ZERO, data.radius, body_color)
	# Barre de vie
	var width: float = maxf(data.radius * 2.0, 20.0)
	var bar := Rect2(-width / 2.0, -data.radius - 9.0, width, 4.0)
	draw_rect(bar, Color(0.0, 0.0, 0.0, 0.7))
	bar.size.x = width * clampf(health / data.max_health, 0.0, 1.0)
	draw_rect(bar, Color(0.45, 0.95, 0.45))
