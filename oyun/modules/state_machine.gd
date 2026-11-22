extends "res://oyun/core/puzzle_module.gd"
## Deterministic state transition automaton.
func create_state(level: Dictionary, layer: String) -> Dictionary:
	return {"mode":str(level["layers"][layer]["params"]["start"]),"events":[],"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	var allowed: Dictionary = p["transitions"].get(s["mode"],{})
	if not allowed.has(token): return {"state":s,"events":["blocked"]}
	if s["events"].size() >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	s["mode"] = allowed[token]
	s["events"].append(token)
	return {"state":s,"events":["transitioned"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var ok: bool = state["mode"] == level["layers"][state["layer"]]["params"]["goal"]
	return {"met":ok,"criteria":{"state":ok}}
