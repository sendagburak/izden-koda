extends "res://oyun/core/puzzle_module.gd"
## Multi-objective plan: attain sufficient benefit while staying within budget.
func create_state(_level: Dictionary, layer: String) -> Dictionary:
	return {"chosen":[],"cost":0,"benefit":0,"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not p["costs"].has(token) or token in s["chosen"]: return {"state":s,"events":["blocked"]}
	if s["chosen"].size() >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	s["chosen"].append(token)
	s["cost"] += int(p["costs"][token])
	s["benefit"] += int(p["benefits"][token])
	return {"state":s,"events":["allocated"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var affordable: bool = int(state["cost"]) <= int(p["budget"])
	var sufficient: bool = int(state["benefit"]) >= int(p["goal"])
	return {"met":affordable and sufficient,"criteria":{"budget":affordable,"coverage":sufficient}}
