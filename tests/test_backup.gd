extends RefCounted
const Save := preload("res://oyun/core/save_store.gd")
const Backup := preload("res://oyun/core/backup_io.gd")
func run() -> bool:
	var store = Save.new("user://test_backup")
	var io = Backup.new()
	var a = store.empty_data("p1")
	a["completed_ids"] = ["d1-p1-001"]
	var b = store.empty_data("p1")
	b["completed_ids"] = ["d1-p1-002"]
	b["reward_ids"] = ["beacon_d1-p1-002"]
	a["daily_history"] = ["2026-11-20"]
	b["daily_history"] = ["2026-11-21"]
	a["workshop"] = {"step": 2, "choices": [1, 0]}
	b["workshop"] = {"step": 4, "choices": [1, 0, 1, 0]}
	a["workshop_criteria"] = {"hypothesis": true, "reflection": false}
	b["workshop_criteria"] = {"hypothesis": false, "reflection": true}
	var union = io.merge(a,b)
	if union["completed_ids"].size() != 2: return false
	if union["daily_history"].size() != 2: return false
	if union["workshop"]["step"] != 4: return false
	if not union["workshop_criteria"]["hypothesis"]: return false
	if not union["workshop_criteria"]["reflection"]: return false
	if not io.merge(a,store.empty_data("p2")).is_empty(): return false
	var path: String = "user://backup_roundtrip.alg.json"
	var invalid = store.empty_data("profile-with-hyphen")
	if io.export_data(invalid,path): return false
	var oversized = store.empty_data("a".repeat(65))
	if io.export_data(oversized,path): return false
	if not io.export_data(union,path): return false
	if io.import_data(path).get("completed_ids", []).size() != 2: return false
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string("broken")
	f.close()
	return io.import_data(path).is_empty()
