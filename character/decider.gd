class_name Decider
extends Node2D

signal updated_ghost(action_name, move_target, rotation_target)
signal action_selected(action_name, move_target, rotation_target)

var action_name: String
var move_target: Vector2
var rotation_target: float


func start_selecting_action(actions, position, angle, team):
	_start_selecting_action(actions, position, angle, team)


func _start_selecting_action(actions, position, angle, team):
	pass


func end_selecting_action(actions, position, angle, team):
	_end_selecting_action(actions, position, angle, team)
	action_selected.emit(action_name, move_target, rotation_target)
	
	action_name = ""
	update_ghost()


func _end_selecting_action(actions, position, angle, team):
	pass


func update_ghost():
	updated_ghost.emit(action_name, move_target, rotation_target)
