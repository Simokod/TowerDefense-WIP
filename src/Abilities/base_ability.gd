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
	ALL
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
@export var self_target: bool = false

@export var effect_scene: PackedScene # Visual effect when ability is used
@export var targeting_indicator_scene: PackedScene # Visual for targeting phase

func trigger(hero: BaseHero):
	if not can_use(hero):
		print("ERROR: Ability cannot be used")
		return

	targeting_system.start_targeting(self, hero)

func on_targeting_completed(target, hero: BaseHero):
	execute(hero, target)

# Virtual method 
func execute(_hero: BaseHero, _target: BaseUnit = null):
	push_error("execute() must be overridden in subclass")


func can_use(_hero: BaseHero) -> bool:
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
