class_name TargetingSystem extends Node

signal targeting_completed(target)
signal targeting_cancelled

var _current_ability: Ability
var _current_hero: Hero
var _is_targeting: bool = false

var _current_highlighted_target: Node = null

func _ready():
	set_process_input(false)

func start_targeting(ability: Ability, hero: Hero):
	if _is_targeting:
		cancel_targeting()
	
	_current_ability = ability
	_current_hero = hero
	_is_targeting = true
	
	# var valid_tiles = _get_tiles_in_range(hero.position, ability.range)
	# _highlight_valid_tiles(valid_tiles)
	
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
	
	_cleanup_targeting()
	targeting_cancelled.emit()

func complete_targeting(target: Node):
	if not _is_targeting:
		return

	targeting_completed.emit(target)
	_cleanup_targeting()

func _cleanup_targeting():
	set_process_input(false)
	_is_targeting = false
	_current_ability = null
	_current_hero = null

func _start_none_target_mode():
	complete_targeting(null)


func _start_single_target_mode():
	set_process_input(true)
	set_process(true) # Enable _process for hover updates

func _start_multi_target_mode():
	pass

func _start_ground_target_mode():
	pass

func _is_valid_target(target: Node) -> bool:
	# var target_tile = _get_tile_position(target.global_position)
	# var hero_tile = _get_tile_position(_current_hero.global_position)
	
	# return target_tile.distance_to(hero_tile) <= _current_ability.range
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