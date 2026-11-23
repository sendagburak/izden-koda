extends SceneTree
const SCRIPTS := [
	"res://tests/test_boot.gd", "res://tests/test_repository.gd", "res://tests/test_puzzles.gd",
	"res://tests/test_locales.gd", "res://tests/test_profiles.gd", "res://tests/test_backup.gd", "res://tests/test_resume.gd"
]
func _initialize() -> void:
	var failures: int = 0
	for path in SCRIPTS:
		var test_script = load(path)
		if test_script == null:
			printerr("FAIL missing ", path)
			failures += 1
			continue
		var test = test_script.new()
		if not test.run():
			printerr("FAIL ", path)
			failures += 1
		else:
			print("PASS ", path.get_file())
	print("TEST RESULT: ", SCRIPTS.size() - failures, "/", SCRIPTS.size())
	quit(1 if failures > 0 else 0)
