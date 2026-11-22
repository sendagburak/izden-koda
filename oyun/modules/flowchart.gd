extends "res://oyun/core/puzzle_module.gd"
## Connect labelled flow nodes without using a node twice.
func create_state(_level: Dictionary, layer: String) -> Dictionary:
	return {"path":[],"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not token in p["nodes"] or token in s["path"]: return {"state":s,"events":["blocked"]}
	if s["path"].size() >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	s["path"].append(token)
	return {"state":s,"events":["connected"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var ok: bool = state["path"] == level["layers"][state["layer"]]["params"]["goal"]
	return {"met":ok,"criteria":{"flow_order":ok}}
