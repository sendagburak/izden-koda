extends RefCounted
## Two validated generations on disk. No deletion of both slots in a write.
const SCHEMA := 1
var root: String
var last_error: String = ""

func _init(folder: String = "user://profiles") -> void:
	root = folder

func empty_data(profile_id: String) -> Dictionary:
	return {"schema_version": SCHEMA, "generation": 0, "profile_id": profile_id, "completed_ids": [], "reward_ids": [], "settings": {}, "skill_events": []}

func _valid_id(id: String) -> bool:
	return id.is_valid_identifier() and id.length() <= 64

func _folder(id: String) -> String:
	return root.path_join(id)

func _checksum(data: Dictionary) -> String:
	var copy: Dictionary = data.duplicate(true)
	copy.erase("checksum")
	return JSON.stringify(copy, "", true).sha256_text()

func _signed(data: Dictionary) -> Dictionary:
	# Godot reads JSON numbers as floats. Sign the representation a reader sees.
	var out: Dictionary = JSON.parse_string(JSON.stringify(data, "", true))
	out["checksum"] = _checksum(out)
	return out

func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 1024 * 1024:
		return {}
	var raw := file.get_as_text()
	var json := JSON.new()
	if json.parse(raw) != OK:
		return {}
	var data = json.data
	if not (data is Dictionary):
		return {}
	if data.get("schema_version", -1) == 0 and data.has("completed_ids") and data.has("profile_id"):
		# Single explicitly-supported migration, keeps achievements.
		data["schema_version"] = SCHEMA
		data["generation"] = int(data.get("generation", 0))
		data["reward_ids"] = data.get("reward_ids", [])
		data["settings"] = data.get("settings", {})
		data["skill_events"] = data.get("skill_events", [])
		return data
	if int(data.get("schema_version", -1)) != SCHEMA:
		return {}
	var checksum := str(data.get("checksum", ""))
	if checksum != _checksum(data):
		# v0.6 wrote sorted, compact JSON with checksum as its first field.
		var prefix := "{\"checksum\":" + JSON.stringify(checksum) + ","
		if not raw.begins_with(prefix) or ("{" + raw.trim_prefix(prefix)).sha256_text() != checksum:
			return {}
	if not (data.get("completed_ids") is Array) or not (data.get("reward_ids") is Array):
		return {}
	return data

func _has_future_schema(path: String) -> bool:
	var f = FileAccess.open(path, FileAccess.READ)
	if f == null or f.get_length() > 1024 * 1024:
		return false
	var json := JSON.new()
	return json.parse(f.get_as_text()) == OK and json.data is Dictionary and int(json.data.get("schema_version", 1)) > SCHEMA

func load_profile(id: String) -> Dictionary:
	last_error = ""
	if not _valid_id(id):
		last_error = "invalid profile id"
		return {}
	var base: String = _folder(id)
	if _has_future_schema(base.path_join("save.json")) or _has_future_schema(base.path_join("save.bak.json")):
		last_error = "future schema; kept untouched"
		return {}
	var a: Dictionary = _read(base.path_join("save.json"))
	var b: Dictionary = _read(base.path_join("save.bak.json"))
	if a.get("profile_id", id) != id:
		a = {}
	if b.get("profile_id", id) != id:
		b = {}
	if int(b.get("generation", -1)) > int(a.get("generation", -1)):
		return b
	if not a.is_empty():
		return a
	if not b.is_empty():
		return b
	var tmp := base.path_join("save.tmp")
	if _has_future_schema(tmp):
		last_error = "future schema; kept untouched"
		return {}
	var pending := _read(tmp)
	if pending.get("profile_id", "") == id:
		return pending
	if FileAccess.file_exists(base.path_join("save.json")):
		last_error = "unable to recover save"
		return {}
	return empty_data(id)

func save_profile(id: String, payload: Dictionary) -> bool:
	last_error = ""
	if not _valid_id(id) or payload.get("profile_id", "") != id:
		last_error = "profile mismatch"
		return false
	var base: String = _folder(id)
	var main: String = base.path_join("save.json")
	var backup: String = base.path_join("save.bak.json")
	var tmp: String = base.path_join("save.tmp")
	if int(payload.get("schema_version", -1)) > SCHEMA:
		last_error = "future schema"
		return false
	var live: Dictionary = load_profile(id)
	if live.is_empty():
		return false
	# A newer save version must never be replaced by a past version.
	if int(live.get("schema_version", -1)) > SCHEMA:
		last_error = "future schema"
		return false
	var data: Dictionary = payload.duplicate(true)
	data["schema_version"] = SCHEMA
	data["generation"] = max(int(data.get("generation", 0)), int(live.get("generation", 0))) + 1
	data = _signed(data)
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base)) != OK:
		last_error = "cannot create directory"
		return false
	var f = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		last_error = "cannot write temp"
		return false
	f.store_string(JSON.stringify(data, "", true))
	f.flush()
	f.close()
	if _read(tmp).get("checksum", "") != data["checksum"]:
		last_error = "temp verification failed"
		return false
	var old: Dictionary = _read(main)
	var previous: Dictionary = _read(backup)
	if old.get("profile_id", "") == id and (
		previous.get("profile_id", "") != id
		or int(old.get("generation", 0)) > int(previous.get("generation", 0))
	):
		var btmp: String = base.path_join("save.bak.tmp")
		if DirAccess.copy_absolute(ProjectSettings.globalize_path(main), ProjectSettings.globalize_path(btmp)) != OK:
			last_error = "backup copy failed"
			return false
		if _read(btmp).is_empty():
			last_error = "backup verification failed"
			return false
		if DirAccess.rename_absolute(ProjectSettings.globalize_path(btmp), ProjectSettings.globalize_path(backup)) != OK:
			last_error = "backup rename failed"
			return false
	# Replace in a single rename with the last recoverable generation still on disk.
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), ProjectSettings.globalize_path(main)) != OK:
		last_error = "primary rename failed; backup retained"
		return false
	return _read(main).get("checksum", "") == data["checksum"]
