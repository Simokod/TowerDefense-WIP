extends Node2D

class_name PlacedHero

var hero: BaseHero
var texture_rect: TextureRect

func setup(hero_data: BaseHero, tilemap: TileMap) -> void:
	hero = hero_data
	
	texture_rect = TextureRect.new()
	texture_rect.texture = hero.sprite.texture
	texture_rect.custom_minimum_size = tilemap.tile_set.tile_size * 0.9
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.ignore_texture_size = true
	
	add_child(texture_rect)
