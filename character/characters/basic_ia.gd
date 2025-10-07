class_name BasicIA
extends Decider

@export var angle_minimal: float = PI / 2 # 90°
@export var distance_ideal: float = 300.0 # pixels

@onready var detection := $Detection as Area2D

func get_visible_enemies(my_team) -> Array:
	var enemies := []
	for body in detection.get_overlapping_bodies():
		if "team" in body and body.team != my_team:
			enemies.append(body)
	return enemies

func get_visible_allies(my_team) -> Array:
	var allies := []
	for body in detection.get_overlapping_bodies():
		if "team" in body and body.team == my_team and body != get_parent():
			allies.append(body)
	return allies

func get_closest_enemy(position, enemies) -> Node:
	if enemies.is_empty():
		return null
	enemies.sort_custom(func(a, b):
		return position.distance_to(a.global_position) < position.distance_to(b.global_position)
	)
	return enemies[0]

func get_allies_focused_on_enemy(enemy, allies, my_position) -> Array:
	var focused := [get_parent()]
	for ally in allies:
		var enemy_dist = ally.global_position.distance_to(enemy.global_position)
		var visible_enemies = get_visible_enemies(ally.team)
		visible_enemies.erase(enemy)
		var min_other_dist = INF
		for other_enemy in visible_enemies:
			min_other_dist = min(min_other_dist, ally.global_position.distance_to(other_enemy.global_position))
		if min_other_dist == INF or enemy_dist < min_other_dist:
			focused.append(ally)
	return focused

func get_my_angle_and_closer_angles(enemy, focus_allies) -> Dictionary:
	var center = enemy.global_position
	var my_pos = get_parent().global_position
	var my_dist = my_pos.distance_to(center)
	var my_angle = (my_pos - center).angle()
	var closer_angles = []
	for ally in focus_allies:
		if ally == get_parent():
			continue
		var ally_pos = ally.global_position
		var ally_dist = ally_pos.distance_to(center)
		if ally_dist < my_dist:
			closer_angles.append((ally_pos - center).angle())
	return { "my_angle": my_angle, "closer_angles": closer_angles }

func angles_are_far_enough(my_angle: float, closer_angles: Array, min_angle: float) -> bool:
	for angle in closer_angles:
		var diff = abs(wrapf(angle - my_angle, -PI, PI))
		if diff < min_angle * 0.75:  # on se donne un peu de marge par rapport à min_angle
			return false
	return true

func compute_reposition_angle(enemy, focus_allies) -> Vector2:
	var center = enemy.global_position
	var my_pos = get_parent().global_position
	var my_angle = (my_pos - center).angle()
	
	# Calculer l'angle de chaque allié autour de l'ennemi
	var angle_focus = []
	for ally in focus_allies:
		var angle = (ally.global_position - center).angle()
		angle_focus.append({ "ally": ally, "angle": angle })
	
	# Trier les alliés par angle croissant
	angle_focus.sort_custom(func(a, b):
		return a["angle"] < b["angle"]
	)
	
	# Trouver l'index de self dans la liste triée
	var my_idx = 0
	for i in range(angle_focus.size()):
		if angle_focus[i]["ally"] == get_parent():
			my_idx = i
			break
	
	# L'angle de base est celui du premier allié de la liste triée
	var base_angle = angle_focus[0]["angle"]
	var desired_angle = base_angle + angle_minimal * float(my_idx)
	
	return center + Vector2(distance_ideal, 0).rotated(desired_angle)

func _start_selecting_action(actions, position, angle, intensity, team):
	await get_tree().create_timer(0.5 + randf()).timeout

	var my_character = get_parent()
	var my_team = my_character.team
	var my_position = my_character.global_position

	var visible_enemies = get_visible_enemies(my_team)
	if visible_enemies.is_empty():
		move_target = Vector2()
		selected_action = actions.get("Idle") if actions.has("Idle") else actions.get("Move")
		return

	var target = get_closest_enemy(my_position, visible_enemies)
	var target_pos = target.global_position

	if randf() < 0.333:  # ajout de guess de mouvement futur par l'IA
		target_pos += randf() ** 0.5 * 256 * Vector2(1, 0).rotated(randf() * 2 * PI)
	
	var visible_allies = get_visible_allies(my_team)
	var focused_allies = get_allies_focused_on_enemy(target, visible_allies, my_position)

	var angle_info = get_my_angle_and_closer_angles(target, focused_allies)
	var my_angle = angle_info["my_angle"]
	var closer_angles = angle_info["closer_angles"]
	
	if angles_are_far_enough(my_angle, closer_angles, angle_minimal):
		var delta_position = target_pos - my_position
		var dist = delta_position.length()
		var direction = delta_position.normalized()
		var rotation_to_target = delta_position.angle()
		var rotation_diff = abs(wrapf(rotation_to_target - angle, -PI, PI))

		var valid_actions = actions.values().filter(func(action):
			return (
				dist < action.expected_position_range() + 64 and  # hardcoded ennemi half size
				rotation_diff < action.expected_rotation_range() + 64 / dist  # hardcoded ennemi half size angle
			)
		)
		
		if valid_actions.size() > 0:
			valid_actions.sort_custom(func(a, b):
				return a.damage > b.damage
			)
			var best_action = valid_actions[0]
			var optimal_distance = best_action.optimal_distance()
			move_target = target_pos - direction * optimal_distance
			
			var min_ally_distance = 192.0
			var closest_ally = null
			var closest_dist = INF
			for ally in focused_allies:
				if ally == my_character:
					continue
				var dist_to_ally = move_target.distance_to(ally.global_position)
				if dist_to_ally < closest_dist:
					closest_dist = dist_to_ally
					closest_ally = ally
			if closest_ally and closest_dist < min_ally_distance:
				var repulse_vec = (move_target - closest_ally.global_position).normalized()
				var needed_dist = min_ally_distance - closest_dist
				move_target += repulse_vec * needed_dist
			
			rotation_target = rotation_to_target
			rotation_intensity = 128.0
			selected_action = best_action
			return
	
	var reposition_pos = compute_reposition_angle(target, focused_allies)
	var move_max_expected = actions.get("Move").expected_position_range()
	move_target = my_position + move_max_expected * (reposition_pos - my_position).normalized()
	rotation_target = (target_pos - move_target).angle()
	rotation_intensity = 128.0
	selected_action = actions.get("Move")
