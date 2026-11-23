extends RefCounted
const R := preload("res://oyun/core/level_repository.gd")
func run() -> bool:
	var repo = R.new()
	var ids: Array = []
	for i in range(1, 6):
		var id: String = "d1-p1-%03d" % i
		var level: Dictionary = repo.load_level(id)
		if level.is_empty() or not repo.validate_level(level).is_empty() or ids.has(id):
			return false
		ids.append(id)
	var bad: Dictionary = repo.load_level("d1-p1-001")
	bad["type"] = "unknown"
	return not repo.validate_level(bad).is_empty() and repo.load_level("../../bad").is_empty()
