class_name SpawnGroup
extends Resource
## Un groupe d'ennemis identiques dans une vague.

@export var enemy: EnemyData
@export var count: int = 5
## Secondes entre deux apparitions.
@export var interval: float = 1.0
## Secondes avant la première apparition, depuis le début de la vague.
@export var start_delay: float = 0.0
