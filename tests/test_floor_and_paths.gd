extends SceneTree
## Vérifie la génération de l'étage et des chemins sur beaucoup de graines (rapide, sans jouer).
## Lancer : tools/test.sh tests/test_floor_and_paths.gd

const SEEDS := 300
const ROOM_RECT := Rect2(160.0, 80.0, 960.0, 520.0)

var _errors: PackedStringArray = []


func _initialize() -> void:
	_check_floors()
	_check_paths()
	if _errors.is_empty():
		print("Résultat : OK — %d étages et %d chemins vérifiés" % [SEEDS, SEEDS])
	else:
		for e in _errors.slice(0, 10):
			printerr("ERROR: " + e)
		print("Résultat : ÉCHEC — %d problèmes" % _errors.size())
	quit()


func _check_floors() -> void:
	for s in range(1, SEEDS + 1):
		var rng := RandomNumberGenerator.new()
		rng.seed = s
		var map: FloorMap = FloorMap.generate(rng, 8, Vector2i(9, 8))
		if map == null or map.rooms.size() != 8:
			_errors.append("graine %d : mauvais nombre de salles" % s)
			continue
		var starts: int = 0
		for cell: Vector2i in map.rooms:
			var room: FloorRoom = map.room_at(cell)
			if room.type == FloorRoom.Type.START:
				starts += 1
			var doors: int = map.doors_of(cell).size()
			if doors < 1 or doors > 4:
				_errors.append("graine %d : salle %s avec %d portes" % [s, cell, doors])
		if starts != 1:
			_errors.append("graine %d : %d salles de départ" % [s, starts])
		# Toutes les salles sont reliées au départ
		var seen: Dictionary = {map.start: true}
		var todo: Array[Vector2i] = [map.start]
		while not todo.is_empty():
			var c: Vector2i = todo.pop_back()
			for d in map.doors_of(c):
				if not seen.has(c + d):
					seen[c + d] = true
					todo.append(c + d)
		if seen.size() != map.rooms.size():
			_errors.append("graine %d : salles non reliées" % s)
		# Même graine, même étage
		var rng2 := RandomNumberGenerator.new()
		rng2.seed = s
		var again: FloorMap = FloorMap.generate(rng2, 8, Vector2i(9, 8))
		if again.rooms.keys() != map.rooms.keys():
			_errors.append("graine %d : étage non reproductible" % s)


func _check_paths() -> void:
	var lengths: Array[float] = []
	for s in range(1, SEEDS + 1):
		var rng := RandomNumberGenerator.new()
		rng.seed = s
		var points: PackedVector2Array = PathGenerator.generate(rng, ROOM_RECT)
		if points.size() < 4:
			_errors.append("graine %d : chemin vide" % s)
			continue
		var length: float = PathGenerator.path_length(points)
		lengths.append(length)
		if length < 1400.0 or length > 2000.0:
			_errors.append("graine %d : longueur %.0f hors limites" % [s, length])
		for p in points:
			if not ROOM_RECT.grow(1.0).has_point(p):
				_errors.append("graine %d : point %s hors de la salle" % [s, p])
		# L'entrée est collée à un mur latéral, la sortie près du mur opposé
		var start: Vector2 = points[0]
		var end: Vector2 = points[points.size() - 1]
		if not (is_equal_approx(start.x, ROOM_RECT.position.x) or is_equal_approx(start.x, ROOM_RECT.end.x)):
			_errors.append("graine %d : entrée pas sur un mur" % s)
		if absf(end.x - start.x) < ROOM_RECT.size.x * 0.8:
			_errors.append("graine %d : sortie trop près de l'entrée" % s)
		# Entrée et sortie loin des portes (milieu des murs)
		for p in [start, end]:
			if absf(p.y - ROOM_RECT.get_center().y) < 60.0:
				_errors.append("graine %d : entrée ou sortie devant une porte" % s)
		# Segments uniquement horizontaux ou verticaux
		for i in range(1, points.size()):
			var a: Vector2 = points[i - 1]
			var b: Vector2 = points[i]
			if not (is_equal_approx(a.x, b.x) or is_equal_approx(a.y, b.y)):
				_errors.append("graine %d : segment en diagonale" % s)
	lengths.sort()
	print("Longueur des chemins : min %.0f, médiane %.0f, max %.0f" % [
		lengths[0], lengths[lengths.size() / 2], lengths[lengths.size() - 1]
	])
