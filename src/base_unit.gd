class_name BaseUnit extends Node2D

@export var unit_name: String
@export var initiative: float = 25.0
@export var movement_speed: int = 3
@export var max_health: int = 100
@export var allowed_tiles: Array[String]

var current_health: int
var unit_sprite: Texture2D

func _ready():
	current_health = max_health
	
	_init_sprite()


func _init_sprite():
	var sprite = $Sprite2D
	var tilemap = GameManager.get_tilemap()
	var target_size = tilemap.tile_set.tile_size * 0.9
	var texture_size = sprite.texture.get_size()
	
	var scale_factor = min(
		target_size.x / texture_size.x,
		target_size.y / texture_size.y
	)
	sprite.scale = Vector2(scale_factor, scale_factor)

	var collision_shape = $CollisionShape2D
	var sprite_radius = (target_size.x / 2)
	collision_shape.shape.radius = sprite_radius * 0.9

	unit_sprite = sprite.texture
	print("Done init sprite for ", unit_name)
	
func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	if current_health == 0:
		die()

func die():
  # TODO: Should it be handled here? maybe in the EnemyManager?
	queue_free()

# Virtual method to be implemented by BaseHero/Enemy
func take_turn():
	pass
