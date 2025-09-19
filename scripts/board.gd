extends Node3D

#
# --- Editor Variables ---
#
@export var grid_length = 10
@export var grid_height = 10
@export var colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW]

#
# --- Other Variables ---
#
var grid = []
var block_scene = preload("res://scenes/block.tscn")

#
# --- Core Functions ---
#
func _ready() -> void:
	randomize()		# Make sure subsequent random num gen is based on new seed
	for y in range(grid_height):
		grid.append([])
		for x in range(grid_length):
			var color_idx = randi() % colors.size()	# Index into color array
			grid[y].append(color_idx)
			
			var block = block_scene.instantiate()
			block.grid_pos = Vector2i(x, y)
			block.set_color(colors[color_idx])
			var offset_x = (grid_length - 1) / 2.0
			var offset_y = (grid_height - 1) / 2.0
			block.transform.origin = Vector3(x - offset_x, block.transform.origin.y, y - offset_y)	# Place block in grid, rest on ground
			add_child(block)
