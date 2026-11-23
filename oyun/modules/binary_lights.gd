extends "res://oyun/core/puzzle_module.gd"
## Physical bit panel: toggling a bit changes its binary value.
func create_state(level: Dictionary, layer: String) -> Dictionary:
	return {"bits":level["layers"][layer]["params"]["initial"].duplicate(), "turns":0, "layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not token in p["alphabet"]: return {"state":s,"events":["blocked"]}
	if int(s["turns"]) >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	var i: int = int(token)
	s["bits"][i] = 1 - int(s["bits"][i])
	s["turns"] += 1
	return {"state":s,"events":["toggled"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var ok: bool = state["bits"] == level["layers"][state["layer"]]["params"]["goal"]
	return {"met":ok,"criteria":{"binary":ok}}
