class_name WeaponSprite
extends Node2D

const SPRITE_HEIGHT = 128.0

enum WeaponTypes {
	MOVE,
	SWORD,
	SPEAR,
	DAGGER,
}

var sprite_paths = {
	WeaponTypes.MOVE: "",
	WeaponTypes.SWORD: "sword",
	WeaponTypes.SPEAR: "spear",
	WeaponTypes.DAGGER: "dagger",
}


func set_size(_size) -> void:
	$Border.scale = Vector2(_size.x / SPRITE_HEIGHT, _size.y / SPRITE_HEIGHT)


func set_weapon(_weapon_type) -> void:
	if sprite_paths[_weapon_type]:
		$Sprite.texture = load("res://character/actions/assets/%s.png" % [sprite_paths[_weapon_type]])
