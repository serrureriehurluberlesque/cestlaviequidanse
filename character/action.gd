class_name Action
extends Node2D

const MOVE_RANGE_MULTIPLIER = 128.0
const ORIENTATION_RANGE_MULTIPLIER = PI/2.0

@export var move_range:= 1.0
@export var orientation_range:= 1.0
@export var damage:= 10.0
@export var defense:= 10.0

@export var weapon_type := WeaponSprite.WeaponTypes.MOVE
@export var has_slow_activation:= false
@export var has_fast_activation:= false
@export var buff_tag:= ""
@export var buff_value:= 0.0

var base_size
var base_move_range
var base_orientation_range
var base_damage
var base_defense

@onready var hitbox := $Hitbox as Area2D
@onready var animation_time := $AnimationTime as Timer
@onready var weapon_sprite := $Hitbox/WeaponSprite as WeaponSprite

func _ready() -> void:
	animation_time.connect("timeout", _stop_animation)
	
	base_size = $Hitbox/Shape.shape.size
	base_move_range = move_range
	base_orientation_range = orientation_range
	base_damage = damage
	base_defense = defense
	update_with_stats()
	
	weapon_sprite.set_weapon(weapon_type)


func update_with_stats(stats=null):
	var x = stats.get_stat("area") if stats else 0.0
	var y = stats.get_stat("area") if stats else 0.0
	var s = Vector2(base_size.x + x, base_size.y + y)
	$Hitbox/Shape.shape.size = s
	weapon_sprite.set_size(s)
	
	move_range = base_move_range + stats.get_stat("move") if stats else 0.0
	orientation_range = base_orientation_range + stats.get_stat("orientation") if stats else 0.0
	damage = base_damage + stats.get_stat("damage") if stats else 0.0
	defense = base_defense + stats.get_stat("defense") if stats else 0.0


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
	stats.add_buff(buff_tag, buff_value * 2.0, 1)
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
	var base = orientation_range * ORIENTATION_RANGE_MULTIPLIER
	var hitbox_width = 0.0
	var hitbox_length = 0.0
	if hitbox and hitbox.has_node("Shape"):
		var shape = hitbox.get_node("Shape").shape
		if shape and shape.has_method("get_rect"):
			hitbox_width = shape.get_rect().size.x / 2.0
			hitbox_length = max(1, abs(abs(hitbox.position.y) - (shape.get_rect().size.y / 2.0)))
	# Utilise la distance d’attaque comme distance de référence pour calculer l’angle supplémentaire
	var extra_angle = 0.0
	if hitbox_width > 0 and hitbox_length > 0:
		extra_angle = atan(hitbox_width / hitbox_length)
	return base + extra_angle


func optimal_distance() -> float:
	return abs(hitbox.position.y)
