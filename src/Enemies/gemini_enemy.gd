extends IEnemy

class_name GeminiEnemy

const BASE_SPEED = 3
const BASE_HEALTH = 10

func _ready():
  base_speed = BASE_SPEED
  base_health = BASE_HEALTH
  $TextureRect.texture = preload("res://Images/Enemies/Enemy_image-removebg-preview.png")
  super._ready()
