extends Node2D

@onready var HeroPlacementManagerResource = preload("res://src/SetupPhase/hero_placement_manager.gd")
const HeroResource = preload("res://src/hero.gd")

var heroes = Node2D.new()
var tilemap_scene = preload("res://demo_tile_map.tscn")
var tilemap
var hero_placement_manager
@onready var canvas_layer = $CanvasLayer

func start_game():
	tilemap = tilemap_scene.instantiate()
	add_child(tilemap)
	add_child(heroes)

	init_setup_phase()

func init_setup_phase():
	get_tree().change_scene_to_file("res://demo_setup_phase.tscn")
	hero_placement_manager = HeroPlacementManagerResource.new()

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
	print("Finished setup, init round 1")
