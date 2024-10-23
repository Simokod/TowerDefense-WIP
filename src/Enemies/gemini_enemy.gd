extends IEnemy

class_name GeminiEnemy

const BASE_SPEED = 3

func _ready():
  base_speed = BASE_SPEED
  super._ready()
  $TextureRect.texture = preload("res://Images/Enemies/Enemy_image-removebg-preview.png")
  print("gemini_enemy _ready")
