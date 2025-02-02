class_name TurnOrderDisplayUnit

var unit: BaseUnit
var time_to_turn: float
var portrait: Texture2D

func _init(p_unit: BaseUnit, p_time: float, p_portrait: Texture2D):
  unit = p_unit
  time_to_turn = p_time
  portrait = p_portrait
