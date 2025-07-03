class_name SuperCali
extends Node

signal test_done()

var calibrating: Calibrating

func _ready() -> void:
	test_values(Vector2(100.0, 0.0), 0.0, 1.0, 1.0)
	test_values(Vector2(200.0, 0.0), 0.0, 1.0, 1.0)
	test_values(Vector2(400.0, 0.0), 0.0, 1.0, 1.0)


func test_values(targeting_pos, targeting_rot, custom_move_range, custom_orientation_range) -> void:
	var package = load("res://game_mode/calibrating/calibrating.tscn")
	calibrating = package.instantiate()
	
	calibrating.targeting_pos = targeting_pos
	calibrating.targeting_rot = targeting_rot

	calibrating.custom_move_range = custom_move_range
	calibrating.custom_orientation_range = custom_orientation_range
	
	add_child(calibrating)
	calibrating.connect("measure", _on_calibrating_finished)
	
	await test_done


func _on_calibrating_finished(expected_dpos, dpos, expected_drot, drot) -> void:
	#print(expected_dpos, dpos, expected_drot, drot)
	print(dpos)
	await get_tree().create_timer(1.0).timeout
	test_done.emit()
	
