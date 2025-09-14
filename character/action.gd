class_name Action
extends Node2D

const MOVE_RANGE_MULTIPLIER = 128.0
const ORIENTATION_RANGE_MULTIPLIER = PI/2.0

@export var weapon_type := WeaponSprite.WeaponTypes.MOVE
@export var move_range:= 1.0
@export var orientation_range:= 1.0
@export var damage:= 10.0
@export var has_slow_activation:= false
@export var has_fast_activation:= false
@export var buff_tag:= ""
@export var buff_value:= 0.0
@export var action_is_buff:= false

var base_size
@onready var hitbox := $Hitbox as Area2D
@onready var animation_time := $AnimationTime as Timer
@onready var weapon_sprite := $Hitbox/WeaponSprite as WeaponSprite

func _ready() -> void:
	animation_time.connect("timeout", _stop_animation)
	
	base_size = $Hitbox/Shape.shape.size
	update_aoe(1.0, 1.0)
	
	weapon_sprite.set_weapon(weapon_type)


func update_aoe(x, y):
	var s = Vector2(base_size.x * x, base_size.y * y)
	$Hitbox/Shape.shape.size = s
	weapon_sprite.set_size(s)


func get_hitted_targets():
	return hitbox.get_overlapping_bodies()


func start_animation():
	show()
	animation_time.start()


func _stop_animation():
	hide()


func get_hitbox_ghost():
	return $Hitbox.duplicate()


func get_icon():
	var icon = load("res://character/actions/action_button.tscn").instantiate()
	icon.set_icon_sprite(weapon_sprite.get_sprite_path(weapon_type))
	return icon


func buff(stats: Stats):
	if action_is_buff:
		stats.add_buff(buff_tag, buff_value * 4, 0)
	stats.add_buff(buff_tag, buff_value * 2, 1)
	stats.add_buff(buff_tag, buff_value, 2)

# ---- Ajouts pour l'IA ----

func expected_position_range() -> float:
	var hitbox_y = abs(hitbox.position.y)
	var shape = hitbox.get_node("Shape")
	var hitbox_height = 0.0
	if shape and shape.has_method("get_rect"):
		hitbox_height = shape.get_rect().size.y
	return move_range * MOVE_RANGE_MULTIPLIER + hitbox_y + hitbox_height / 2.0


func expected_rotation_range() -> float:
	return orientation_range * ORIENTATION_RANGE_MULTIPLIER


func optimal_distance() -> float:
	return abs(hitbox.position.y)
