extends Control

const HeroPortraitResource = preload("res://HeroPortrait.tscn")

@onready var heroes_selection_ui = get_node("/root/DemoSetupPhase/CanvasLayer/HeroesSelectionUI")

var hero_locations: Dictionary = {}
var object_locations: Dictionary
var tilemap

func _init():
	tilemap = GameManager.get_tilemap()


func setup(_object_locations: Dictionary = {}):
	object_locations = _object_locations


func is_valid_hero_placement_position(selected_hero: Hero, tile_pos: Vector2i, debug = false) -> bool:
	var is_allowed_tile = _is_allowed_tile(selected_hero, tile_pos)
	var is_empty_tile = _is_empty_tile(tile_pos)
	
	if debug:
		print("is_allowed_tile: ", is_allowed_tile)
		print("is_empty_tile: ", is_empty_tile)

	return is_allowed_tile and is_empty_tile

func _is_allowed_tile(hero: Hero, tile_pos: Vector2i) -> bool:
	var chosen_tile = tilemap.get_cell_tile_data(0, tile_pos)
	if not chosen_tile: return false

	var chosen_tile_type = chosen_tile.get_custom_data("tile_type")
	return chosen_tile_type in hero.allowed_tiles


func _is_empty_tile(tile_pos: Vector2i) -> bool:
	return tile_pos not in hero_locations.values() and tile_pos not in object_locations.values()


func place_hero(hero: Hero, tile_position: Vector2i) -> bool:
	var is_valid_pos = is_valid_hero_placement_position(hero, tile_position, true)
	if not is_valid_pos:
		_handle_invalid_placement(hero, tile_position)
		return false
	
	hero_locations[hero.id] = tile_position
	print("Hero {hero_name} placed at {tile_pos}".format({"hero_name": hero.name, "tile_pos": tile_position}))

	var hero_portrait: HeroPortrait = HeroPortraitResource.instantiate()
	hero_portrait.setup(hero, heroes_selection_ui)
	hero_portrait.set_to_tile_size()

	var tile_center_delta = tilemap.tile_set.tile_size / 2.0
	hero_portrait.position = tilemap.map_to_local(tile_position) - tile_center_delta

	GameManager.add_hero_portrait(hero_portrait)
	return true

func remove_hero(hero: Hero) -> void:
	hero_locations.erase(hero.id)
	GameManager.free_hero_portrait(hero)


func _handle_invalid_placement(hero: Hero, tile_position: Vector2i):
	print("Can't place hero {hero_name} at {tile_pos}".format({"hero_name": hero.name, "tile_pos": tile_position}))
