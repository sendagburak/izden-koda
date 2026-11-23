extends "res://oyun/core/puzzle_module.gd"
## A hand-cranked educational Caesar cipher (not security encryption).
func create_state(_level: Dictionary, layer: String) -> Dictionary:
	return {"shift":0,"turns":0,"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not token in p["alphabet"]: return {"state":s,"events":["blocked"]}
	if int(s["turns"]) >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	s["shift"] = posmod(int(s["shift"]) + (1 if token == "+" else -1), 26)
	s["turns"] += 1
	return {"state":s,"events":["rotated"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var ok: bool = int(state["shift"]) == int(level["layers"][state["layer"]]["params"]["goal_shift"])
	return {"met":ok,"criteria":{"cipher_key":ok}}
