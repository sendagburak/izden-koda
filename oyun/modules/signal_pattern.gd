extends "res://oyun/core/puzzle_module.gd"
## Distinct input-output machine: reconstruct an optical signal sequence.
func _params(level: Dictionary, layer: String) -> Dictionary:
	return level.get("layers", {}).get(layer, {}).get("params", {})

func validate_level(level: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for layer in ["concrete", "blocks", "system"]:
		var p = _params(level, layer)
		if p.get("target", []).is_empty():
			errors.append("empty signal: " + layer)
		for token in p.get("target", []):
			if not p.get("alphabet", []).has(token):
				errors.append("target outside alphabet: " + layer)
	return errors

func create_state(_level: Dictionary, layer: String) -> Dictionary:
	return {"sequence": [], "layer": layer}

func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var next_state: Dictionary = state.duplicate(true)
	var p = _params(level, str(state.get("layer", "concrete")))
	var token: String = str(action.get("command", ""))
	if not p.get("alphabet", []).has(token):
		return {"state": next_state, "events": ["blocked"]}
	if next_state["sequence"].size() >= int(p.get("max_steps", 999)):
		return {"state": next_state, "events": ["limit"]}
	next_state["sequence"].append(token)
	return {"state": next_state, "events": ["recorded"]}

func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var target = _params(level, str(state.get("layer", "concrete"))).get("target", [])
	var matched: bool = state.get("sequence", []) == target
	return {"met": matched, "criteria": {"pattern": matched}, "evidence": state.get("sequence", [])}
