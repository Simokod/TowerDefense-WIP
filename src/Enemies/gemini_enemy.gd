extends BaseEnemy

class_name GeminiEnemy

const BASE_SPEED = 4
const BASE_INITIATIVE = 25
const BASE_HEALTH = 10

func _ready():
  movement_speed = BASE_SPEED
  initiative = BASE_INITIATIVE
  max_health = BASE_HEALTH
  $TextureRect.texture = preload("res://Images/Enemies/Enemy_image-removebg-preview.png")
  super._ready()
