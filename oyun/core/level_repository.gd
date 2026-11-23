extends RefCounted
const LEVEL_ROOT := "res://veri/levels/"
const SUPPORTED_TYPES := ["grid_route", "signal_pattern", "toggle_board"]
const LAYERS := ["concrete", "blocks", "system"]
var last_error: String = ""

func load_level(level_id: String) -> Dictionary:
	last_error = ""
	if not level_id.begins_with("d1-p1-") or level_id.length() != 9:
		last_error = "invalid level id"
		return {}
	var index = _read_json(LEVEL_ROOT + "index.json")
	for entry in index.get("missions", []):
		if entry.get("id") == level_id:
			var data: Dictionary = _read_json("res://" + str(entry.get("file", "")))
			if not validate_level(data).is_empty():
				last_error = "invalid level data"
				return {}
			return data
	last_error = "level not listed"
	return {}

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}

func validate_level(level: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for field in ["schema_version", "id", "world", "act", "order", "type", "locale_key", "hints", "layers", "concepts"]:
		if not level.has(field):
			errors.append("missing " + field)
	if not errors.is_empty():
		return errors
	if int(level["schema_version"]) != 1 or level["type"] not in SUPPORTED_TYPES:
		errors.append("unsupported level schema or type")
	if level["world"] != "d1" or int(level["act"]) != 1:
		errors.append("incorrect world/act")
	if not (level["hints"] is Array) or level["hints"].size() != 3:
		errors.append("invalid hint tiers")
	if not (level["layers"] is Dictionary):
		errors.append("invalid layers")
		return errors
	for layer in LAYERS:
		if not level["layers"].has(layer):
			errors.append("missing layer " + layer)
		else:
			var data = level["layers"][layer]
			if not data.has("params") or not data.has("witness") or data["witness"].is_empty():
				errors.append("missing params or witness " + layer)
	return errors
