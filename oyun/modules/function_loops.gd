extends "res://oyun/core/puzzle_module.gd"
## Call tiny reusable procedures to assemble a pattern.
func create_state(_level: Dictionary, layer: String) -> Dictionary:
	return {"sequence":"","calls":[],"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not token in p["alphabet"]: return {"state":s,"events":["blocked"]}
	var parts := token.split("*")
	if not p["macros"].has(parts[0]) or parts.size() > 2:
		return {"state":s,"events":["blocked"]}
	if parts.size() == 2 and parts[1] not in ["2", "3"]:
		return {"state":s,"events":["blocked"]}
	if s["calls"].size() >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	s["calls"].append(token)
	var repetitions := int(parts[1]) if parts.size() == 2 else 1
	s["sequence"] += str(p["macros"][parts[0]]).repeat(repetitions)
	return {"state":s,"events":["called"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var matched: bool = str(state["sequence"]) == str(p["target"])
	var concise: bool = state["calls"].size() < str(p["target"]).length()
	return {"met":matched and concise,"criteria":{"pattern":matched,"abstraction":concise}}
