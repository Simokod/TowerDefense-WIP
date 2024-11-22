extends Control

func _ready():
	hide()

func announce(message: String, duration: float = 3) -> void:
	# Show announcement
	$PanelContainer/MarginContainer/Label.text = message
	show()
	modulate = Color(1, 1, 1, 0) # Start fully transparent

	# Fade in
	var tween_in = create_tween()
	tween_in.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
	await tween_in.finished

	# Wait for the announcement duration
	await get_tree().create_timer(duration).timeout

	# Fade out
	var tween_out = create_tween()
	tween_out.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween_out.finished

	hide()
