class_name BaseEnemy extends BaseUnit

const MOVEMENT_ANIMATION_DURATION = 0.3

var astar = AStar2D.new()
var valid_destination_cells: Array[Vector2i] = []

var move_tween: Tween
var current_tile_position
var debug_draw_cells = []
var debug_walbkable_cells = []

func _ready():
	super._ready()
	z_index = Layers.ENEMIES

	var sprite = $Sprite2D
	var target_size = tilemap.tile_set.tile_size * 0.9
	var texture_size = sprite.texture.get_size()
	
	# Calculate scale to fit the target size while maintaining aspect ratio
	var scale_factor = min(
		target_size.x / texture_size.x,
		target_size.y / texture_size.y
	)
	sprite.scale = Vector2(scale_factor, scale_factor)

	var collision_shape = $CollisionShape2D
	var sprite_radius = (target_size.x / 2)
	collision_shape.shape.radius = sprite_radius * 0.9

func set_tile_position(tile_coords: Vector2i):
	var tile_center_position = tilemap.map_to_local(tile_coords)

	global_position = tile_center_position
	current_tile_position = tile_coords
	print("Initiallized enemy, global_pos: {global_pos}, tile: {tile}".format({"global_pos": global_position, "tile": tile_coords}))


func calculate_path() -> Array:
	astar.clear()
	valid_destination_cells.clear()
	
	var cells: Array[Vector2i] = tilemap.get_used_cells(0)
	var walkable_cells: Array[Vector2i] = []
	
	# Find all walkable cells
	for cell in cells:
		var tile_data = tilemap.get_cell_tile_data(0, cell)
		if is_walkable_tile(tile_data):
			astar.add_point(get_point_id(cell), Vector2(cell.x, cell.y))
			walkable_cells.append(cell)

			if !TileOccupancyManager.is_tile_occupied_by_enemy(cell, self):
				valid_destination_cells.append(cell)

	
	# Connect ALL neighboring walkable tiles
	for cell in walkable_cells:
		for neighbor in get_hex_neighbors(cell):
			var neighbor_tile_data = tilemap.get_cell_tile_data(0, neighbor)
			# Check if it's a road, but don't check if it's occupied
			if neighbor_tile_data and is_walkable_tile(neighbor_tile_data):
				var cell_id = get_point_id(cell)
				var neighbor_id = get_point_id(neighbor)
				if !astar.are_points_connected(cell_id, neighbor_id):
					astar.connect_points(cell_id, neighbor_id)
				
				debug_walbkable_cells.append(cell) # DEBUG
				
	
	var target_pos = find_nearest_target()
	
	var full_path_ids: PackedVector2Array = astar.get_point_path(get_point_id(current_tile_position), get_point_id(target_pos))
	var full_path = Array(full_path_ids).map(func(point): return Vector2i(point.x, point.y))

	if full_path.size() > 0 and full_path.front() == current_tile_position:
		full_path.pop_front()

	# Get the position we'd reach this turn
	var steps_possible = min(movement_speed, full_path.size())
	var turn_end_pos = full_path[steps_possible - 1] if steps_possible > 0 else current_tile_position
		
	# If the end position for this turn would be occupied, find a new path
	if TileOccupancyManager.is_tile_occupied_by_enemy(turn_end_pos, self):
		# Find nearest unoccupied tile that's within our movement range
		var alternative_end = find_nearest_accessible_tile(target_pos, steps_possible)
		if alternative_end != current_tile_position:
			full_path_ids = astar.get_point_path(
				get_point_id(current_tile_position),
				get_point_id(alternative_end)
			)
			full_path = Array(full_path_ids).map(func(point): return Vector2i(point.x, point.y))
			if full_path.size() > 0 and full_path.front() == current_tile_position:
				full_path.pop_front()
	
	for cell in full_path:
		debug_draw_cells.append(cell) # DEBUG - can also use for physicist
	
	# if GameManager.is_debug_mode():
	# 	GameManager.get_debugger().debug_path(debug_draw_cells, debug_walbkable_cells)
		
	return full_path


func find_nearest_accessible_tile(target: Vector2i, max_steps: int) -> Vector2i:
	var distances_from_start = calculate_distances_from_point(current_tile_position)
	var distances_to_target = calculate_distances_from_point(target)
	
	var nearest_distance = INF
	var best_tile = current_tile_position
	var best_steps_used = 0 # Track how many steps the best option uses

	for cell in valid_destination_cells:
		# Check if we can reach this cell within our movement range
		var steps_to_cell = distances_from_start.get(get_point_id(cell), INF)
		if steps_to_cell <= max_steps:
			# Get the pre-calculated distance from this cell to target
			var distance_to_target = distances_to_target.get(get_point_id(cell), INF)
			if distance_to_target < nearest_distance or \
			   (distance_to_target == nearest_distance and steps_to_cell > best_steps_used):
				nearest_distance = distance_to_target
				best_tile = cell
				best_steps_used = steps_to_cell
				
	return best_tile

func calculate_distances_from_point(point: Vector2i) -> Dictionary:
	var distances = {}
	var points_to_process = [get_point_id(point)]
	distances[get_point_id(point)] = 0
	
	while points_to_process.size() > 0:
		var current = points_to_process.pop_front()
		var current_distance = distances[current]
		
		for connection in astar.get_point_connections(current):
			if not distances.has(connection) or distances[connection] > current_distance + 1:
				distances[connection] = current_distance + 1
				points_to_process.append(connection)
	
	return distances

func is_walkable_tile(tile_data: TileData) -> bool:
	return tile_data.get_custom_data("tile_type") == Tiles.TILE_TYPES["ROAD"]

func get_point_id(point: Vector2i) -> int:
	var bounds = tilemap.get_used_rect()
	return point.x + bounds.size.x * point.y

func get_hex_neighbors(cell: Vector2i) -> Array[Vector2i]:
	if cell.x % 2 == 0:
		return [
			Vector2i(cell.x, cell.y - 1), # North
			Vector2i(cell.x + 1, cell.y - 1), # Northeast
			Vector2i(cell.x + 1, cell.y), # Southeast
			Vector2i(cell.x, cell.y + 1), # South
			Vector2i(cell.x - 1, cell.y), # Southwest
			Vector2i(cell.x - 1, cell.y - 1), # Northwest
		]
	else:
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

	
func take_turn():
	var path = calculate_path()
	var steps_taken = 0
	var steps_possible = min(movement_speed, path.size())
	while steps_taken < steps_possible:
		var next_tile = path.pop_front()
		await move_to_adjacent_tile(next_tile)
		steps_taken += 1

func move_to_adjacent_tile(next_tile: Vector2i):
	var target_position = tilemap.map_to_local(next_tile)
	
	if move_tween:
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_position, MOVEMENT_ANIMATION_DURATION)
	await move_tween.finished
	
	current_tile_position = next_tile
	tile_pos = current_tile_position
	TileOccupancyManager.register_entity_position(self, current_tile_position)

# Virtual method for enemy-specific behavior
func perform_action():
	pass
