extends SceneTree
## A scene integration test using a clean Godot user-data directory.
const MAIN := preload("res://oyun/app/main.tscn")
var app
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS ", label)
	else:
		printerr("FAIL ", label)
		failures += 1

func _press(label: String, prefix := false) -> bool:
	for item in app.find_children("*", "Button", true, false):
		var button: Button = item
		if not button.disabled and (button.text == label or (prefix and button.text.begins_with(label))):
			button.pressed.emit()
			return true
	_expect(false, "button exists: " + label)
	return false

func _write(path: String, contents: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(contents)
		file.close()
	else:
		_expect(false, "write test fixture: " + path)

func _restore(path: String) -> void:
	if not _press(app._tr("ui.settings")) or not _press(app._tr("ui.import")):
		return
	var dialogs: Array = app.find_children("*", "FileDialog", true, false)
	if dialogs.size() != 1:
		_expect(false, "file selection opens exactly one dialog")
		return
	dialogs[0].file_selected.emit(path)

func _legacy_backup() -> void:
	var record: Dictionary = app.store.empty_data("legacy_student")
	record["generation"] = 8
	record["completed_ids"] = ["d1-p1-001"]
	record["workshop"] = {"step": 2, "choices": [0, 1]}
	var compact := JSON.stringify(record, "", true)
	var digest := compact.sha256_text()
	var signed := record.duplicate(true)
	signed["checksum"] = digest
	var path := "user://profiles/legacy_student/save.tmp"
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	_write(path, JSON.stringify(signed, "", true))
	_expect(app.store.load_profile("legacy_student").get("completed_ids", []).size() == 1, "interrupted legacy integer-token save recovered")
	var legacy := '{"backup_schema":1,"checksum":"%s","data":%s}' % [digest, compact]
	_write("user://legacy.alg.json", legacy)
	_expect(app.backups.import_data("user://legacy.alg.json").get("profile_id", "") == "legacy_student", "legacy integer-token backup validated")
	_write("user://tampered.alg.json", legacy.replace("d1-p1-001", "d1-p1-002"))
	_expect(app.backups.import_data("user://tampered.alg.json").is_empty(), "tampered backup rejected")

func _run() -> void:
	if FileAccess.file_exists("user://profiles/profiles.json"):
		printerr("Run test_app_flow.gd with a fresh user-data directory.")
		quit(2)
		return
	app = MAIN.instantiate()
	root.add_child(app)
	await process_frame
	_expect(app.level.get("id") == "d1-p1-001", "first start opens world 1 and first task")
	var older_id: String = app.profiles.selected
	_expect(FileAccess.file_exists("user://profiles".path_join(older_id).path_join("save.json")), "first profile stored on disk")
	var older: Dictionary = app.store.load_profile(older_id)
	older["completed_ids"] = ["d1-p4-040", "d2-p1-001"]
	older["settings"]["sfx_volume"] = 0
	app.preferences["sfx_volume"] = 0
	_expect(app.store.save_profile(older_id, older), "advanced world progress seeded")
	_press(app._tr("ui.profiles"))
	_press(app._tr("ui.new_profile"))
	var newer_id: String = app.profiles.selected
	app.preferences["sfx_volume"] = 0
	app.data["settings"]["sfx_volume"] = 0
	app.store.save_profile(newer_id, app.data)
	_expect(newer_id != older_id and app.level.get("id") == "d1-p1-001", "new profile starts at the first task")
	_press(app._tr("ui.profiles"))
	_press(app.profiles.title_for(older_id), true)
	_expect(app.current_world == 2 and app.level.get("id") == "d2-p1-002", "profile resumes highest unlocked world and first incomplete task")
	_press(app._tr("ui.profiles"))
	_press(app.profiles.title_for(newer_id), true)
	_expect(app.current_world == 1 and app.level.get("id") == "d1-p1-001" and app.mode_context == "story", "profile switch keeps worlds and mode independent")

	var foreign_id := "backup_student"
	var foreign: Dictionary = app.store.empty_data(foreign_id)
	foreign["completed_ids"] = ["d1-p1-002"]
	_expect(app.backups.export_data(foreign, "user://foreign.alg.json"), "foreign backup fixture exported")
	var block := "user://profiles/".path_join(foreign_id)
	_write(block, "file blocks creating a profile directory")
	_restore("user://foreign.alg.json")
	_expect(app.feedback == "ui.backup_failed" and not app.profiles.has_profile(foreign_id), "profile save failure produces no false success or listing")
	DirAccess.remove_absolute(block)
	var manifest_tmp := "user://profiles/profiles.json.tmp"
	DirAccess.make_dir_recursive_absolute(manifest_tmp)
	_restore("user://foreign.alg.json")
	_expect(app.feedback == "ui.backup_failed" and not app.profiles.has_profile(foreign_id), "manifest write failure produces no false success")
	DirAccess.remove_absolute(manifest_tmp)
	_restore("user://foreign.alg.json")
	_expect(app.feedback == "ui.backup_restored" and app.profiles.has_profile(foreign_id) and app.profiles.selected == newer_id, "retry registers separate profile without switching")

	app.data["daily_history"] = ["2026-11-19"]
	app.data["skill_events"] = ["sequence"]
	app.data["workshop"] = {"step": 2, "choices": [0, 1]}
	app.data["workshop_criteria"] = {"hypothesis": true}
	var incoming: Dictionary = app.store.empty_data(newer_id)
	incoming["daily_history"] = ["2026-11-20"]
	incoming["skill_events"] = ["condition"]
	incoming["workshop"] = {"step": 4, "choices": [1, 0, 1, 0]}
	incoming["workshop_criteria"] = {"reflection": true}
	_expect(app.backups.export_data(incoming, "user://own.alg.json"), "same-profile backup fixture exported")
	_restore("user://own.alg.json")
	var merged: Dictionary = app.store.load_profile(newer_id)
	_expect(app.feedback == "ui.backup_restored" and merged.get("daily_history", []).size() == 2 and merged.get("skill_events", []).size() == 2, "merged profile persists daily and skill histories")
	_expect(merged.get("workshop", {}).get("step") == 4 and merged.get("workshop_criteria", {}).values().count(true) == 2, "merged profile persists STEM step and criteria")
	_legacy_backup()

	_press(app._tr("ui.settings"))
	_press(app._tr("ui.layer"), true)
	_press(app._tr("ui.back"))
	_expect(app.runner.layer == "blocks", "block layer selected")
	_press(app._tr("ui.move_right"))
	_press(app._tr("ui.move_up"))
	_press("2. " + app._tr("ui.move_up"))
	_press(app._tr("ui.block_left"))
	_expect(app.command_queue == ["U", "R"], "blocks reorder through visible controls")
	_press(app._tr("ui.step"))
	_expect(app.trace_index == 1 and app.runner.state.get("moves", 0) == 1 and app.data["completed_ids"].is_empty(), "step simulates one actual move without committing progress")

	_press(app._tr("ui.settings"))
	_press(app._tr("ui.layer"), true)
	_press(app._tr("ui.text_size"), true)
	_press(app._tr("ui.readable_font"), true)
	_press(app._tr("ui.back"))
	_expect(app.runner.layer == "system", "system layer selected")
	var glyphs := "ÇĞİÖŞÜçğıöşü"
	var font_ok: bool = app.theme.default_font.get_font_name().contains("Atkinson")
	for index in range(glyphs.length()):
		font_ok = font_ok and app.theme.default_font.has_char(glyphs.unicode_at(index))
	_expect(font_ok and app.preferences["text_size"] == 1, "selected font has all 12 Turkish-specific glyphs")

	var editors: Array = app.find_children("CodeNotebook", "TextEdit", true, false)
	if not editors.is_empty():
		var editor: TextEdit = editors[0]
		editor.text = "R;D"
		editor.text_changed.emit()
		_press(app._tr("ui.run"))
		_expect(app.notebook_error.visible and app.data["completed_ids"].is_empty(), "notebook rejects unlisted syntax")
		editor.text = ",\n".join(PackedStringArray(app.level["layers"]["system"]["witness"])).to_lower()
		editor.text_changed.emit()
		_press(app._tr("ui.run"))
		_expect(app.data["completed_ids"].has("d1-p1-001"), "typed program solves through production evaluator")
	else:
		_expect(false, "visible code notebook")
	app.queue_free()
	await process_frame
	await process_frame
	print("APP FLOW FAILURES: ", failures)
	quit(1 if failures else 0)
