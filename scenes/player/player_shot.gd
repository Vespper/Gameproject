class_name PlayerShot
extends Node2D
## Tir du personnage : part en ligne droite et touche le premier ennemi rencontré.

var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0
var speed: float = 750.0
var max_distance: float = 420.0

var _travelled: float = 0.0


func _process(delta: float) -> void:
	var step: float = speed * delta
	global_position += direction * step
	_travelled += step
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy != null and enemy.is_alive() and enemy.global_position.distance_to(global_position) <= enemy.data.radius + 4.0:
			enemy.take_damage(damage)
			queue_free()
			return
	if _travelled >= max_distance:
		queue_free()


func _draw() -> void:
	draw_line(-direction * 8.0, direction * 4.0, Color(1.0, 0.95, 0.75), 4.0)
