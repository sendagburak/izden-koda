extends RefCounted
const MODULES := {
	"grid_route": preload("res://oyun/modules/grid_route.gd"),
	"signal_pattern": preload("res://oyun/modules/signal_pattern.gd"),
	"toggle_board": preload("res://oyun/modules/toggle_board.gd"),
	"sort_train": preload("res://oyun/modules/sort_train.gd"),
	"binary_lights": preload("res://oyun/modules/binary_lights.gd"),
	"cipher_wheel": preload("res://oyun/modules/cipher_wheel.gd"),
	"flowchart": preload("res://oyun/modules/flowchart.gd"),
	"logic_gate": preload("res://oyun/modules/logic_gate.gd"),
	"pattern_machine": preload("res://oyun/modules/pattern_machine.gd"),
	"resource_plan": preload("res://oyun/modules/resource_plan.gd"),
	"sensor_lab": preload("res://oyun/modules/sensor_lab.gd"),
	"robot_course": preload("res://oyun/modules/robot_course.gd"),
	"graph_path": preload("res://oyun/modules/graph_path.gd"),
	"function_loops": preload("res://oyun/modules/function_loops.gd"),
	"state_machine": preload("res://oyun/modules/state_machine.gd"),
	"data_detective": preload("res://oyun/modules/data_detective.gd")
}
var module: RefCounted
var level: Dictionary = {}
var layer: String = "concrete"
var state: Dictionary = {}
var completed: bool = false

func open(next_level: Dictionary, next_layer: String) -> bool:
	if not MODULES.has(next_level.get("type", "")) or not next_level.get("layers", {}).has(next_layer):
		return false
	var next_module = MODULES[next_level["type"]].new()
	if not next_module.validate_level(next_level).is_empty():
		return false
	module = next_module
	level = next_level
	layer = next_layer
	state = module.create_state(level, layer)
	completed = false
	return true

func submit(action: Dictionary) -> Dictionary:
	if module == null:
		return {"state": {}, "events": ["unavailable"], "met": false}
	if action.get("type") != "run":
		return {"state": state.duplicate(true), "events": ["unavailable"], "met": false}
	state = module.create_state(level, layer)
	var events: Array = []
	for command in action.get("commands", []):
		var result: Dictionary = module.apply_action(level, state, {"command": command})
		state = result["state"]
		var raised: Array = result.get("events", [])
		events.append_array(raised)
		if raised.has("blocked") or raised.has("limit"):
			break
	var evaluation: Dictionary = module.evaluate(level, state)
	completed = bool(evaluation.get("met", false)) and not events.has("blocked") and not events.has("limit")
	return {"state": state.duplicate(true), "events": events, "met": completed, "criteria": evaluation.get("criteria", {})}

func get_result() -> Dictionary:
	return {"state": state.duplicate(true), "met": completed}

func witness(layer_name: String) -> bool:
	if module == null:
		return false
	return module.verify_witness(level, layer_name)
