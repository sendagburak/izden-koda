extends RefCounted
## Each mission module owns its own mechanics; all share this small contract.
func validate_level(_level: Dictionary) -> PackedStringArray:
	return PackedStringArray()
func create_state(_level: Dictionary, _layer: String) -> Dictionary:
	return {}
func apply_action(_level: Dictionary, state: Dictionary, _action: Dictionary) -> Dictionary:
	return {"state": state.duplicate(true), "events": []}
func evaluate(_level: Dictionary, _state: Dictionary) -> Dictionary:
	return {"met": false, "criteria": {}, "evidence": []}
func explain_hint(level: Dictionary, _state: Dictionary, tier: int) -> Dictionary:
	var hints: Array = level.get("hints", [])
	if tier < 1 or tier > hints.size():
		return {}
	return {"key": hints[tier - 1]}
func verify_witness(level: Dictionary, layer: String) -> bool:
	if not level.get("layers", {}).has(layer):
		return false
	var state: Dictionary = create_state(level, layer)
	for command in level["layers"][layer].get("witness", []):
		var result: Dictionary = apply_action(level, state, {"command": command, "layer": layer})
		if result.get("events", []).has("blocked") or result.get("events", []).has("limit"):
			return false
		state = result["state"]
	return bool(evaluate(level, state).get("met", false))
