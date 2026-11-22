extends "res://oyun/core/puzzle_module.gd"
## Numeric transformation machine; order of operations matters.
func create_state(level: Dictionary, layer: String) -> Dictionary:
	return {"value":int(level["layers"][layer]["params"]["start"]),"turns":0,"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not token in p["alphabet"]: return {"state":s,"events":["blocked"]}
	if int(s["turns"]) >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	if token == "*2": s["value"] *= 2
	elif token == "-1": s["value"] -= 1
	else: s["value"] += int(token)
	s["turns"] += 1
	return {"state":s,"events":["transformed"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var ok: bool = int(state["value"]) == int(level["layers"][state["layer"]]["params"]["goal"])
	return {"met":ok,"criteria":{"target_value":ok}}
