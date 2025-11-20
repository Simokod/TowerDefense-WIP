class_name HealthBarUI extends ProgressBar

@export var width_ratio: float = 0.9
@export var height_ratio: float = 0.18
@export var vertical_offset_ratio: float = 0.75

@onready var health_label: Label = $HealthLabel


func setup(tile_size: Vector2i, max_health: int, current_health: int):
	_configure_dimensions(tile_size)
	_configure_styles(tile_size)
	update_health(current_health, max_health)


func update_health(current_health: int, max_health: int):
	max_value = max_health
	value = current_health
	
	if health_label:
		health_label.text = "%d / %d" % [current_health, max_health]


func hide_health():
	visible = false


func _configure_dimensions(tile_size: Vector2i):
	var bar_width = tile_size.x * width_ratio
	var bar_height = tile_size.y * height_ratio
	custom_minimum_size = Vector2(bar_width, bar_height)
	position = Vector2(-bar_width / 2, -tile_size.y * vertical_offset_ratio)


func _configure_styles(tile_size: Vector2i):
	var bar_height = tile_size.y * height_ratio
	var background_style = StyleBoxFlat.new()
	background_style.bg_color = Color("#7f1d1d")
	background_style.set_corner_radius_all(int(bar_height / 2))
	add_theme_stylebox_override("background", background_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color("#22c55e")
	fill_style.set_corner_radius_all(int(bar_height / 2))
	add_theme_stylebox_override("fill", fill_style)
	
	if health_label:
		health_label.add_theme_font_size_override("font_size", max(10, int(bar_height)))
