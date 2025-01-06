class_name SetupPlacedHero extends BaseHeroButton

func setup(hero_data: BaseHero, _heroes_selection_ui: HeroesSelectionUI, tilemap: TileMap) -> void:
	super.setup(hero_data, _heroes_selection_ui, tilemap)
	custom_minimum_size = tilemap.tile_set.tile_size * 0.9

	# TODO: Placed heroes positiosn are off probably because I changed the hero's positions.
	# This is true both to the placed hero's sprite and the actual button itself.
	
	# var sprite = Sprite2D.new()
	# sprite.texture = hero.unit_sprite
	# var texture_size = sprite.texture.get_size()
	# var scale_factor = min(
	# 	custom_minimum_size.x / texture_size.x,
	# 	custom_minimum_size.y / texture_size.y
	# )
	# sprite.scale = Vector2(scale_factor, scale_factor)
	
	# add_child(sprite)
	# texture_normal = null

func is_selection_button() -> bool:
	return false
