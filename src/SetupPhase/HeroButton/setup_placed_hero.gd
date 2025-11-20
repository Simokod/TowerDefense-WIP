class_name SetupPlacedHero extends BaseHeroButton

var tile_pos: Vector2i

func setup(hero_data: BaseHero, _heroes_selection_ui: HeroesSelectionUI, tilemap: TileMapLayer) -> void:
	super.setup(hero_data, _heroes_selection_ui, tilemap)
	custom_minimum_size = tilemap.tile_set.tile_size * 0.9

func is_selection_button() -> bool:
	return false
