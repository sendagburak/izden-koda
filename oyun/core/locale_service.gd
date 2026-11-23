extends RefCounted
var translations: Dictionary = {}
var language: String = "tr"

func _init() -> void:
	for lang in ["tr", "en"]:
		translations[lang] = {}
		var file = FileAccess.open("res://veri/locale/" + lang + ".csv", FileAccess.READ)
		if file == null:
			continue
		file.get_csv_line()
		while not file.eof_reached():
			var entry = file.get_csv_line()
			if entry.size() >= 2 and not entry[0].is_empty():
				translations[lang][entry[0]] = entry[1]

func text(key: String, lang: String = "") -> String:
	var target = lang if lang in ["tr", "en"] else language
	if translations.get(target, {}).has(key):
		return str(translations[target][key])
	if translations.get("tr", {}).has(key):
		return str(translations["tr"][key])
	return "…"

func available(key: String) -> bool:
	return translations.get("tr", {}).has(key) and translations.get("en", {}).has(key)
