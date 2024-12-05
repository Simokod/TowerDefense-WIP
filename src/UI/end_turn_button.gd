extends Button

var turn_manager: TurnManager

func _ready():
	pressed.connect(_on_pressed)
	hide()

func _on_pressed():
	if turn_manager:
		turn_manager.end_current_turn()

func set_turn_manager(new_turn_manager: TurnManager):
	turn_manager = new_turn_manager