extends Node2D

class_name EnemyManager

signal all_enemies_defeated
signal enemy_spawned_and_moved(enemy: BaseEnemy)

var active_enemies: Array = []
var enemy_layer: CanvasLayer

func _ready():
	enemy_layer = CanvasLayer.new()
	enemy_layer.layer = Layers.ENEMIES
	add_child(enemy_layer)

func start_wave(wave_config: WaveConfig):
	for group in wave_config.enemy_groups:
		print("Spawning group {group} of {count}".format({"group": group, "count": wave_config.enemy_groups.size()}))
		for i in range(group.count):
			print("Spawning enemy {i} of {count}".format({"i": i + 1, "count": group.count}))
			var enemy_scene: PackedScene = Constants.ENEMY_SCENES[group.enemy_type]
			var spawn_tile: Vector2i = GameManager.get_spawn_points()[group.spawn_point_id]
			var enemy: BaseEnemy = spawn_enemy(enemy_scene, spawn_tile)

			AnnouncementSystem.announce_turn_start(enemy.unit_name)
			await enemy.take_turn()
			enemy_spawned_and_moved.emit(enemy)

			await get_tree().create_timer(1).timeout # TODO Should change waiting mechanism?
			# if GameManager.is_debug_mode():
			# 	GameManager.get_debugger().clear_debug_paths()
			await get_tree().create_timer(0.5).timeout


func spawn_enemy(enemy_scene: PackedScene, spawn_tile: Vector2i) -> BaseEnemy:
	if not enemy_scene:
		push_error("Enemy scene not set in EnemyManager")
		return

	var enemy_instance: BaseEnemy = enemy_scene.instantiate()
	enemy_layer.add_child(enemy_instance)
	enemy_instance.set_tile_position(spawn_tile)
	
	active_enemies.append(enemy_instance)
	# TODO this should 'kill' the enemy, which in turn will free itself, rather then to have it done here
	enemy_instance.tree_exiting.connect(func(): _on_enemy_defeated(enemy_instance))
	print("spawned enemy", enemy_instance)
	return enemy_instance


func _on_enemy_defeated(enemy: BaseEnemy) -> void:
	active_enemies.erase(enemy)
	if active_enemies.is_empty():
		all_enemies_defeated.emit()
