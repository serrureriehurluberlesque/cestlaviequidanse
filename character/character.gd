class_name Character
extends RigidBody2D

const SPEED = 72.0
const RSPEED = 1.35
const SPRITE_ROTATION = PI / 2

@export var max_health_points:= 100.0
@export var team:= 1

@onready var actions := $Actions as Node2D
@onready var decider := $Decider as Decider
@onready var health_points := max_health_points
var ghost: Node2D
var ghost_hitboxes = {}
var damage_stack: Array[float] = []
var action: Action
var move_target: Vector2
var rotation_target: float
var move_speed: float
var orientation_speed: float
var is_moving: bool

func _ready() -> void:
	for a in actions.get_children():
		a.hide()
	
	decider.connect("action_selected", select_action)
	decider.connect("updated_ghost", update_ghost)
	
	ghost = $Body/Sprite2D.duplicate()
	$Body.add_child(ghost)
	ghost.hide()
	for action in get_actions().values():
		var ghost_hitbox = action.get_hitbox_ghost()
		if action.has_fast_activation:
			$Body.add_child(ghost_hitbox)
		else :
			ghost.add_child(ghost_hitbox)

		ghost_hitbox.hide()
		ghost_hitboxes[action.name] = ghost_hitbox

	$Control/LifeBar.max_value = max_health_points
	$Control/LifeBarDamage.max_value = max_health_points
	update_lifebar()
	
	action = get_actions()["Move"]


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
			   #if stop_factor:
					   #print(stop_factor)
		apply_central_impulse(-1.0 * mass * v)
		
		var rv = get_angular_velocity()
		var rstop_factor = rv ** 2 / (max(orientation_speed, 1.0) if orientation_speed else 1.0)
			   #if rstop_factor:
					   #print(rstop_factor)
		var self_inertia = 1.0 / PhysicsServer2D.body_get_direct_state(get_rid()).inverse_inertia
		
		if self_inertia < INF:
			apply_torque_impulse(-1.0 * self_inertia * rv)


func start_round():
	decider.start_selecting_action(get_actions(), get_position(), (get_rotation() - SPRITE_ROTATION), team)

func end_selection():
	decider.end_selecting_action(get_actions(), get_position(), (get_rotation() - SPRITE_ROTATION), team)

func start_fast_activations():
	if action.has_fast_activation:
		do_attack_activation()

func start_move_activations():
	is_moving = true

func start_slow_activations():
	is_moving = false
	
	if action.has_slow_activation:
		do_attack_activation()

func end_round():
	unstack_damage()

func get_actions():
	var dict_of_actions = {}
	for child in actions.get_children():
		dict_of_actions[child.name] = child
	return dict_of_actions

func do_attack_activation():
	action.start_animation()
	
	for target in action.get_hitted_targets():
		if target != self:
			target.hurt(action.damage)

func hurt(damage):
	damage_stack.append(damage)
	$Control/LifeBarDamage.set_value($Control/LifeBarDamage.get_value() - damage)

func update_lifebar():
	$Control/LifeBar.set_value(health_points)

func unstack_damage():
	for damage in damage_stack:
		health_points -= damage
	
	update_lifebar()
	damage_stack = []
	
	if health_points <= 0.0:
		queue_free()

func select_action(selected_action, selected_move_target, selected_rotation_target):
	if selected_action:
		action = selected_action
		move_target = selected_move_target
		rotation_target = selected_rotation_target
		
		rotation_target += SPRITE_ROTATION
		move_speed = action.move_range
		orientation_speed = action.orientation_range

func update_ghost(selected_action_name, move_target, rotation_target):
	if selected_action_name:
		ghost.set_position((move_target - get_position()).rotated(-(get_rotation() - SPRITE_ROTATION) - PI/2))
		ghost.set_rotation(rotation_target - (get_rotation() - SPRITE_ROTATION))
		ghost.show()
	else:
		ghost.hide()
	for action in get_actions():
		if action == selected_action_name:
			ghost_hitboxes[action].show()
		else:
			ghost_hitboxes[action].hide()
