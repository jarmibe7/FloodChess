extends Node3D

var grid_pos: Vector2i	= Vector2i.ZERO	# Board coordinates
var color_index: int = 0

func set_color(color: Color):
	var mat_override = $MeshInstance3D.get_surface_override_material(0)
	mat_override.albedo_color = color
