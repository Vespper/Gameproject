class_name Tower
extends Node2D
## Tour posée sur un emplacement. Vise l'ennemi le plus avancé à portée et tire.

@export var data: TowerData
@export var projectile_scene: PackedScene

## Nœud qui reçoit les projectiles (défini par la salle).
var projectile_parent: Node
## Énergie réellement payée à la pose (le coût monte avec le nombre de tours de la salle).
var paid_cost: int = 0

var _cooldown: float = 0.0
var _aim: Vector2 = Vector2.UP


func _ready() -> void:
	add_to_group("towers")


func _process(delta: float) -> void:
	_cooldown -= delta
	var target := _find_target()
	if target == null:
		return
	_aim = global_position.direction_to(target.global_position)
	queue_redraw()
	if _cooldown <= 0.0:
		_fire(target)
		_cooldown = 1.0 / data.fire_rate


func _find_target() -> Enemy:
	var best: Enemy = null
	var range_squared: float = data.attack_range * data.attack_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or not enemy.is_alive():
			continue
		if global_position.distance_squared_to(enemy.global_position) > range_squared:
			continue
		if best == null or enemy.progress > best.progress:
			best = enemy
	return best


func _fire(target: Enemy) -> void:
	var projectile := projectile_scene.instantiate() as Projectile
	projectile.setup(data, target)
	var parent: Node = projectile_parent if projectile_parent != null else get_parent()
	parent.add_child(projectile)
	projectile.global_position = global_position + _aim * 16.0


func _draw() -> void:
	draw_rect(Rect2(-18.0, -18.0, 36.0, 36.0), Color(0.22, 0.22, 0.26))
	draw_circle(Vector2.ZERO, 12.0, data.color)
	draw_line(Vector2.ZERO, _aim * 20.0, data.color.lightened(0.3), 5.0)
