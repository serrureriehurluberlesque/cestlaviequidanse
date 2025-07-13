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
	
	splash_screen.start("Start?")


func _on_splash_screen_screen_passed(_text) -> void:
	var package = load("res://arena/level/arena_poc_%d.tscn" % [level])
	arena = package.instantiate()
	level_splash_screen.start(arena.TITLE)
	
func _on_level_splash_screen_screen_passed(_text) -> void:
	world.add_child(arena)
	arena.connect("ended", _on_arena_finished)

func _on_arena_finished(is_won) -> void:
	if is_won:
		level += 1
		splash_screen.start("You win! Start the next level?")
	else:
		splash_screen.start("You loose! Start again this level?")
	arena.queue_free()
