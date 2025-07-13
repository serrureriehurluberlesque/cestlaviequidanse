class_name SplashScreen
extends TextureButton

signal screen_passed(text)

const MINIMUM_DURATION = 1.0

@onready var text := $Text as RichTextLabel
var skippable = true

func _ready() -> void:
	connect("pressed", _on_pressed)


func _on_pressed() -> void:
	#if MINIMUM_DURATION...
	if skippable:
		hide()
		emit_signal("screen_passed", text.get_text())
		text.set_text("")


func start(path, init_text := "", _skippable := true):
	if not _skippable:
		skippable = false
	show()
	texture_normal = load(path)
	text.set_text(init_text)
