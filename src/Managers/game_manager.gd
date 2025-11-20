extends Node2D

const DebuggerResource = preload("res://src/Debugger/debugger.gd")

var DEBUG_MODE = OS.has_feature("editor")
var config_manager: ConfigManager
var turn_manager: TurnManager
var debugger: Debugger
var debug_layer: CanvasLayer
var placed_heroes: Array[BaseHero] = []
var available_heroes: Array[BaseHero] = []

var wave_manager: WaveManager

const HERO_SCENE_PATHS = {
	"Warrior": preload("res://scenes/Units/Heroes/warrior_hero.tscn"),
	"Ranger": preload("res://scenes/Units/Heroes/ranger_hero.tscn"),
}

func initialize_game():
	if DEBUG_MODE:
		debugger = DebuggerResource.new()
		add_child(debugger)
		debugger.z_index = Layers.DEBUG
	
	for hero_name in HERO_SCENE_PATHS:
		var hero_instance: BaseHero = HERO_SCENE_PATHS[hero_name].instantiate() as BaseHero
		add_child(hero_instance)
		hero_instance.visible = false
		available_heroes.append(hero_instance)

func get_available_heroes() -> Array[BaseHero]:
	return available_heroes

func get_available_heroes_count() -> int:
	return HERO_SCENE_PATHS.size()

func add_placed_hero(setup_hero: SetupPlacedHero) -> void:
	var main = get_tree().get_root().get_node("Main")
	
	var hero_index = available_heroes.find(setup_hero.hero)
	var hero_instance: BaseHero = available_heroes[hero_index]
	available_heroes.remove_at(hero_index)
	
	# TODO: This seems like they only way I could fix the position. 
	# I think this is because both the hovering hero and the placed hero button are textures, 
	# while the heroes use sprites. This causes the positioning to be different.
	# TODO: This still isnt perfect, as once the setup is finished, you see the texture turning to sprite moving a little.
	var tilemap = get_tilemap()
	hero_instance.position = setup_hero.position + Vector2(tilemap.tile_set.tile_size / 2)
	hero_instance.tile_pos = setup_hero.tile_pos

	main.add_child(hero_instance)
	hero_instance.visible = true
	placed_heroes.append(hero_instance)


func setup_gameplay():
	print("GameManager: Setup gameplay")
	var enemy_manager: EnemyManager = EnemyManager.new()
	add_child(enemy_manager)

	turn_manager = TurnManager.new(enemy_manager)
	add_child(turn_manager)

	wave_manager = WaveManager.new(enemy_manager)
	add_child(wave_manager)

	var targeting_system = TargetingSystem.new()
	add_child(targeting_system)
	Ability.targeting_system = targeting_system

	config_manager = ConfigManager.new()

	# SETUPS
	turn_manager.setup()

	for hero in placed_heroes:
		turn_manager.register_unit(hero, TurnManager.INITIATIVE_BASE)

func start_gameplay():
	var current_level = config_manager.load_level("demo")
	await wave_manager.initialize_waves(current_level.waves)


func get_spawn_points() -> Array[Vector2i]:
	return config_manager.current_level.spawn_points


func is_debug_mode() -> bool:
	return DEBUG_MODE

func get_debugger() -> Debugger:
	return debugger if DEBUG_MODE else null

func get_tilemap() -> TileMapLayer:
	return get_tree().get_root().get_node("Main").get_tilemap()

func get_wave_manager() -> WaveManager:
	return wave_manager
