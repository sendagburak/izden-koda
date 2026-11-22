extends Control
## Main scene for the campaign and local creative modes.
const RepoScript = preload("res://oyun/core/level_repository.gd")
const RunnerScript = preload("res://oyun/core/puzzle_runner.gd")
const LocaleScript = preload("res://oyun/core/locale_service.gd")
const HintScript = preload("res://oyun/core/hint_service.gd")
const ProfileScript = preload("res://oyun/core/profile_store.gd")
const SaveScript = preload("res://oyun/core/save_store.gd")
const ProgressScript = preload("res://oyun/core/progress_rules.gd")
const SettingsScript = preload("res://oyun/core/settings_store.gd")
const BackupScript = preload("res://oyun/core/backup_io.gd")
const InputScript = preload("res://oyun/core/input_actions.gd")
const StageScript = preload("res://oyun/app/mission_stage.gd")
const STANDARD_FONT = preload("res://varliklar/fonts/NotoSans-Regular.ttf")
const READABLE_FONT = preload("res://varliklar/fonts/AtkinsonHyperlegibleNext-Regular.ttf")
const COMMAND_LIMIT := 40
const ROUTE_COMMANDS := {"U": "ui.move_up", "D": "ui.move_down", "L": "ui.move_left", "R": "ui.move_right", "S": "ui.scan"}
const WORLD_BACKDROPS = {
	1: preload("res://varliklar/sprites/coast_dusk.png"),
	2: preload("res://varliklar/sprites/world_2.png"),
	3: preload("res://varliklar/sprites/world_3.png"),
	4: preload("res://varliklar/sprites/world_4.png"),
	5: preload("res://varliklar/sprites/world_5.png"),
	6: preload("res://varliklar/sprites/world_6.png"),
	7: preload("res://varliklar/sprites/world_7.png")
}
const CHARACTER_SPRITES = {
	1: preload("res://varliklar/sprites/character_1.png"),
	2: preload("res://varliklar/sprites/character_2.png"),
	3: preload("res://varliklar/sprites/character_3.png"),
	4: preload("res://varliklar/sprites/character_4.png"),
	5: preload("res://varliklar/sprites/character_5.png"),
	6: preload("res://varliklar/sprites/character_6.png"),
	7: preload("res://varliklar/sprites/character_7.png")
}
const WORLD_ACCENTS = {
	1: Color("#ffd277"), 2: Color("#efb182"), 3: Color("#a8e5b3"), 4: Color("#f2bb9d"),
	5: Color("#f3cc98"), 6: Color("#a5dfed"), 7: Color("#bedaff")
}
const SPRITES = {
	"rock": preload("res://varliklar/sprites/rock.png"),
	"floor": preload("res://varliklar/sprites/floor.png"),
	"start": preload("res://varliklar/sprites/agent.png"),
	"goal": preload("res://varliklar/sprites/lighthouse.png"),
	"trail": preload("res://varliklar/sprites/trail.png")
}
const WORLDS := ["ui.preview_d1", "ui.preview_d2", "ui.preview_d3", "ui.preview_d4", "ui.preview_d5", "ui.preview_d6", "ui.preview_d7"]
const COLORS := {"ink": Color("#142638"), "panel": Color("#192e3e"), "paper": Color("#fff0d3"), "muted": Color("#b5cbd0"), "gold": Color("#dfa556"), "line": Color("#597784"), "sea": Color("#2b5060"), "light": Color("#ffd57e")}
var repository = RepoScript.new()
var runner = RunnerScript.new()
var locale = LocaleScript.new()
var hints = HintScript.new()
var profiles = ProfileScript.new()
var store = SaveScript.new()
var progress = ProgressScript.new()
var settings_service = SettingsScript.new()
var backups = BackupScript.new()
var input_actions = InputScript.new()
var data: Dictionary = {}
var preferences: Dictionary = {}
var mission_order: int = 1
var current_world: int = 1
var mode_context: String = "story"
var sim_timer_enabled: bool = false
var sim_started_ms: int = 0
var sim_clock_label: Label
var music_player: AudioStreamPlayer
var effects_player: AudioStreamPlayer
var playing_world: int = -1
var level: Dictionary = {}
var command_queue: Array = []
var hint_tier: int = 0
var feedback: String = ""
var screen: String = "mission"
var sandbox_commands: Array = []
var sandbox_rocks: Array = [[2, 1], [2, 2], [2, 3]]
var sandbox_last: Dictionary = {}
var game_scroll: ScrollContainer
var mission_columns: BoxContainer
var mission_board: PanelContainer
var mission_desk: PanelContainer
var mission_stage: StageScript
var mission_readouts: VBoxContainer
var run_status: Label
var route_budget: Label
var queued_chips: Array[PanelContainer] = []
var playback_active := false
var block_index: int = -1
var notebook_text: String = ""
var notebook_error: Label
var trace_index: int = 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	theme = Theme.new()
	get_window().size_changed.connect(_resize_canvas)
	resized.connect(_fit_mission_columns)
	_resize_canvas()
	profiles.open()
	data = store.load_profile(profiles.selected)
	if data.is_empty():
		_show_recovery_error()
		return
	preferences = settings_service.normalize(data.get("settings", {}))
	if int(data.get("generation", 0)) == 0:
		preferences["language"] = "tr" if OS.get_locale_language() == "tr" else "en"
		data["settings"] = preferences
		store.save_profile(profiles.selected, data)
	locale.language = str(preferences["language"])
	_init_audio()
	_resume_progress()

func _resume_target() -> Dictionary:
	# Choose the highest unlocked world; profile changes must not inherit the previous world.
	var world_number: int = 1
	for w in range(7, 1, -1):
		if _world_unlocked(w):
			world_number = w
			break
	var order: int = 50
	var finished: Array = data.get("completed_ids", [])
	for i in range(1, 51):
		if not finished.has("d%d-p%d-%03d" % [world_number, int((i - 1) / 10) + 1, i]):
			order = i
			break
	return {"world": world_number, "order": order}

func _resume_progress() -> void:
	mode_context = "story"
	var target: Dictionary = _resume_target()
	current_world = int(target["world"])
	_open_mission(int(target["order"]))

func _accent() -> Color:
	if bool(preferences.get("high_contrast", false)):
		return Color("#FFE08C")
	return WORLD_ACCENTS.get(current_world,Color("#D9A75C"))

func _resize_canvas() -> void:
	var window := get_window()
	var base := Vector2i(430, 740) if window.size.x < window.size.y else Vector2i(960, 540)
	if window.content_scale_size != base:
		window.content_scale_size = base

func _fit_mission_columns() -> void:
	if not is_instance_valid(mission_columns) or not mission_columns.is_inside_tree():
		return
	var horizontal := size.x >= 760.0
	mission_columns.vertical = not horizontal
	mission_board.custom_minimum_size.x = 365.0 if horizontal else 0.0
	mission_desk.custom_minimum_size.x = 320.0 if horizontal else 0.0
	mission_board.size_flags_stretch_ratio = 1.75 if horizontal else 1.0

func _tr(key: String) -> String:
	return locale.text(key)

func _mechanic_label(group: String, value: String) -> String:
	var key := group + value.to_lower()
	return _tr(key) if locale.available(key) else value

func _sequence_text(commands: Array) -> String:
	var parts := PackedStringArray()
	for item in commands:
		parts.append(str(item))
	return "  ".join(parts)

func _clear() -> void:
	for child in get_children():
		if child is AudioStreamPlayer: continue
		remove_child(child)
		child.queue_free()

func _box_color(shade: Color, edge: Color) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = shade
	box.border_color = edge
	box.set_border_width_all(2)
	box.set_corner_radius_all(5)
	box.set_content_margin_all(8)
	return box

func _panel() -> PanelContainer:
	var item = PanelContainer.new()
	var color = COLORS.ink if bool(preferences.get("high_contrast", false)) else COLORS.panel
	item.add_theme_stylebox_override("panel", _box_color(color, _accent()))
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return item

func _txt(message: String, font_size: int = 19, tint: Color = Color(0.914, 0.859, 0.718), wrap: bool = true) -> Label:
	var node = Label.new()
	node.text = message
	node.add_theme_color_override("font_color", tint)
	node.add_theme_font_size_override("font_size", font_size + int(preferences.get("text_size", 0)) * 3)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node

func _btn(message: String, callback: Callable, small: bool = false) -> Button:
	var button = Button.new()
	button.text = message
	button.set_meta("focus_key", message)
	button.custom_minimum_size = Vector2(74 if small else 130, 44 if small else 49)
	if not small:
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_stylebox_override("normal", _box_color(COLORS.ink, COLORS.line))
	button.add_theme_stylebox_override("hover", _box_color(COLORS.sea, _accent()))
	button.add_theme_stylebox_override("pressed", _box_color(_accent(), COLORS.paper))
	button.add_theme_stylebox_override("disabled", _box_color(COLORS.panel, COLORS.line))
	button.add_theme_stylebox_override("focus", _box_color(Color.TRANSPARENT, _accent()))
	button.add_theme_color_override("font_color", COLORS.paper)
	button.add_theme_color_override("font_hover_color", COLORS.paper)
	button.add_theme_color_override("font_pressed_color", COLORS.ink)
	button.add_theme_color_override("font_focus_color", COLORS.paper)
	button.add_theme_color_override("font_disabled_color", COLORS.muted)
	button.add_theme_font_size_override("font_size", 16 + int(preferences.get("text_size", 0)) * 3)
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(func(): _effect("tap"))
	button.pressed.connect(callback)
	return button

func _stack() -> VBoxContainer:
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 9)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return v

func _scroll_area(body: VBoxContainer) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.scroll_deadzone = 10
	body.add_child(scroll)
	var content := _stack()
	scroll.add_child(content)
	return content

func _frame(subtitle: String, image_world: int = -1) -> VBoxContainer:
	_clear()
	theme.default_font = READABLE_FONT if preferences.get("readable_font", false) else STANDARD_FONT
	var img = TextureRect.new()
	var active_world: int = image_world if image_world > 0 else current_world
	img.texture = _world_image(active_world)
	_play_world_music(active_world)
	img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	img.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(img)
	var tint = ColorRect.new()
	tint.color = Color(0.02, 0.07, 0.12, 0.70 if preferences.get("high_contrast", false) else 0.62)
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tint)
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)
	var body = _stack()
	margin.add_child(body)
	var top = HFlowContainer.new()
	top.add_theme_constant_override("h_separation", 8)
	top.add_theme_constant_override("v_separation", 5)
	body.add_child(top)
	var title := _heading(_tr("ui.app"), 27, COLORS.light)
	title.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top.add_child(title)
	top.add_child(_btn(_tr("ui.atlas"), func(): _open_atlas(), true))
	top.add_child(_btn(_tr("ui.mode"), func(): _open_modes(), true))
	top.add_child(_btn(_tr("ui.profiles"), func(): _open_profiles(), true))
	top.add_child(_btn(_tr("ui.settings"), func(): _open_settings(), true))
	if not subtitle.is_empty():
		body.add_child(_heading(subtitle, 21, _accent()))
	return body

func _heading(message: String, points: int, color: Color) -> Label:
	var label := _txt(message, points, color)
	label.add_theme_color_override("font_outline_color", Color("#07131e"))
	label.add_theme_constant_override("outline_size", 6)
	return label

func _world_image(world: int) -> Texture2D:
	var path := "res://varliklar/sahne/dunya_%02d.webp" % world
	if ResourceLoader.exists(path):
		return load(path)
	return WORLD_BACKDROPS.get(world, WORLD_BACKDROPS[1])

func _stage_art() -> Dictionary:
	var art := {"explorer": SPRITES["start"], "robot": SPRITES["start"], "rock": SPRITES["rock"],
		"goal": SPRITES["goal"], "open": SPRITES["goal"], "tree": null, "flowers": null, "relay": null}
	for key in art:
		var path := "res://varliklar/sahne/%s.png" % key
		if ResourceLoader.exists(path):
			art[key] = load(path)
	if current_world == 1 and mission_order == 1:
		var beacon := "res://varliklar/sahne/beacon.png"
		if ResourceLoader.exists(beacon):
			art["goal"] = load(beacon)
			art["open"] = art["goal"]
	return art

func _route_params() -> Dictionary:
	if str(level["type"]) in ["grid_route", "robot_course"]:
		return level["layers"][runner.layer]["params"]
	return {}

func _open_mission(order: int) -> void:
	mission_order = clampi(order, 1, 50)
	var act: int = int((mission_order-1)/10) + 1
	level = repository.load_level("d%d-p%d-%03d" % [current_world, act, mission_order])
	if level.is_empty():
		_show_recovery_error()
		return
	if not runner.open(level, str(preferences.get("layer", "concrete"))):
		_show_recovery_error()
		return
	command_queue.clear()
	notebook_text = ""
	block_index = -1
	trace_index = 0
	var attempt: Dictionary = data.get("last_attempt", {})
	if attempt.get("mission_id", "") == level["id"] and attempt.get("layer", "") == runner.layer:
		for cmd in attempt.get("commands", []):
			if command_queue.size() < COMMAND_LIMIT:
				command_queue.append(str(cmd))
		notebook_text = str(attempt.get("draft", " ".join(PackedStringArray(command_queue))))
	hint_tier = int(attempt.get("hint_tier", 0)) if attempt.get("mission_id", "") == level["id"] else 0
	feedback = ""
	screen = "mission"
	game_scroll = null
	_render_mission()
	if not bool(preferences.get("reduced_motion", false)) and DisplayServer.get_name() != "headless":
		mission_stage.modulate.a = 0.68
		mission_stage.create_tween().tween_property(mission_stage, "modulate:a", 1.0, 0.24)

func _render_mission() -> void:
	var previous_scroll := game_scroll.scroll_vertical if is_instance_valid(game_scroll) and game_scroll.is_inside_tree() else 0
	var previous_focus := get_viewport().gui_get_focus_owner()
	var focus_key := str(previous_focus.get_meta("focus_key", "")) if is_instance_valid(previous_focus) else ""
	var body := _scroll_area(_frame(""))
	queued_chips.clear()
	game_scroll = body.get_parent()
	if previous_scroll:
		game_scroll.set_deferred("scroll_vertical", previous_scroll)
	if mode_context == "simulation" and sim_timer_enabled:
		sim_clock_label = _txt("00:00", 20, _accent())
		body.add_child(sim_clock_label)
	body.add_child(_heading("%s   ·   %02d / 50" % [_tr(WORLDS[current_world - 1]), mission_order], 15, _accent()))
	body.add_child(_heading(_tr(str(level["locale_key"])), 26, COLORS.paper))
	body.add_child(_heading(_tr("mission.desc." + str(level["id"])), 17, COLORS.paper))
	mission_columns = BoxContainer.new()
	mission_columns.add_theme_constant_override("separation", 12)
	mission_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(mission_columns)
	mission_board = _panel()
	mission_columns.add_child(mission_board)
	var area = _stack()
	mission_board.add_child(area)
	mission_stage = StageScript.new()
	mission_stage.name = "MissionStage"
	area.add_child(mission_stage)
	var route := _route_params()
	mission_stage.setup(_world_image(current_world), _stage_art(), route, runner.state,
		current_world, mission_order, str(level["type"]) == "robot_course", preferences, runner.completed)
	mission_readouts = _stack()
	area.add_child(mission_readouts)
	_refresh_readouts(runner.state)
	mission_desk = _panel()
	mission_columns.add_child(mission_desk)
	_fit_mission_columns()
	var commands = _stack()
	mission_desk.add_child(commands)
	commands.add_child(_txt(_tr("ui.add_command"), 17, _accent()))
	route_budget = _txt("", 14, COLORS.muted)
	route_budget.visible = not route.is_empty()
	commands.add_child(route_budget)
	_update_route_budget()
	run_status = _txt("", 15, COLORS.light)
	run_status.hide()
	commands.add_child(run_status)
	_draw_palette(commands)
	match runner.layer:
		"system": _draw_notebook(commands)
		"blocks": _draw_blocks(commands)
		_: _draw_concrete_queue(commands)
	var run := _btn(_tr("ui.run"), func(): _run_commands())
	run.add_theme_stylebox_override("normal", _box_color(COLORS.light, Color("#9a642f")))
	run.add_theme_stylebox_override("hover", _box_color(Color("#ffe6a6"), COLORS.gold))
	run.add_theme_color_override("font_color", COLORS.ink)
	run.add_theme_color_override("font_hover_color", COLORS.ink)
	run.add_theme_color_override("font_focus_color", COLORS.ink)
	commands.add_child(run)
	var row = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 6)
	commands.add_child(row)
	row.add_child(_btn(_tr("ui.undo"), func(): _undo(), true))
	row.add_child(_btn(_tr("ui.clear"), func(): _clear_commands(), true))
	row.add_child(_btn(_tr("ui.step"), func(): _step_commands(), true))
	var hint_button := _btn(_tr("ui.hint") + "  %d/3" % hint_tier, func(): _take_hint())
	hint_button.set_meta("focus_key", "mission_hint")
	commands.add_child(hint_button)
	if trace_index > 0:
		commands.add_child(_txt(_tr("ui.trace") % trace_index, 15, COLORS.paper))
	if hint_tier > 0:
		var text = _tr(str(hints.get_hint(level, hint_tier).get("key", "")))
		if hint_tier == 3:
			text += "\n" + _tr("ui.witness") + ": " + _sequence_text(level["layers"][runner.layer]["witness"])
		commands.add_child(_txt(text, 15, COLORS.muted))
	if feedback != "":
		commands.add_child(_txt(_tr(feedback), 17, _accent()))
	if data.get("completed_ids", []).has(level["id"]):
		commands.add_child(_txt(_tr("ui.completed"), 16, COLORS.light))
		if mission_order < 50:
			commands.add_child(_btn(_tr("ui.next"), func(): _open_mission(mission_order + 1)))
		elif current_world < 7:
			commands.add_child(_btn(_tr("ui.next_world"), func(): _go_to_next_world()))
	if mode_context in ["simulation", "daily"]:
		commands.add_child(_btn(_tr("ui.mode"), func(): _open_modes()))
	if not focus_key.is_empty():
		_restore_mission_focus.call_deferred(focus_key)

func _restore_mission_focus(focus_key: String) -> void:
	if screen != "mission":
		return
	for control in find_children("*", "Button", true, false):
		if control.get_meta("focus_key", "") == focus_key and not control.disabled:
			control.grab_focus()
			return

func _refresh_readouts(snapshot: Dictionary) -> void:
	for child in mission_readouts.get_children():
		mission_readouts.remove_child(child)
		child.queue_free()
	match str(level["type"]):
		"grid_route":
			if str(level["id"]) == "d1-p1-001":
				mission_readouts.add_child(_txt(_tr("ui.prologue"), 14, COLORS.muted))
		"robot_course":
			var key := "ui.sensor_scanned" if snapshot.get("scanned", false) else "ui.sensor_waiting"
			mission_readouts.add_child(_txt(_tr(key), 15, COLORS.muted))
		"signal_pattern": _draw_pattern(mission_readouts, snapshot)
		"toggle_board": _draw_panel(mission_readouts, snapshot)
		_: _draw_mechanic(mission_readouts, snapshot)

func _update_route_budget() -> void:
	if not is_instance_valid(route_budget) or not route_budget.visible:
		return
	var limit := int(_route_params().get("max_steps", COMMAND_LIMIT))
	route_budget.text = _tr("ui.route_budget") % [command_queue.size(), limit]
	route_budget.add_theme_color_override("font_color", COLORS.light if command_queue.size() > limit else COLORS.muted)

func _light_badge(letter: String, lit: bool) -> PanelContainer:
	var shell = PanelContainer.new()
	shell.custom_minimum_size = Vector2(56, 56)
	shell.add_theme_stylebox_override("panel", _box_color(_accent() if lit else COLORS.sea, COLORS.paper if lit else COLORS.line))
	if preferences.get("color_blind_mode", false):
		letter = ("◆ " if lit else "◇ ") + letter
	shell.add_child(_txt(letter, 23, COLORS.ink if lit else COLORS.paper))
	return shell

func _draw_pattern(area: VBoxContainer, snapshot: Dictionary) -> void:
	area.add_child(_txt(_tr("ui.signal") + " / " + _tr("ui.target"), 18, _accent()))
	var p: Dictionary = level["layers"][runner.layer]["params"]
	var target = HFlowContainer.new()
	target.add_theme_constant_override("h_separation", 8)
	area.add_child(target)
	for symbol in p["target"]:
		target.add_child(_light_badge(str(symbol), true))
	area.add_child(_txt(_tr("ui.sequence"), 16, COLORS.muted))
	var chosen = HFlowContainer.new()
	chosen.add_theme_constant_override("h_separation", 7)
	area.add_child(chosen)
	for symbol in snapshot.get("sequence", []):
		chosen.add_child(_light_badge(str(symbol), true))

func _draw_panel(area: VBoxContainer, snapshot: Dictionary) -> void:
	area.add_child(_txt(_tr("ui.panel"), 18, _accent()))
	var p: Dictionary = level["layers"][runner.layer]["params"]
	area.add_child(_txt(_tr("ui.target"), 16, COLORS.muted))
	var target = HFlowContainer.new()
	area.add_child(target)
	for index in range(p["goal"].size()):
		var lamp: int = p["goal"][index]
		target.add_child(_light_badge("%d·%d" % [index + 1, lamp], lamp == 1))
	area.add_child(_txt(_tr("ui.sequence"), 16, COLORS.muted))
	var actual = HFlowContainer.new()
	area.add_child(actual)
	var lamps: Array = snapshot.get("lamps", p["initial"])
	for index in range(lamps.size()):
		actual.add_child(_light_badge("%d·%d" % [index + 1, lamps[index]], lamps[index] == 1))
	for symbol in p["wiring"]:
		var connected := PackedStringArray()
		for index in p["wiring"][symbol]:
			connected.append(str(int(index) + 1))
		area.add_child(_txt(str(symbol) + "  →  " + ", ".join(connected), 15, COLORS.muted))

func _mission_symbols() -> Array:
	if str(level["type"]) in ["grid_route", "robot_course"]:
		return ["S", "U", "R", "D", "L"] if str(level["type"]) == "robot_course" else ["U", "R", "D", "L"]
	var params: Dictionary = level["layers"][runner.layer]["params"]
	return params["wiring"].keys() if str(level["type"]) == "toggle_board" else params.get("alphabet", [])

func _command_name(symbol: String) -> String:
	if str(level["type"]) in ["grid_route", "robot_course"]:
		return _tr(ROUTE_COMMANDS.get(symbol, symbol))
	return symbol

func _draw_palette(commands: VBoxContainer) -> void:
	var panel := HFlowContainer.new()
	panel.add_theme_constant_override("h_separation", 7)
	panel.add_theme_constant_override("v_separation", 7)
	commands.add_child(panel)
	for symbol in _mission_symbols():
		var s: String = str(symbol)
		var text := _command_name(s)
		if runner.layer == "system" and text != s:
			text = s + " · " + text
		var button := _btn(text, func(): _add_command(s), true)
		button.set_meta("command", s)
		button.add_theme_stylebox_override("normal", _box_color(COLORS.sea, COLORS.line))
		panel.add_child(button)

func _draw_concrete_queue(commands: VBoxContainer) -> void:
	if command_queue.is_empty():
		commands.add_child(_txt(_tr("ui.no_command"), 14, COLORS.muted))
		return
	var strip := HFlowContainer.new()
	strip.add_theme_constant_override("h_separation", 4)
	strip.add_theme_constant_override("v_separation", 4)
	commands.add_child(strip)
	var direction_icons := {"U": "↑", "R": "→", "D": "↓", "L": "←", "S": "⌁"} if not _route_params().is_empty() else {}
	for token in command_queue:
		var chip := PanelContainer.new()
		var chip_style := _box_color(Color("#223c4a"), COLORS.line)
		chip_style.set_content_margin_all(4)
		chip.add_theme_stylebox_override("panel", chip_style)
		var text := _txt(str(direction_icons.get(token, token)), 16, COLORS.light, false)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.custom_minimum_size.x = 20
		chip.tooltip_text = _command_name(str(token))
		chip.add_child(text)
		strip.add_child(chip)
		queued_chips.append(chip)

func _draw_blocks(commands: VBoxContainer) -> void:
	commands.add_child(_txt(_tr("ui.block_bench"), 16, _accent()))
	if command_queue.is_empty():
		commands.add_child(_txt(_tr("ui.no_command"), 15, COLORS.muted))
		return
	var blocks := HFlowContainer.new()
	commands.add_child(blocks)
	for i in range(command_queue.size()):
		var index := i
		var label := "%d. %s" % [index + 1, _command_name(command_queue[index])]
		var button := _btn(label, func(): _select_block(index), true)
		if index == block_index:
			button.add_theme_stylebox_override("normal", _box_color(COLORS.sea, _accent()))
			button.text = "◆ " + label
		blocks.add_child(button)
	if block_index >= 0:
		var row := HFlowContainer.new()
		commands.add_child(row)
		var earlier := _btn(_tr("ui.block_left"), func(): _move_block(-1), true)
		earlier.disabled = block_index == 0
		row.add_child(earlier)
		var later := _btn(_tr("ui.block_right"), func(): _move_block(1), true)
		later.disabled = block_index == command_queue.size() - 1
		row.add_child(later)

func _select_block(index: int) -> void:
	block_index = index
	_render_mission()

func _move_block(offset: int) -> void:
	var target := block_index + offset
	if block_index < 0 or target < 0 or target >= command_queue.size():
		return
	var command = command_queue.pop_at(block_index)
	command_queue.insert(target, command)
	block_index = target
	trace_index = 0
	feedback = ""
	_persist_attempt()
	_render_mission()

func _draw_notebook(commands: VBoxContainer) -> void:
	commands.add_child(_txt(_tr("ui.code_notebook"), 16, _accent()))
	var editor := TextEdit.new()
	editor.name = "CodeNotebook"
	editor.custom_minimum_size.y = 95
	editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	editor.placeholder_text = _tr("ui.code_edit")
	editor.text = notebook_text
	editor.add_theme_font_size_override("font_size", 17 + int(preferences.get("text_size", 0)) * 3)
	commands.add_child(editor)
	notebook_error = _txt(_tr("ui.code_invalid"), 15, COLORS.light)
	notebook_error.visible = not _code_queue().get("valid", false)
	commands.add_child(notebook_error)
	editor.text_changed.connect(func(): _edit_notebook(editor.text))

func _code_queue() -> Dictionary:
	if notebook_text.length() > 1024:
		return {"valid": false}
	var allowed := _mission_symbols()
	var cleaned := notebook_text.to_upper().replace("\r", " ").replace("\n", " ").replace("\t", " ").replace(",", " ")
	var tokens := Array(cleaned.split(" ", false))
	if tokens.size() > COMMAND_LIMIT:
		return {"valid": false}
	for token in tokens:
		if not allowed.has(token):
			return {"valid": false}
	return {"valid": true, "commands": tokens}

func _edit_notebook(draft: String) -> void:
	notebook_text = draft
	var parsed := _code_queue()
	command_queue.assign(parsed.get("commands", []))
	if is_instance_valid(notebook_error):
		notebook_error.visible = not parsed["valid"]
	_update_route_budget()
	feedback = ""
	trace_index = 0
	_persist_attempt()

func _persist_attempt() -> void:
	if level.is_empty() or data.is_empty(): return
	data["last_attempt"] = {"mission_id": str(level["id"]), "layer": runner.layer, "commands": command_queue.duplicate(), "hint_tier": hint_tier}
	if runner.layer == "system":
		data["last_attempt"]["draft"] = notebook_text.substr(0, 1025)
	data["settings"] = preferences
	store.save_profile(profiles.selected, data)

func _add_command(symbol: String) -> void:
	if command_queue.size() >= COMMAND_LIMIT:
		return
	if runner.layer == "system":
		_edit_notebook((notebook_text.strip_edges() + " " + symbol).strip_edges())
	else:
		command_queue.append(symbol)
		_persist_attempt()
	trace_index = 0
	feedback = ""
	_render_mission()

func _undo() -> void:
	if runner.layer == "system":
		var draft := notebook_text.strip_edges()
		var cut := maxi(maxi(draft.rfind(" "), draft.rfind(",")), maxi(draft.rfind("\n"), draft.rfind("\t")))
		_edit_notebook(draft.left(cut) if cut >= 0 else "")
	elif not command_queue.is_empty():
		command_queue.pop_back()
		_persist_attempt()
	block_index = -1
	trace_index = 0
	_render_mission()

func _clear_commands() -> void:
	command_queue.clear()
	notebook_text = ""
	block_index = -1
	trace_index = 0
	runner.open(level, runner.layer)
	feedback = ""
	_persist_attempt()
	_render_mission()

func _run_commands() -> void:
	if playback_active or (runner.layer == "system" and not _code_queue()["valid"]):
		return
	trace_index = 0
	var animate := DisplayServer.get_name() != "headless" and not command_queue.is_empty()
	var initial: Dictionary = runner.module.create_state(level, runner.layer) if animate else {}
	var result: Dictionary = runner.submit({"type": "run", "commands": command_queue, "trace": animate})
	if bool(result.get("met", false)):
		data = progress.complete(data, str(level["id"]))
		if mode_context == "daily":
			var history: Array = data.get("daily_history",[])
			var date_key: String = Time.get_date_string_from_system()
			if not history.has(date_key): history.append(date_key)
			data["daily_history"] = history
		data.erase("last_attempt")
		data["settings"] = preferences
		if not store.save_profile(profiles.selected, data):
			feedback = "ui.backup_failed"
		else:
			feedback = "result." + str(level["id"])
	else:
		feedback = _failure_key(result)
		if feedback.is_empty():
			feedback = "ui.incomplete"
	if animate:
		await _play_program(initial, result)
	elif result["met"]:
		_effect("discover")
	_render_mission()

func _failure_key(result: Dictionary) -> String:
	var events: Array = result["events"]
	var route := not _route_params().is_empty()
	if events.has("blocked"):
		if str(level["type"]) == "robot_course" and not result["state"].get("scanned", false):
			return "ui.sensor_waiting"
		return "ui.route_blocked" if route else "ui.blocked"
	if events.has("limit"):
		return "ui.route_limit" if route else "ui.limit"
	return ""

func _play_program(initial: Dictionary, result: Dictionary) -> void:
	playback_active = true
	for item in find_children("*", "Button", true, false):
		item.disabled = true
	for item in find_children("CodeNotebook", "TextEdit", true, false):
		item.editable = false
	mission_stage.reset_trace(initial)
	_refresh_readouts(initial)
	run_status.show()
	var steps: Array = result["trace"]
	var duration := minf(0.23, 4.8 / maxf(float(steps.size()), 1.0))
	var active_chip := _box_color(COLORS.sea, COLORS.light)
	active_chip.set_content_margin_all(4)
	var resting_chip := _box_color(Color("#223c4a"), COLORS.line)
	resting_chip.set_content_margin_all(4)
	for index in range(steps.size()):
		var step: Dictionary = steps[index]
		run_status.text = _tr("ui.program_step") % [index + 1, steps.size(), _command_name(step["command"])]
		if index > 0 and index - 1 < queued_chips.size():
			queued_chips[index - 1].add_theme_stylebox_override("panel", resting_chip)
		if index < queued_chips.size():
			queued_chips[index].add_theme_stylebox_override("panel", active_chip)
		var events: Array = step["events"]
		if events.has("blocked") or events.has("limit") or events.has("scanned"):
			_effect("scan")
		else:
			_effect("tap")
		await mission_stage.play_step(step["state"], events, step["command"], duration)
		_refresh_readouts(step["state"])
	if bool(result["met"]):
		_effect("discover")
	await mission_stage.play_outcome(bool(result["met"]))
	playback_active = false

func _step_commands() -> void:
	if command_queue.is_empty() or (runner.layer == "system" and not _code_queue()["valid"]):
		return
	trace_index = (trace_index % command_queue.size()) + 1
	var result: Dictionary = runner.submit({"type": "run", "commands": command_queue.slice(0, trace_index)})
	feedback = _failure_key(result)
	_render_mission()

func _take_hint() -> void:
	_effect("scan")
	hint_tier = mini(hint_tier + 1, 3)
	_persist_attempt()
	_render_mission()

func _world_unlocked(world_number: int) -> bool:
	if world_number <= 1: return true
	return data.get("completed_ids", []).has("d%d-p4-040" % (world_number-1))

func _go_to_next_world() -> void:
	if _world_unlocked(current_world + 1):
		_open_world(current_world + 1)
	else:
		_preview_world(current_world)

func _open_atlas() -> void:
	mode_context = "story"
	screen = "atlas"
	var body = _frame(_tr("ui.atlas"))
	body.add_child(_txt(_tr("ui.journey"), 25, _accent()))
	var listing := _scroll_area(body)
	for world_number in range(1,8):
		var w: int = world_number
		var count: int = 0
		for mid in data.get("completed_ids", []):
			if str(mid).begins_with("d%d-" % w): count += 1
		var title: String = _tr(WORLDS[w-1])
		if _world_unlocked(w):
			listing.add_child(_btn("%s  ·  %d/50" % [title, count], func(): _open_world(w)))
		else:
			listing.add_child(_btn(title + "  ·  " + _tr("ui.preview"), func(): _preview_world(w-1)))
	body.add_child(_btn(_tr("ui.mode"), func(): _open_modes()))
	body.add_child(_btn(_tr("ui.back"), func(): _open_mission(mission_order)))

func _open_world(w: int) -> void:
	if not _world_unlocked(w):
		_preview_world(w-1)
		return
	current_world = w
	screen = "missions"
	var body = _frame(_tr("ui.mission_list"))
	body.add_child(_txt(_tr(WORLDS[w-1]), 26, _accent()))
	var listing := _scroll_area(body)
	for act in range(1,6):
		listing.add_child(_txt(_tr("ui.act") + "  %d" % act, 20, _accent()))
		for order in range((act-1)*10+1,act*10+1):
			var n: int = order
			var key: String = "d%d-p%d-%03d" % [w, act, order]
			var mission_title: String = _tr("mission." + key)
			var done: String = "  •  ✓" if data.get("completed_ids", []).has(key) else ""
			listing.add_child(_btn("%02d  %s%s" % [order, mission_title, done], func(): _open_mission(n)))
	body.add_child(_btn(_tr("ui.atlas"), func(): _open_atlas()))

func _preview_world(i: int) -> void:
	screen = "preview"
	var body = _frame(_tr("ui.atlas"), i+1)
	body.add_child(_txt(_tr(WORLDS[i]), 27, _accent()))
	var mascot = TextureRect.new()
	mascot.texture = CHARACTER_SPRITES[i+1]
	mascot.custom_minimum_size = Vector2(84,110)
	mascot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mascot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(mascot)
	body.add_child(_txt(_tr("ui.world_locked"), 20))
	body.add_child(_txt(_tr("ui.preview_route"), 17, COLORS.muted))
	body.add_child(_btn(_tr("ui.atlas"), func(): _open_atlas()))

func _save_preferences() -> void:
	data["settings"] = preferences.duplicate(true)
	locale.language = str(preferences["language"])
	store.save_profile(profiles.selected, data)
	_apply_audio()

func _flip_setting(key: String) -> void:
	preferences[key] = not bool(preferences.get(key, false))
	_save_preferences()
	_open_settings()

func _change_language() -> void:
	preferences["language"] = "en" if preferences["language"] == "tr" else "tr"
	_save_preferences()
	_open_settings()

func _change_layer() -> void:
	var list = ["concrete", "blocks", "system"]
	preferences["layer"] = list[(list.find(preferences["layer"]) + 1) % 3]
	_save_preferences()
	_open_settings()

func _change_text_size() -> void:
	preferences["text_size"] = (int(preferences.get("text_size", 0)) + 1) % 3
	_save_preferences()
	_open_settings()

func _cycle_volume(key: String) -> void:
	preferences[key] = (int(preferences.get(key, 0)) + 25) % 125
	_save_preferences()
	_open_settings()

func _open_settings() -> void:
	screen = "settings"
	var body = _frame(_tr("ui.settings"))
	var v := _scroll_area(body)
	v.add_child(_btn(_tr("ui.language") + " : " + str(preferences["language"]).to_upper(), func(): _change_language()))
	var layer_key = "ui." + str(preferences["layer"])
	v.add_child(_btn(_tr("ui.layer") + " : " + _tr(layer_key), func(): _change_layer()))
	v.add_child(_btn(_tr("ui.text_size") + " · " + _tr("ui.text_size_%d" % int(preferences["text_size"])), _change_text_size))
	v.add_child(_btn(_tr("ui.readable_font") + " · " + ("Atkinson" if preferences["readable_font"] else "Noto Sans"), func(): _flip_setting("readable_font")))
	for key in ["high_contrast", "color_blind_mode", "reduced_motion", "performance"]:
		var k: String = key
		v.add_child(_btn(_tr("ui."+key) + " : " + (_tr("ui.on") if preferences[key] else _tr("ui.off")), func(): _flip_setting(k)))
	for audio_key in ["music_volume", "sfx_volume"]:
		var k: String = audio_key
		v.add_child(_btn(_tr("ui." + k) + " : " + str(preferences[k]) + "%", func(): _cycle_volume(k)))
	v.add_child(_btn(_tr("ui.export"), func(): _choose_backup(true)))
	v.add_child(_btn(_tr("ui.import"), func(): _choose_backup(false)))
	if feedback in ["ui.backup_success", "ui.backup_failed", "ui.backup_restored"]:
		v.add_child(_txt(_tr(feedback), 16, _accent()))
	body.add_child(_btn(_tr("ui.back"), func(): _open_mission(mission_order)))

func _open_profiles() -> void:
	screen = "profiles"
	var body = _frame(_tr("ui.profiles"))
	var stack := _scroll_area(body)
	for entry in profiles.entries:
		var id: String = str(entry["id"])
		var label: String = str(entry["title"]) + ("  *" if id == profiles.selected else "")
		stack.add_child(_btn(label, func(): _choose_profile(id)))
	stack.add_child(_btn(_tr("ui.new_profile"), func(): _create_profile()))
	body.add_child(_btn(_tr("ui.back"), func(): _open_mission(mission_order)))

func _choose_profile(id: String) -> void:
	if not profiles.select_profile(id):
		_show_recovery_error()
		return
	data = store.load_profile(id)
	if data.is_empty():
		_show_recovery_error()
		return
	preferences = settings_service.normalize(data.get("settings", {}))
	locale.language = str(preferences["language"])
	_apply_audio()
	_resume_progress()

func _create_profile() -> void:
	var id: String = profiles.create_profile("Oyuncu " + str(profiles.entries.size()+1))
	if id.is_empty():
		_show_recovery_error()
		return
	data = store.empty_data(id)
	preferences = settings_service.normalize({"language": locale.language})
	data["settings"] = preferences
	if not store.save_profile(id, data):
		_show_recovery_error()
		return
	_apply_audio()
	_resume_progress()

func _choose_backup(exporting: bool) -> void:
	var dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE if exporting else FileDialog.FILE_MODE_OPEN_FILE
	dialog.filters = PackedStringArray(["*.alg.json ; Local backup"])
	dialog.use_native_dialog = true
	add_child(dialog)
	dialog.file_selected.connect(func(path: String):
		if exporting:
			feedback = "ui.backup_success" if backups.export_data(data, path) else "ui.backup_failed"
		else:
			feedback = "ui.backup_restored" if _restore_backup(path) else "ui.backup_failed"
		_open_settings()
	)
	dialog.canceled.connect(func(): dialog.queue_free())
	dialog.popup_centered_ratio(0.75)

func _restore_backup(path: String) -> bool:
	var imported: Dictionary = backups.import_data(path)
	var target := str(imported.get("profile_id", ""))
	if not target.is_valid_identifier() or target.length() > 64:
		return false
	var active: bool = target == profiles.selected
	var existing: Dictionary = data if active and not data.is_empty() else store.load_profile(target)
	if existing.is_empty():
		return false
	var merged: Dictionary = backups.merge(existing, imported)
	if merged.is_empty() or not store.save_profile(target, merged):
		return false
	if active:
		data = merged
		return true
	return profiles.register_profile(target, "Oyuncu " + str(profiles.entries.size() + 1))

func _show_recovery_error() -> void:
	screen = "recovery"
	preferences = settings_service.normalize({})
	var body = _frame(_tr("ui.recovery_heading"))
	body.add_child(_txt(_tr("ui.recovery_warning"), 23, _accent()))

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if playback_active:
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_ESCAPE:
		_go_back()
		get_viewport().set_input_as_handled()
		return
	if screen != "mission":
		return
	var cmd: Dictionary = input_actions.from_key(event.keycode)
	var type := str(level.get("type", ""))
	if type == "robot_course" and event.keycode == KEY_Q:
		_add_command("S")
		get_viewport().set_input_as_handled()
	elif not cmd.is_empty() and type in ["grid_route", "robot_course"]:
		_add_command(str(cmd["command"]))
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_BACKSPACE:
		_undo()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ENTER:
		_run_commands()
		get_viewport().set_input_as_handled()

func _go_back() -> void:
	if playback_active:
		return
	match screen:
		"mission", "preview", "missions": _open_atlas()
		"daily", "competition", "sandbox", "workshop", "collection", "skills": _open_modes()
		"recovery": _open_profiles()
		_:
			if level.is_empty():
				_show_recovery_error()
			else:
				_open_mission(mission_order)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_node_ready():
		_go_back()
	if what == NOTIFICATION_APPLICATION_PAUSED and not data.is_empty() and not profiles.selected.is_empty():
		data["settings"] = preferences
		store.save_profile(profiles.selected, data)

func _exit_tree() -> void:
	for player in [music_player, effects_player]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	if not data.is_empty() and not profiles.selected.is_empty():
		data["settings"] = preferences
		store.save_profile(profiles.selected, data)

func _draw_mechanic(area: VBoxContainer, current: Dictionary) -> void:
	var p: Dictionary = level["layers"][runner.layer]["params"]
	var typ: String = str(level["type"])
	match typ:
		"sort_train":
			area.add_child(_txt("→  " + _sequence_text(p["goal"]), 17, _accent()))
			area.add_child(_txt(_sequence_text(current.get("order", p["initial"])), 25, COLORS.paper))
		"binary_lights":
			area.add_child(_txt(_tr("ui.target") + "  " + _sequence_text(p["goal"]), 16, _accent()))
			var bits = HFlowContainer.new()
			area.add_child(bits)
			for bit in current.get("bits",p["initial"]):bits.add_child(_light_badge(str(bit), int(bit)==1))
		"cipher_wheel":
			area.add_child(_txt("◈  " + str(p["source"]), 27, COLORS.paper))
			area.add_child(_txt(_tr("ui.target") + ": " + str(p["encodings"][int(p["goal_shift"])]), 21, _accent()))
			area.add_child(_txt(_tr("ui.sequence") + ": " + str(p["encodings"][int(current.get("shift",0))]), 19, COLORS.muted))
		"flowchart":
			area.add_child(_txt(_tr("ui.flow_start") + "  →  …  →  " + _tr("ui.flow_end"), 17, _accent()))
			for code in p["nodes"]:
				area.add_child(_txt(str(code) + "   ·   " + _mechanic_label("flow.step_", str(p["labels"][code])), 16, COLORS.muted))
			area.add_child(_txt(_sequence_text(current.get("path",[])), 22, COLORS.paper))
		"logic_gate":
			area.add_child(_txt("[ A ]  ─┐", 22, COLORS.paper))
			area.add_child(_txt(_tr("ui.gate_" + str(p["gate"]).to_lower()), 23, _accent()))
			var inputs := "A=" + str(current.get("a", 0))
			if p["gate"] != "NOT":
				area.add_child(_txt("[ B ]  ─┘", 22, COLORS.paper))
				inputs += "   B=" + str(current.get("b", 0))
			area.add_child(_txt(inputs, 18, COLORS.muted))
			var output: Array = runner.module.evaluate(level, current).get("evidence", [])
			if not output.is_empty():
				area.add_child(_txt(_tr("ui.gate_output") % [int(output[0]), int(p["goal"])], 18, COLORS.paper))
		"pattern_machine":
			area.add_child(_txt(_tr("ui.start_number") + ": " + str(p["start"]), 18, COLORS.muted))
			area.add_child(_txt("[ " + str(current.get("value",p["start"])) + " ]   →   [ " + str(p["goal"]) + " ]", 25, _accent()))
		"resource_plan":
			area.add_child(_txt(_tr("ui.goal_number") + ": " + str(p["goal"]) + "   /  " + _tr("ui.cost") + ": ≤" + str(p["budget"]), 17, _accent()))
			for item in p["costs"].keys():
				area.add_child(_txt(str(item) + "   ·   " + str(p["benefits"][item]) + " +  /  " + str(p["costs"][item]) + " −", 16, COLORS.paper))
			area.add_child(_txt(_sequence_text(current.get("chosen",[])), 19, COLORS.muted))
		"sensor_lab":
			area.add_child(_txt(_tr("ui.data") + "  ·  " + _tr("ui.target"), 17, COLORS.muted))
			var lights := HFlowContainer.new()
			area.add_child(lights)
			for index in range(p["samples"].size()):
				var active := int(p["expected"][index]) == 1
				lights.add_child(_light_badge("%s · %s" % [p["samples"][index], p["expected"][index]], active))
			var auto := _tr("ui.on") if current.get("auto", false) else _tr("ui.off")
			area.add_child(_txt(_tr("ui.sensor_status") % [int(current.get("threshold", 1)), auto], 17, COLORS.paper))
		"graph_path":
			var waypoints: Array = [p["start"]]
			waypoints.append_array(p.get("via", []))
			waypoints.append(p["goal"])
			area.add_child(_txt("  →  ".join(PackedStringArray(waypoints)), 20, _accent()))
			for node in p["edges"].keys():
				var options: Array = []
				for neighbour in p["edges"][node].keys():options.append(str(neighbour) + "(" + str(p["edges"][node][neighbour]) + ")")
				area.add_child(_txt(str(node) + ": " + _sequence_text(options), 15, COLORS.paper))
			area.add_child(_txt(str(current.get("node",p["start"])) + "   " + _tr("ui.cost") + ": " + str(current.get("cost",0)) + "/" + str(p["max_cost"]), 19, _accent()))
		"function_loops":
			for macro in p["macros"].keys():area.add_child(_txt(str(macro)+"()  →  " + str(p["macros"][macro]), 19, COLORS.paper))
			area.add_child(_txt(_tr("ui.target") + ": " + str(p["target"]), 20, _accent()))
			area.add_child(_txt(str(current.get("sequence","")), 18, COLORS.muted))
		"state_machine":
			var mode := str(current.get("mode", p["start"]))
			area.add_child(_txt(_tr("ui.machine_state") % [_mechanic_label("machine.state_", mode), _mechanic_label("machine.state_", str(p["goal"]))], 20, _accent()))
			for origin in p["transitions"]:
				for action in p["transitions"][origin]:
					var origin_label := _mechanic_label("machine.state_", str(origin))
					var event := _mechanic_label("machine.event_", str(action))
					var destination := _mechanic_label("machine.state_", str(p["transitions"][origin][action]))
					area.add_child(_txt("%s  ·  %s [%s]  →  %s" % [origin_label, event, action, destination], 16, COLORS.muted))
		"data_detective":
			area.add_child(_txt("≥ " + str(p["threshold"]), 23, _accent()))
			var items = HFlowContainer.new()
			area.add_child(items)
			for i in range(p["values"].size()): items.add_child(_light_badge(str(i) + ":" + str(p["values"][i]), current.get("selected",[]).has(str(i))))
		_:
			area.add_child(_txt(_tr("ui.unsupported"), 18, COLORS.paper))

func _open_modes() -> void:
	screen = "modes"
	var body = _frame(_tr("ui.mode"))
	body.add_child(_txt(_tr("ui.journey"), 25, _accent()))
	var listing := _scroll_area(body)
	listing.add_child(_btn(_tr("ui.daily"), func(): _show_daily()))
	listing.add_child(_btn(_tr("ui.simulation"), func(): _show_competition()))
	listing.add_child(_btn(_tr("ui.workshop"), func(): _show_workshop()))
	listing.add_child(_btn(_tr("ui.sandbox"), func(): _show_sandbox()))
	listing.add_child(_btn(_tr("ui.collection"), func(): _show_collection()))
	listing.add_child(_btn(_tr("ui.skills"), func(): _show_skills()))
	body.add_child(_btn(_tr("ui.atlas"), func(): _open_atlas()))

func _daily_seed() -> int:
	var today: Dictionary = Time.get_date_dict_from_system()
	return int(today["year"])*372 + int(today["month"])*31 + int(today["day"])

func _show_daily() -> void:
	mode_context = "daily"
	screen = "daily"
	var body = _frame(_tr("ui.daily"))
	body.add_child(_txt(_tr("ui.daily_note"), 22, _accent()))
	var available_worlds: int = 1
	for w in range(2,8):
		if _world_unlocked(w): available_worlds = w
	var number: int = posmod(_daily_seed()*17, available_worlds*50)
	var world_number: int = int(number/50) + 1
	var level_number: int = number%50 + 1
	var mission_id: String = "d%d-p%d-%03d" % [world_number,int((level_number-1)/10)+1,level_number]
	body.add_child(_txt(_tr("mission." + mission_id), 20, COLORS.paper))
	body.add_child(_btn(_tr("ui.world_open"), func(): _start_mode_mission(world_number,level_number,"daily")))
	body.add_child(_btn(_tr("ui.mode"), func(): _open_modes()))

func _start_mode_mission(w: int, n: int, mode: String) -> void:
	if not _world_unlocked(w): return
	current_world = w
	mode_context = mode
	_open_mission(n)

func _show_competition() -> void:
	mode_context = "simulation"
	screen = "competition"
	var body := _scroll_area(_frame(_tr("ui.simulation")))
	body.add_child(_txt(_tr("ui.practice_note"), 18, COLORS.paper))
	body.add_child(_btn(_tr("ui.timer") + " : " + (_tr("ui.on") if sim_timer_enabled else _tr("ui.off")), func(): _toggle_sim_timer()))
	if sim_timer_enabled:
		if sim_started_ms == 0: sim_started_ms = Time.get_ticks_msec()
		sim_clock_label = _txt("00:00", 20, _accent())
		body.add_child(sim_clock_label)
	var available_worlds: int = 1
	for w in range(2,8):
		if _world_unlocked(w): available_worlds = w
	for i in range(5):
		var index: int = posmod(_daily_seed() * 3 + i*23,available_worlds*50)
		var w: int = int(index/50)+1
		var n: int = index%50+1
		var mid: String = "d%d-p%d-%03d" % [w,int((n-1)/10)+1,n]
		body.add_child(_btn(_tr("mission."+mid),func(): _start_mode_mission(w,n,"simulation")))
	body.add_child(_btn(_tr("ui.mode"), func(): _open_modes()))

func _toggle_sim_timer() -> void:
	sim_timer_enabled = not sim_timer_enabled
	sim_started_ms = Time.get_ticks_msec() if sim_timer_enabled else 0
	_show_competition()

func _process(_delta: float) -> void:
	if screen in ["competition", "mission"] and mode_context == "simulation" and sim_timer_enabled and is_instance_valid(sim_clock_label):
		var elapsed: int = int((Time.get_ticks_msec()-sim_started_ms)/1000)
		sim_clock_label.text = "%02d:%02d" % [int(elapsed/60),elapsed%60]

func _show_sandbox() -> void:
	# Independent creative robot board. No user progress, badges, or profile writes.
	mode_context = "sandbox"
	screen = "sandbox"
	var body = _frame(_tr("ui.sandbox"), 3)
	body.add_child(_txt(_tr("ui.sandbox_instruction"), 18, COLORS.paper))
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var panel = _stack()
	scroll.add_child(panel)
	var map = GridContainer.new()
	map.columns = 5
	panel.add_child(map)
	var position: Array = sandbox_last.get("position", [0, 0])
	var trail: Array = sandbox_last.get("trail", [])
	for y in range(5):
		for x in range(5):
			var xy: Array = [x, y]
			var tile = Button.new()
			tile.custom_minimum_size = Vector2(49, 49)
			var symbol: String = "floor"
			if sandbox_rocks.has(xy): symbol = "rock"
			elif xy == [4, 4]: symbol = "goal"
			elif xy == position: symbol = "start"
			elif trail.has(xy): symbol = "trail"
			tile.icon = SPRITES[symbol]
			tile.expand_icon = true
			tile.add_theme_stylebox_override("normal", _box_color(COLORS.sea, COLORS.line))
			tile.add_theme_stylebox_override("hover", _box_color(COLORS.panel, _accent()))
			tile.tooltip_text = _tr("ui.sandbox_terrain")
			tile.pressed.connect(func(): _sandbox_toggle_rock(xy))
			map.add_child(tile)
	panel.add_child(_txt(_tr("ui.sequence") + ": " + (_sequence_text(sandbox_commands) if not sandbox_commands.is_empty() else _tr("ui.no_command")), 18, _accent()))
	var palette = HFlowContainer.new()
	panel.add_child(palette)
	for code in ["U", "R", "D", "L"]:
		var symbol: String = code
		var names: Dictionary = {"U":"ui.move_up", "R":"ui.move_right", "D":"ui.move_down", "L":"ui.move_left"}
		palette.add_child(_btn(_tr(names[symbol]), func(): _sandbox_add(symbol), true))
	var controls = HFlowContainer.new()
	panel.add_child(controls)
	controls.add_child(_btn(_tr("ui.undo"), func(): _sandbox_undo(), true))
	controls.add_child(_btn(_tr("ui.clear"), func(): _sandbox_clear(), true))
	controls.add_child(_btn(_tr("ui.run"), func(): _sandbox_execute()))
	if sandbox_last.has("position"):
		panel.add_child(_txt(_tr("ui.sandbox_reached" if sandbox_last.get("reached", false) else "ui.sandbox_explore"), 17, COLORS.paper))
	body.add_child(_btn(_tr("ui.mode"), func(): _open_modes()))

func _sandbox_toggle_rock(xy: Array) -> void:
	if xy == [0, 0] or xy == [4, 4]: return
	if sandbox_rocks.has(xy): sandbox_rocks.erase(xy)
	else: sandbox_rocks.append(xy.duplicate())
	sandbox_last.clear()
	_show_sandbox()

func _sandbox_add(symbol: String) -> void:
	if sandbox_commands.size() < 40:
		sandbox_commands.append(symbol)
		sandbox_last.clear()
	_show_sandbox()

func _sandbox_undo() -> void:
	if not sandbox_commands.is_empty(): sandbox_commands.pop_back()
	sandbox_last.clear()
	_show_sandbox()

func _sandbox_clear() -> void:
	sandbox_commands.clear()
	sandbox_last.clear()
	_show_sandbox()

func _sandbox_execute() -> void:
	# A free, deterministic simulator with editable terrain; never calls progress.complete.
	var position: Array = [0, 0]
	var trail: Array = [[0, 0]]
	var directions: Dictionary = {"U":[0,-1],"R":[1,0],"D":[0,1],"L":[-1,0]}
	for command in sandbox_commands:
		var delta: Array = directions.get(command, [0, 0])
		var next: Array = [int(position[0])+int(delta[0]), int(position[1])+int(delta[1])]
		if next[0] < 0 or next[0] > 4 or next[1] < 0 or next[1] > 4 or sandbox_rocks.has(next): break
		position = next
		trail.append(position.duplicate())
	sandbox_last = {"position":position,"trail":trail,"reached":position == [4, 4]}
	_show_sandbox()

func _show_collection() -> void:
	screen = "collection"
	var body = _frame(_tr("ui.collection"))
	body.add_child(_txt(_tr("ui.collection_note"), 17, COLORS.paper))
	body.add_child(_txt(str(data.get("reward_ids",[]).size()) + "  " + _tr("ui.progress"), 23, _accent()))
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var list = _stack()
	scroll.add_child(list)
	for id in data.get("completed_ids", []):
		list.add_child(_txt("◈  " + _tr("mission." + str(id)), 15, COLORS.paper))
	body.add_child(_btn(_tr("ui.mode"), func(): _open_modes()))

func _show_skills() -> void:
	screen = "skills"
	var body = _frame(_tr("ui.skills"))
	body.add_child(_txt(_tr("ui.skills_note"), 17, COLORS.paper))
	var concepts: Dictionary = {}
	for id in data.get("completed_ids", []):
		var mission: Dictionary = repository.load_level(str(id))
		for name in mission.get("concepts",[]):
			concepts[name] = int(concepts.get(name,0))+1
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var listing = _stack()
	scroll.add_child(listing)
	for concept in concepts.keys():
		listing.add_child(_txt(str(concept).replace("_"," ").capitalize() + "  ·  " + str(concepts[concept]), 20, _accent()))
	if concepts.is_empty(): listing.add_child(_txt(_tr("ui.no_results"), 19, COLORS.paper))
	body.add_child(_btn(_tr("ui.mode"), func(): _open_modes()))

func _show_workshop() -> void:
	screen = "workshop"
	var body := _scroll_area(_frame(_tr("ui.workshop")))
	body.add_child(_txt(_tr("ui.workshop_note"), 18, COLORS.paper))
	var record: Dictionary = data.get("workshop", {"step":0,"choices":[]})
	var step: int = clampi(int(record.get("step",0)),0,5)
	if step >= 5:
		body.add_child(_txt(_tr("ui.workshop_result"), 23, _accent()))
		for criterion in data.get("workshop_criteria",{}).keys():
			var good: bool = bool(data["workshop_criteria"][criterion])
			body.add_child(_txt(_tr("ui.workshop_criterion_"+str(criterion))+": "+_tr("ui.workshop_found" if good else "ui.workshop_discover"), 16, COLORS.muted))
		body.add_child(_btn(_tr("ui.play_again"), func(): _workshop_reset()))
	else:
		body.add_child(_txt(_tr("ui.workshop_phase_%d" % (step+1)), 25, _accent()))
		body.add_child(_txt(_tr("ui.workshop_question_%d" % (step+1)), 20, COLORS.paper))
		for i in range(2):
			var choice: int = i
			body.add_child(_btn(_tr("ui.workshop_choice_%d_%d" % [step+1,i+1]), func(): _workshop_choose(choice)))
	body.add_child(_btn(_tr("ui.mode"), func(): _open_modes()))

func _workshop_choose(choice: int) -> void:
	var record: Dictionary = data.get("workshop", {"step":0,"choices":[]})
	var choices: Array = record.get("choices",[])
	choices.append(choice)
	# Multiple automatic criteria: observable hypothesis, controlled test, data reflection.
	record["choices"] = choices
	record["step"] = mini(int(record.get("step",0))+1,5)
	data["workshop"] = record
	if int(record["step"]) == 5:
		var criteria: Dictionary = {"hypothesis": choices[1]==0, "controlled_test": choices[3]==0, "reflection": choices[4]==0}
		data["workshop_criteria"] = criteria
		if criteria.values().count(true) >= 2:
			var rewards: Array = data.get("reward_ids",[])
			if not rewards.has("workshop_first_model"):
				rewards.append("workshop_first_model")
			data["reward_ids"] = rewards
	store.save_profile(profiles.selected,data)
	_show_workshop()

func _workshop_reset() -> void:
	# Retrying the studio never removes a badge or previously completed mission.
	data["workshop"] = {"step":0,"choices":[]}
	store.save_profile(profiles.selected,data)
	_show_workshop()

func _init_audio() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "WorldMusic"
	add_child(music_player)
	effects_player = AudioStreamPlayer.new()
	effects_player.name = "WorldEffects"
	add_child(effects_player)
	_apply_audio()

func _apply_audio() -> void:
	if not is_instance_valid(music_player) or not is_instance_valid(effects_player): return
	music_player.volume_db = linear_to_db(maxf(0.001,float(preferences.get("music_volume",0))/100.0))
	if int(preferences.get("music_volume",0)) > 0 and music_player.stream != null and not music_player.playing: music_player.play()
	if int(preferences.get("music_volume",0)) == 0 and music_player.playing: music_player.stop()
	effects_player.volume_db = linear_to_db(maxf(0.001,float(preferences.get("sfx_volume",35))/100.0))

func _effect(key: String) -> void:
	if not is_instance_valid(effects_player) or int(preferences.get("sfx_volume",35)) <= 0:return
	var audio_path: String = "res://varliklar/audio/" + key + ".wav"
	effects_player.stop()
	effects_player.stream = load(audio_path)
	effects_player.play()

func _play_world_music(w: int) -> void:
	if not is_instance_valid(music_player) or playing_world == w:return
	playing_world = w
	music_player.stop()
	var track: AudioStreamWAV = load("res://varliklar/audio/world_%d.wav" % w)
	if track == null:return
	track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music_player.stream = track
	if int(preferences.get("music_volume",0)) > 0: music_player.play()
