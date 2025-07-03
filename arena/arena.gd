class_name Arena
extends Node2D

signal ended(won)

@export var ROUND_TOTAL_NUMBER = 10

@onready var action_selection_timer := $ActionSelectionTimer as Timer
@onready var fast_activation_timer := $FastActionTimer as Timer
@onready var move_activation_timer := $MoveActionTimer as Timer
@onready var slow_activation_timer := $SlowActionTimer as Timer
@onready var characters := $Characters as Node2D
var actual_round_number := 0


func _ready() -> void:
	action_selection_timer.connect("timeout", _end_selection)
	fast_activation_timer.connect("timeout", _start_move_activation)
	move_activation_timer.connect("timeout", _start_slow_activation)
	slow_activation_timer.connect("timeout", _end_round)
	
	
	if OS.is_debug_build():
		print("Starting arena %s" % [name])
	
	await get_tree().create_timer(2.0).timeout
	
	_start_round()


func _start_round():
	actual_round_number += 1
	if OS.is_debug_build():
		print("Starting round %d" % [actual_round_number])
	
	arena_says("start_round")
	action_selection_timer.start()


func _end_selection():
	if OS.is_debug_build():
		print("Ending selection of round %d" % [actual_round_number])
	
	arena_says("end_selection")
	_start_fast_activation()


func _start_fast_activation():
	if OS.is_debug_build():
		print("Starting fast actions for round %d" % [actual_round_number])
	
	arena_says("start_fast_activations")
	fast_activation_timer.start()


func _start_move_activation():
	if OS.is_debug_build():
		print("Starting move actions for round %d" % [actual_round_number])
	
	arena_says("start_move_activations")
	move_activation_timer.start()


func _start_slow_activation():
	if OS.is_debug_build():
		print("Starting slow actions for round %d" % [actual_round_number])
	
	arena_says("start_slow_activations")
	slow_activation_timer.start()
	
func _end_round():
	if OS.is_debug_build():
		print("ending round %d" % [actual_round_number])
	
	arena_says("end_round")
	
	if actual_round_number >= ROUND_TOTAL_NUMBER:
		_ended()
	else:
		_start_round()


func _ended():
	var team_scores = {1: 0, 2: 0}
	for character in characters.get_children():
		team_scores[character.team] = team_scores.get(character.team, 0.0) + character.health_points
		
	for team in team_scores.keys():
		print("Team %d has %d points" % [team, team_scores[team]])
	
	var is_won = team_scores[1] > team_scores[2]
	
	if OS.is_debug_build():
		print("Ending, arena won" if is_won else "Ending, arena lost")
	ended.emit(is_won)


func get_characters():
	return characters.get_children()


func arena_says(function):
	for character in get_characters():
		character.call(function)
