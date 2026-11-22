extends "res://oyun/core/puzzle_module.gd"
## Robot must scan before navigating; unlike simple routes this models a sensor precondition.
const DELTA := {"U":Vector2i(0,-1),"D":Vector2i(0,1),"L":Vector2i(-1,0),"R":Vector2i(1,0)}
func create_state(level: Dictionary, layer: String) -> Dictionary:
	var p: Dictionary = level["layers"][layer]["params"]
	return {"position":p["start"].duplicate(),"trail":[],"scanned":false,"turns":0,"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if int(s["turns"]) >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	if token == "S":
		s["scanned"] = true
		s["turns"] += 1
		return {"state":s,"events":["scanned"]}
	if not DELTA.has(token) or not bool(s["scanned"]): return {"state":s,"events":["blocked"]}
	var old: Array = s["position"]
	var next = Vector2i(int(old[0]),int(old[1])) + DELTA[token]
	if next.x < 0 or next.y < 0 or next.x >= int(p["size"][0]) or next.y >= int(p["size"][1]) or p.get("rocks",[]).has([next.x,next.y]):
		return {"state":s,"events":["blocked"]}
	s["trail"].append(old.duplicate())
	s["position"] = [next.x,next.y]
	s["turns"] += 1
	return {"state":s,"events":["moved"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var ok: bool = bool(state["scanned"]) and state["position"] == level["layers"][state["layer"]]["params"]["goal"]
	return {"met":ok,"criteria":{"scanned":state["scanned"],"destination":ok}}
