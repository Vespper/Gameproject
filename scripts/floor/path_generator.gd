class_name PathGenerator
extends RefCounted
## Génère le chemin des ennemis d'une salle : segments horizontaux et verticaux sur une grille,
## d'un bord de la salle (entrée) jusqu'à la sortie, près du bord opposé.
## Règles (pour garder de la place aux tours et un chemin lisible) :
## - le chemin avance toujours vers la sortie, il ne revient jamais en arrière ;
## - deux virages verticaux sont séparés d'au moins 2 cases ;
## - chaque virage vertical fait au moins 2 cases ;
## - l'entrée et la sortie évitent le milieu des murs, où sont les portes ;
## - la longueur totale reste dans [min_length, max_length].

const MAX_ATTEMPTS := 200


## Renvoie les points du chemin en coordonnées de la salle.
static func generate(
		rng: RandomNumberGenerator, rect: Rect2, cell: float = 80.0,
		min_length: float = 1400.0, max_length: float = 2000.0,
		min_turns: int = 2, max_turns: int = 4) -> PackedVector2Array:
	var cols: int = int(rect.size.x / cell)
	var rows: int = int(rect.size.y / cell)
	var origin: Vector2 = rect.position + (rect.size - Vector2(cols, rows) * cell) / 2.0
	# Rangées autorisées pour l'entrée et la sortie : loin du milieu des murs (portes)
	var edge_rows: Array[int] = []
	for row in rows:
		var y: float = origin.y + (row + 0.5) * cell
		if absf(y - rect.get_center().y) >= cell * 0.75:
			edge_rows.append(row)

	var best := PackedVector2Array()
	for attempt in MAX_ATTEMPTS:
		var grid_points: Array[Vector2] = _try_grid_path(rng, cols, rows, edge_rows, min_turns, max_turns)
		if grid_points.is_empty():
			continue
		var points := PackedVector2Array()
		for p in grid_points:
			# x = -0.5 : collé au mur d'entrée
			var x: float = rect.position.x if p.x < 0.0 else origin.x + (p.x + 0.5) * cell
			points.append(Vector2(x, origin.y + (p.y + 0.5) * cell))
		best = points
		var length: float = path_length(points)
		if length >= min_length and length <= max_length:
			break
	# Une fois sur deux, les ennemis viennent de la droite
	if rng.randf() < 0.5:
		for i in best.size():
			best[i].x = rect.position.x + rect.end.x - best[i].x
	return best


static func path_length(points: PackedVector2Array) -> float:
	var total: float = 0.0
	for i in range(1, points.size()):
		total += points[i - 1].distance_to(points[i])
	return total


## Chemin en cases (colonne, rangée), de gauche à droite. Vide si la tentative échoue.
static func _try_grid_path(
		rng: RandomNumberGenerator, cols: int, rows: int, edge_rows: Array[int],
		min_turns: int, max_turns: int) -> Array[Vector2]:
	var start_row: int = edge_rows[rng.randi_range(0, edge_rows.size() - 1)]
	var end_row: int = edge_rows[rng.randi_range(0, edge_rows.size() - 1)]

	# Colonnes des virages : entre 1 et cols - 2, espacées d'au moins 2 cases
	var candidates: Array[int] = []
	for c in range(1, cols - 1):
		candidates.append(c)
	# Mélange avec rng (et non shuffle()) pour que la graine reproduise le chemin
	for i in range(candidates.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var swap: int = candidates[i]
		candidates[i] = candidates[j]
		candidates[j] = swap
	var wanted: int = rng.randi_range(min_turns, max_turns)
	var turn_cols: Array[int] = []
	for c in candidates:
		if turn_cols.size() >= wanted:
			break
		var spaced: bool = true
		for other in turn_cols:
			if absi(other - c) < 2:
				spaced = false
		if spaced:
			turn_cols.append(c)
	if turn_cols.size() < min_turns:
		return []
	turn_cols.sort()

	var points: Array[Vector2] = [Vector2(-0.5, start_row)]
	var row: int = start_row
	for i in turn_cols.size():
		var target: int
		if i == turn_cols.size() - 1:
			target = end_row
		else:
			var options: Array[int] = []
			for r in rows:
				if absi(r - row) >= 2:
					options.append(r)
			target = options[rng.randi_range(0, options.size() - 1)]
		if absi(target - row) < 2:
			return []
		points.append(Vector2(turn_cols[i], row))
		points.append(Vector2(turn_cols[i], target))
		row = target
	points.append(Vector2(cols - 1, row))
	return points
