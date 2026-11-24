class_name RunState
extends RefCounted
## État du run qui survit au changement de salle : personnage, stats, objets, types de tours,
## PV, énergie, carte de l'étage.
## Tenu par la scène principale. Deviendra un autoload quand d'autres scènes en auront besoin.

## Stats où une valeur plus basse est meilleure (pour les flèches ▲ ▼ du HUD).
const LOWER_IS_BETTER: Array[StringName] = [&"shot_cooldown", &"spell_cooldown"]

var seed_value: int = 0
var floor_map: FloorMap
var current: Vector2i
var energy: int = 0
var health: int = 0
var max_health: int:
	get:
		return stat_int(&"max_health")
## Personnage joué : ses stats de base.
var character: CharacterData
## Objets ramassés ou achetés, dans l'ordre.
var items: Array[ItemData] = []
## Types de tours possédés (au plus tower_slots).
var tower_types: Array[TowerData] = []


## Nouveau run avec ce personnage : énergie, PV et tours de départ.
static func create(character_data: CharacterData) -> RunState:
	var state := RunState.new()
	state.character = character_data
	state.energy = character_data.starting_energy
	state.tower_types = character_data.starting_towers.duplicate()
	state.health = state.max_health
	return state


## Stat finale : (base + somme des add) × produit des multiply, sur tous les objets.
func stat(stat_name: StringName) -> float:
	var added: float = 0.0
	var factor: float = 1.0
	for item in items:
		for modifier in item.modifiers:
			if modifier.stat == stat_name:
				added += modifier.add
				factor *= modifier.multiply
	return (float(character.get(stat_name)) + added) * factor


func stat_int(stat_name: StringName) -> int:
	return roundi(stat(stat_name))


## 1 si la stat est meilleure que la base du personnage, -1 si pire, 0 sinon.
func stat_trend(stat_name: StringName) -> int:
	var difference: float = stat(stat_name) - float(character.get(stat_name))
	if is_zero_approx(difference):
		return 0
	var better: bool = difference > 0.0
	if stat_name in LOWER_IS_BETTER:
		better = not better
	return 1 if better else -1


## Ajoute un objet. Les PV max gagnés sont aussi rendus en PV.
func add_item(item: ItemData) -> void:
	var before: int = max_health
	items.append(item)
	health = clampi(health + maxi(max_health - before, 0), 0, max_health)


func heal(amount: int) -> void:
	health = mini(health + amount, max_health)


func has_tower_type(tower: TowerData) -> bool:
	return tower in tower_types


func has_free_tower_slot() -> bool:
	return tower_types.size() < stat_int(&"tower_slots")


func add_tower_type(tower: TowerData) -> bool:
	if has_tower_type(tower) or not has_free_tower_slot():
		return false
	tower_types.append(tower)
	return true


## Copie des stats d'un type de tour avec les bonus des objets (dégâts, cadence, portée).
func tower_stats(tower: TowerData) -> TowerData:
	var result := tower.duplicate() as TowerData
	result.damage = tower.damage * stat(&"tower_damage")
	result.fire_rate = tower.fire_rate * stat(&"tower_fire_rate")
	result.attack_range = tower.attack_range * stat(&"tower_range")
	return result
