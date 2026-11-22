extends "res://oyun/core/puzzle_module.gd"
## Sorting train: only adjacent carriages may swap.
func create_state(level: Dictionary, layer: String) -> Dictionary:
	return {"order": level["layers"][layer]["params"]["initial"].duplicate(), "turns": 0, "layer": layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not token in p["alphabet"]: return {"state": s, "events": ["blocked"]}
	if int(s["turns"]) >= int(p["max_steps"]): return {"state": s, "events": ["limit"]}
	var i: int = int(token)
	var v: Array = s["order"]
	var temp = v[i]
	v[i] = v[i + 1]
	v[i + 1] = temp
	s["turns"] += 1
	return {"state": s, "events": ["swapped"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var met: bool = state["order"] == level["layers"][state["layer"]]["params"]["goal"]
	return {"met": met, "criteria": {"sorted": met}}
