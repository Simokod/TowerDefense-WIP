extends Node2D

class_name BaseUnit

@export var unit_name: String
@export var initiative: float = 25.0
@export var movement_speed: int = 3
@export var max_health: int = 100
@export var allowed_tiles: Array[String]

var tilemap: TileMap = null
var sprite: Sprite2D
var current_health: int

func _init():
	allowed_tiles = []
	current_health = max_health


func initialize_sprite():
	# tilemap = get_tree().get_root().get_node("Main").get_tilemap()
	sprite = $Area2D/Sprite2D
	# var target_size = tilemap.tile_set.tile_size * 0.9
	# var texture_size = sprite.texture.get_size()
	
	# var scale_factor = min(
	# 	target_size.x / texture_size.x,
	# 	target_size.y / texture_size.y
	# )
	# sprite.scale = Vector2(scale_factor, scale_factor)

	# var collision_shape = $Area2D/CollisionShape2D
	# var sprite_radius = (target_size.x / 2)
	# collision_shape.shape.radius = sprite_radius * 0.9

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	if current_health == 0:
		die()

func die():
  # TODO: Should it be handled here? maybe in the EnemyManager?
	queue_free()

func take_turn():
	pass
