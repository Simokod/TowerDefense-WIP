extends Control

class_name HoveringHero

var tilemap: TileMap = null
var heroes_selection_ui: HeroesSelectionUI

var hero: BaseHero = null
var hero_sprite: TextureRect = null
var tile_center_delta: Vector2 = Vector2()

func setup(seleced_hero: BaseHero, _heroes_selection_ui: HeroesSelectionUI) -> void:
	tilemap = get_tree().get_root().get_node("Main").get_tilemap()

	hero = seleced_hero
	var texture_rect = TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.custom_minimum_size = tilemap.tile_set.tile_size * 0.9
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_sprite = texture_rect
	add_child(texture_rect)
	
	hero_sprite.texture = hero.sprite.texture
	tile_center_delta = Vector2(tilemap.tile_set.tile_size.x, tilemap.tile_set.tile_size.y) / 2

	heroes_selection_ui = _heroes_selection_ui

func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var tile_position: Vector2i = tilemap.local_to_map(mouse_position)

	var tile_center_position = (
		tilemap.map_to_local(tile_position) -
		tile_center_delta
	)

	global_position = tile_center_position
	
	if heroes_selection_ui.is_valid_hero_placement_position(hero, tile_position):
		hero_sprite.modulate = Color(0.7, 1, 0.7, 1) # Light green color
	else:
		hero_sprite.modulate = Color(1, 0.5, 0.5, 0.8) # Light red-transparent color
