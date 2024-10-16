extends Control

class_name HeroesSelectionUI

const HeroPortraitResource = preload("res://HeroPortrait.tscn")
const HoveringHeroResource = preload("res://src/SetupPhase/hovering_hero.gd")

@onready var hero_buttons_container: VBoxContainer = $HeroSelectionContainer
@onready var tilemap = GameManager.get_tilemap()
@onready var canvas_layer = get_parent()

var selected_hero_button: HeroPortrait = null
var hovering_hero: HoveringHero = null

func _ready():
	set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	var available_heroes = GameManager.get_available_heroes()
	for hero in available_heroes:
		create_hero_button(hero)


func create_hero_button(hero):
	var hero_selection_button: HeroPortrait = HeroPortraitResource.instantiate()
	const is_selection_button = true
	hero_selection_button.setup(hero, self, is_selection_button)
	
	hero_buttons_container.add_child(hero_selection_button)


func start_hovering(hero: Hero) -> void:
	if hovering_hero == null:
		hovering_hero = HoveringHeroResource.new()
		add_child(hovering_hero)
	
	hovering_hero.setup(hero)


func stop_hovering() -> void:
	if hovering_hero != null:
		hovering_hero.free()


func deselect_hero() -> void:
	if selected_hero_button == null:
		return
	print("Deselected hero: ", selected_hero_button.hero.name)
	selected_hero_button.deselect()
	selected_hero_button = null
	stop_hovering()


func on_hero_button_pressed(new_selected_button: HeroPortrait, event: InputEvent, is_selection_button: bool):
	if event.button_index == MOUSE_BUTTON_RIGHT:
		_handle_right_press(new_selected_button, is_selection_button)
		return

	if event.button_index == MOUSE_BUTTON_LEFT:
		_handle_left_press(new_selected_button, is_selection_button)
		return

	print("button not left or right, do nothing: ", event.button_index)


func _handle_left_press(new_selected_button: HeroPortrait, is_selection_button: bool) -> void:
	# Left click on any button while no selected hero - select hero
	if not is_instance_valid(selected_hero_button):
		if not is_selection_button:
			selected_hero_button = new_selected_button.duplicate()
			selected_hero_button.setup(new_selected_button.hero, self, is_selection_button)
		else:
			selected_hero_button = new_selected_button

		GameManager.hero_placement_manager.remove_hero(new_selected_button.hero)
		selected_hero_button.select()
		start_hovering(selected_hero_button.hero)
		return
	
	# Left click on selection button while selected hero - deselect hero
	if is_selection_button:
		if selected_hero_button.hero.id == new_selected_button.hero.id:
			deselect_hero()
			return

		if selected_hero_button:
			deselect_hero()
			selected_hero_button = new_selected_button
			selected_hero_button.select()
			start_hovering(selected_hero_button.hero)


func _handle_right_press(new_selected_button: HeroPortrait, is_selection_button: bool) -> void:
		# Right click on selction button - deselect hero
		if is_selection_button:
			deselect_hero()
			GameManager.hero_placement_manager.remove_hero(new_selected_button.hero)
		else: # Right click on placed hero - if hero is selected, deselect hero, otherwise remove hero from tile
			if selected_hero_button:
				deselect_hero()
			else:
				GameManager.hero_placement_manager.remove_hero(new_selected_button.hero)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if selected_hero_button == null:
			return

		if event.button_index == MOUSE_BUTTON_RIGHT:
			deselect_hero()
			return

		if event.button_index == MOUSE_BUTTON_LEFT:
			var tile_position = tilemap.local_to_map(get_global_mouse_position())
			var successfully_placed_hero = GameManager.hero_placement_manager.place_hero(selected_hero_button.hero, tile_position)
			if successfully_placed_hero:
				deselect_hero()
