extends Control

signal finished

enum Position {
	TOP,
	TOP_LEFT,
	TOP_RIGHT,
	CENTER,
	BOTTOM,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	CUSTOM
}

func _ready():
	hide()


func _set_announcement_position(announcement_position: Position, custom_anchor_y: float = 0.5):
	match announcement_position:
		Position.CUSTOM:
			$PanelContainer.set_anchor(SIDE_LEFT, 0.5, true)
			$PanelContainer.set_anchor(SIDE_RIGHT, 0.5, true)
			$PanelContainer.set_anchor(SIDE_TOP, custom_anchor_y, true)
			$PanelContainer.set_anchor(SIDE_BOTTOM, custom_anchor_y, true)
			# $PanelContainer.set_offset(SIDE_LEFT, -$PanelContainer.size.x / 2)
		Position.CENTER:
			$PanelContainer.set_anchors_preset(PRESET_CENTER, true)
		Position.TOP:
			$PanelContainer.set_anchors_preset(PRESET_CENTER_TOP, true)
		Position.TOP_LEFT:
			$PanelContainer.set_anchors_preset(PRESET_TOP_LEFT, true)
		Position.TOP_RIGHT:
			$PanelContainer.set_anchors_preset(PRESET_TOP_RIGHT, true)
		Position.BOTTOM:
			$PanelContainer.set_anchors_preset(PRESET_CENTER_BOTTOM, true)
		Position.BOTTOM_LEFT:
			$PanelContainer.set_anchors_preset(PRESET_BOTTOM_LEFT, true)
		Position.BOTTOM_RIGHT:
			$PanelContainer.set_anchors_preset(PRESET_BOTTOM_RIGHT, true)
	

func announce_wave_start(wave_number: int) -> void:
	_set_announcement_position(Position.CUSTOM, 0.9)
	await _announce("Wave {number}".format({"number": wave_number}), 1.5)


func announce_turn_completed(wave_number: int) -> void:
	_set_announcement_position(Position.CUSTOM, 0.9)
	await _announce("Turn {number} completed, player turn starts.".format({"number": wave_number}), 1.5)

func _announce(message: String, duration: float) -> Signal:
	$PanelContainer/MarginContainer/Label.text = message
	show()
	modulate = Color(1, 1, 1, 0)

	var tween_in = create_tween()
	tween_in.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
	await tween_in.finished

	await get_tree().create_timer(duration).timeout

	var tween_out = create_tween()
	tween_out.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween_out.finished

	hide()
	return finished
