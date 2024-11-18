extends Node2D

const HeroResource = preload("res://src/hero.gd")

var heroes = Node2D.new()
var tilemap_scene = preload("res://demo_tile_map.tscn")
var tilemap

var debug_draw_cells = [] ## DEBUG
var debug_walkable_cells = []

var config_manager: ConfigManager

func start_game():
	tilemap = tilemap_scene.instantiate()
	add_child(tilemap)
	add_child(heroes)

	init_setup_phase()

func init_setup_phase():
	get_tree().change_scene_to_file("res://demo_setup_phase.tscn")

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
	return heroes.get_child_count()

func add_hero_portrait(hero_portrait: HeroPortrait) -> void:
	heroes.add_child(hero_portrait)

func free_hero_portrait(hero: Hero) -> void:
	for node in heroes.get_children():
		if node.hero == hero:
			node.queue_free()
			print("Hero {hero_name} removed".format({"hero_name": hero.name}))
			break

func get_tilemap() -> TileMap:
	return tilemap.get_child(0)

func finish_setup():
	print("Finished setup, init demo level scene")
	get_tree().change_scene_to_file("res://demo_level.tscn")

	var enemy_manager: EnemyManager = EnemyManager.new()
	add_child(enemy_manager)

	config_manager = ConfigManager.new()
	var current_level = config_manager.load_level("demo")
	var wave_number = 1

	# TODO this should not be a loop, but a signal from the enemy/game/loop manager
	for wave in current_level.waves:
		await enemy_manager.start_wave(wave, wave_number)
		wave_number += 1
		print("Done wave {wave_number}".format({"wave_number": wave_number}))
		await get_tree().create_timer(2).timeout


func get_spawn_points() -> Array[Vector2]:
	return config_manager.current_level.spawn_points


### Move to DEBUG MANAGER THINGY
func debug_path(_debug_draw_cells: Array, _debug_walkable_cells: Array):
	debug_draw_cells = _debug_draw_cells
	debug_walkable_cells = _debug_walkable_cells
	queue_redraw()

func clear_debug_paths():
	debug_draw_cells.clear()
	debug_walkable_cells.clear()
	queue_redraw()

func _draw():
	for cell in debug_draw_cells:
		var pos = get_tilemap().map_to_local(cell)
		draw_circle(pos, 10, Color(1, 0, 0, 1))

	for cell in debug_walkable_cells:
		var pos = get_tilemap().map_to_local(cell)
		var size = 10
		var points = PackedVector2Array([
			pos + Vector2(0, -2 * size), # top point
			pos + Vector2(-size, -3 * size), # bottom left
			pos + Vector2(size, -3 * size) # bottom right
		])
		draw_colored_polygon(points, Color(0, 1, 0, 1))
