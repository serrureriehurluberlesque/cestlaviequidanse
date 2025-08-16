class_name Stats

var stats := {}
var buffs := {}
var actual_round_number := 0


func start_round(round_number: int):
	actual_round_number = round_number
	_compute_value()


func add_buff(tag: String, increase: float, duration: int):
	for t in duration:
		var key = actual_round_number + t + 1
		if not buffs.has(key):
			buffs[key] = {}
		if not buffs[key].has(tag):
			buffs[key][tag] = []
		buffs[key][tag].append(increase)


func add_stat(name: String, tags: Dictionary, base_value: float):
	stats[name] = {"tags": tags, "base_value": base_value, "value": base_value}


func get_stat(name: String):
	return max(0.01, stats[name]["value"])


func _compute_value():
	for s in stats:
		var v = 1.0
		if buffs.has(actual_round_number):
			for buff in buffs[actual_round_number]:
				if buff in stats[s]["tags"]:
					for value in buffs[actual_round_number][buff]:
						v += stats[s]["tags"][buff] * value
		stats[s]["value"] = v * stats[s]["base_value"]
