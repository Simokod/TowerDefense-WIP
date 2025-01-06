extends Node

var occupied_tiles: Dictionary = {}

func register_entity_position(entity, tile_pos: Vector2i):
	for pos in occupied_tiles.keys():
		if occupied_tiles[pos] == entity:
			occupied_tiles.erase(pos)
	
	occupied_tiles[tile_pos] = entity

func unregister_entity(entity):
	for pos in occupied_tiles.keys():
		if occupied_tiles[pos] == entity:
			occupied_tiles.erase(pos)

func is_tile_occupied(tile_pos: Vector2i) -> bool:
	return tile_pos in occupied_tiles

func is_tile_occupied_by_enemy(tile_pos: Vector2i, excluding_enemy) -> bool:
	if tile_pos not in occupied_tiles:
		return false
	var entity = occupied_tiles[tile_pos]
	return entity != excluding_enemy and entity is BaseEnemy

func get_entity_at_tile(tile_pos: Vector2i):
	return occupied_tiles.get(tile_pos)

func get_all_entities_of_type(type: Variant) -> Array:
	return occupied_tiles.values().filter(func(entity): return is_instance_of(entity, type))
