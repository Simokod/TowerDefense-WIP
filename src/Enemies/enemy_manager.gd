extends Node2D

class_name EnemyManager

var enemy_scene
var enemy_to_spawn = "gemini_enemy"
var enemies: Array = []

func start_wave():
	# 1. spawn enemies
	#for enemy in enemy_to_spawn:
	enemy_scene = Constants.ENEMY_SCENES[enemy_to_spawn]
	var spawn_tile = Vector2i(0, 0)
	spawn_enemy(spawn_tile)
	# 2. move them
	# 3. end turn

func spawn_enemy(spawn_tile: Vector2i):
	if not enemy_scene:
		push_error("Enemy scene not set in EnemyManager")
		return

	var enemy_instance: GeminiEnemy = enemy_scene.instantiate()
	add_child(enemy_instance)
	enemy_instance._ready()
	enemy_instance.set_tile_position(spawn_tile)
	enemies.append(enemy_instance)
	print("spawned enemy", enemy_instance)
