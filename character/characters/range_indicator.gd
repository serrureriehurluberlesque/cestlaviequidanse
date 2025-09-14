extends Node2D

var move_range: float = 0.0
var orientation_range: float = 0.0
var base_position: Vector2 = Vector2.ZERO
var base_rotation: float = 0.0
var sprite_size: float = 0.0
var move_length: float = 0.0
var ghost_rotation: float = 0.0

func _draw():
	# Cercle de déplacement
	if move_range > 0:
		draw_circle(Vector2.ZERO, move_range, Color(0, 1, 0, 0.10))
	# Arc d’orientation
	if orientation_range > 0:
		var arc_radius = sprite_size * 1.5
		var arc_start = base_rotation - orientation_range/2
		var arc_end = base_rotation + orientation_range/2
		draw_arc(base_position, arc_radius, arc_start, arc_end, 32, Color(1, 0.7, 0, 0.2), 4)
	
	if move_length > 0:
		draw_line(base_position + move_length * Vector2(1, 0).rotated(ghost_rotation + PI), base_position, Color(0.3, 0.0, 0.8, 0.3), 4.0)

		

func update_ranges(_move_range, _orientation_range, _base_position, _base_rotation, _sprite_size, _move_length, _ghost_rotation):
	move_range = _move_range
	orientation_range = _orientation_range
	base_position = _base_position
	base_rotation = _base_rotation
	sprite_size = _sprite_size
	move_length = _move_length
	ghost_rotation = _ghost_rotation
	queue_redraw()
