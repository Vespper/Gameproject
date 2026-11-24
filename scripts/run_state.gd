class_name RunState
extends RefCounted
## État du run qui survit au changement de salle : PV du personnage, énergie, carte de l'étage.
## Tenu par la scène principale. Deviendra un autoload quand d'autres scènes en auront besoin.

var seed_value: int = 0
var floor_map: FloorMap
var current: Vector2i
var energy: int = 0
## -1 : pas encore fixé, la première salle prend les PV du personnage.
var health: int = -1
var max_health: int = -1
