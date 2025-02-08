class_name TurnOrderDisplay extends PanelContainer

var turn_manager: TurnManager
@onready var portrait_container: HBoxContainer = $HBoxContainer

func set_turn_manager(new_turn_manager: TurnManager):
	turn_manager = new_turn_manager
	turn_manager.turn_order_changed.connect(_on_turn_order_changed)

func _on_turn_order_changed(new_order: Array[TurnOrderDisplayUnit]):
	print("on_turn_order_changed")
	if not portrait_container:
		return
	
	for child in portrait_container.get_children():
		child.queue_free()
		
	print("XXX: ", new_order)
	for unit_data in new_order:
		var portrait = TextureRect.new()
		portrait.texture = unit_data.portrait
		portrait.custom_minimum_size = GameManager.get_tilemap().tile_set.tile_size
		portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		portrait_container.add_child(portrait)
