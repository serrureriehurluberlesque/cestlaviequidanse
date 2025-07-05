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
	
	decider.connect("selected_action", select_action)
	decider.connect("updated_ghost", update_ghost)
	
	ghost = $Body/Sprite2D.duplicate()
	$Body.add_child(ghost)
	ghost.hide()
	for action in get_actions().values():
		var ghost_hitbox = action.get_hitbox_ghost()
		ghost_hitbox.hide()
		ghost.add_child(ghost_hitbox)
		ghost_hitboxes[action.name] = ghost_hitbox

func start_selection():
	decider.start_selecting_action(get_actions().values(), get_position(), (get_rotation() - SPRITE_ROTATION), team)

func end_selection():
	decider.end_selecting_action(get_actions().values(), get_position(), (get_rotation() - SPRITE_ROTATION), team)

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
	action = selected_action
	move_target = selected_move_target
	rotation_target = selected_rotation_target
	
	rotation_target += SPRITE_ROTATION
	move_speed = action.move_range
	orientation_speed = action.orientation_range

func update_ghost(selected_action, move_target, rotation_target):
	if selected_action:
		ghost.set_position((move_target - get_position()).rotated(-(get_rotation() - SPRITE_ROTATION) - PI/2))
		ghost.set_rotation(rotation_target - (get_rotation() - SPRITE_ROTATION))
		ghost.show()
	else:
		ghost.hide()
	for action in get_actions():
		if action == (selected_action.name if selected_action else ""):
			ghost_hitboxes[action].show()
		else:
			ghost_hitboxes[action].hide()