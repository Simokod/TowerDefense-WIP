class_name AbilityButton extends Button

@export var _ability: Ability
@export var _hero: BaseHero

@onready var cooldown_label = $CooldownLabel
var is_targeting: bool = false

func _ready():
	custom_minimum_size = Vector2(100, 100)
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	expand_icon = true
	toggle_mode = true

	pressed.connect(_on_pressed)
	

func setup(ability: Ability, hero: BaseHero):
	_ability = ability
	_hero = hero
	icon = _ability.icon
	tooltip_text = "%s\n%s" % [_ability.ability_name, _ability.description]

	Ability.targeting_system.targeting_completed.connect(end_targeting)
	Ability.targeting_system.targeting_cancelled.connect(end_targeting)

func _process(_delta):
	disabled = not _ability.can_use(_hero)
	
	if cooldown_label:
		cooldown_label.visible = _ability.current_cooldown > 0
		cooldown_label.text = str(_ability.current_cooldown)

func _on_pressed():
	if not _ability.can_use(_hero):
		button_pressed = false
		return
	
	if is_targeting:
		Ability.targeting_system.cancel_targeting()
		is_targeting = false
		return

	is_targeting = true
	_ability.trigger(_hero)


func end_targeting(ability: Ability, target: Node = null):
	if not is_targeting or ability != self._ability:
		return
	
	var target_name = "null"
	if target:
		target_name = target.name
	print("Ending ", ability.ability_name, " targeting for ", _hero.unit_name, " with target ", target_name)
	
	button_pressed = false
	is_targeting = false
