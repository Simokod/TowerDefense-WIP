extends Node2D

class_name IEnemy

var base_speed: int
var tilemap = GameManager.get_tilemap()
var tile_size = tilemap.tile_set.tile_size
var move_tween: Tween
var tile_center_delta

func _ready():
	var texture_rect = $TextureRect
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.custom_minimum_size = tilemap.tile_set.tile_size * 0.9
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	tile_center_delta = Vector2(tilemap.tile_set.tile_size.x / 2.0, tilemap.tile_set.tile_size.y / 2.0)
	print("tile_center_delta", tile_center_delta)

func set_tile_position(tile_coords: Vector2i):
	var tile_center_position = (
		tilemap.map_to_local(tile_coords) -
		tile_center_delta
	)

	print("tile_position", tile_center_position)
	global_position = tile_center_position
	

func execute_turn(path: Array):
	var steps_taken = 0
	while steps_taken < base_speed and not path.is_empty():
		var next_tile = path.pop_front()
		move_to_adjacent_tile(next_tile)
		steps_taken += 1

func move_to_adjacent_tile(next_tile: Vector2i):
	var target_position = Vector2(next_tile * tile_size)
	
	if move_tween:
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_position, 0.3)
	
	global_position = next_tile
	await move_tween.finished

# Virtual method for enemy-specific behavior
func perform_action():
	pass # To be overridden by specific enemy types
