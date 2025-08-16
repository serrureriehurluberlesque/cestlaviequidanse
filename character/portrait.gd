class_name Portrait
extends Node2D

const SPRITE_HEIGHT = 128.0

var max_value: float


func _ready() -> void:
	for s in [$Background, $Character]:
		s.texture = s.texture.duplicate()


func set_max_value(_max_value) -> void:
	max_value = _max_value


func set_value(value) -> void:
	for s in [$Background, $Character]:
		var r = s.texture.region
		var h = min(SPRITE_HEIGHT, max(0, round(SPRITE_HEIGHT * value / max_value)))
		r.size = Vector2(r.size.x, h)
		r.position = Vector2(0, SPRITE_HEIGHT -h)
		s.texture.region = r
		s.position = Vector2(0, SPRITE_HEIGHT -h)


func set_color(_color) -> void:
	$Background.modulate = _color
	$BackgroundDead.modulate = _color.darkened(0.8)


func clean():
	set_value(max_value)
	$BackgroundDead.queue_free()
	$CharacterDead.queue_free()
