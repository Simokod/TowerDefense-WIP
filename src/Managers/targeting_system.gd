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
	
	_highlight_valid_tiles(_current_hero.tile_pos, ability.cast_range)
	
	match ability.target_type:
		Ability.TargetType.NONE:
			_start_none_target_mode()
		Ability.TargetType.SINGLE:
			_start_single_target_mode()
		Ability.TargetType.MULTI:
			_start_multi_target_mode()
		Ability.TargetType.GROUND:
			_start_ground_target_mode()


func _highlight_valid_tiles(hero_pos: Vector2i, ability_range: int):
	var tiles: Array[Vector2i] = []
	for q in range(-ability_range, ability_range + 1):
		for r in range(max(-ability_range, -q - ability_range), min(ability_range, -q + ability_range) + 1):
			var hex = Vector2i(
				hero_pos.x + q,
				hero_pos.y + r + floor((q + (hero_pos.x & 1)) / 2.0)
			)
			tiles.append(hex)
	
	
	GameManager.get_debugger().debug_path(tiles, [])


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
	_clear_target_highlight()
	GameManager.get_debugger().clear_debug_paths()

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


func _calc_hex_distance(from: Vector2i, to: Vector2i) -> int:
	# Convert from offset coordinates to cube coordinates
	var from_x = from.x
	var from_z = from.y - floor((from.x - (from.x & 1)) / 2.0)
	var from_y = -from_x - from_z
	
	var to_x = to.x
	var to_z = to.y - floor((to.x - (to.x & 1)) / 2.0)
	var to_y = -to_x - to_z
	
	# Calculate the distance using cube coordinates
	var distance = (abs(from_x - to_x) + abs(from_y - to_y) + abs(from_z - to_z)) / 2
	
	return int(distance)


func _is_valid_target(target: Node) -> bool:
	# TODO: Also need to check range for non-unit targets, implement when implementing ground targeting
	if target is BaseUnit:
		if not _is_target_in_range(target):
			return false

	if _current_ability.self_target and target == _current_hero:
		return true
	
	if ((_current_ability.target_team == Ability.TargetTeam.ENEMY or
			_current_ability.target_team == Ability.TargetTeam.ALL) and
			target is BaseEnemy):
		return true
	
	if ((_current_ability.target_team == Ability.TargetTeam.FRIENDLY or
			_current_ability.target_team == Ability.TargetTeam.ALL) and
			target is BaseHero):
		return true
	
	return false

func _is_target_in_range(target: Node) -> bool:
	if target is BaseUnit:
		var distance = _calc_hex_distance(_current_hero.tile_pos, target.tile_pos)
		if distance > _current_ability.cast_range:
			return false
	return true
	

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
