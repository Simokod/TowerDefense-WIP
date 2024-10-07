extends TextureButton

class_name HeroPortrait

@export var heroes_selection_ui: HeroesSelectionUI
var texture_node: TextureRect
var tilemap: TileMap
var is_selected: bool = false
var hero: Hero
var is_selection_button: bool # Can change this to an enum if more types are needed


func _ready():
	gui_input.connect(on_press)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(_hero: Hero, _tilemap: TileMap, _heroes_selection_ui: HeroesSelectionUI, _is_selection_button: bool = false):
	hero = _hero
	tilemap = _tilemap
	heroes_selection_ui = _heroes_selection_ui
	is_selection_button = _is_selection_button

	texture_normal = hero.sprite
	z_index = 10
	custom_minimum_size = Vector2(100, 100)
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	ignore_texture_size = true

func set_to_tile_size():
	custom_minimum_size = tilemap.tile_set.tile_size * 0.9


func on_press(event: InputEvent):
	if not event is InputEventMouseButton or not event.pressed:
		return
	print("HeroPortrait pressed: ", hero.name)
	heroes_selection_ui.on_hero_button_pressed(self, event, is_selection_button)
	accept_event()

func select() -> void:
	is_selected = true

func deselect() -> void:
	is_selected = false
	modulate = Color(1, 1, 1)


func _on_mouse_entered() -> void:
	modulate = Color(1.2, 1.2, 1.2) # Brighten color

func _on_mouse_exited() -> void:
	if not is_selected:
		modulate = Color(1, 1, 1)
