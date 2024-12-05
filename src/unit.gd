class_name Unit
extends Node2D

@export var initiative: float = 25.0 # How quickly unit gets turns
@export var movement_speed: int = 3 # How many tiles can move per turn
@export var max_health: int = 100

var id: int
var allowed_tiles: Array
var current_health: int
var sprite_node: Sprite2D
var texture: CompressedTexture2D:
	set(value):
		texture = value
		if sprite_node:
			sprite_node.texture = value

func _init():
	allowed_tiles = []

func _ready():
	current_health = max_health
	sprite_node = Sprite2D.new()
	add_child(sprite_node)

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	if current_health == 0:
		die()

func die():
  # TODO: Should it be handled here? maybe in the EnemyManager?
	queue_free()

# Virtual method to be implemented by Hero/Enemy
func take_turn():
	pass