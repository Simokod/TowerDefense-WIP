class_name BaseHeroButton extends TextureButton

var heroes_selection_ui: HeroesSelectionUI
var hero: BaseHero
var is_selected: bool = false

func setup(_hero: BaseHero, _heroes_selection_ui: HeroesSelectionUI, _tilemap: TileMapLayer) -> void:
	hero = _hero
	heroes_selection_ui = _heroes_selection_ui

	texture_normal = hero.unit_sprite
	custom_minimum_size = Vector2(100, 100)
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	ignore_texture_size = true

	gui_input.connect(on_press)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func on_press(event: InputEvent):
	if not event is InputEventMouseButton or not event.pressed:
		return
	print("BaseHero button pressed: ", hero.unit_name)
	
	if is_instance_valid(heroes_selection_ui):
		heroes_selection_ui.on_hero_button_pressed(self, event, is_selection_button())
	
	accept_event()

func is_selection_button() -> bool:
	return false

func select() -> void:
	is_selected = true

func deselect() -> void:
	is_selected = false
	modulate = Color(1, 1, 1)

func _on_mouse_entered() -> void:
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited() -> void:
	if not is_selected:
		modulate = Color(1, 1, 1)
