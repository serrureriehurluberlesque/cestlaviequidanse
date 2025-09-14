class_name WeaponSprite
extends Node2D

const SPRITE_HEIGHT = 128.0

enum WeaponTypes {
	MOVE,
	SWORD,
	SPEAR,
	DAGGER,
	SHIELD,
}

var sprite_paths = {
	WeaponTypes.MOVE: "foot",
	WeaponTypes.SWORD: "sword",
	WeaponTypes.SPEAR: "spear",
	WeaponTypes.DAGGER: "dagger",
	WeaponTypes.SHIELD: "shield",
}


func set_size(_size) -> void:
	$Border.scale = Vector2(_size.x / SPRITE_HEIGHT, _size.y / SPRITE_HEIGHT)


func set_weapon(_weapon_type) -> void:
	if get_sprite_path(_weapon_type):
		$Sprite.texture = load(get_sprite_path(_weapon_type))


func get_sprite_path(_weapon_type):
	return "res://character/actions/assets/%s.png" % [sprite_paths[_weapon_type]]
