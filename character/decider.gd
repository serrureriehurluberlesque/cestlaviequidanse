class_name Decider
extends Node2D

signal updated_ghost(action_name, move_target, rotation_target)
signal action_selected(action_name, move_target, rotation_target)

var selected_action: Action
var move_target: Vector2
var rotation_target: float


func start_selecting_action(actions, position, angle, team):
	_start_selecting_action(actions, position, angle, team)


func _start_selecting_action(actions, position, angle, team):
	pass


func end_selecting_action(actions, position, angle, team):
	_end_selecting_action(actions, position, angle, team)
	action_selected.emit(selected_action, move_target, rotation_target)
	
	selected_action = null
	update_ghost()


func _end_selecting_action(actions, position, angle, team):
	pass


func die(pos):
	_die(pos)


func _die(pos):
	pass


func update_ghost():
	updated_ghost.emit(selected_action.name if selected_action else "", move_target, rotation_target)
