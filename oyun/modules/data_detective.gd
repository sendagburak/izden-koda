extends "res://oyun/core/puzzle_module.gd"
## Classify local measurements; both false positives and omissions matter.
func create_state(_level: Dictionary, layer: String) -> Dictionary:
	return {"selected":[],"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not token in p["alphabet"] or token in s["selected"]: return {"state":s,"events":["blocked"]}
	if s["selected"].size() >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	s["selected"].append(token)
	return {"state":s,"events":["classified"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var expected: Array = []
	for i in range(p["values"].size()):
		if int(p["values"][i]) >= int(p["threshold"]): expected.append(str(i))
	var correct: bool = expected.size() == state["selected"].size()
	for item in expected:
		if not state["selected"].has(item): correct = false
	return {"met":correct,"criteria":{"filter":correct}}
