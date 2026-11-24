class_name FloorData
extends Resource
## Réglages d'un étage. Une instance = un fichier .tres dans data/floors/.

## Nombre de salles, départ compris (la carte complète en aura 8 à 12, voir map.md).
@export var room_count: int = 5
@export var grid_size := Vector2i(9, 8)
