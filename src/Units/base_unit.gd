class_name BaseUnit extends Node2D

@export var unit_name: String
@export var initiative: float = 25.0
@export var movement_speed: int = 3
@export var max_health: int = 100
@export var allowed_tiles: Array[String]
@onready var initiative_progress: TextureProgressBar = $InitiativeProgress
@onready var health_bar: HealthBarUI = $HealthBar

var current_health: int
var unit_sprite: Texture2D
var tile_pos: Vector2i
var tilemap: TileMapLayer


func _ready():
	current_health = max_health
	tilemap = GameManager.get_tilemap()
	_init_sprite()
	_init_progress_bar()
	if health_bar:
		health_bar.setup(tilemap.tile_set.tile_size, max_health, current_health)


func _init_sprite():
	var sprite = $Sprite2D
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


func _init_progress_bar():
	var target_size = tilemap.tile_set.tile_size * 1.1
	var texture_size = initiative_progress.texture_progress.get_size()
	
	var scale_factor = min(
		target_size.x / texture_size.x,
		target_size.y / texture_size.y
	)
	initiative_progress.scale = Vector2(scale_factor, scale_factor)
	initiative_progress.position = - (tilemap.tile_set.tile_size * 0.55)

	initiative_progress.modulate.a = 0.9


func take_damage(amount: int):
	print("Taking damage: ", amount, " to ", unit_name)
	current_health = max(0, current_health - amount)
	
	if health_bar:
		health_bar.update_health(current_health, max_health)

	if current_health == 0:
		print("Unit ", unit_name, " has died")
		die()


func die():
	if health_bar:
		health_bar.hide_health()
	queue_free()


# Virtual method
func take_turn():
	push_error("take_turn() must be overridden in subclass")


func get_damage_multiplier() -> float:
	return 1.0


func get_damage_received_multiplier() -> float:
	return 1.0
