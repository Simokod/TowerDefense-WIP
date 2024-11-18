extends Resource
class_name EnemyGroup
    
@export var enemy_type: String
@export var count: int
@export var spawn_point_id: int # References a spawn point in the map
@export var spawn_turn: int = 0