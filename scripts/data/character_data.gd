class_name CharacterData
extends Resource
## Stats de base d'un personnage jouable. Une instance = un fichier .tres dans data/characters/.
## Les objets ne modifient jamais ce fichier : RunState calcule les stats finales
## (stats de base + modificateurs des objets, voir RunState.stat()).

@export var display_name: String = "Personnage"

@export_group("Départ")
@export var starting_energy: int = 100
## Types de tours possédés au départ du run.
@export var starting_towers: Array[TowerData] = []

@export_group("Corps")
@export var max_health: int = 3
@export var speed: float = 240.0
## Secondes d'invulnérabilité après un contact avec un ennemi.
@export var contact_invulnerability: float = 1.0
## Distance à laquelle l'énergie est aspirée vers le personnage.
@export var pickup_radius: float = 90.0

@export_group("Tir")
@export var shot_damage: float = 8.0
## Secondes entre deux tirs.
@export var shot_cooldown: float = 0.3
@export var shot_speed: float = 750.0
@export var shot_range: float = 360.0

@export_group("Sort : onde de givre")
@export var spell_damage: float = 20.0
@export var spell_radius: float = 130.0
@export_range(0.0, 1.0) var spell_slow_factor: float = 0.4
@export var spell_slow_duration: float = 2.5
@export var spell_cooldown: float = 8.0

@export_group("Tours")
## Multiplicateurs appliqués à toutes les tours posées (1 = sans changement).
@export var tower_damage: float = 1.0
@export var tower_fire_rate: float = 1.0
@export var tower_range: float = 1.0
## Part du coût des tours rendue quand elles sont démontées en fin de salle.
@export var tower_refund: float = 0.25
## Nombre de types de tours qu'on peut posséder.
@export var tower_slots: int = 3
