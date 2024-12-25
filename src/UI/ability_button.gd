class_name AbilityButton extends Button

@export var ability: Ability
@export var hero: Hero

@onready var cooldown_label = $CooldownLabel

func _ready():
	custom_minimum_size = Vector2(100, 100)
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	expand_icon = true

	pressed.connect(_on_pressed)
	

func setup(_ability: Ability, _hero: Hero):
	ability = _ability
	hero = _hero
	icon = ability.icon
	tooltip_text = "%s\n%s" % [ability.ability_name, ability.description]

func _process(_delta):
	disabled = not ability.can_use(hero)
	
	if cooldown_label:
		cooldown_label.visible = ability.current_cooldown > 0
		cooldown_label.text = str(ability.current_cooldown)

func _on_pressed():
	print("Ability button pressed")
	if not ability.can_use(hero):
		return
	
	ability.trigger(hero)
