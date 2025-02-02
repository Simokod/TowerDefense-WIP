extends Button

var turn_manager: TurnManager

func _ready():
	pressed.connect(_on_pressed)
	hide()


func set_turn_manager(new_turn_manager: TurnManager):
	turn_manager = new_turn_manager


func _on_pressed():
	if turn_manager:
		if Ability.targeting_system and Ability.targeting_system._is_targeting:
			Ability.targeting_system.cancel_targeting()

		turn_manager.end_current_turn()
