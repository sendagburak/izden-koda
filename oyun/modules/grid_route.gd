extends "res://oyun/core/puzzle_module.gd"
## D1 route commands: U/D/L/R; no physics, deterministic and replayable.
const DIRECTIONS := {"U": Vector2i(0, -1), "D": Vector2i(0, 1), "L": Vector2i(-1, 0), "R": Vector2i(1, 0)}

func _params(level: Dictionary, layer: String) -> Dictionary:
	return level.get("layers", {}).get(layer, {}).get("params", {})

func validate_level(level: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for layer in ["concrete", "blocks", "system"]:
		var params = _params(level, layer)
		if not params.has("start") or not params.has("goal") or not params.has("size"):
			errors.append("missing coordinates: " + layer)
			continue
		if int(params["size"][0]) < 2 or int(params["size"][1]) < 2:
			errors.append("invalid dimensions: " + layer)
	return errors

func create_state(level: Dictionary, layer: String) -> Dictionary:
	var p = _params(level, layer)
	return {"position": p.get("start", [0, 0]).duplicate(), "moves": 0, "layer": layer, "trail": [p.get("start", [0, 0]).duplicate()]}

func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary:
	var next_state: Dictionary = state.duplicate(true)
	var cmd: String = str(action.get("command", ""))
	var p = _params(level, str(state.get("layer", "concrete")))
	if not DIRECTIONS.has(cmd):
		return {"state": next_state, "events": ["blocked"]}
	if int(state.get("moves", 0)) >= int(p.get("max_steps", 999)):
		return {"state": next_state, "events": ["limit"]}
	var xy: Array = next_state["position"]
	var move: Vector2i = DIRECTIONS[cmd]
	var x: int = int(xy[0]) + move.x
	var y: int = int(xy[1]) + move.y
	var dim: Array = p["size"]
	if x < 0 or y < 0 or x >= int(dim[0]) or y >= int(dim[1]):
		return {"state": next_state, "events": ["blocked"]}
	for obstacle in p.get("rocks", []):
		if int(obstacle[0]) == x and int(obstacle[1]) == y:
			return {"state": next_state, "events": ["blocked"]}
	next_state["position"] = [x, y]
	next_state["moves"] = int(next_state["moves"]) + 1
	next_state["trail"].append([x, y])
	return {"state": next_state, "events": ["moved"]}

func evaluate(level: Dictionary, state: Dictionary) -> Dictionary:
	var p = _params(level, str(state.get("layer", "concrete")))
	var at_goal: bool = state.get("position", []) == p.get("goal", [])
	return {"met": at_goal, "criteria": {"arrived": at_goal}, "evidence": state.get("trail", [])}
