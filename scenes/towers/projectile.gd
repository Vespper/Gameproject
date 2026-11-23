class_name Projectile
extends Node2D
## Projectile à tête chercheuse. Applique dégâts, zone et ralentissement de la tour.

var _data: TowerData
var _target: Enemy
var _target_position: Vector2 = Vector2.ZERO


func setup(tower_data: TowerData, target: Enemy) -> void:
	_data = tower_data
	_target = target
	_target_position = target.global_position


func _process(delta: float) -> void:
	if is_instance_valid(_target) and _target.is_alive():
		_target_position = _target.global_position
	var step: float = _data.projectile_speed * delta
	if global_position.distance_to(_target_position) <= step:
		global_position = _target_position
		_hit()
		return
	global_position = global_position.move_toward(_target_position, step)


func _hit() -> void:
	if _data.splash_radius > 0.0:
		for node in get_tree().get_nodes_in_group("enemies"):
			var enemy := node as Enemy
			if enemy != null and enemy.global_position.distance_to(global_position) <= _data.splash_radius:
				_apply_to(enemy)
		RingEffect.spawn(get_parent(), global_position, _data.splash_radius, _data.color, 0.25)
	elif is_instance_valid(_target) and _target.is_alive():
		_apply_to(_target)
	queue_free()


func _apply_to(enemy: Enemy) -> void:
	if _data.slow_factor < 1.0:
		enemy.apply_slow(_data.slow_factor, _data.slow_duration)
	enemy.take_damage(_data.damage)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0 if _data.splash_radius <= 0.0 else 7.0, _data.color.lightened(0.4))
