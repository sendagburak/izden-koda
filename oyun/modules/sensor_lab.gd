extends "res://oyun/core/puzzle_module.gd"
## Set sensor threshold and activate local automatic control.
func create_state(_level: Dictionary, layer: String) -> Dictionary:
	return {"threshold":1,"auto":false,"turns":0,"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not token in p["alphabet"]: return {"state":s,"events":["blocked"]}
	if int(s["turns"]) >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	if token == "AUTO": s["auto"] = true
	else: s["threshold"] = int(token.substr(1))
	s["turns"] += 1
	return {"state":s,"events":["configured"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var readings_ok: bool = true
	for v in p["samples"]:
		if (int(v) < int(state["threshold"])) != (int(v) < int(p["goal_threshold"])):
			readings_ok = false
	return {"met":readings_ok and bool(state["auto"]),"criteria":{"readings":readings_ok,"automatic":bool(state["auto"])}}
