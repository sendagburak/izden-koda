extends RefCounted
const R := preload("res://oyun/core/level_repository.gd")
const Runner := preload("res://oyun/core/puzzle_runner.gd")
func run() -> bool:
	var repo = R.new()
	var runner = Runner.new()
	for i in range(1, 6):
		var level: Dictionary = repo.load_level("d1-p1-%03d" % i)
		if level.is_empty(): return false
		for layer in ["concrete", "blocks", "system"]:
			if not runner.open(level, layer) or not runner.witness(layer):
				return false
			var steps: Array = level["layers"][layer]["witness"]
			if not runner.submit({"type": "run", "commands": steps}).get("met", false):
				return false
			var proof1: Dictionary = runner.get_result()
			if not runner.submit({"type": "run", "commands": steps}).get("met", false):
				return false
			if proof1 != runner.get_result(): return false
	return true
