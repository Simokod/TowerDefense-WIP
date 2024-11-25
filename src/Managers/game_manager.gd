extends Node2D

const HeroResource = preload("res://src/hero.gd")
const DebuggerResource = preload("res://src/Debugger/debugger.gd")

var config_manager: ConfigManager
var debugger: Debugger
var ui_layer: CanvasLayer

var DEBUG_MODE = OS.has_feature("editor")

var heroes_container = Node2D.new()

func start_game():
	add_child(heroes_container)

	if DEBUG_MODE:
		ui_layer = CanvasLayer.new()
		ui_layer.layer = Layers.DEBUG
		add_child(ui_layer)
		
		debugger = DebuggerResource.new()
		ui_layer.add_child(debugger)

func get_available_heroes() -> Array[Hero]:
	# TODO make this not hardcoded.
	var warrior_hero = HeroResource.new()
	warrior_hero.id = 1
	warrior_hero.name = "Warrior"
	warrior_hero.sprite = preload("res://Images/Heroes/Warrior/Warrior-portrait-removebg-preview.png")
	warrior_hero.health = 100
	warrior_hero.attack = 10
	warrior_hero.allowed_tiles = [Constants.TILE_TYPES.ROAD, Constants.TILE_TYPES.FOREST]
	
	var ranger_hero = HeroResource.new()
	ranger_hero.id = 2
	ranger_hero.name = "Ranger"
	ranger_hero.sprite = preload("res://Images/Heroes/Ranger/Ranger_portrait_removed_bg.png")
	ranger_hero.health = 80
	ranger_hero.attack = 13
	ranger_hero.allowed_tiles = [Constants.TILE_TYPES.FOREST]
	
	return [warrior_hero, ranger_hero]

func get_placed_heroes_count():
	return heroes_container.get_child_count()

func add_hero_portrait(hero_portrait: HeroPortrait) -> void:
	heroes_container.add_child(hero_portrait)

func free_hero_portrait(hero: Hero) -> void:
	for node in heroes_container.get_children():
		if node.hero == hero:
			node.queue_free()
			print("Hero {hero_name} removed".format({"hero_name": hero.name}))
			break


func finish_setup():
	print("GameManager: Finished setup")
	var enemy_manager: EnemyManager = EnemyManager.new()
	add_child(enemy_manager)
	
	var wave_manager = WaveManager.new(enemy_manager)
	add_child(wave_manager)

	config_manager = ConfigManager.new()
	var current_level = config_manager.load_level("demo")
	wave_manager.initialize_waves(current_level.waves)


func get_spawn_points() -> Array[Vector2i]:
	return config_manager.current_level.spawn_points


func is_debug_mode() -> bool:
	return DEBUG_MODE

func get_debugger() -> Debugger:
	return debugger if DEBUG_MODE else null
