class_name Base
extends Node2D
## Sortie de la salle, au bout du chemin. Un ennemi qui l'atteint retire des PV au personnage.
## Le nom « Base » est gardé pour l'instant ; elle ne porte plus de PV.

var _hit_flash: float = 0.0


func _process(delta: float) -> void:
	if _hit_flash > 0.0:
		_hit_flash -= delta
		queue_redraw()


## Petit retour visuel quand un ennemi passe.
func flash() -> void:
	_hit_flash = 0.25
	queue_redraw()


func _draw() -> void:
	var color := Color(0.35, 0.55, 0.95) if _hit_flash <= 0.0 else Color(1.0, 0.35, 0.35)
	draw_rect(Rect2(-28.0, -28.0, 56.0, 56.0), color)
	draw_rect(Rect2(-28.0, -28.0, 56.0, 56.0), Color.WHITE, false, 2.0)
