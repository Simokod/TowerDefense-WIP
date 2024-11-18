extends Resource
class_name LevelConfig

@export var level_id: int
@export var map_scene_path: String # TODO is needed?
@export var spawn_points: Array[Vector2] # Array of possible spawn positions
@export var waves: Array[WaveConfig]