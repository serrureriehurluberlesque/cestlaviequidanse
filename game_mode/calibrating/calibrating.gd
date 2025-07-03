class_name Calibrating
extends Node

@onready var world := $World as Node2D
var arena: Arena

var targeting_pos = Vector2(100.0, 0.0)
var starting_pos = Vector2.ZERO
var ending_pos = Vector2.ZERO

var targeting_rot = 0.0
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
	
	var decider = player.get_node("Decider")
	decider.move_target = targeting_pos
	decider.rotation_target = targeting_rot - player.SPRITE_ROTATION
	decider.select_action("Move")


func _on_arena_finished(is_won) -> void:
	var player = arena.get_node("Characters/Player")
	ending_pos = player.get_position()
	ending_rot = player.get_rotation()
	
	print("Starting pos is: ", starting_pos)
	print("Ending pos is: ", ending_pos)
	print("Delta pos is: ", ending_pos - starting_pos)
	
	print("Starting rot is: ", starting_rot)
	print("Ending rot is: ", ending_rot)
	print("Delta rot is: ", ending_rot - starting_rot)
	
	await get_tree().create_timer(0.5).timeout
	
	arena.queue_free()
	
	get_tree().quit()
