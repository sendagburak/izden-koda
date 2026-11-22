extends RefCounted
const LEVEL_ROOT := "res://veri/levels/"
const SUPPORTED_TYPES := ["grid_route", "signal_pattern", "toggle_board", "sort_train", "binary_lights", "cipher_wheel", "flowchart", "logic_gate", "pattern_machine", "resource_plan", "sensor_lab", "robot_course", "graph_path", "function_loops", "state_machine", "data_detective"]
const LAYERS := ["concrete", "blocks", "system"]
var last_error: String = ""

func load_level(level_id: String) -> Dictionary:
	last_error = ""
	if level_id.length() != 9 or not level_id.begins_with("d") or level_id.substr(2, 2) != "-p" or level_id.substr(5, 1) != "-":
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
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
		return _normalize_json_numbers(json.data)
	return {}

func _normalize_json_numbers(value: Variant) -> Variant:
	# JSON numbers are floats in Godot. Array equality distinguishes 1 from 1.0.
	if value is float and is_finite(value) and absf(value) <= 9007199254740991.0 and floorf(value) == value:
		return int(value)
	if value is Array:
		for index in range(value.size()):
			value[index] = _normalize_json_numbers(value[index])
	elif value is Dictionary:
		for key in value:
			value[key] = _normalize_json_numbers(value[key])
	return value

func validate_level(level: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for field in ["schema_version", "id", "world", "act", "order", "type", "locale_key", "hints", "layers", "concepts"]:
		if not level.has(field):
			errors.append("missing " + field)
	if not errors.is_empty():
		return errors
	if int(level["schema_version"]) != 1 or level["type"] not in SUPPORTED_TYPES:
		errors.append("unsupported level schema or type")
	if str(level["world"]) not in ["d1", "d2", "d3", "d4", "d5", "d6", "d7"] or int(level["act"]) < 1 or int(level["act"]) > 5:
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
