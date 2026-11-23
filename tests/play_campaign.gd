extends SceneTree
## Runs the concrete campaign through the real scene and its controls.
const MAIN := preload("res://oyun/app/main.tscn")
var app

func _initialize() -> void:
	call_deferred("_play")

func _press(value: String, meta := "focus_key") -> bool:
	for node in app.find_children("*", "Button", true, false):
		var button: Button = node
		if not button.disabled and button.get_meta(meta, "") == value:
			button.pressed.emit()
			return true
	printerr("Missing or disabled control: ", value, " (", meta, ")")
	return false

func _play() -> void:
	if FileAccess.file_exists("user://profiles/profiles.json"):
		printerr("Run play_campaign.gd with a fresh user-data directory.")
		quit(2)
		return
	app = MAIN.instantiate()
	root.add_child(app)
	await process_frame
	app.preferences["sfx_volume"] = 0
	var modules := {}
	for world in range(1, 8):
		for order in range(1, 51):
			var mission_id := "d%d-p%d-%03d" % [world, int((order - 1) / 10) + 1, order]
			if app.level.get("id") != mission_id:
				printerr("Wrong mission: wanted ", mission_id, " got ", app.level.get("id"))
				quit(1)
				return
			for token in app.level["layers"]["concrete"]["witness"]:
				if not _press(str(token), "command"):
					printerr(mission_id)
					quit(1)
					return
			if not _press(app._tr("ui.run")) or not app.data["completed_ids"].has(mission_id):
				printerr("Could not complete the mission through the UI: ", mission_id)
				quit(1)
				return
			modules[app.level["type"]] = true
			if order < 50 and not _press(app._tr("ui.next")):
				quit(1)
				return
			await process_frame
		print("PASS world ", world, " / 50 missions / total ", app.data["completed_ids"].size())
		if world < 7:
			var first_id := "d%d-p1-001" % (world + 1)
			var first_button: String = "01  " + app._tr("mission." + first_id)
			if not _press(app._tr("ui.next_world")) or not _press(first_button):
				printerr("The next world was not reachable from the previous mission.")
				quit(1)
				return
	var saved: Dictionary = app.store.load_profile(app.profiles.selected)
	var complete: bool = saved.get("completed_ids", []).size() == 350 and modules.size() == 16
	print("UI CAMPAIGN: ", saved.get("completed_ids", []).size(), "/350 stored, ", modules.size(), "/16 mechanics")
	quit(0 if complete else 1)
