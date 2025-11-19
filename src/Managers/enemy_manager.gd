extends Node2D

class_name EnemyManager

signal all_enemies_defeated
signal enemy_spawned(enemy: BaseEnemy, spawn_initiative: float)

var active_enemies: Array = []

func _ready():
	# Enable Y-sort on the root node
	y_sort_enabled = true

func spawn_wave(wave_config: WaveConfig):
	for group in wave_config.enemy_groups:
		print("Spawning group ", group, " of ", wave_config.enemy_groups.size())
		for i in range(group.count):
			print("Spawning enemy ", i + 1, " of ", group.count)
			var enemy_scene: PackedScene = Enemies.ENEMY_SCENES[group.enemy_type]
			var spawn_tile: Vector2i = GameManager.get_spawn_points()[group.spawn_point_id]
			var enemy: BaseEnemy = spawn_enemy(enemy_scene, spawn_tile)

			enemy_spawned.emit(enemy, TurnManager.INITIATIVE_MAX)
	print("All enemies spawned")


func spawn_enemy(enemy_scene: PackedScene, spawn_tile: Vector2i) -> BaseEnemy:
	if not enemy_scene:
		push_error("Enemy scene not set in EnemyManager")
		return

	var enemy_instance: BaseEnemy = enemy_scene.instantiate()
	add_child(enemy_instance)
	enemy_instance.set_tile_position(spawn_tile)
	
	active_enemies.append(enemy_instance)
	print("spawned enemy", enemy_instance)

	enemy_instance.tree_exiting.connect(func(): _on_enemy_defeated(enemy_instance))
	return enemy_instance


func _on_enemy_defeated(enemy: BaseEnemy) -> void:
	print("Enemy manager: Enemy ", enemy.unit_name, " has died")
	_unregister_enemy(enemy)
	if active_enemies.is_empty():
		all_enemies_defeated.emit()
		print("Enemy manager: All enemies have died")

func _unregister_enemy(enemy: BaseEnemy) -> void:
	TileOccupancyManager.unregister_entity(enemy)
	GameManager.turn_manager.unregister_unit(enemy)
	active_enemies.erase(enemy)
