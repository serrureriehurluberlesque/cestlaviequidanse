class_name SplashScreen
extends Control

signal screen_passed(text)

const MINIMUM_DURATION = 1.0

@onready var text := $Text as RichTextLabel


func _ready() -> void:
	connect("pressed", _on_pressed)


func _on_pressed() -> void:
	#if MINIMUM_DURATION...
	hide()
	emit_signal("screen_passed", text.get_text())
	text.set_text("")


func start(init_text := ""):
	show()
	text.set_text(init_text)
