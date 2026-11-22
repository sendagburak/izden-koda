extends SceneTree
## Render the actual mission scene and exercise its controls on a graphical display.
const MAIN := preload("res://oyun/app/main.tscn")
var app
var failures := 0
var screenshots := ""

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS ", message)
	else:
		printerr("FAIL ", message)
		failures += 1

func _press(label: String) -> bool:
	for child in app.find_children("*", "Button", true, false):
		if child.text == label and child.is_visible_in_tree() and not child.disabled:
			child.pressed.emit()
			return true
	_check(false, "button visible: " + label)
	return false

func _enter(commands: Array) -> void:
	for token in commands:
		_press(app._command_name(token))

func _wait_for_program() -> void:
	var deadline := Time.get_ticks_msec() + 7000
	while app.playback_active and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(not app.playback_active, "program returns to playable controls")

func _capture(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	if not screenshots.is_empty():
		var frame := root.get_texture().get_image()
		var path := screenshots.path_join(filename + ".png")
		_check(frame.save_png(path) == OK, "%s rendered at %s" % [filename, frame.get_size()])

func _run() -> void:
	if DisplayServer.get_name() == "headless" or FileAccess.file_exists("user://profiles/profiles.json"):
		printerr("The scene test requires a display and an empty user-data directory.")
		quit(2)
		return
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		screenshots = args[0]
		DirAccess.make_dir_recursive_absolute(screenshots)
	root.size = Vector2i(1152, 648)
	app = MAIN.instantiate()
	root.add_child(app)
	await process_frame
	app.preferences["language"] = "tr"
	app.locale.language = "tr"
	app._open_mission(1)
	_check(app._tr("ui.app") == "İzden Koda" and app._tr("ui.run") == "Başlat", "new Turkish title and run label")
	_check(OS.get_user_data_dir().ends_with("godot/app_userdata/ALGORİTMA OYUNU"), "existing desktop profile path is preserved")
	await _capture("01_Kayip_Feneri")

	_enter(app.level["layers"]["concrete"]["witness"])
	var position: Vector2 = app.mission_stage.actor
	var stage: Control = app.mission_stage
	_press("Başlat")
	_check(app.playback_active, "the visible run button starts timed playback")
	var moving_deadline := Time.get_ticks_msec() + 2500
	while app.playback_active and app.mission_stage.actor.is_equal_approx(position) and Time.get_ticks_msec() < moving_deadline:
		await process_frame
	_check(app.playback_active and app.mission_stage == stage and app.mission_stage.actor != position and app.mission_order == 1,
		"explorer moves while the original mission is on screen")
	_check(app.run_status.visible and app.run_status.text.begins_with("Adım "), "running command has Turkish feedback")
	await _capture("02_Komut_Isliyor")
	await _wait_for_program()
	_check(app.mission_stage.completed and app.data["completed_ids"].has("d1-p1-001"), "visible playback reaches the beacon and stores completion")

	_press(app._tr("ui.next"))
	_check(app.mission_order == 2 and not app.mission_stage.route["rocks"].is_empty(), "next mission has a different rocky layout")
	root.size = Vector2i(430, 780)
	await process_frame
	await _capture("03_Kayalik_Iskele_Dikey")
	_enter(["R", "R"])
	_press("Başlat")
	await _wait_for_program()
	_check(app.feedback == "ui.route_blocked" and not app.data["completed_ids"].has("d1-p1-002"), "rock impact is explained and does not complete the mission")
	_press(app._tr("ui.clear"))
	app.preferences["reduced_motion"] = true
	app._render_mission()
	_enter(["U", "U", "R", "R", "R", "R", "D", "D"])
	_press("Başlat")
	await _wait_for_program()
	_check(app.mission_stage.reduced and app.mission_stage.completed and app.data["completed_ids"].has("d1-p1-002"),
		"eight-step alternative completes with reduced motion")

	root.size = Vector2i(1152, 648)
	var worlds := {}
	for world in range(1, 8):
		app.current_world = world
		app._open_mission(1)
		worlds[app.mission_stage.backdrop.resource_path] = true
		if world == 3 or world == 7:
			await _capture("04_Yasayan_Istasyon" if world == 3 else "05_Yeni_Gun_Kenti")
	_check(worlds.size() == 7, "all seven worlds load distinct production backdrops")
	app.queue_free()
	await process_frame
	print("STAGE PLAYBACK FAILURES: ", failures)
	quit(1 if failures else 0)
