class_name TurnManager extends Node2D

signal turn_started(unit: BaseUnit)
signal turn_ended(unit: BaseUnit)
signal turn_order_changed(new_order: Array[Dictionary])

const INITIATIVE_MAX = 100.0

class ActiveUnit:
	var unit: BaseUnit
	var initiative: float = 0.0
	
	func _init(unit_ref: BaseUnit):
		unit = unit_ref
	
	func accumulate_initiative(delta: float) -> bool:
		initiative += unit.initiative * delta
		return initiative >= INITIATIVE_MAX

var enemy_manager: EnemyManager

func _init(_enemy_manager: EnemyManager):
	enemy_manager = _enemy_manager
	enemy_manager.enemy_spawned_and_moved.connect(register_unit)

var turn_units: Array[ActiveUnit] = []
var current_unit: ActiveUnit
var is_paused: bool = false

func register_unit(unit: BaseUnit):
	var turn_unit = ActiveUnit.new(unit)
	turn_units.append(turn_unit)
	_update_turn_order()

func unregister_unit(unit: BaseUnit):
	for i in turn_units.size():
		if turn_units[i].unit == unit:
			turn_units.remove_at(i)
			break
	_update_turn_order()

func _process(delta: float):
	if is_paused or current_unit != null:
		return
		
	for turn_unit in turn_units:
		if turn_unit.accumulate_initiative(delta):
			await _start_unit_turn(turn_unit)
			break
	
	_update_turn_order()

func _start_unit_turn(turn_unit: ActiveUnit):
	current_unit = turn_unit
	turn_started.emit(turn_unit.unit)
	print("Turn started for ", turn_unit.unit.unit_name)
	AnnouncementSystem.announce_turn_start(turn_unit.unit.unit_name)
	
	if turn_unit.unit is BaseEnemy:
		await _process_enemy_turn(turn_unit)
		end_current_turn()

# Let the enemy AI take its turn
func _process_enemy_turn(turn_unit: ActiveUnit):
	await turn_unit.unit.take_turn()

func end_current_turn():
	if current_unit == null:
		return

	current_unit.initiative = 0.0
	turn_ended.emit(current_unit.unit)
	current_unit = null
	_update_turn_order()

# Calculate and emit the next few expected turns
func _update_turn_order():
	var preview_order = []
	for turn_unit in turn_units:
		var time_to_turn = (INITIATIVE_MAX - turn_unit.initiative) / turn_unit.unit.initiative
		preview_order.append({
			"unit": turn_unit.unit,
			"time": time_to_turn
		})
	
	preview_order.sort_custom(func(a, b): return a.time < b.time)
	turn_order_changed.emit(preview_order)

func pause():
	is_paused = true

func resume():
	is_paused = false