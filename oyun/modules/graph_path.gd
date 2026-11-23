extends "res://oyun/core/puzzle_module.gd"
## Weighted graph navigation; a stop can only be reached along an edge.
func create_state(level: Dictionary, layer: String) -> Dictionary:
	return {"node":str(level["layers"][layer]["params"]["start"]),"cost":0,"path":[],"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var to: String = str(action.get("command", ""))
	var neighbours: Dictionary = p["edges"].get(s["node"],{})
	if not neighbours.has(to): return {"state":s,"events":["blocked"]}
	if s["path"].size() >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	s["cost"] += int(neighbours[to])
	s["node"] = to
	s["path"].append(to)
	return {"state":s,"events":["travelled"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var destination: bool = state["node"] == p["goal"]
	var efficient: bool = int(state["cost"]) <= int(p["max_cost"])
	return {"met":destination and efficient,"criteria":{"destination":destination,"efficient":efficient}}
