extends Node

class_name ConfigManager

const LEVELS_PATH = "res://resources/LevelsConfiguration/"

var current_level: LevelConfig

# TODO this should probably also load the map and such
func load_level(level_id: String) -> LevelConfig:
	var level_path = LEVELS_PATH + "level_%s.tres" % level_id
	var level = load(level_path) as LevelConfig
	if level:
		current_level = level
		return level
	print("Failed to load level configuration for level %s" % level_id)
	return null
