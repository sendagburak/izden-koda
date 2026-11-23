extends SceneTree
const Repo := preload("res://oyun/core/level_repository.gd")
const Runner := preload("res://oyun/core/puzzle_runner.gd")
const Locale := preload("res://oyun/core/locale_service.gd")
func _initialize() -> void:
	var repo = Repo.new()
	var runner = Runner.new()
	var locale = Locale.new()
	var errors: Array = []
	var validated: int = 0
	for i in range(1, 6):
		var id: String = "d1-p1-%03d" % i
		var level: Dictionary = repo.load_level(id)
		if level.is_empty():
			errors.append(id + " missing")
			continue
		for key in [str(level.get("locale_key","")), "mission.desc." + id] + level.get("hints", []):
			if not locale.available(key):
				errors.append("missing localization " + key)
		for layer in ["concrete", "blocks", "system"]:
			if not runner.open(level, layer) or not runner.witness(layer):
				errors.append(id + " unsolved " + layer)
			else:
				validated += 1
	for problem in errors:
		printerr(problem)
	print("Godot witness checker: ", validated, " / 15; errors=", errors.size())
	quit(0 if errors.is_empty() else 1)
