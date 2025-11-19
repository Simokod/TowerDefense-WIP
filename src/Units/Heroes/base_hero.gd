class_name BaseHero extends BaseUnit

@export var abilities: Array[Ability] = []

func _ready():
  super._ready()
  z_index = Layers.HEROES
