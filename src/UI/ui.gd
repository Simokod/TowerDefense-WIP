extends Control

class_name UI

var turn_manager: TurnManager

func set_turn_manager(new_turn_manager: TurnManager):
	turn_manager = new_turn_manager
	$EndTurnButton.set_turn_manager(turn_manager)
	turn_manager.turn_started.connect(_on_turn_started)

func _on_turn_started(entity: Unit):
	var show_controls = entity is Hero
	$EndTurnButton.visible = show_controls
	$AbilitiesContainer.visible = show_controls