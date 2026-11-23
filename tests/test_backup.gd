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
	var union = io.merge(a,b)
	if union["completed_ids"].size() != 2: return false
	if not io.merge(a,store.empty_data("p2")).is_empty(): return false
	var path: String = "user://backup_roundtrip.alg.json"
	if not io.export_data(union,path): return false
	if io.import_data(path).get("completed_ids", []).size() != 2: return false
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string("broken")
	f.close()
	return io.import_data(path).is_empty()
