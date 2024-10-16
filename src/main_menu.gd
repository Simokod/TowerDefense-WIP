extends Node2D

func _ready():
	$Control/PlayButton.connect("pressed", _on_PlayButton_pressed)

func _on_PlayButton_pressed():
	GameManager.start_game()
