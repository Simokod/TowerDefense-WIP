extends Node2D

class_name EnemyManager

var enemy_to_spawn = "gemini_enemy" # TODO use level configuration to know which enemies to spawn on each wave
var count_enemies = 3
var enemies: Array = []

func start_wave():
	# 1. spawn enemies
	for index in range(count_enemies):
		var enemy_scene: PackedScene = Constants.ENEMY_SCENES[enemy_to_spawn]
		var spawn_tile = Vector2i(0, 0)
		var ememy: BaseEnemy = spawn_enemy(enemy_scene, spawn_tile)
		# 2. move them
		print("Moving enemy")
		await ememy.execute_turn()
		print("Done moving")
		await get_tree().create_timer(1.0).timeout # Wait for 1 second
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
