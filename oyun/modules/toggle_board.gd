extends "res://oyun/core/puzzle_module.gd"
## A signal panel: switches operate other lamps according to wiring.
func _params(level: Dictionary, layer: String) -> Dictionary:
	return level.get("layers", {}).get(layer, {}).get("params", {})
func validate_level(level: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for layer in ["concrete", "blocks", "system"]:
		var p: Dictionary = _params(level, layer)
		if not p.has("initial") or not p.has("goal") or not p.has("wiring"):
			errors.append("missing panel: " + layer)
		elif p["initial"].size() != p["goal"].size():
			errors.append("lamp count mismatch: " + layer)
	return errors
func create_state(level: Dictionary, layer: String) -> Dictionary:
	return {"lamps": _params(level, layer).get("initial", []).duplicate(), "turns": 0, "layer": layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var next_state = state.duplicate(true)
	var p = _params(level, str(state.get("layer", "concrete")))
	var key: String = str(action.get("command", ""))
	if not p.get("wiring", {}).has(key):
		return {"state": next_state, "events": ["blocked"]}
	if int(state.get("turns", 0)) >= int(p.get("max_steps", 99)):
		return {"state": next_state, "events": ["limit"]}
	for index in p["wiring"][key]:
		var i: int = int(index)
		if i < 0 or i >= next_state["lamps"].size():
			return {"state": state.duplicate(true), "events": ["blocked"]}
		next_state["lamps"][i] = 1 - int(next_state["lamps"][i])
	next_state["turns"] = int(state.get("turns", 0)) + 1
	return {"state": next_state, "events": ["switched"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var goal = _params(level, str(state.get("layer", "concrete"))).get("goal", [])
	var matched: bool = state.get("lamps", []) == goal
	return {"met": matched, "criteria": {"lamps": matched}, "evidence": state.get("lamps", [])}
