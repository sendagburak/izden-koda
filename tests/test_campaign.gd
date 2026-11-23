extends SceneTree
## Production-level replay across every mission and age layer.
const Repo := preload("res://oyun/core/level_repository.gd")
const Runner := preload("res://oyun/core/puzzle_runner.gd")
const Locale := preload("res://oyun/core/locale_service.gd")

var failures := 0
var mechanics := 0

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var output := args[0] if not args.is_empty() else "user://campaign-coverage"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var task_csv := FileAccess.open(output.path_join("gorev-kapsama.csv"), FileAccess.WRITE)
	var module_csv := FileAccess.open(output.path_join("modul-kapsama.csv"), FileAccess.WRITE)
	if task_csv == null or module_csv == null:
		printerr("CSV output could not be opened: ", output)
		quit(2)
		return
	task_csv.store_csv_line(PackedStringArray([
		"gorev", "dunya", "perde", "modul", "parametre_sha256",
		"somut_cozum", "somut_bos_red", "somut_gecersiz_red", "somut_tekrar",
		"blok_cozum", "blok_bos_red", "blok_gecersiz_red", "blok_tekrar",
		"sistem_cozum", "sistem_bos_red", "sistem_gecersiz_red", "sistem_tekrar",
	]))
	module_csv.store_csv_line(PackedStringArray([
		"modul", "gorev", "benzersiz_parametre_kumesi", "basarili_katman", "beklenen_katman",
	]))
	var repo := Repo.new()
	var runner := Runner.new()
	var locale := Locale.new()
	var records: Array = repo._read_json("res://veri/levels/index.json").get("missions", [])
	var ids := {}
	var distinct := {}
	var summaries := {}
	var good_layers := 0
	for record in records:
		var id: String = record["id"]
		var level: Dictionary = repo.load_level(id)
		if level.is_empty() or ids.has(id):
			_fail("missing, invalid, or duplicate mission " + id)
			continue
		ids[id] = true
		var type: String = level["type"]
		for key in [str(level["locale_key"]), "mission.desc." + id, "result." + id] + level["hints"]:
			if not locale.available(key):
				_fail(id + " missing bilingual text " + str(key))
		var params := []
		for layer in Repo.LAYERS:
			params.append(level["layers"][layer]["params"])
		var signature := JSON.stringify([type, params]).sha256_text()
		var unique := not distinct.has(signature)
		if not unique:
			_fail(id + " duplicates playable parameters of " + str(distinct[signature]))
		distinct[signature] = id
		var entry: Dictionary = summaries.get(type, {"missions": 0, "distinct": 0, "passed": 0})
		entry["missions"] += 1
		entry["distinct"] += int(unique)
		var row := PackedStringArray([id, str(level["world"]), str(level["act"]), type, signature])
		for layer in Repo.LAYERS:
			if not runner.open(level, layer):
				_fail(id + "/" + layer + " did not open")
				row.append_array(PackedStringArray(["FAIL", "FAIL", "FAIL", "FAIL"]))
				continue
			var commands: Array = level["layers"][layer]["witness"]
			var solved := _run(runner, commands)
			var empty := _run(runner, [])
			var invalid := _run(runner, commands + ["__invalid_test_command__"])
			var repeated := _run(runner, commands)
			var valid_solution := bool(solved.get("met", false))
			var rejected_empty := not bool(empty.get("met", false))
			var rejected_invalid := not bool(invalid.get("met", false))
			var deterministic := solved == repeated
			for passed in [valid_solution, rejected_empty, rejected_invalid, deterministic]:
				row.append("PASS" if passed else "FAIL")
			if valid_solution and rejected_empty and rejected_invalid and deterministic:
				good_layers += 1
				entry["passed"] += 1
			else:
				_fail("%s/%s pass=%s empty_rejected=%s invalid_rejected=%s replay=%s" % [
					id, layer, valid_solution, rejected_empty, rejected_invalid, deterministic,
				])
		summaries[type] = entry
		task_csv.store_csv_line(row)
	for type in Repo.SUPPORTED_TYPES:
		var entry: Dictionary = summaries.get(type, {"missions": 0, "distinct": 0, "passed": 0})
		module_csv.store_csv_line(PackedStringArray([
			type, str(entry["missions"]), str(entry["distinct"]), str(entry["passed"]), str(entry["missions"] * 3),
		]))
	task_csv.close()
	module_csv.close()
	if ids.size() != 350 or summaries.size() != 16 or good_layers != 1050:
		_fail("campaign counts are incomplete")
	_check_mechanics(runner, repo)
	print("Campaign: ", ids.size(), " missions; ", summaries.size(), " modules; ",
		distinct.size(), " distinct parameter sets; ", good_layers, "/1050 layers passed; failures=", failures)
	print("Targeted cases: ", mechanics, "/9")
	quit(0 if failures == 0 else 1)

func _run(runner: RefCounted, commands: Array) -> Dictionary:
	return runner.submit({"type": "run", "commands": commands})

func _fixture(kind: String, params: Dictionary) -> Dictionary:
	return {"type": kind, "layers": {"concrete": {"params": params}}}

func _check_mechanics(runner: RefCounted, repo: RefCounted) -> void:
	var route: Dictionary = repo.load_level("d1-p1-001")
	route["layers"]["concrete"]["params"]["max_steps"] = 6
	var route_open: bool = runner.open(route, "concrete")
	_check(route_open and _run(runner, ["U", "R", "R", "R", "D"])["met"], "alternate route accepted")
	var robot := _fixture("robot_course", {"size": [3, 2], "start": [0, 0], "goal": [2, 0],
		"rocks": [[1, 0]], "max_steps": 6})
	var robot_open: bool = runner.open(robot, "concrete")
	_check(robot_open and _run(runner, ["D"])["events"].has("blocked"), "robot movement requires a scan")
	_check(robot_open and _run(runner, ["S", "R"])["events"].has("blocked"), "robot rock collision rejected")
	var graph := _fixture("graph_path", {"edges": {"A": {"B": 2, "D": 1}, "B": {"D": 2}, "D": {}},
		"start": "A", "goal": "D", "via": ["B"], "max_cost": 4, "max_steps": 3})
	var graph_open: bool = runner.open(graph, "concrete")
	_check(graph_open and not _run(runner, ["D"])["met"] and _run(runner, ["B", "D"])["met"],
		"cheap graph shortcut rejected when a required stop was skipped")
	var gate := _fixture("logic_gate", {"gate": "NOT", "initial": [0, 0], "alphabet": ["A0", "A1"],
		"goal": 0, "max_steps": 2})
	var gate_open: bool = runner.open(gate, "concrete")
	_check(gate_open and _run(runner, ["A1"])["met"], "unary NOT returns the target output")
	var rhythm := _fixture("function_loops", {"macros": {"A": "ST", "B": "TS"}, "target": "STSTTS",
		"alphabet": ["A", "A*2", "B"], "max_steps": 4})
	var rhythm_open: bool = runner.open(rhythm, "concrete")
	_check(rhythm_open and not _run(runner, ["A*2"])["met"], "short rhythm leaves the objective unmet")
	_check(rhythm_open and _run(runner, ["A*2", "B"])["met"] and _run(runner, ["A", "A", "B"])["met"],
		"bounded and expanded routines both work")
	var timing := _fixture("state_machine", {"start": "IDLE", "goal": "DONE", "max_steps": 4,
		"transitions": {"IDLE": {"START": "WAITING"}, "WAITING": {"TICK": "READY"}, "READY": {"SEND": "DONE"}}})
	var timing_open: bool = runner.open(timing, "concrete")
	_check(timing_open and not _run(runner, ["START", "SEND"])["met"]
		and _run(runner, ["START", "TICK", "SEND"])["met"], "clock step is required before sending")
	var numbers: Array = repo._normalize_json_numbers([1.0, 1.25])
	_check(numbers[0] is int and numbers[1] is float, "integral JSON values normalize without truncating fractions")

func _check(condition: bool, title: String) -> void:
	if condition:
		mechanics += 1
		print("PASS ", title)
	else:
		_fail(title)

func _fail(title: String) -> void:
	failures += 1
	printerr("FAIL ", title)
