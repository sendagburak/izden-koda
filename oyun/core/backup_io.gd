extends RefCounted
const MAX_SIZE := 1024 * 1024

func _digest(data: Dictionary) -> String:
	return JSON.stringify(data, "", true).sha256_text()

func export_data(payload: Dictionary, path: String) -> bool:
	var data: Dictionary = payload.duplicate(true)
	if data.get("profile_id", "").is_empty():
		return false
	var wrapper := {"backup_schema": 1, "data": data, "checksum": _digest(data)}
	var f = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(wrapper, "", true))
	f.flush()
	f.close()
	return true

func import_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var f = FileAccess.open(path, FileAccess.READ)
	if f == null or f.get_length() > MAX_SIZE:
		return {}
	var wrapper = JSON.parse_string(f.get_as_text())
	if not (wrapper is Dictionary) or int(wrapper.get("backup_schema", -1)) != 1:
		return {}
	var data = wrapper.get("data", {})
	if not (data is Dictionary) or str(data.get("profile_id", "")).is_empty():
		return {}
	if _digest(data) != wrapper.get("checksum", ""):
		return {}
	if int(data.get("schema_version", -1)) > 1:
		return {}
	return data

func merge(current: Dictionary, incoming: Dictionary) -> Dictionary:
	if current.get("profile_id", "") != incoming.get("profile_id", ""):
		return {}
	var out: Dictionary = current.duplicate(true)
	for field in ["completed_ids", "reward_ids"]:
		var joined: Array = out.get(field, []).duplicate()
		for element in incoming.get(field, []):
			if not joined.has(element):
				joined.append(element)
		out[field] = joined
	out["generation"] = max(int(current.get("generation", 0)), int(incoming.get("generation", 0)))
	return out
