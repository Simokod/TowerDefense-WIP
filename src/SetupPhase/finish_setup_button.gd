extends Button

var total_heroes_count
var placed_heroes_count = 0

func _ready():
	total_heroes_count = len(GameManager.get_available_heroes())

func _process(_delta):
	placed_heroes_count = GameManager.get_placed_heroes_count()
	text = "Finish setup ({placed_heroes_count}/{total_heroes_count})".format({
		"placed_heroes_count": placed_heroes_count,
		"total_heroes_count": total_heroes_count
	})
	
	if placed_heroes_count < total_heroes_count:
		disabled = true
	else:
		disabled = false

func finish_setup():
	self.queue_free()
