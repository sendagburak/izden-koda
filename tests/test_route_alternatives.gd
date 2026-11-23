extends SceneTree
## Exercises the authored missions with hand-checked routes besides their hints.
const Repo := preload("res://oyun/core/level_repository.gd")
const Runner := preload("res://oyun/core/puzzle_runner.gd")
var failures := 0

func _initialize() -> void:
	var repository := Repo.new()
	var runner := Runner.new()
	var coast := repository.load_level("d1-p1-002")
	_check(runner.open(coast, "concrete"), "Sisli iskele postası opens")
	_check(_submit(runner, ["U", "R", "R", "R", "R", "D"])["met"], "the hint route reaches the postbox")
	_check(_submit(runner, ["R", "U", "R", "R", "R", "D"])["met"], "a second short route reaches the postbox")
	_check(_submit(runner, ["U", "U", "R", "R", "R", "R", "D", "D"])["met"],
		"a safe eight-step detour reaches the postbox")
	_check(_submit(runner, ["U", "U", "U", "R", "R", "R", "R", "D", "D", "D"])["met"],
		"a ten-step exploration reaches the postbox")
	var over_budget: Array = []
	for _lap in range(9):
		over_budget.append_array(["U", "D"])
	over_budget.append_array(["U", "R", "R", "R", "R", "D"])
	_check(_submit(runner, over_budget)["events"].has("limit"),
		"a route with too many extra loops still exceeds the command budget")
	_check(_submit(runner, ["R", "R"])["events"].has("blocked"), "walking into a rock fails")
	_check(_submit(runner, ["D"])["events"].has("blocked"), "walking off the board fails")
	_check(not _submit(runner, ["U"])["met"] and not _submit(runner, [])["met"],
		"stopping away from the goal or submitting nothing fails")

	var station := repository.load_level("d3-p1-006")
	var detour := ["D", "R", "R", "R", "R", "R", "U", "U", "U", "U"]
	_check(runner.open(station, "system"), "the station's sensor course opens")
	_check(_submit(runner, ["S"] + detour)["met"], "a safe longer robot route reaches the goal after scanning")
	_check(_submit(runner, detour)["events"].has("blocked"), "the same robot route must scan first")
	_check(_submit(runner, ["S", "U", "U", "U", "R", "R"])["events"].has("blocked"),
		"scanning still does not allow a robot through rocks")
	quit(1 if failures else 0)

func _submit(runner: RefCounted, commands: Array) -> Dictionary:
	return runner.submit({"type": "run", "commands": commands})

func _check(condition: bool, title: String) -> void:
	if condition:
		print("PASS ", title)
	else:
		printerr("FAIL ", title)
		failures += 1
