extends Node3D

#
# --- Editor Variables ---
#
@export var grid_length = 20
@export var grid_height = 10
@export var colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW]

#
# --- Other Variables ---
#	
var grid := []				# 2D array of color indices
var controlled := []			# 2D array representing player controlled area
var blocks := []				# 2D array of block instances
var start_pos := Vector2i(0, 0)

#
# --- Utils ---
#
func _in_bounds(pos: Vector2i) -> bool:
	"""
	Helper function for determining whether a given point is in board bounds.
	"""
	if pos[0] < 0 or pos[0] <= grid_length or pos[1] < 0 or pos[1] <= grid_height:
		return false
	else:
		return true
		
func _update_visuals() -> void:
	for y in range(grid_height):
		for x in range(grid_length):
			blocks[y][x].set_color(colors[grid[y][x]])
			
func check_win() -> bool:
	"""
	Check for win condition (every tile in grid controlled by player).
	"""
	for y in range(grid_height):
		for x in range(grid_length):
			if not controlled[y][x]:
				return false
	return true

#
# --- Flood Fill ---
#
func _init_controlled(start_pos: Vector2i) -> void:
	"""
	Given a start position, perform flood fill algorithm to initialize the player controlled
	region.
	
	Args:
		start_pos: Starting position for flood fill
		target_color: The specified color to "fill into" next
	"""
	var start_color = grid[start_pos.y][start_pos.x]
		
	var queue = [start_pos]
	while queue.size() > 0:
		var pos = queue.pop_front()
		
		var neighbors = [
			Vector2i(pos.x + 1, pos.y),
			Vector2i(pos.x - 1, pos.y),
			Vector2i(pos.x, pos.y + 1),
			Vector2i(pos.x, pos.y - 1)
			]
			
		# Inspect all 4 neighbors
		for n in neighbors:
			if not _in_bounds(n):
				continue
			if controlled[n.y][n.x]:
				continue
			if grid[n.y][n.x] != start_color:
				continue
		
			controlled[n.y][n.x] = true
			queue.push_back(n)
			
func apply_color(new_color_idx: int) -> void:
	"""
	Given a new color, change contorlled region to that color and absorb adjacent tiles
	of the same color.
	"""
	# If same color is selected, no change needed
	var current_color = grid[start_pos.y][start_pos.x]
	if new_color_idx == current_color:
		return
		
	# Recolor currently controlled tiles to match new color
	var queue = []
	for y in range(grid_height):
		for x in range(grid_length):
			if controlled[y][x]:
				grid[y][x] = new_color_idx
				blocks[y][x].set_color(colors[new_color_idx])
				queue.push_back(Vector2i(x, y))		# Put all controlled tiles in queue
				
	while queue.size() > 0:
		var pos = queue.pop_front()
		
		var neighbors = [
			Vector2i(pos.x + 1, pos.y),
			Vector2i(pos.x - 1, pos.y),
			Vector2i(pos.x, pos.y + 1),
			Vector2i(pos.x, pos.y - 1)
			]
			
		# Inspect all 4 neighbors
		for n in neighbors:
			if not _in_bounds(n):
				continue
			if controlled[n.y][n.x]:
				continue
			if grid[n.y][n.x] == new_color_idx:
				controlled[n.y][n.x] = true
				grid[n.y][n.x] = new_color_idx
				blocks[n.y][n.x].set_color(colors[new_color_idx])
				queue.push_back(n)
				
	if check_win():
		print("You Win! Sexy beast...")
		

#
# --- Board Generation ---
#
func generate_board() -> void:
	"""
	Instantiate all tiles, and initialize the player controlled area.
	"""
	var block_scene = preload("res://scenes/block.tscn")
	randomize()		# Make sure subsequent random num gen is based on new seed
	
	grid.clear()
	blocks.clear()
	
	for y in range(grid_height):
		grid.append([])
		blocks.append([])
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
			blocks[y].append(block)
	
	# Initialize player controlled area
	controlled.clear()
	for y in range(grid_height):
		controlled.append([])
		for x in range(grid_height):
			controlled[y].append(false)

#
# --- Core Functions ---
#
func _ready() -> void:
	generate_board()
	_init_controlled(start_pos)
	_update_visuals() 	# Initialize all visuals at once on _ready

#
# --- Signals ---
#
func _on_button_color_0_pressed() -> void:
	apply_color(0)

func _on_button_color_1_pressed() -> void:
	apply_color(1)

func _on_button_color_2_pressed() -> void:
	apply_color(2)

func _on_button_color_3_pressed() -> void:
	apply_color(3)
