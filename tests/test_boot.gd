extends RefCounted
func run() -> bool:
	return ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility" and ResourceLoader.exists("res://oyun/app/main.tscn")
