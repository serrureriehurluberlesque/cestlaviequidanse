class_name Poc
extends Node

@onready var splash_screen := $Gui/SplashScreen as SplashScreen
@onready var level_splash_screen := $Gui/LevelSplashScreen as SplashScreen
@onready var world := $World as Node2D

var arena: Arena
var level := 1


func _ready() -> void:
	level_splash_screen.connect("screen_passed", _on_level_splash_screen_screen_passed)
	splash_screen.connect("screen_passed", _on_splash_screen_screen_passed)
	
	splash_screen.start("res://gui/assets/titre.png")  # , "Start?")


func _on_splash_screen_screen_passed(_text) -> void:
	var package = load("res://arena/level/arena_poc_%d.tscn" % [level])
	arena = package.instantiate()
	level_splash_screen.start("res://gui/assets/level.png", arena.TITLE)
	
func _on_level_splash_screen_screen_passed(_text) -> void:
	world.add_child(arena)
	arena.connect("ended", _on_arena_finished)

func _on_arena_finished(is_won) -> void:
	if is_won:
		level += 1
		if level >= 6:
			splash_screen.start("res://gui/assets/fin.png", "", false)
		else:
			splash_screen.start("res://gui/assets/win.png")  # , "You win! Start the next level?")
	else:
		splash_screen.start("res://gui/assets/loose.png")  # , "You loose! Start again this level?")
	arena.queue_free()
