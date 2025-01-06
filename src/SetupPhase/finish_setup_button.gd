extends Button

var total_heroes_count
var heroes_selection_ui: HeroesSelectionUI

func _ready():
	total_heroes_count = GameManager.get_available_heroes_count()
	heroes_selection_ui = get_parent().get_node("HeroesSelectionUI")

func _process(_delta):
	var placed_heroes_count = heroes_selection_ui.get_placed_heroes_count()
	text = "Finish setup ({placed_heroes_count}/{total_heroes_count})".format({
		"placed_heroes_count": placed_heroes_count,
		"total_heroes_count": total_heroes_count
	})
	
	disabled = placed_heroes_count < total_heroes_count
