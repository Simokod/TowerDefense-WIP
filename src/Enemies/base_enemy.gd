extends Node2D

class_name BaseEnemy
const MOVEMENT_ANIMATION_DURATION = 0.3

@export var base_speed: int
@export var base_health: int

var tilemap = GameManager.get_tilemap()
var tile_center_delta = Vector2(tilemap.tile_set.tile_size.x / 2.0, tilemap.tile_set.tile_size.y / 2.0)

var astar = AStar2D.new()
var valid_destination_cells: Array[Vector2i] = []

var move_tween: Tween
var current_tile_position
var debug_draw_cells = []

func _ready():
	var texture_rect = $TextureRect
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.custom_minimum_size = tilemap.tile_set.tile_size * 0.9


func set_tile_position(tile_coords: Vector2i):
	var tile_center_position = (
		tilemap.map_to_local(tile_coords) -
		tile_center_delta
	)

	print("yo: {tile_pos}".format({"tile_pos": tilemap.map_to_local(tile_coords)}))
	global_position = tile_center_position
	# global_position = tilemap.map_to_local(tile_coords)
	current_tile_position = tile_coords
	print("Initiallized enemy, global_pos: {global_pos}, tile: {tile}".format({"global_pos": global_position, "tile": tile_coords}))


func calculate_path() -> Array:
	astar.clear()
	valid_destination_cells.clear()
	
	var used_cells: Array[Vector2i] = tilemap.get_used_cells(0)
	
	# Find walkable cells (empty tiles)
	for cell in used_cells:
		var tile_data = tilemap.get_cell_tile_data(0, cell)
		# Don't add points for tiles occupied by other enemies
		# This prevents pathfinding from considering these as valid end points
		# but we can still pass through them during movement
		if is_walkable_tile(tile_data) and !TileOccupancyManager.is_tile_occupied_by_enemy(cell, self):
			valid_destination_cells.append(cell)
			astar.add_point(get_point_id(cell), Vector2(cell.x, cell.y))

			tile_data.modulate = Color(0, 0, 1, 0.3) # DEBUG - can also use for physicist
	
	# Connect ALL neighboring road tiles, even occupied ones
	# This allows passing through occupied tiles

	# TODO bug here I think, because the 2 first enemies cut off the path, the 3rd enemy is stuck and doesn't get as close as it can.
	for cell in valid_destination_cells:
		for neighbor in get_hex_neighbors(cell):
			var neighbor_tile_data = tilemap.get_cell_tile_data(0, neighbor)
			# Check if it's a road, but don't check if it's occupied
			if neighbor_tile_data and is_walkable_tile(neighbor_tile_data):
				var cell_id = get_point_id(cell)
				var neighbor_id = get_point_id(neighbor)
				if !astar.are_points_connected(cell_id, neighbor_id):
					astar.connect_points(cell_id, neighbor_id)
	
	var target_pos = find_nearest_target()
	
	var path_ids: PackedVector2Array = astar.get_point_path(get_point_id(current_tile_position), get_point_id(target_pos))
	var path = Array(path_ids).map(func(point): return Vector2i(point.x, point.y))

	if path.size() > 0 and path.front() == current_tile_position:
		path.pop_front()

	
	for cell in path:
		debug_draw_cells.append(cell) # DEBUG - can also use for physicist
	
	GameManager.debug_path(debug_draw_cells)
	return path


func is_walkable_tile(tile_data: TileData) -> bool:
	return tile_data.get_custom_data("tile_type") == Constants.TILE_TYPES.ROAD

# Convert 2D coordinates to unique identifier
func get_point_id(point: Vector2i) -> int:
	var bounds = tilemap.get_used_rect()
	return point.x + bounds.size.x * point.y

# Offset coordinates for flat-top hexagonal grid
func get_hex_neighbors(cell: Vector2i) -> Array[Vector2i]:
	if cell.x % 2 == 0: # Even col
		return [
			Vector2i(cell.x, cell.y - 1), # North
			Vector2i(cell.x + 1, cell.y - 1), # Northeast
			Vector2i(cell.x + 1, cell.y), # Southeast
			Vector2i(cell.x, cell.y + 1), # South
			Vector2i(cell.x - 1, cell.y), # Southwest
			Vector2i(cell.x - 1, cell.y - 1), # Northwest
		]
	else: # Odd col
		return [
			Vector2i(cell.x, cell.y - 1), # North
			Vector2i(cell.x + 1, cell.y), # Northeast
			Vector2i(cell.x + 1, cell.y + 1), # Southeast
			Vector2i(cell.x, cell.y + 1), # South
			Vector2i(cell.x - 1, cell.y + 1), # Southwest
			Vector2i(cell.x - 1, cell.y), # Northwest
		]


func find_nearest_target():
	return Vector2i(23, 7) # Placeholder target

	
func execute_turn():
	var path = calculate_path()
	var steps_taken = 0
	var steps_possible = min(base_speed, path.size())
	while steps_taken < steps_possible:
		var next_tile = path.pop_front()
		print("Taking step, next tile: {next_tile}".format({"next_tile": next_tile}))
		await move_to_adjacent_tile(next_tile)
		steps_taken += 1

func move_to_adjacent_tile(next_tile: Vector2i):
	var target_position = tilemap.map_to_local(next_tile) - tile_center_delta
	
	if move_tween:
		move_tween.kill()
	
	print("Tweening to: {pos}".format({"pos": target_position}))
	print("cur global: {glo_pos}, cur tile: {cur_pos}".format({"glo_pos": global_position, "cur_pos": current_tile_position}))
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_position, MOVEMENT_ANIMATION_DURATION)
	await move_tween.finished
	
	current_tile_position = next_tile
	TileOccupancyManager.register_entity_position(self, current_tile_position)

# Virtual method for enemy-specific behavior
func perform_action():
	pass # To be overridden by specific enemy types
