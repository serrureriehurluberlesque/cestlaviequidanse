class_name BasicIA
extends Decider

@onready var detection := $Detection as Area2D


func _start_selecting_action(actions, position, angle, team):
	await get_tree().create_timer(0.5 + randf()).timeout
	
	var targets = []
	for body in detection.get_overlapping_bodies():
		if body.team != team:
			targets.append(body)
	
	if targets:
		var target
		var distance = 2000.0
		for t in targets:
			var d = position.distance_to(t.get_position())
			if d < distance:
				target = t
				distance = d
		
		var optimaL_distance
		if distance < 228.0:
			action_name = "MediumAttack"
			optimaL_distance = 250.0
		elif distance < 340.0:
			action_name = "HeavyAttack"
			optimaL_distance = 200.0
		else:
			action_name = "LightAttack"
			optimaL_distance = distance / 2.0 + 100.0
		
		var target_position = target.get_position()
		var delta_position = (target_position - position).normalized()
		move_target = position + (distance - optimaL_distance) * delta_position 
		rotation_target = (target_position - position).angle()
		
	else:
		move_target = position
		rotation_target = angle
		action_name = "LightAttack"
