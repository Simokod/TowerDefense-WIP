class_name Ability extends Resource


enum TargetType {
	NONE,
	SINGLE,
	MULTI,
	GROUND,
}

enum TargetTeam {
	NONE,
	FRIENDLY,
	ENEMY,
	BOTH
}

static var targeting_system: TargetingSystem

@export var ability_name: String
@export var description: String
@export var icon: Texture
@export var cost: int = 0
@export var cast_range: int = 0

@export var cooldown_duration: int = 0
var current_cooldown: int = 0

@export var target_type: TargetType = TargetType.NONE
@export var target_team: TargetTeam = TargetTeam.NONE

@export var effect_scene: PackedScene # Visual effect when ability is used
@export var targeting_indicator_scene: PackedScene # Visual for targeting phase

func trigger(hero: Hero):
	if not can_use(hero):
		print("ERROR: Ability cannot be used")
		return

	targeting_system.targeting_completed.connect(_on_targeting_completed.bind(hero), CONNECT_ONE_SHOT)
	targeting_system.start_targeting(self, hero)

func _on_targeting_completed(target, hero: Hero):
	print("Targeting completed for ", hero.name, " with target ", target)
	execute(hero, target)

func execute(_hero: Hero, _target = null):
	pass


func can_use(_hero: Hero) -> bool:
	if current_cooldown > 0:
		return false
	# if hero.action_points < cost: 
	#     return false
	return true


func start_cooldown():
	current_cooldown = cooldown_duration

# TODO: This should be called in the game loop or maybe by some ability manager?
func update_cooldown():
	if current_cooldown > 0:
		current_cooldown -= 1

func show_targeting_indicator():
	if targeting_indicator_scene:
		var indicator = targeting_indicator_scene.instantiate()
		return indicator
	return null

# Visual effects
func spawn_effect(position: Vector2):
	if effect_scene:
		var effect = effect_scene.instantiate()
		GameManager.get_tree().current_scene.add_child(effect)
		effect.global_position = position
		return effect
