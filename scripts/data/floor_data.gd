class_name FloorData
extends Resource
## Réglages d'un étage. Une instance = un fichier .tres dans data/floors/.

## Nombre de salles, départ compris (la carte complète en aura 8 à 12, voir map.md).
@export var room_count: int = 7
@export var grid_size := Vector2i(9, 8)

@export_group("Salles spéciales")
## Placées dans les culs-de-sac. Le plus éloigné reste un combat (place du futur boss).
@export var treasure_rooms: int = 1
@export var shop_rooms: int = 1

@export_group("Objets et boutique")
## Objets qu'on peut trouver dans l'étage (trésor, boutique). Chaque objet sort au plus une fois.
@export var item_pool: Array[ItemData] = []
## Types de tours qu'on peut acheter en boutique (seulement ceux qu'on n'a pas).
@export var shop_tower_pool: Array[TowerData] = []
@export var shop_item_count: int = 2
@export var shop_heal_amount: int = 5
@export var shop_heal_price: int = 35
