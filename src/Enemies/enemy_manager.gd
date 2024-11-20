extends Node2D

class_name EnemyManager

var enemy_to_spawn = "gemini_enemy" # TODO use level configuration to know which enemies to spawn on each wave
var count_enemies = 4
var enemies: Array = []

func start_wave(wave_config: WaveConfig, wave_number: int):
	print("Starting wave {wave_number} with {groups} groups".format({"wave_number": wave_number, "groups": wave_config.enemy_groups.size()}))
	for group in wave_config.enemy_groups:
		print("Spawning group {group}".format({"group": group}))
		# 1. spawn enemies
		for i in range(group.count):
			print("Spawning enemy {i} of {count}".format({"i": i + 1, "count": group.count}))
			var enemy_scene: PackedScene = Constants.ENEMY_SCENES[group.enemy_type]
			var spawn_tile: Vector2i = GameManager.get_spawn_points()[group.spawn_point_id]
			var ememy: BaseEnemy = spawn_enemy(enemy_scene, spawn_tile)
			
			# 2. move them
			print("Moving enemy")
			await ememy.execute_turn()
			print("Done moving")

			await get_tree().create_timer(1).timeout # TODO Should change waiting mechanism?
			if GameManager.is_debug_mode():
				GameManager.get_debugger().clear_debug_paths()
			await get_tree().create_timer(0.5).timeout
			# 3. end turn


func spawn_enemy(enemy_scene: PackedScene, spawn_tile: Vector2i) -> BaseEnemy:
	if not enemy_scene:
		push_error("Enemy scene not set in EnemyManager")
		return

	var enemy_instance: GeminiEnemy = enemy_scene.instantiate()
	add_child(enemy_instance)
	enemy_instance._ready()
	enemy_instance.set_tile_position(spawn_tile)
	enemies.append(enemy_instance)
	print("spawned enemy", enemy_instance)
	return enemy_instance
