class_name Pedestal
extends Node2D
## Socle d'un article (objet, type de tour, soin) dans une salle du trésor ou une boutique.
## Le personnage le prend en marchant dessus ; la salle vérifie le prix.

## Distance à laquelle le personnage touche le socle.
@export var touch_radius: float = 30.0

var offer: RoomOffer


func touches(point: Vector2) -> bool:
	return global_position.distance_to(point) <= touch_radius


func _draw() -> void:
	draw_rect(Rect2(-26.0, -26.0, 52.0, 52.0), Color(0.22, 0.2, 0.24))
	draw_rect(Rect2(-26.0, -26.0, 52.0, 52.0), Color(0.6, 0.58, 0.55), false, 2.0)
	var tint: Color = offer.color()
	match offer.kind:
		RoomOffer.Kind.ITEM:
			draw_circle(Vector2.ZERO, 14.0, tint)
			draw_circle(Vector2.ZERO, 14.0, Color.WHITE, false, 2.0)
		RoomOffer.Kind.TOWER:
			draw_rect(Rect2(-14.0, -14.0, 28.0, 28.0), Color(0.3, 0.3, 0.34))
			draw_circle(Vector2.ZERO, 9.0, tint)
		RoomOffer.Kind.HEAL:
			draw_rect(Rect2(-4.0, -14.0, 8.0, 28.0), tint)
			draw_rect(Rect2(-14.0, -4.0, 28.0, 8.0), tint)

	var price: String = "Gratuit" if offer.price == 0 else "%d énergie" % offer.price
	_draw_centered(offer.title(), Vector2(0.0, -38.0), 16, Color(0.95, 0.9, 0.75))
	_draw_centered(offer.description(), Vector2(0.0, 46.0), 14, Color(0.8, 0.8, 0.85))
	_draw_centered(price, Vector2(0.0, 66.0), 16, Color(0.4, 1.0, 0.85))


func _draw_centered(text: String, at: Vector2, font_size: int, color: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var pos: Vector2 = at + Vector2(-width / 2.0, font_size / 3.0)
	draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, Color.BLACK)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
