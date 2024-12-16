class_name Ability extends Resource

enum TargetType {
    NONE,
    SINGLE_TARGET,
    MULTI_TARGET,
    GROUND,
}

enum TargetTeam {
    NONE,
    FRIENDLY,
    ENEMY,
    BOTH
}

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

func can_use(_hero: Hero) -> bool:
    if current_cooldown > 0:
        return false
    # if hero.action_points < cost: 
    #     return false
    return true

func execute(hero: Hero, target = null):
    print("Executing ability: ", ability_name, " on ", target)
    if not can_use(hero):
        print("ERROR: Ability cannot be used")
        return
    
    start_cooldown()
    
    if target:
        spawn_effect(target.global_position)
    

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

# Utility methods for targeting validation
func is_valid_target(target) -> bool:
    if target == null:
        return false
        
    match target_team:
        TargetTeam.FRIENDLY:
            return target.is_in_group("friendly")
        TargetTeam.ENEMY:
            return target.is_in_group("enemy")
        TargetTeam.BOTH:
            return target.is_in_group("friendly") or target.is_in_group("enemy")
    
    return false

# TODO: Implement using tile range
func is_in_range(hero: Hero, target_position: Vector2) -> bool:
    return true
