class_name Poc
extends Node

@onready var splash_screen := $Gui/SplashScreen as SplashScreen
@onready var world := $World as Node2D
var arena: Arena


func _ready() -> void:
	splash_screen.connect("screen_passed", _on_splash_screen_screen_passed)
	
	splash_screen.start("Start?")


func _on_splash_screen_screen_passed(_text) -> void:
	var package = load("res://arena/level/arena_poc_0.tscn")
	arena = package.instantiate()
	world.add_child(arena)
	arena.connect("ended", _on_arena_finished)

func _on_arena_finished(is_won) -> void:
	if is_won:
		splash_screen.start("You win! Start again?")
	else:
		splash_screen.start("You loose! Start again?")
	arena.queue_free()
