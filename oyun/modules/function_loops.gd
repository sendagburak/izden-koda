extends "res://oyun/core/puzzle_module.gd"
## Call tiny reusable procedures to assemble a pattern.
func create_state(_level: Dictionary, layer: String) -> Dictionary:
	return {"sequence":"","calls":[],"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not p["macros"].has(token): return {"state":s,"events":["blocked"]}
	if s["calls"].size() >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	s["calls"].append(token)
	s["sequence"] += str(p["macros"][token])
	return {"state":s,"events":["called"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var matched: bool = str(state["sequence"]) == str(p["target"])
	var concise: bool = state["calls"].size() < str(p["target"]).length()
	return {"met":matched and concise,"criteria":{"pattern":matched,"abstraction":concise}}
