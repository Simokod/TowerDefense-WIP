extends Node2D

const HeroResource = preload("res://src/hero.gd")

var heroes = Node2D.new()
var tilemap_scene = preload("res://demo_tile_map.tscn")
var tilemap

var debug_draw_cells = [] ## DEBUG

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
	enemy_manager.start_wave()


func debug_path(cells_to_draw: Array):
	debug_draw_cells = cells_to_draw
	queue_redraw()

func _draw():
	for cell in debug_draw_cells:
		var pos = get_tilemap().map_to_local(cell)
		draw_circle(pos, 10, Color(1, 0, 0, 0.5))
