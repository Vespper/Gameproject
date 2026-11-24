class_name TowerData
extends Resource
## Statistiques d'un type de tour. Une instance = un fichier .tres dans data/towers/.

@export var display_name: String = "Tour"
## Coût en énergie pour la poser.
@export var cost: int = 50
## Prix en énergie du type de tour à la boutique.
@export var shop_price: int = 90
@export var damage: float = 10.0
## Tirs par seconde.
@export var fire_rate: float = 1.0
@export var attack_range: float = 160.0
@export var projectile_speed: float = 500.0
## Rayon des dégâts de zone (0 = cible unique).
@export var splash_radius: float = 0.0
## Multiplicateur de vitesse appliqué à la cible (1 = pas de ralentissement).
@export_range(0.0, 1.0) var slow_factor: float = 1.0
@export var slow_duration: float = 0.0
@export var color: Color = Color(0.3, 0.8, 0.6)
