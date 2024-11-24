extends Node
class_name WaveManager

signal wave_starting(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

var current_wave_number: int = 0
var waves: Array = []
var enemy_manager: EnemyManager

func _init(enemy_mgr: EnemyManager):
	enemy_manager = enemy_mgr
	enemy_manager.all_enemies_defeated.connect(_on_all_enemies_defeated)

func initialize_waves(level_waves: Array) -> void:
	waves = level_waves
	current_wave_number = 0
	start_next_wave()

func start_next_wave() -> void:
	if current_wave_number >= waves.size():
		all_waves_completed.emit()
		return
		
	current_wave_number += 1
	var wave = waves[current_wave_number - 1]
	spawn_wave(wave, current_wave_number)
	
	wave_starting.emit(current_wave_number)

func spawn_wave(wave_config: WaveConfig, wave_number: int) -> void:
	print("Starting wave {number}".format({"number": wave_number}))
	await AnnouncementSystem.announce_wave_start(wave_number)
	await enemy_manager.start_wave(wave_config)

	AnnouncementSystem.announce_turn_completed(wave_number)

func _on_all_enemies_defeated() -> void:
	print("Wave {number} completed".format({"number": current_wave_number}))
	wave_completed.emit(current_wave_number)

	if not is_instance_valid(get_tree()):
		return
		
	await get_tree().create_timer(2).timeout
	start_next_wave()
