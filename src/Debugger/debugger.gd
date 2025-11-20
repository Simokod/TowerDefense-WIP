extends Node2D

class_name Debugger

var debug_draw_cells = []
var debug_walkable_cells = []

var tilemap: TileMapLayer

func _ready():
	tilemap = GameManager.get_tilemap()

func debug_path(_debug_draw_cells: Array, _debug_walkable_cells: Array):
	debug_draw_cells = _debug_draw_cells
	debug_walkable_cells = _debug_walkable_cells
	queue_redraw()

func clear_debug_paths():
	debug_draw_cells.clear()
	debug_walkable_cells.clear()
	queue_redraw()

func _draw():
	for cell in debug_draw_cells:
		var pos = tilemap.map_to_local(cell)
		draw_circle(pos, 10, Color(1, 0, 0, 1))

	for cell in debug_walkable_cells:
		var pos = tilemap.map_to_local(cell)
		var size = 10
		var points = PackedVector2Array([
			pos + Vector2(0, -2 * size), # top point
			pos + Vector2(-size, -3 * size), # bottom left
			pos + Vector2(size, -3 * size) # bottom right
		])
		draw_colored_polygon(points, Color(0, 1, 0, 1))
