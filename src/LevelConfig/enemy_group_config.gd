extends Resource
class_name EnemyGroup
    
@export var enemy_type: Enemies.EnemyNames
@export var count: int
@export var spawn_point_id: int # References a spawn point in the map
@export var spawn_delay: float = 0.0