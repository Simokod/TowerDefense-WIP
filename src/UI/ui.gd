extends Control

class_name UI

var turn_manager: TurnManager

func set_turn_manager(new_turn_manager: TurnManager):
	turn_manager = new_turn_manager
	$EndTurnButton.set_turn_manager(turn_manager)
	turn_manager.turn_started.connect(_on_turn_started)
	turn_manager.turn_ended.connect(_on_turn_ended)

func _on_turn_started(entity: BaseUnit):
	var show_controls = entity is BaseHero
	$EndTurnButton.visible = show_controls
	$AbilitiesContainer.visible = show_controls
	
	if show_controls:
		setup_hero_abilities(entity as BaseHero)

func _on_turn_ended(entity: BaseUnit):
	$EndTurnButton.hide()
	$AbilitiesContainer.hide()
	clear_abilities()

func setup_hero_abilities(hero: BaseHero):
	clear_abilities()
	for ability in hero.abilities:
		var button = AbilityButton.new()
		button.setup(ability, hero)
		$AbilitiesContainer.add_child(button)

func clear_abilities():
	for child in $AbilitiesContainer.get_children():
		child.queue_free()
