class_name Base
extends Node2D
## Ce que le joueur défend. Si ses PV tombent à 0, la partie est perdue.

signal health_changed(current: int, maximum: int)
signal destroyed

@export var max_health: int = 20

var health: int = 0

var _hit_flash: float = 0.0


func _ready() -> void:
	health = max_health


func _process(delta: float) -> void:
	if _hit_flash > 0.0:
		_hit_flash -= delta
		queue_redraw()


func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health = maxi(health - amount, 0)
	_hit_flash = 0.25
	health_changed.emit(health, max_health)
	if health == 0:
		destroyed.emit()


func _draw() -> void:
	var color := Color(0.35, 0.55, 0.95) if _hit_flash <= 0.0 else Color(1.0, 0.35, 0.35)
	draw_rect(Rect2(-28.0, -28.0, 56.0, 56.0), color)
	draw_rect(Rect2(-28.0, -28.0, 56.0, 56.0), Color.WHITE, false, 2.0)
