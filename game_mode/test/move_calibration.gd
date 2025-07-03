extends Node2D

@onready var character := $Character as Character

var move_target:= Vector2(300, 200)
var move_speed:= 5.0

func _ready() -> void:
	character.set_move(move_target, move_speed)
	character.apply_central_impulse(1.0 * character.mass * (move_target - get_position()).normalized())
	character.apply_central_impulse(1.0 * character.mass * Vector2(50, 20).normalized())
	character.start_moving()
	await get_tree().create_timer(1.0).timeout
	character.stop_moving()
