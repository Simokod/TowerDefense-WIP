extends Node2D

const DebuggerResource = preload("res://src/Debugger/debugger.gd")

var DEBUG_MODE = OS.has_feature("editor")
var config_manager: ConfigManager
var turn_manager: TurnManager
var debugger: Debugger
var debug_layer: CanvasLayer
var placed_heroes = []

const HERO_SCENE_PATHS = {
	"Warrior": preload("res://scenes/Heroes/warrior_hero.tscn"),
	"Ranger": preload("res://scenes/Heroes/ranger_hero.tscn")
}

func initialize_game():
	if DEBUG_MODE:
		debugger = DebuggerResource.new()
		add_child(debugger)
		debugger.z_index = Layers.DEBUG

func get_available_heroes() -> Array[Hero]:
	var heroes: Array[Hero] = []
	
	for hero_name in HERO_SCENE_PATHS:
		var hero_instance = HERO_SCENE_PATHS[hero_name].instantiate() as Hero
		heroes.append(hero_instance)
	
	return heroes

func get_available_hero_count() -> int:
	return HERO_SCENE_PATHS.size()
	
func add_placed_hero(setup_hero: SetupPlacedHero) -> void:
	var tilemap = get_tree().get_root().get_node("Main").get_tilemap()
	var canvas_layer = get_tree().get_root().get_node("Main").get_node("CanvasLayer")
	
	var placed_hero = PlacedHero.new()
	placed_hero.setup(setup_hero.hero, tilemap)
	placed_hero.position = setup_hero.position
	
	canvas_layer.add_child(placed_hero)
	placed_heroes.append(placed_hero)


func start_gameplay():
	print("GameManager: Starting gameplay")
	var enemy_manager: EnemyManager = EnemyManager.new()
	add_child(enemy_manager)

	turn_manager = TurnManager.new(enemy_manager)
	add_child(turn_manager)

	var wave_manager = WaveManager.new(enemy_manager)
	add_child(wave_manager)

	var targeting_system = TargetingSystem.new()
	add_child(targeting_system)
	Ability.targeting_system = targeting_system

	config_manager = ConfigManager.new()
	var current_level = config_manager.load_level("demo")
	await wave_manager.initialize_waves(current_level.waves)
	
	for hero in placed_heroes:
		turn_manager.register_unit(hero.hero)


func get_spawn_points() -> Array[Vector2i]:
	return config_manager.current_level.spawn_points


func is_debug_mode() -> bool:
	return DEBUG_MODE

func get_debugger() -> Debugger:
	return debugger if DEBUG_MODE else null
