class_name Minimap
extends Control
## Mini-carte de l'étage : salles visitées, salles voisines (contour), salle actuelle.
## Centrée sur la salle actuelle ; les salles lointaines restent cachées (voir map.md).

@export var cell_size: float = 22.0
@export var gap: float = 4.0

var floor_map: FloorMap
var current: Vector2i


func show_map(map: FloorMap, at: Vector2i) -> void:
	floor_map = map
	current = at
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.45))
	if floor_map == null:
		return
	var font: Font = ThemeDB.fallback_font
	for cell: Vector2i in floor_map.rooms:
		var room: FloorRoom = floor_map.room_at(cell)
		if not room.visited and not _next_to_visited(cell):
			continue
		var center: Vector2 = size / 2.0 + Vector2(cell - current) * (cell_size + gap)
		var rect := Rect2(center - Vector2.ONE * cell_size / 2.0, Vector2.ONE * cell_size)
		if not Rect2(Vector2.ZERO, size).encloses(rect):
			continue
		if cell == current:
			draw_rect(rect, Color(0.95, 0.9, 0.75))
		elif room.visited:
			draw_rect(rect, Color(0.45, 0.45, 0.5))
		else:
			draw_rect(rect, Color(0.7, 0.7, 0.75), false, 2.0)
		if room.type == FloorRoom.Type.START:
			draw_string(font, rect.position + Vector2(6.0, 16.0), "D", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.BLACK if cell == current else Color.WHITE)


func _next_to_visited(cell: Vector2i) -> bool:
	for direction in FloorMap.DIRECTIONS:
		var other: FloorRoom = floor_map.room_at(cell + direction)
		if other != null and other.visited:
			return true
	return false
