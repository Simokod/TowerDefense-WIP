extends Node2D

const DebuggerResource = preload("res://src/Debugger/debugger.gd")

var DEBUG_MODE = OS.has_feature("editor")
var config_manager: ConfigManager
var turn_manager: TurnManager
var debugger: Debugger
var debug_layer: CanvasLayer
var placed_heroes: Array[Hero] = []
var available_heroes: Array[Hero] = []

const HERO_SCENE_PATHS = {
	"Warrior": preload("res://scenes/Heroes/warrior_hero.tscn"),
	"Ranger": preload("res://scenes/Heroes/ranger_hero.tscn")
}

func initialize_game():
	if DEBUG_MODE:
		debugger = DebuggerResource.new()
		add_child(debugger)
		debugger.z_index = Layers.DEBUG
	
	for hero_name in HERO_SCENE_PATHS:
		var hero_instance = HERO_SCENE_PATHS[hero_name].instantiate() as Hero
		available_heroes.append(hero_instance)

func get_available_heroes() -> Array[Hero]:
	return available_heroes

func get_available_heroes_count() -> int:
	return HERO_SCENE_PATHS.size()

func add_placed_hero(setup_hero: SetupPlacedHero) -> void:
	var main = get_tree().get_root().get_node("Main")
	
	var hero_index = available_heroes.find(setup_hero.hero)
	var hero_instance: Hero = available_heroes[hero_index]
	available_heroes.remove_at(hero_index)
	
	hero_instance.position = setup_hero.position
	hero_instance.z_index = Layers.HEROES
		
	var sprite = Sprite2D.new()
	sprite.texture = hero_instance.sprite
	var target_size = main.get_tilemap().tile_set.tile_size * 0.9
	var texture_size = sprite.texture.get_size()

	var scale_factor = min(
		target_size.x / texture_size.x,
		target_size.y / texture_size.y
	)
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.centered = false
	hero_instance.add_child(sprite)

	main.add_child(hero_instance)
	placed_heroes.append(hero_instance)


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
		turn_manager.register_unit(hero)


func get_spawn_points() -> Array[Vector2i]:
	return config_manager.current_level.spawn_points


func is_debug_mode() -> bool:
	return DEBUG_MODE

func get_debugger() -> Debugger:
	return debugger if DEBUG_MODE else null
