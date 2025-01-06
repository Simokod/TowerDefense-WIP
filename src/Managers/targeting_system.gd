class_name TargetingSystem extends Node2D

signal targeting_completed(ability, target)
signal targeting_cancelled(ability)

var _current_ability: Ability
var _current_hero: BaseHero
var _is_targeting: bool = false
var _current_highlighted_target: Node = null


func _ready():
	set_process_input(false)


func start_targeting(ability: Ability, hero: BaseHero):
	if _is_targeting:
		cancel_targeting()
	
	_current_ability = ability
	_current_hero = hero
	_is_targeting = true
	
	var tiles_in_range = _get_tiles_in_range(hero.position, ability.cast_range)
	print("hero position: ", hero.position)
	print("hero tile position: ", _get_tile_position(hero.position))
	print("ability cast range: ", ability.cast_range)
	print("tiles in range: ", tiles_in_range)
	_highlight_tiles(tiles_in_range)
	
	match ability.target_type:
		Ability.TargetType.NONE:
			_start_none_target_mode()
		Ability.TargetType.SINGLE:
			_start_single_target_mode()
		Ability.TargetType.MULTI:
			_start_multi_target_mode()
		Ability.TargetType.GROUND:
			_start_ground_target_mode()


func cancel_targeting():
	if not _is_targeting:
		return
	
	targeting_cancelled.emit(_current_ability)
	_cleanup_targeting()


func complete_targeting(target: Node):
	if not _is_targeting:
		return

	targeting_completed.emit(_current_ability, target)
	_current_ability.on_targeting_completed(target, _current_hero)
	_cleanup_targeting()


func _cleanup_targeting():
	set_process_input(false)
	_is_targeting = false
	_current_ability = null
	_current_hero = null


func _start_none_target_mode():
	complete_targeting(null)


func _start_single_target_mode():
	print("Starting single target mode for ", _current_ability.ability_name, " by ", _current_hero.unit_name)
	set_process_input(true)
	set_process(true)


func _start_multi_target_mode():
	pass


func _start_ground_target_mode():
	pass


func _is_valid_target(target: Node) -> bool:
	var target_tile = _get_tile_position(target.global_position)
	var hero_tile = _get_tile_position(_current_hero.global_position)

	var distance = _calc_distance(target_tile, hero_tile)
	return distance <= _current_ability.cast_range

func _calc_distance(entity_1: Vector2i, entity_2: Vector2i) -> int:
	var dx = entity_1.x - entity_2.x
	var dy = entity_1.y - entity_2.y
	return (abs(dx) + abs(dy) + abs(dx + dy)) / 2

func _process(_delta):
	if not _is_targeting:
		return
		
	var hovered_entity = _get_target_under_mouse()
	if hovered_entity and _is_valid_target(hovered_entity):
		_highlight_target(hovered_entity)
	else:
		_clear_target_highlight()


func _input(event: InputEvent):
	if not _is_targeting:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var target = _get_target_under_mouse()
			if target and _is_valid_target(target):
				complete_targeting(target)
				_clear_target_highlight()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_targeting()


func _get_target_under_mouse() -> Node:
	var mouse_pos = get_viewport().get_mouse_position()
	var global_mouse_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos

	var space = get_viewport().get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_mouse_pos
	query.collision_mask = 2
	query.collide_with_areas = true
	
	var results = space.intersect_point(query)
	if results.size() > 0:
		return results[0].collider
	return null


func _highlight_target(target: Node):
	if _current_highlighted_target and _current_highlighted_target != target:
			_clear_target_highlight()
	
	# Don't highlight again if already highlighted
	if _current_highlighted_target == target:
			return
	
	_current_highlighted_target = target

	target.modulate = Color(1.2, 1.2, 1.2, 1)
	
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _clear_target_highlight() -> void:
	if not _current_highlighted_target:
			return
	
	_current_highlighted_target.modulate = Color.WHITE
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	_current_highlighted_target = null

	
# TODO This is good for a square range, need to change for hex grid
func _get_tiles_in_range(center_pos: Vector2, range_value: int) -> Array:
	var tiles = []
	var center_tile = _get_tile_position(center_pos)
	
	for x in range(-range_value, range_value + 1):
		for y in range(-range_value, range_value + 1):
			var check_pos = Vector2i(center_tile.x + x, center_tile.y + y)
			if abs(x) + abs(y) <= range_value:
				tiles.append(check_pos)
	
	return tiles
	

func _highlight_tiles(tiles: Array) -> void:
	var tilemap = get_tree().get_root().get_node("Main").get_tilemap()
	
	# tilemap.clear_layer(1)
	
	for tile_pos in tiles:
		tilemap.set_cell(1, tile_pos, 0, Vector2i(0, 0))


func _get_tile_position(world_pos: Vector2) -> Vector2i:
	var tilemap = get_tree().get_root().get_node("Main").get_tilemap()
	return tilemap.local_to_map(world_pos)
