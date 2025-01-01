class_name AbilityButton extends Button

@export var ability: Ability
@export var hero: Hero

@onready var cooldown_label = $CooldownLabel
var is_targeting: bool = false

func _ready():
	custom_minimum_size = Vector2(100, 100)
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	expand_icon = true
	toggle_mode = true

	pressed.connect(_on_pressed)
	

func setup(_ability: Ability, _hero: Hero):
	ability = _ability
	hero = _hero
	icon = ability.icon
	tooltip_text = "%s\n%s" % [ability.ability_name, ability.description]

	ability.targeting_system.targeting_completed.connect(end_targeting)
	ability.targeting_system.targeting_cancelled.connect(end_targeting)

func _process(_delta):
	disabled = not ability.can_use(hero)
	
	if cooldown_label:
		cooldown_label.visible = ability.current_cooldown > 0
		cooldown_label.text = str(ability.current_cooldown)

func _on_pressed():
	if not ability.can_use(hero):
		button_pressed = false
		return
	
	if is_targeting:
		ability.targeting_system.cancel_targeting()
		is_targeting = false
		return

	is_targeting = true
	ability.trigger(hero)

## Currently theres a bug where an ability is pressed while targeting another ability
## This cancels the targeting on both abilities, and then starts targeting on the new ability
## This doesn't seem to be a problem, but it should be fixed
func end_targeting(target: Node = null):
	print("end_targeting ", ability.ability_name, " by ", hero.unit_name, " with target ", target, " is_targeting ", is_targeting)
	if not is_targeting:
		return
	
	var target_name = "null"
	if target:
		target_name = target.name
	print("Ending ", ability.ability_name, " targeting for ", hero.unit_name, " with target ", target_name)
	
	button_pressed = false
	is_targeting = false
