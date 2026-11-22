extends RefCounted
const MAX_SIZE := 1024 * 1024

func _digest(data: Dictionary) -> String:
	return JSON.stringify(data, "", true).sha256_text()

func export_data(payload: Dictionary, path: String) -> bool:
	var data: Dictionary = JSON.parse_string(JSON.stringify(payload, "", true))
	var profile_id: String = str(data.get("profile_id", ""))
	if not profile_id.is_valid_identifier() or not profile_id.length() <= 64:
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
	var raw := f.get_as_text()
	var json := JSON.new()
	if json.parse(raw) != OK:
		return {}
	var wrapper = json.data
	if not (wrapper is Dictionary) or int(wrapper.get("backup_schema", -1)) != 1:
		return {}
	var data = wrapper.get("data", {})
	if not (data is Dictionary):
		return {}
	var profile_id: String = str(data.get("profile_id", ""))
	if not profile_id.is_valid_identifier() or not profile_id.length() <= 64:
		return {}
	var checksum := str(wrapper.get("checksum", ""))
	if _digest(data) != checksum:
		var prefix := "{\"backup_schema\":1,\"checksum\":" + JSON.stringify(checksum) + ",\"data\":"
		if not raw.begins_with(prefix) or not raw.ends_with("}") or raw.trim_prefix(prefix).trim_suffix("}").sha256_text() != checksum:
			return {}
	if int(data.get("schema_version", -1)) > 1:
		return {}
	for key in ["completed_ids", "reward_ids", "daily_history", "skill_events"]:
		if not (data.get(key, []) is Array):
			return {}
	for key in ["settings", "workshop", "workshop_criteria", "last_attempt"]:
		if not (data.get(key, {}) is Dictionary):
			return {}
	return data

func merge(current: Dictionary, incoming: Dictionary) -> Dictionary:
	if current.get("profile_id", "") != incoming.get("profile_id", ""):
		return {}
	var out: Dictionary = current.duplicate(true)
	for field in ["completed_ids", "reward_ids", "daily_history", "skill_events"]:
		var joined: Array = out.get(field, []).duplicate(true)
		for element in incoming.get(field, []):
			if not joined.has(element):
				joined.append(element)
		out[field] = joined
	var local_workshop: Dictionary = current.get("workshop", {})
	var remote_workshop: Dictionary = incoming.get("workshop", {})
	if int(remote_workshop.get("step", 0)) > int(local_workshop.get("step", 0)):
		out["workshop"] = remote_workshop.duplicate(true)
	var criteria: Dictionary = current.get("workshop_criteria", {}).duplicate(true)
	for key in incoming.get("workshop_criteria", {}).keys():
		criteria[key] = bool(criteria.get(key, false)) or bool(incoming["workshop_criteria"][key])
	if not criteria.is_empty(): out["workshop_criteria"] = criteria
	if not out.has("last_attempt") and incoming.has("last_attempt"):
		out["last_attempt"] = incoming["last_attempt"].duplicate(true)
	out["generation"] = max(int(current.get("generation", 0)), int(incoming.get("generation", 0)))
	return out
