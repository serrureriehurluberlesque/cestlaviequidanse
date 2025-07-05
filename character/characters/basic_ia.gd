class_name BasicIA
extends Decider

@onready var detection := $Detection as Area2D

func _start_selecting_action(actions, position, angle, team):
	await get_tree().create_timer(0.5 + randf()).timeout

	# 1. Recherche de la cible la plus proche
	var targets := detection.get_overlapping_bodies().filter(func(body):
		return body.team != team
	)
	targets.sort_custom(func(a, b):
		return position.distance_to(a.get_position()) < position.distance_to(b.get_position())
	)

	if targets.size() > 0:
		var target = targets[0]
		var target_position = target.get_position()
		var delta_position = (target_position - position)
		var distance = delta_position.length()
		var direction = delta_position.normalized()
		var rotation_to_target = delta_position.angle()
		var rotation_diff = abs(wrapf(rotation_to_target - angle, -PI, PI))

		# 2. Filtrer les actions selon la position et la rotation requises
		var valid_actions = actions.filter(func(action):
			return (
				distance < action.expected_position_range() and
				rotation_diff < action.expected_rotation_range()
			)
		)

		# 3. Choisir l'action ayant le plus de damage
		if valid_actions.size() > 0:
			valid_actions.sort_custom(func(a, b):
				return a.damage > b.damage
			)
			var best_action = valid_actions[0]

			# 4. Définir les targets et action_name
			var optimal_distance = best_action.optimal_distance()
			move_target = target_position - direction * optimal_distance
			rotation_target = rotation_to_target
			action_name = best_action.name
		else:
			# Si aucune action valable, comportement fallback
			move_target = position
			rotation_target = angle
			action_name = "LightAttack"
	else:
		move_target = position
		rotation_target = angle
		action_name = "LightAttack"
