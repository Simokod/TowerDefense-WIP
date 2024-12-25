class_name TargetingSystem extends Node

signal targeting_completed(target)
signal targeting_cancelled

var _current_ability: Ability
var _current_hero: Hero
var _is_targeting: bool = false

func _ready():
	set_process_input(false)

func start_targeting(ability: Ability, hero: Hero):
	if _is_targeting:
		cancel_targeting()
	
	_current_ability = ability
	_current_hero = hero
	_is_targeting = true
	
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

func _cleanup_targeting():
	set_process_input(false)
	_is_targeting = false
	_current_ability = null
	_current_hero = null

func _start_none_target_mode():
	targeting_completed.emit(null)
	_cleanup_targeting()


func _start_single_target_mode():
	print("Targeting system: Starting single target mode, waiting for input")
	set_process_input(true)

func _input(event: InputEvent):
	if not _is_targeting:
		return
	
		
	if event is InputEventMouseButton:
		print("Targeting system: Input event: ", event)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Try to get target under mouse
			var target = _get_target_under_mouse()
			print("Targeting system: Target under mouse: ", target)
			if target:
				targeting_completed.emit(target)
				_cleanup_targeting()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_targeting()

# TODO: this isnt working, debug7
func _get_target_under_mouse() -> Node:
	var mouse_pos = get_viewport().get_mouse_position()
	var space = get_viewport().get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(mouse_pos, mouse_pos)
	var result = space.intersect_ray(query)
	print("Targeting system: Result: ", result)
	
	if result and result.collider:
		return result.collider
	return null

func _start_multi_target_mode():
	pass

func _start_ground_target_mode():
	pass
