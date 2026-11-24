class_name Door
extends Node2D
## Porte dans un mur de la salle. Fermée pendant le combat, ouverte une fois la salle nettoyée.
## Affiche ce qu'il y a derrière (type de salle).

@export var width: float = 96.0
@export var thickness: float = 20.0

## Côté de la salle : Vector2i.UP, RIGHT, DOWN ou LEFT.
var direction: Vector2i = Vector2i.LEFT
## Ce qui est écrit à côté de la porte.
var label: String = ""
var is_open: bool = false


## Vrai si le point (coordonnées globales) est dans l'embrasure de la porte.
func contains(point: Vector2) -> bool:
	var local: Vector2 = point - global_position
	var normal := Vector2(direction)
	var along: float = absf(local.dot(normal.orthogonal()))
	var depth: float = absf(local.dot(normal))
	return along <= width / 2.0 and depth <= thickness + 12.0


func set_open(value: bool) -> void:
	is_open = value
	queue_redraw()


func _draw() -> void:
	var normal := Vector2(direction)
	var size: Vector2 = Vector2(thickness, width) if direction.x != 0 else Vector2(width, thickness)
	var rect := Rect2(-size / 2.0 + normal * thickness / 2.0, size)
	var color := Color(0.35, 0.8, 0.45) if is_open else Color(0.55, 0.18, 0.18)
	draw_rect(rect, color)
	draw_rect(rect, Color(0.9, 0.9, 0.9, 0.8), false, 2.0)
	if not is_open:
		# Barreaux : porte fermée
		for i in range(1, 4):
			var t: float = -width / 2.0 + width * i / 4.0
			var tangent: Vector2 = normal.orthogonal()
			draw_line(tangent * t, tangent * t + normal * thickness, Color(0.2, 0.05, 0.05), 3.0)

	# Texte à l'intérieur de la salle, devant la porte
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 16
	var text_size: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var anchor: Vector2 = -normal * (thickness + 18.0)
	if direction.x != 0:
		anchor -= normal * text_size.x / 2.0
	var text_pos: Vector2 = anchor + Vector2(-text_size.x / 2.0, text_size.y / 4.0)
	draw_string_outline(font, text_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, Color.BLACK)
	draw_string(font, text_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.95, 0.9, 0.75))
