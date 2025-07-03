class_name Action
extends Node2D


@export var move_range:= 1.0
@export var orientation_range:= 1.0
@export var damage:= 10.0
@export var has_slow_activation:= false
@export var has_fast_activation:= false

@onready var hitbox := $Hitbox as Area2D
@onready var animation_time := $AnimationTime as Timer


func _ready() -> void:
	animation_time.connect("timeout", _stop_animation)


func get_hitted_targets():
	return hitbox.get_overlapping_bodies()


func start_animation():
	show()
	animation_time.start()


func _stop_animation():
	hide()


func get_hitbox_ghost():
	return $Hitbox.duplicate()
