class_name Character
extends RigidBody2D

const SPEED = 72.0
const RSPEED = 0.75
const SPRITE_ROTATION = PI / 2

@export var max_health_points:= 100.0
@export var team:= 1
@export var range_indicator : Node2D
@export var color_override : Color


@onready var actions := $Actions as Node2D
@onready var decider := $Decider as Decider
@onready var health_points := max_health_points

var team_colors = {
	1: Color(0.1, 0.1, 0.75),
	2: Color(0.75, 0.1, 0.1),
}

var stats : Stats
var actual_round_number := 0
var ghost: Node2D
var ghost_hitboxes = {}
var damage_stack: Array[float] = []
var action: Action
var move_target: Vector2
var rotation_target: float
var is_moving: bool

var move_speed: float
var orientation_speed: float
var damage: float
var defense: float


func get_color() -> Color:
	if color_override:
		return color_override
	else:
		return team_colors[team]


func _ready() -> void:
	stats = Stats.new()
	stats.add_stat("move", {"move": 1.0}, 2.0)
	stats.add_stat("orientation", {"orientation": 1.0}, 2.0)
	stats.add_stat("area", {"area": 1.0}, 100.0)
	stats.add_stat("damage", {"damage": 1.0}, 20.0)
	stats.add_stat("defense", {"defense": 1.0}, 20.0)
	
	for a in actions.get_children():
		a.hide()
	
	decider.connect("action_selected", select_action)
	decider.connect("updated_ghost", update_ghost)
	

	$Body/Sprite2D/Portrait.set_max_value(max_health_points)
	$Body/Sprite2D/Portrait.set_color(get_color())
	
	for action in get_actions().values():
		action.modulate = get_color()
	
	$Control/LifeBar.max_value = max_health_points
	$Control/LifeBarDamage.max_value = max_health_points
	update_lifebar()
	
	action = get_actions()["Move"]

func create_ghosts():
	ghost = $Body/Sprite2D.duplicate()
	$Body.add_child(ghost)
	ghost.modulate.a = 0.8
	ghost.get_node("Portrait").set_max_value(max_health_points)
	ghost.get_node("Portrait").clean()
	ghost.hide()
	for action in get_actions().values():
		var ghost_hitbox = action.get_hitbox_ghost()
		ghost_hitbox.modulate = get_color()
		if action.has_fast_activation:
			$Body.add_child(ghost_hitbox)
		elif action.has_slow_activation:
			ghost.add_child(ghost_hitbox)

		ghost_hitbox.hide()
		ghost_hitboxes[action.name] = ghost_hitbox

func remove_ghosts():
	ghost.free()

func _physics_process(delta: float) -> void:
	if is_moving:
		if move_speed > 0.0:
			# Linear
			var max_speed = SPEED * move_speed
			var acceleration =  max_speed
			var max_acceleration = 2 * max_speed
			
			var speed = get_linear_velocity()
			
			var dx = move_target - get_position()
			
			var speed_target_squared = 2 * acceleration * dx
			if speed_target_squared.length_squared() > 0.0:
				var speed_target = (speed_target_squared.length() ** 0.5) * speed_target_squared.normalized()
				var dv = speed_target.limit_length(max_speed) - speed
				3
				var a = (dv / delta).limit_length(1 * max_acceleration)
				apply_central_force(mass * a)
				
		if orientation_speed > 0.0:
			# Angular
			var max_rspeed = RSPEED * orientation_speed
			var racceleration =  max_rspeed
			var max_racceleration = 2 * max_rspeed
			
			var rspeed = get_angular_velocity()
			
			var dr = rotation_target - get_rotation()
			if abs(dr) > PI:
				dr = dr - 2 * PI * sign(dr)
				
			var rspeed_target_squared = 2 * racceleration * dr
			if abs(rspeed_target_squared) > 0.0:
				var rspeed_target = (abs(rspeed_target_squared) ** 0.5) * sign(rspeed_target_squared)
				var drv = rspeed_target - rspeed
				
				var ra = max(-1 * max_racceleration, min(drv / delta, 1 * max_racceleration))
				var self_inertia = 1.0 / PhysicsServer2D.body_get_direct_state(get_rid()).inverse_inertia
				
				apply_torque(self_inertia * ra)
	else:
		var v = get_linear_velocity()
		var stop_factor = v.length_squared() / (max(move_speed, 1.0) if move_speed else 1.0)
		apply_central_impulse(-1.0 * mass * v)
		
		var rv = get_angular_velocity()
		var rstop_factor = rv ** 2 / (max(orientation_speed, 1.0) if orientation_speed else 1.0)
		var self_inertia = 1.0 / PhysicsServer2D.body_get_direct_state(get_rid()).inverse_inertia
		
		if self_inertia < INF:
			apply_torque_impulse(-1.0 * self_inertia * rv)


func start_round(round_number):
	stats.start_round(round_number)
	for action in get_actions().values():
		action.update_with_stats(stats)
	create_ghosts()
	decider.start_selecting_action(get_actions(), get_position(), (get_rotation() - SPRITE_ROTATION), team)

func end_selection():
	decider.end_selecting_action(get_actions(), get_position(), (get_rotation() - SPRITE_ROTATION), team)

func start_fast_activations():
	if action and action.has_fast_activation:
		do_attack_activation()

func start_move_activations():
	is_moving = true

func start_slow_activations():
	is_moving = false
	
	if action and action.has_slow_activation:
		do_attack_activation()

func end_round():
	unstack_damage()
	remove_ghosts()

func get_actions():
	var dict_of_actions = {}
	for child in actions.get_children():
		dict_of_actions[child.name] = child
	return dict_of_actions

func do_attack_activation():
	
	action.start_animation()
	
	for target in action.get_hitted_targets():
		if target != self and "hurt" in target:
			target.hurt(damage)

func hurt(damage_received):
	if damage_received > 0:
		var damage_taken = damage_received ** 2 / (damage_received + defense)
		damage_stack.append(damage_taken)
		$Control/LifeBarDamage.set_value($Control/LifeBarDamage.get_value() - damage_taken)

func update_lifebar():
	$Body/Sprite2D/Portrait.set_value(health_points)
	
	$Control/LifeBar.set_value(health_points)

func unstack_damage():
	var total_damage = 0.0
	for damage in damage_stack:
		health_points -= damage
		total_damage += damage
	
	if total_damage > 0.5:
		$Blood.amount = total_damage * 5
		$Blood.restart()
	
	update_lifebar()
	damage_stack = []
	
	if health_points <= 0.0:
		decider.die(get_position())
		queue_free()
	else:
		action = null
		move_target = Vector2.ZERO
		rotation_target = 0

func select_action(selected_action, selected_move_target, selected_rotation_target):
	if selected_action:
		action = selected_action
		move_target = selected_move_target
		rotation_target = selected_rotation_target
		
		rotation_target += SPRITE_ROTATION
		
		action.buff(stats)
		stats.update_round()
		
		move_speed = action.move_range
		orientation_speed = action.orientation_range
		damage = action.damage
		defense = action.defense
		
	else:  # on veut plutôt toujours attribuer une action?
		move_target = get_position()
		rotation_target = get_rotation()
		
		move_speed = 0.0
		orientation_speed = 0.0
		damage = 0.0
		defense = 0.0
		

func update_ghost(selected_action_name, move_target, rotation_target):
	if selected_action_name:
		var ghost_pos = (move_target - get_position()).rotated(-(get_rotation() - SPRITE_ROTATION) - PI/2)
		ghost.set_position((move_target - get_position()).rotated(-(get_rotation() - SPRITE_ROTATION) - PI/2))
		ghost.set_rotation(rotation_target - (get_rotation() - SPRITE_ROTATION))
		ghost.show()
		
		if range_indicator:
			var selected_action = get_actions()[selected_action_name]
			range_indicator.update_ranges(
				selected_action.move_range * Action.MOVE_RANGE_MULTIPLIER,
				selected_action.orientation_range * Action.ORIENTATION_RANGE_MULTIPLIER * 2,
				ghost_pos,
				- SPRITE_ROTATION,
				128.0,
				100.0,
				rotation_target - (get_rotation() - SPRITE_ROTATION) - PI/2,
			)
			range_indicator.show()
	else:
		ghost.hide()
		if range_indicator:
			range_indicator.hide()
	
	for action in get_actions():
		if action == selected_action_name:
			ghost_hitboxes[action].show()
		else:
			ghost_hitboxes[action].hide()
