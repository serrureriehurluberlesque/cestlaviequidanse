class_name Stats
extends Node2D

var stats := {}
var buffs := {}
var actual_round_number := 0

@onready var particles_template := $GPUParticles2D

func start_round(round_number: int):
	actual_round_number = round_number
	_compute_value()

func update_round():
	_compute_value()

func add_buff(tag: String, increase: float, round: int):
	var key = actual_round_number + round
	if not buffs.has(key):
		buffs[key] = {}
	if not buffs[key].has(tag):
		buffs[key][tag] = []
	buffs[key][tag].append(increase)

func add_stat(
	name: String, 
	tags: Dictionary, 
	base_value: float, 
	texture: Texture2D, 
	color: Color, 
):
	# Duplique le template
	var particles = particles_template.duplicate()
	particles.name = "Particles_" + name
	# particles.process_material = particles_template.process_material.duplicate()  # pour l'instant c'est tous les même
	particles.lifetime = particles_template.lifetime
	particles.amount_ratio = 0.0
	particles.emitting = true

	# Applique la texture
	particles.texture = texture

	# Applique la couleur (modulate)
	particles.modulate = color

	add_child(particles)

	stats[name] = {
		"tags": tags,
		"base_value": base_value,
		"value": base_value,
		"texture": texture,
		"color": color,
		"particles": particles
	}

func get_stat(name: String):
	var value = max(0.01, stats[name]["value"])
	return value

func _compute_value():
	for s in stats:
		var v = 0.0
		if buffs.has(actual_round_number):
			for buff in buffs[actual_round_number]:
				if buff in stats[s]["tags"]:
					for value in buffs[actual_round_number][buff]:
						v += stats[s]["tags"][buff] * value
		stats[s]["value"] = v * stats[s]["base_value"]

		# --- Update des particules ---
		var stat = stats[s]
		var diff = abs(stat["value"])
		var amount_ratio = diff / stats[s]["base_value"]
		if stat.has("particles") and stat["particles"]:
			stat["particles"].amount_ratio = amount_ratio
