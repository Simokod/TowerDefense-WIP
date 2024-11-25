extends Node

enum GamePhase {
	SETUP,
	GAMEPLAY
}

@export_file("*.tscn") var level_scene_path = "res://scenes/levels/demo_level.tscn"

var current_level: Node
var current_phase: GamePhase = GamePhase.SETUP

@onready var heroes_selection_ui: HeroesSelectionUI = $CanvasLayer/HeroesSelectionUI

func _ready():
	load_level(level_scene_path)
	GameManager.start_game()
	
	heroes_selection_ui.initialize()
	$CanvasLayer/FinishSetupButton.pressed.connect(_on_finish_setup_pressed)

func load_level(path: String):
	if current_level:
		current_level.queue_free()
	current_level = load(path).instantiate()
	add_child(current_level)

func _on_finish_setup_pressed():
	heroes_selection_ui.hide()
	$CanvasLayer/FinishSetupButton.hide()
	current_phase = GamePhase.GAMEPLAY
	start_gameplay()

func start_gameplay():
	# Initialize gameplay systems
	pass

func get_tilemap() -> TileMap:
	return current_level.get_node("LevelTileMap")
