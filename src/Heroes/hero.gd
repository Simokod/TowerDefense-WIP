extends Unit
class_name Hero

@export var sprite: Texture2D
var abilities: Array[Ability] = [
  preload("res://Resources/Abilities/warrior_basic_attack.tres")
]
