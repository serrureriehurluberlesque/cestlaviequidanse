class_name Calibrating
extends Node

signal measure(expected_dpos, dpos, expected_drot, drot)

@onready var world := $World as Node2D
var arena: Arena

@export var targeting_pos = Vector2(100.0, 0.0)
@export var targeting_rot = 0.0

@export var custom_move_range = 1.0
@export var custom_orientation_range = 1.0

var starting_pos = Vector2.ZERO
var ending_pos = Vector2.ZERO

var starting_rot = 0.0
var ending_rot = 0.0


func _ready() -> void:
	var package = load("res://arena/level/calibrating_ground.tscn")
	arena = package.instantiate()
	world.add_child(arena)
	arena.connect("ended", _on_arena_finished)
	
	await get_tree().create_timer(2.1).timeout
	
	var player = arena.get_node("Characters/Player")
	starting_pos = player.get_position()
	starting_rot = player.get_rotation()
	
	player.get_node("Actions/Move").move_range = custom_move_range
	player.get_node("Actions/Move").orientation_range = custom_orientation_range
	
	var decider = player.get_node("Decider")
	decider.move_target = targeting_pos
	decider.rotation_target = targeting_rot - player.SPRITE_ROTATION
	decider.select_action("Move")


func _on_arena_finished(is_won) -> void:
	var player = arena.get_node("Characters/Player")
	ending_pos = player.get_position()
	ending_rot = player.get_rotation()
	
	measure.emit(targeting_pos.length(), (ending_pos- starting_pos).length(), targeting_rot, ending_rot - starting_rot)
	
	await get_tree().create_timer(0.5).timeout
	
	queue_free()
