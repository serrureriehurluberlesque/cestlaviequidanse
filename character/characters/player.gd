class_name Player
extends Decider

signal drop_camera(pos)

enum SelectionSteps {
	NONE,
	ACTION,
	POSITION,
	ROTATION,
	SELECTED,
}

@onready var selection_ui := $Selection/SelectionUI as Control
@onready var actions_ui := $Selection/SelectionUI/Footer/HBoxContainer as Control

var actual_position: Vector2
var actual_rotation: float
var selection_step: SelectionSteps

var action_matching = {}

func _ready() -> void:
	selection_ui.hide()

func init_buttons(actions) -> void:
	var i = 1
	for action_name in actions:
		var button = actions[action_name].get_icon()
		button.set_name(action_name)
		actions_ui.add_child(button)
		button.toggled.connect(button_toggled.bind(actions[action_name]))
		action_matching[i] = actions[action_name]
		i += 1

func remove_buttons():
	action_matching = {}
	for button in actions_ui.get_children():
		button.queue_free()

func _unhandled_input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.pressed and is_selection_step(SelectionSteps.POSITION):
			move_target = mouse_event_to_game(event.position)
			set_selection_step(SelectionSteps.ROTATION)
		elif not event.pressed and is_selection_step(SelectionSteps.ROTATION):
			var orientation_target = mouse_event_to_game(event.position)
			if (orientation_target - move_target).length() > 0.0001:
				rotation_target = (orientation_target - move_target).angle()
			set_selection_step(SelectionSteps.SELECTED)
	elif event is InputEventMouseMotion:
		if is_selection_step(SelectionSteps.ACTION):
			move_target = mouse_event_to_game(event.position)
		elif is_selection_step(SelectionSteps.POSITION):
			move_target = mouse_event_to_game(event.position)
			update_ghost()
		elif is_selection_step(SelectionSteps.ROTATION):
			var orientation_target = mouse_event_to_game(event.position)
			if (orientation_target - move_target).length() > 0.0001:
				rotation_target = (orientation_target - move_target).angle()
			update_ghost()
	for i in range(1,5):
		if event.is_action_pressed("action%d" % [i]) and i in action_matching:
			select_action(action_matching[i])


func mouse_event_to_game(event_position):
	var game_position = (get_viewport().get_canvas_transform()).affine_inverse() * event_position  # get_viewport().get_screen_transform() * 
	return game_position


func set_selection_step(step):
	selection_step = step
	if step == SelectionSteps.POSITION or step == SelectionSteps.ROTATION or step == SelectionSteps.SELECTED:
		update_ghost()

func is_selection_step(step):
	return selection_step == step

func button_toggled(pressed, action):
	select_action(action)

func select_action(action):
	if not is_selection_step(SelectionSteps.NONE):
		if selected_action:
			unselect_action(selected_action)
		actions_ui.get_node(str(action.name)).set_pressed_no_signal(true)
		selected_action = action
		set_selection_step(SelectionSteps.POSITION)

func unselect_action(action, hard=true):
	actions_ui.get_node(str(action.name)).set_pressed_no_signal(false)
	if hard:
		selected_action = null

func _start_selecting_action(actions, position, angle, team):
	init_buttons(actions)
	selection_ui.show()
	set_selection_step(SelectionSteps.ACTION)
	
	actual_position = position
	actual_rotation = angle
	move_target = position
	rotation_target = angle

func _end_selecting_action(actions, position, angle, team):
	if selected_action:
		unselect_action(selected_action, false)
	set_selection_step(SelectionSteps.NONE)
	selection_ui.hide()
	remove_buttons()


func _die(pos):
	drop_camera.emit(pos)
