extends Node2D

func _ready():
	$Control/PlayButton.connect("pressed", _on_PlayButton_pressed)

func _on_PlayButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
