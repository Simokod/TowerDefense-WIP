class_name BaseHero extends BaseUnit

var abilities: Array[Ability] = [
  preload("res://Resources/Abilities/warrior_basic_attack.tres"),
  preload("res://Resources/Abilities/warrior_ranged_attack.tres"),
]

func _ready():
  super._ready()
  z_index = Layers.HEROES
