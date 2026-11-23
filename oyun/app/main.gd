extends Control
## Vertical slice. All major screens use one handcrafted pixel-forward UI language.
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
const BACKDROP = preload("res://varliklar/sprites/coast_dusk.png")
const SPRITES = {
	"rock": preload("res://varliklar/sprites/rock.png"),
	"floor": preload("res://varliklar/sprites/floor.png"),
	"start": preload("res://varliklar/sprites/agent.png"),
	"goal": preload("res://varliklar/sprites/lighthouse.png"),
	"trail": preload("res://varliklar/sprites/trail.png")
}
const WORLDS := ["ui.preview_d1", "ui.preview_d2", "ui.preview_d3", "ui.preview_d4", "ui.preview_d5", "ui.preview_d6", "ui.preview_d7"]
const COLORS := {"ink": Color("#102B34"), "panel": Color("#163841"), "paper": Color("#E9DBB7"), "muted": Color("#BDD1CC"), "gold": Color("#D9A75C"), "line": Color("#67847B"), "sea": Color("#28545C"), "light": Color("#F7C86D")}
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
var level: Dictionary = {}
var command_queue: Array = []
var hint_tier: int = 0
var feedback: String = ""
var screen: String = "mission"

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
	for i in range(1, 6):
		if not data.get("completed_ids", []).has("d1-p1-%03d" % i):
			mission_order = i
			break
		mission_order = 5
	_open_mission(mission_order)

func _tr(key: String) -> String:
	return locale.text(key)

func _sequence_text(commands: Array) -> String:
	var parts := PackedStringArray()
	for item in commands:
		parts.append(str(item))
	return "  ".join(parts)

func _clear() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func _box_color(shade: Color, edge: Color) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = shade
	box.border_color = edge
	box.set_border_width_all(2)
	box.set_content_margin_all(11)
	return box

func _panel() -> PanelContainer:
	var item = PanelContainer.new()
	var color = COLORS.ink if bool(preferences.get("high_contrast", false)) else COLORS.panel
	item.add_theme_stylebox_override("panel", _box_color(color, COLORS.gold))
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return item

func _txt(message: String, font_size: int = 19, tint: Color = Color(0.914, 0.859, 0.718), wrap: bool = true) -> Label:
	var node = Label.new()
	node.text = message
	node.add_theme_color_override("font_color", tint)
	node.add_theme_font_size_override("font_size", font_size + (4 if bool(preferences.get("large_text", false)) else 0))
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node

func _btn(message: String, callback: Callable, small: bool = false) -> Button:
	var button = Button.new()
	button.text = message
	button.custom_minimum_size = Vector2(82 if small else 130, 43 if small else 49)
	button.add_theme_stylebox_override("normal", _box_color(COLORS.ink, COLORS.line))
	button.add_theme_stylebox_override("hover", _box_color(COLORS.sea, COLORS.gold))
	button.add_theme_stylebox_override("pressed", _box_color(COLORS.gold, COLORS.paper))
	button.add_theme_stylebox_override("focus", _box_color(Color.TRANSPARENT, COLORS.gold))
	button.add_theme_color_override("font_color", COLORS.paper)
	button.add_theme_color_override("font_hover_color", COLORS.paper)
	button.add_theme_color_override("font_pressed_color", COLORS.ink)
	button.add_theme_color_override("font_focus_color", COLORS.paper)
	button.add_theme_font_size_override("font_size", 16 + (4 if bool(preferences.get("large_text", false)) else 0))
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	return button

func _stack() -> VBoxContainer:
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 9)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return v

func _frame(subtitle: String) -> VBoxContainer:
	_clear()
	var img = TextureRect.new()
	img.texture = BACKDROP
	img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_SCALE
	img.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(img)
	var tint = ColorRect.new()
	tint.color = Color(0.03, 0.10, 0.13, 0.76)
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
	top.add_theme_constant_override("h_separation", 9)
	body.add_child(top)
	top.add_child(_txt(_tr("ui.app") + "  /  " + subtitle, 17, COLORS.gold))
	top.add_child(_btn(_tr("ui.atlas"), func(): _open_atlas(), true))
	top.add_child(_btn(_tr("ui.profiles"), func(): _open_profiles(), true))
	top.add_child(_btn(_tr("ui.settings"), func(): _open_settings(), true))
	return body

func _open_mission(order: int) -> void:
	mission_order = clampi(order, 1, 5)
	level = repository.load_level("d1-p1-%03d" % mission_order)
	if level.is_empty():
		_show_recovery_error()
		return
	if not runner.open(level, str(preferences.get("layer", "concrete"))):
		_show_recovery_error()
		return
	command_queue.clear()
	var attempt: Dictionary = data.get("last_attempt", {})
	if attempt.get("mission_id", "") == level["id"] and attempt.get("layer", "") == runner.layer:
		for cmd in attempt.get("commands", []):
			if command_queue.size() < 30:
				command_queue.append(str(cmd))
	hint_tier = int(attempt.get("hint_tier", 0)) if attempt.get("mission_id", "") == level["id"] else 0
	feedback = ""
	screen = "mission"
	_render_mission()

func _render_mission() -> void:
	var body = _frame(_tr("ui.agent"))
	body.add_child(_txt(_tr("ui.world"), 24, COLORS.paper))
	body.add_child(_txt("%02d / 05   ·   %s" % [mission_order, _tr(str(level["locale_key"]))], 23, COLORS.gold))
	body.add_child(_txt(_tr("mission.desc." + str(level["id"])), 17, COLORS.paper))
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var horizontal: bool = size.x >= 680
	var contents: BoxContainer = HBoxContainer.new() if horizontal else VBoxContainer.new()
	contents.add_theme_constant_override("separation", 12)
	contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(contents)
	var board: PanelContainer = _panel()
	if horizontal:
		board.custom_minimum_size.x = max(330.0, size.x * 0.51)
	contents.add_child(board)
	var area = _stack()
	board.add_child(area)
	if str(level["type"]) == "grid_route":
		_draw_grid(area)
	elif str(level["type"]) == "signal_pattern":
		_draw_pattern(area)
	else:
		_draw_panel(area)
	var desk: PanelContainer = _panel()
	if horizontal:
		desk.custom_minimum_size.x = max(280.0, size.x * 0.35)
	contents.add_child(desk)
	var commands = _stack()
	desk.add_child(commands)
	commands.add_child(_txt(_tr("ui.add_command"), 17, COLORS.gold))
	_draw_palette(commands)
	commands.add_child(_txt(_tr("ui.sequence") + ": " + (_sequence_text(command_queue) if not command_queue.is_empty() else _tr("ui.no_command")), 15, COLORS.paper))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	commands.add_child(row)
	row.add_child(_btn(_tr("ui.undo"), func(): _undo(), true))
	row.add_child(_btn(_tr("ui.clear"), func(): _clear_commands(), true))
	commands.add_child(_btn(_tr("ui.run"), func(): _run_commands()))
	commands.add_child(_btn(_tr("ui.hint") + "  %d/3" % hint_tier, func(): _take_hint()))
	if hint_tier > 0:
		var text = _tr(str(hints.get_hint(level, hint_tier).get("key", "")))
		if hint_tier == 3:
			text += "\n" + _tr("ui.witness") + ": " + _sequence_text(level["layers"][runner.layer]["witness"])
		commands.add_child(_txt(text, 15, COLORS.muted))
	if feedback != "":
		commands.add_child(_txt(_tr(feedback), 17, COLORS.gold))
	if data.get("completed_ids", []).has(level["id"]):
		commands.add_child(_txt(_tr("ui.completed"), 16, COLORS.light))
		if mission_order < 5:
			commands.add_child(_btn(_tr("ui.next"), func(): _open_mission(mission_order + 1)))

func _square(surface: Container, image_key: String, cell: int) -> void:
	var cell_node = PanelContainer.new()
	cell_node.custom_minimum_size = Vector2(cell, cell)
	cell_node.add_theme_stylebox_override("panel", _box_color(COLORS.sea, COLORS.line))
	surface.add_child(cell_node)
	var texture = TextureRect.new()
	texture.texture = SPRITES[image_key]
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_SCALE
	texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell_node.add_child(texture)

func _draw_grid(area: VBoxContainer) -> void:
	area.add_child(_txt(_tr("ui.route"), 18, COLORS.gold))
	var p: Dictionary = level["layers"][runner.layer]["params"]
	var w: int = int(p["size"][0])
	var h: int = int(p["size"][1])
	var cell: int = 47 if size.x > 720 else 38
	var grid = GridContainer.new()
	grid.columns = w
	grid.add_theme_constant_override("h_separation", 1)
	grid.add_theme_constant_override("v_separation", 1)
	area.add_child(grid)
	var at: Array = runner.state.get("position", p["start"])
	var trail: Array = runner.state.get("trail", [])
	for y in range(h):
		for x in range(w):
			var key = "floor"
			if p.get("rocks", []).has([x, y]): key = "rock"
			elif p["goal"] == [x, y]: key = "goal"
			elif at == [x, y]: key = "start"
			elif trail.has([x, y]): key = "trail"
			_square(grid,key,cell)
	area.add_child(_txt(_tr("ui.prologue"), 15, COLORS.muted))

func _light_badge(letter: String, lit: bool) -> PanelContainer:
	var shell = PanelContainer.new()
	shell.custom_minimum_size = Vector2(56, 56)
	shell.add_theme_stylebox_override("panel", _box_color(COLORS.gold if lit else COLORS.sea, COLORS.paper if lit else COLORS.line))
	shell.add_child(_txt(letter, 23, COLORS.ink if lit else COLORS.paper))
	return shell

func _draw_pattern(area: VBoxContainer) -> void:
	area.add_child(_txt(_tr("ui.signal") + " / " + _tr("ui.target"), 18, COLORS.gold))
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
	for symbol in runner.state.get("sequence", []):
		chosen.add_child(_light_badge(str(symbol), true))

func _draw_panel(area: VBoxContainer) -> void:
	area.add_child(_txt(_tr("ui.panel"), 18, COLORS.gold))
	var p: Dictionary = level["layers"][runner.layer]["params"]
	area.add_child(_txt(_tr("ui.target"), 16, COLORS.muted))
	var target = HFlowContainer.new()
	area.add_child(target)
	for lamp in p["goal"]:
		target.add_child(_light_badge(str(lamp), lamp == 1))
	area.add_child(_txt(_tr("ui.sequence"), 16, COLORS.muted))
	var actual = HFlowContainer.new()
	area.add_child(actual)
	for lamp in runner.state.get("lamps", p["initial"]):
		actual.add_child(_light_badge(str(lamp), lamp == 1))

func _draw_palette(commands: VBoxContainer) -> void:
	var panel = HFlowContainer.new()
	panel.add_theme_constant_override("h_separation", 7)
	panel.add_theme_constant_override("v_separation", 7)
	commands.add_child(panel)
	var symbols: Array = []
	if str(level["type"]) == "grid_route":
		symbols = ["U", "R", "D", "L"]
	else:
		symbols = level["layers"][runner.layer]["params"].get("alphabet", []) if str(level["type"]) == "signal_pattern" else level["layers"][runner.layer]["params"]["wiring"].keys()
	for symbol in symbols:
		var s: String = str(symbol)
		var text = s
		if str(level["type"]) == "grid_route":
			var names: Dictionary = {"U": "ui.move_up", "D": "ui.move_down", "L": "ui.move_left", "R": "ui.move_right"}
			text = _tr(names[s])
		panel.add_child(_btn(text, func(): _add_command(s), true))

func _persist_attempt() -> void:
	if level.is_empty() or data.is_empty(): return
	data["last_attempt"] = {"mission_id": str(level["id"]), "layer": runner.layer, "commands": command_queue.duplicate(), "hint_tier": hint_tier}
	data["settings"] = preferences
	store.save_profile(profiles.selected, data)

func _add_command(symbol: String) -> void:
	if command_queue.size() >= 30: return
	command_queue.append(symbol)
	feedback = ""
	_persist_attempt()
	_render_mission()

func _undo() -> void:
	if not command_queue.is_empty():
		command_queue.pop_back()
		_persist_attempt()
	_render_mission()

func _clear_commands() -> void:
	command_queue.clear()
	runner.open(level, runner.layer)
	feedback = ""
	_persist_attempt()
	_render_mission()

func _run_commands() -> void:
	var result: Dictionary = runner.submit({"type":"run", "commands": command_queue})
	if bool(result.get("met", false)):
		data = progress.complete(data, str(level["id"]))
		data.erase("last_attempt")
		data["settings"] = preferences
		if not store.save_profile(profiles.selected, data):
			feedback = "ui.backup_failed"
		else:
			feedback = "result." + str(level["id"])
	elif result.get("events", []).has("blocked"):
		feedback = "ui.blocked"
	elif result.get("events", []).has("limit"):
		feedback = "ui.limit"
	else:
		feedback = "ui.incomplete"
	_render_mission()

func _take_hint() -> void:
	hint_tier = mini(hint_tier + 1, 3)
	_persist_attempt()
	_render_mission()

func _open_atlas() -> void:
	screen = "atlas"
	var body = _frame(_tr("ui.atlas"))
	body.add_child(_txt(_tr("ui.preview_title"), 23, COLORS.gold))
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var list = _stack()
	scroll.add_child(list)
	for i in range(7):
		var n: int = i
		var caption: String = _tr(WORLDS[i])
		if i == 0:
			list.add_child(_btn(caption + "  ·  %d/5" % data.get("completed_ids", []).size(), func(): _open_mission(mission_order)))
		else:
			list.add_child(_btn(caption + "  /  " + _tr("ui.preview"), func(): _preview_world(n)))
	body.add_child(_btn(_tr("ui.back"), func(): _open_mission(mission_order)))

func _preview_world(i: int) -> void:
	screen = "preview"
	var body = _frame(_tr("ui.atlas"))
	body.add_child(_txt(_tr(WORLDS[i]), 27, COLORS.gold))
	body.add_child(_txt(_tr("ui.preview"), 20))
	body.add_child(_btn(_tr("ui.atlas"), func(): _open_atlas()))

func _save_preferences() -> void:
	data["settings"] = preferences.duplicate(true)
	locale.language = str(preferences["language"])
	store.save_profile(profiles.selected, data)

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
	runner.open(level, str(preferences["layer"]))
	command_queue.clear()
	_open_settings()

func _cycle_volume(key: String) -> void:
	preferences[key] = (int(preferences.get(key, 0)) + 25) % 125
	_save_preferences()
	_open_settings()

func _open_settings() -> void:
	screen = "settings"
	var body = _frame(_tr("ui.settings"))
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var v = _stack()
	scroll.add_child(v)
	v.add_child(_btn(_tr("ui.language") + " : " + str(preferences["language"]).to_upper(), func(): _change_language()))
	var layer_key = "ui." + str(preferences["layer"])
	v.add_child(_btn(_tr("ui.layer") + " : " + _tr(layer_key), func(): _change_layer()))
	for key in ["high_contrast", "large_text", "color_blind_mode", "reduced_motion", "performance"]:
		var k: String = key
		v.add_child(_btn(_tr("ui."+key) + " : " + (_tr("ui.on") if preferences[key] else _tr("ui.off")), func(): _flip_setting(k)))
	for audio_key in ["music_volume", "sfx_volume"]:
		var k: String = audio_key
		v.add_child(_btn(_tr("ui." + k) + " : " + str(preferences[k]) + "%", func(): _cycle_volume(k)))
	v.add_child(_btn(_tr("ui.export"), func(): _choose_backup(true)))
	v.add_child(_btn(_tr("ui.import"), func(): _choose_backup(false)))
	if feedback in ["ui.backup_success", "ui.backup_failed", "ui.backup_restored"]:
		v.add_child(_txt(_tr(feedback), 16, COLORS.gold))
	body.add_child(_btn(_tr("ui.back"), func(): _open_mission(mission_order)))

func _open_profiles() -> void:
	screen = "profiles"
	var body = _frame(_tr("ui.profiles"))
	var stack = _stack()
	body.add_child(stack)
	for entry in profiles.entries:
		var id: String = str(entry["id"])
		var label: String = str(entry["title"]) + ("  *" if id == profiles.selected else "")
		stack.add_child(_btn(label, func(): _choose_profile(id)))
	stack.add_child(_btn(_tr("ui.new_profile"), func(): _create_profile()))
	body.add_child(_btn(_tr("ui.back"), func(): _open_mission(mission_order)))

func _choose_profile(id: String) -> void:
	if not profiles.select_profile(id): return
	data = store.load_profile(id)
	if data.is_empty():
		_show_recovery_error()
		return
	preferences = settings_service.normalize(data.get("settings", {}))
	locale.language = str(preferences["language"])
	_open_mission(1)

func _create_profile() -> void:
	var id: String = profiles.create_profile("Oyuncu " + str(profiles.entries.size()+1))
	data = store.empty_data(id)
	preferences = settings_service.normalize({"language": locale.language})
	data["settings"] = preferences
	store.save_profile(id, data)
	_open_mission(1)

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
			var imported: Dictionary = backups.import_data(path)
			if imported.is_empty():
				feedback = "ui.backup_failed"
			elif imported.get("profile_id", "") == profiles.selected:
				var merged: Dictionary = backups.merge(data, imported)
				if store.save_profile(profiles.selected, merged):
					data = store.load_profile(profiles.selected)
					feedback = "ui.backup_restored"
				else: feedback = "ui.backup_failed"
			else:
				# Different immutable ID: preserve a separate local student record.
				var target: String = str(imported.get("profile_id", ""))
				if target.is_valid_identifier() and not profiles.has_profile(target):
					profiles.entries.append({"id":target,"title":"Oyuncu " + str(profiles.entries.size()+1)})
					profiles.persist()
				if target.is_valid_identifier():
					var existing: Dictionary = store.load_profile(target)
					if not existing.is_empty(): store.save_profile(target, backups.merge(existing, imported))
				feedback = "ui.backup_restored"
		_open_settings()
	)
	dialog.canceled.connect(func(): dialog.queue_free())
	dialog.popup_centered_ratio(0.75)

func _show_recovery_error() -> void:
	preferences = settings_service.normalize({})
	var body = _frame(_tr("ui.recovery_heading"))
	body.add_child(_txt(_tr("ui.recovery_warning"), 23, COLORS.gold))

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo or screen != "mission": return
	var cmd: Dictionary = input_actions.from_key(event.keycode)
	if not cmd.is_empty() and str(level.get("type", "")) == "grid_route":
		_add_command(str(cmd["command"]))
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_BACKSPACE:
		_undo()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ENTER:
		_run_commands()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED and not data.is_empty() and not profiles.selected.is_empty():
		data["settings"] = preferences
		store.save_profile(profiles.selected, data)

func _exit_tree() -> void:
	if not data.is_empty() and not profiles.selected.is_empty():
		data["settings"] = preferences
		store.save_profile(profiles.selected, data)
