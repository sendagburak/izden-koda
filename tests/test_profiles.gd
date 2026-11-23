extends RefCounted
const Save := preload("res://oyun/core/save_store.gd")
const Progress := preload("res://oyun/core/progress_rules.gd")
func run() -> bool:
	var store = Save.new("user://test_profiles")
	var rules = Progress.new()
	var a = store.empty_data("test_a")
	var b = store.empty_data("test_b")
	a = rules.complete(a, "d1-p1-001")
	a = rules.complete(a, "d1-p1-001")
	if a["completed_ids"].size() != 1: return false
	if not store.save_profile("test_a", a): return false
	if not store.save_profile("test_b", b): return false
	if store.load_profile("test_b")["completed_ids"].size() != 0: return false
	var restored: Dictionary = store.load_profile("test_a")
	if restored["reward_ids"].size() != 1: return false
	# Simulate corrupt current: a verified backup must remain recoverable.
	a = rules.complete(restored, "d1-p1-002")
	if not store.save_profile("test_a", a): return false
	var f = FileAccess.open("user://test_profiles/test_a/save.json", FileAccess.WRITE)
	if f == null: return false
	f.store_string("{corrupt")
	f.close()
	return store.load_profile("test_a")["completed_ids"].has("d1-p1-001")
