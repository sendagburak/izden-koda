extends RefCounted
const PATH := "user://profiles/profiles.json"
var entries: Array = []
var selected: String = ""

func _safe_read(path: String) -> Dictionary:
	var f = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var data = JSON.parse_string(f.get_as_text())
	if data is Dictionary and data.get("profiles") is Array:
		return data
	return {}

func open() -> void:
	var data: Dictionary = _safe_read(PATH)
	if data.is_empty():
		data = _safe_read(PATH + ".bak")
	entries = data.get("profiles", [])
	selected = str(data.get("selected", ""))
	if entries.is_empty():
		_recover_existing()
		if entries.is_empty():
			create_profile("Oyuncu 1")
		else:
			selected = str(entries[0]["id"])
			persist()
	elif not has_profile(selected):
		selected = str(entries[0]["id"])
		persist()

func _recover_existing() -> void:
	# Corrupt manifest is not permission to hide existing student records.
	var dir = DirAccess.open("user://profiles")
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var name = dir.get_next()
		if name.is_empty(): break
		if not dir.current_is_dir() or not name.is_valid_identifier(): continue
		var save = load("res://oyun/core/save_store.gd").new()
		var record: Dictionary = save.load_profile(name)
		if int(record.get("generation", 0)) > 0 and record.get("profile_id", "") == name:
			entries.append({"id":name,"title":"Oyuncu " + str(entries.size() + 1)})
	dir.list_dir_end()

func has_profile(id: String) -> bool:
	for p in entries:
		if p.get("id", "") == id:
			return true
	return false

func create_profile(title: String) -> String:
	var id: String = "p_" + str(Time.get_ticks_usec()) + "_" + str(randi())
	entries.append({"id": id, "title": title.substr(0, 30)})
	selected = id
	persist()
	return id

func select_profile(id: String) -> bool:
	if not has_profile(id):
		return false
	selected = id
	persist()
	return true

func persist() -> bool:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://profiles"))
	var tmp: String = PATH + ".tmp"
	var f = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify({"profiles": entries, "selected": selected}, "", true))
	f.flush()
	f.close()
	if _safe_read(tmp).is_empty():
		return false
	if FileAccess.file_exists(PATH):
		DirAccess.copy_absolute(ProjectSettings.globalize_path(PATH), ProjectSettings.globalize_path(PATH + ".bak"))
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), ProjectSettings.globalize_path(PATH)) == OK

func title_for(id: String) -> String:
	for p in entries:
		if p.get("id", "") == id:
			return str(p.get("title", ""))
	return ""
