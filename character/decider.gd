class_name Decider
extends Node2D

signal updated_ghost(action_name, move_target, rotation_target, rotation_intensity)
signal action_selected(action_name, move_target, rotation_target, rotation_intensity)

var selected_action: Action
var move_target: Vector2
var rotation_target: float
var rotation_intensity: float


func start_selecting_action(actions, position, angle, intensity, team):
	_start_selecting_action(actions, position, angle, intensity, team)


func _start_selecting_action(actions, position, angle, intensity, team):
	pass


func end_selecting_action(actions, position, angle, intensity, team):
	_end_selecting_action(actions, position, angle, intensity, team)
	action_selected.emit(selected_action, move_target, rotation_target, rotation_intensity)
	
	selected_action = null
	update_ghost()


func _end_selecting_action(actions, position, angle, intensity, team):
	pass


func die(pos):
	_die(pos)


func _die(pos):
	pass


func update_ghost():
	updated_ghost.emit(selected_action.name if selected_action else "", move_target, rotation_target, rotation_intensity)
