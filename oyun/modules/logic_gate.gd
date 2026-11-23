extends "res://oyun/core/puzzle_module.gd"
## Configure two boolean inputs; evaluate actual AND/OR/XOR/NAND/NOR.
func create_state(level: Dictionary, layer: String) -> Dictionary:
	var gate: String = str(level["layers"][layer]["params"]["gate"])
	var initial: int = 1 if gate in ["NAND", "NOR"] else 0
	return {"a":initial,"b":initial,"turns":0,"layer":layer}
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var p: Dictionary = level["layers"][state["layer"]]["params"]
	var s: Dictionary = state.duplicate(true)
	var token: String = str(action.get("command", ""))
	if not token in p["alphabet"]: return {"state":s,"events":["blocked"]}
	if int(s["turns"]) >= int(p["max_steps"]): return {"state":s,"events":["limit"]}
	s["a" if token.begins_with("A") else "b"] = int(token.substr(1))
	s["turns"] += 1
	return {"state":s,"events":["assigned"]}
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var gate: String = str(level["layers"][state["layer"]]["params"]["gate"])
	var a: bool = int(state["a"]) == 1
	var b: bool = int(state["b"]) == 1
	var output: bool = false
	match gate:
		"AND": output = a and b
		"OR": output = a or b
		"XOR": output = a != b
		"NAND": output = not (a and b)
		"NOR": output = not (a or b)
	var ok: bool = int(output) == int(level["layers"][state["layer"]]["params"]["goal"])
	return {"met":ok,"criteria":{"gate_output":ok},"evidence":[int(output)]}
