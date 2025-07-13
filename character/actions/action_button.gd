class_name ActionButton
extends TextureButton


func set_icon_sprite(path):
	if path.is_absolute_path():
		$TextureRect.set_texture(load(path))
