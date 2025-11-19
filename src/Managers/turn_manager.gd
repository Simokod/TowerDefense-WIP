class_name TurnManager extends Node2D

signal turn_started(unit: BaseUnit)
signal turn_ended(unit: BaseUnit)
signal turn_order_changed(new_order: Array[TurnOrderDisplayUnit])

const INITIATIVE_BASE = 0.0
const INITIATIVE_MAX = 100.0

class ActiveUnit:
	var unit: BaseUnit
	var initiative_progress: float = 0.0
	
	func _init(unit_ref: BaseUnit):
		unit = unit_ref
	
	func accumulate_initiative(delta: float) -> bool:
		initiative_progress += unit.initiative * delta
		return initiative_progress >= INITIATIVE_MAX

var enemy_manager: EnemyManager

var turn_units: Array[ActiveUnit] = []
var current_unit: ActiveUnit
var is_paused: bool = false
var wave_started: bool = false

func _init(_enemy_manager: EnemyManager):
	enemy_manager = _enemy_manager
	enemy_manager.enemy_spawned.connect(register_unit)
	

func setup():
	GameManager.get_wave_manager().wave_started.connect(_on_wave_started)


func register_unit(unit: BaseUnit, spawn_initiative: float):
	var turn_unit = ActiveUnit.new(unit)
	turn_unit.initiative_progress = spawn_initiative
	turn_units.append(turn_unit)
	
	unit.initiative_progress.value = (spawn_initiative / INITIATIVE_MAX) * 100

	_update_turn_order()
	return turn_unit


func unregister_unit(unit: BaseUnit):
	print("Turn Manager: unregister_unit:", unit)
	for i in turn_units.size():
		if turn_units[i].unit == unit:
			turn_units.remove_at(i)
			break
	_update_turn_order()

func _on_wave_started():
	wave_started = true
	_update_turn_order()

func _process(delta: float):
	if !wave_started or is_paused or current_unit != null:
		return
		
	for turn_unit in turn_units:
		if turn_unit.accumulate_initiative(delta):
			await _start_unit_turn(turn_unit)
			break
		
		turn_unit.unit.initiative_progress.value = 100 - (turn_unit.initiative_progress / INITIATIVE_MAX) * 100
	

func _start_unit_turn(turn_unit: ActiveUnit):
	current_unit = turn_unit
	turn_started.emit(turn_unit.unit)
	print("Turn started for ", turn_unit.unit.unit_name)
	AnnouncementSystem.announce_turn_start(turn_unit.unit.unit_name)
	
	# Player turn is managed by the UI - maybe change it?
	if turn_unit.unit is BaseEnemy:
		await _process_enemy_turn(turn_unit)
		end_current_turn()

# Let the enemy AI take its turn
func _process_enemy_turn(turn_unit: ActiveUnit):
	await turn_unit.unit.take_turn()

func end_current_turn():
	if current_unit == null:
		return

	current_unit.initiative_progress = 0.0
	turn_ended.emit(current_unit.unit)
	current_unit = null
	_update_turn_order()

func _update_turn_order():
	var preview_order: Array[TurnOrderDisplayUnit] = []
	const TURNS_TO_SHOW = 10
	
	for turn_unit in turn_units:
		var current_initiative = turn_unit.initiative_progress
		var initiative_rate = turn_unit.unit.initiative
		
		var time_to_first_turn = (INITIATIVE_MAX - current_initiative) / initiative_rate
		preview_order.append(TurnOrderDisplayUnit.new(
			turn_unit.unit,
			time_to_first_turn,
			turn_unit.unit.unit_sprite
		))
		
		for i in range(1, TURNS_TO_SHOW):
			var time_to_turn = time_to_first_turn + (INITIATIVE_MAX * i) / initiative_rate
			preview_order.append(TurnOrderDisplayUnit.new(
				turn_unit.unit,
				time_to_turn,
				turn_unit.unit.unit_sprite
			))
	
	preview_order.sort_custom(func(a, b): return a.time_to_turn < b.time_to_turn)
	
	if preview_order.size() > TURNS_TO_SHOW:
		preview_order.resize(TURNS_TO_SHOW)
	
	turn_order_changed.emit(preview_order)

func pause():
	is_paused = true

func resume():
	is_paused = false
