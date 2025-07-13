class_name SuperCali
extends Node

signal test_done(dpos, drot)

var calibrating: Calibrating
var values

var unit_pos = 128.0
var unit_rot = PI/2.0

func _ready() -> void:
	test_values(Vector2(10000.0, 0.0), 0.0, 1.0, 1.0)
	
	values = await test_done
	print("SPEED of characters should be: ", Character.SPEED / (values[0] / unit_pos))
	
	await get_tree().create_timer(1.0).timeout
	
	test_values(Vector2(0.0, 0.0), PI * 0.9, 1.0, 0.25)
	
	values = await test_done
	print("RSPEED of characters should be: ", Character.RSPEED / (values[1] / unit_rot) / 2.0)
	
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()


func test_values(targeting_pos, targeting_rot, custom_move_range, custom_orientation_range) -> void:
	var package = load("res://game_mode/calibrating/calibrating.tscn")
	calibrating = package.instantiate()
	
	calibrating.targeting_pos = targeting_pos
	calibrating.targeting_rot = targeting_rot

	calibrating.custom_move_range = custom_move_range
	calibrating.custom_orientation_range = custom_orientation_range
	
	add_child(calibrating)
	calibrating.connect("measure", _on_calibrating_finished)


func _on_calibrating_finished(expected_dpos, dpos, expected_drot, drot) -> void:
	await get_tree().create_timer(1.0).timeout
	test_done.emit(dpos, drot)
