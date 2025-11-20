class_name BaseUnit extends Node2D

@export var unit_name: String
@export var initiative: float = 25.0
@export var movement_speed: int = 3
@export var max_health: int = 100
@export var allowed_tiles: Array[String]
@onready var initiative_progress: TextureProgressBar = $InitiativeProgress
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/HealthLabel

var current_health: int
var unit_sprite: Texture2D
var tile_pos: Vector2i
var tilemap: TileMapLayer


func _ready():
	current_health = max_health
	tilemap = GameManager.get_tilemap()
	_init_sprite()
	_init_progress_bar()
	_init_health_bar()
	_update_health_bar()


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


func _init_health_bar():
	if health_bar == null:
		return
	
	var tile_size = tilemap.tile_set.tile_size
	var bar_width = tile_size.x * 0.9
	var bar_height = tile_size.y * 0.18
	
	health_bar.custom_minimum_size = Vector2(bar_width, bar_height)
	health_bar.position = Vector2(-bar_width / 2, -tile_size.y * 0.75)
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	var background_style := StyleBoxFlat.new()
	background_style.bg_color = Color("#7f1d1d")
	background_style.corner_radius_all = int(bar_height / 2)
	health_bar.add_theme_stylebox_override("background", background_style)
	
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color("#22c55e")
	fill_style.corner_radius_all = int(bar_height / 2)
	health_bar.add_theme_stylebox_override("fill", fill_style)
	
	if health_label:
		health_label.text = "%d / %d" % [current_health, max_health]
		health_label.add_theme_font_size_override("font_size", max(10, int(bar_height)))


func _update_health_bar():
	if health_bar == null:
		return
	
	health_bar.value = current_health
	
	if health_label:
		health_label.text = "%d / %d" % [current_health, max_health]
		health_label.visible = true

func take_damage(amount: int):
	print("Taking damage: ", amount, " to ", unit_name)
	current_health = max(0, current_health - amount)
	_update_health_bar()

	if current_health == 0:
		print("Unit ", unit_name, " has died")
		die()

func die():
	if health_bar:
		health_bar.visible = false
	queue_free()

# Virtual method
func take_turn():
	push_error("take_turn() must be overridden in subclass")

func get_damage_multiplier() -> float:
	return 1.0

func get_damage_received_multiplier() -> float:
	return 1.0
