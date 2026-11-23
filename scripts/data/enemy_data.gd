class_name EnemyData
extends Resource
## Statistiques d'un type d'ennemi. Une instance = un fichier .tres dans data/enemies/.

@export var display_name: String = "Ennemi"
@export var max_health: float = 30.0
## Vitesse le long du chemin, en pixels par seconde.
@export var speed: float = 80.0
## PV retirés au personnage quand l'ennemi atteint la sortie.
@export var base_damage: int = 1
## PV retirés au personnage quand il touche l'ennemi.
@export var contact_damage: int = 1
## Énergie lâchée à la mort.
@export var energy_drop: int = 8
@export var radius: float = 12.0
## 0 = cercle, sinon nombre de côtés du polygone (3 = triangle, 4 = carré).
@export var shape_sides: int = 0
@export var color: Color = Color(0.85, 0.25, 0.25)
