extends Node2D

const DebuggerResource = preload("res://src/Debugger/debugger.gd")

var DEBUG_MODE = OS.has_feature("editor")
var config_manager: ConfigManager
var turn_manager: TurnManager
var debugger: Debugger
var ui_layer: CanvasLayer

var heroes_container = Node2D.new()

# Update the HERO_SCENE_PATHS to point to the new hero scenes
const HERO_SCENE_PATHS = {
	"Warrior": preload("res://scenes/Heroes/warrior_hero.tscn"),
	"Ranger": preload("res://scenes/Heroes/ranger_hero.tscn")
}

func initialize_game():
	add_child(heroes_container)

	if DEBUG_MODE:
		ui_layer = CanvasLayer.new()
		ui_layer.layer = Layers.DEBUG
		add_child(ui_layer)
		
		debugger = DebuggerResource.new()
		ui_layer.add_child(debugger)

func get_available_heroes() -> Array[Hero]:
	var heroes: Array[Hero] = []
	
	for hero_name in HERO_SCENE_PATHS:
		var hero_instance = HERO_SCENE_PATHS[hero_name].instantiate() as Hero
		heroes.append(hero_instance)
	
	return heroes

func get_placed_heroes_count():
	return heroes_container.get_child_count()

func add_hero_portrait(hero_portrait: HeroPortrait) -> void:
	heroes_container.add_child(hero_portrait)

func free_hero_portrait(hero: Hero) -> void:
	for node in heroes_container.get_children():
		if node.hero == hero:
			node.queue_free()
			print("Hero {hero_name} removed".format({"hero_name": hero.unit_name}))
			break


func start_gameplay():
	print("GameManager: Starting gameplay")
	var enemy_manager: EnemyManager = EnemyManager.new()
	add_child(enemy_manager)

	turn_manager = TurnManager.new(enemy_manager)
	add_child(turn_manager)

	var wave_manager = WaveManager.new(enemy_manager)
	add_child(wave_manager)

	config_manager = ConfigManager.new()
	var current_level = config_manager.load_level("demo")
	await wave_manager.initialize_waves(current_level.waves)
	
	for hero in heroes_container.get_children():
		turn_manager.register_unit(hero.hero)


func get_spawn_points() -> Array[Vector2i]:
	return config_manager.current_level.spawn_points


func is_debug_mode() -> bool:
	return DEBUG_MODE

func get_debugger() -> Debugger:
	return debugger if DEBUG_MODE else null
