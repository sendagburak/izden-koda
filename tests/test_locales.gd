extends RefCounted
const Locales := preload("res://oyun/core/locale_service.gd")
const Hints := preload("res://oyun/core/hint_service.gd")
const R := preload("res://oyun/core/level_repository.gd")
func run() -> bool:
	var loc = Locales.new()
	var hs = Hints.new()
	var repo = R.new()
	for i in range(1, 6):
		var level: Dictionary = repo.load_level("d1-p1-%03d" % i)
		if not loc.available(str(level.get("locale_key", ""))): return false
		if not loc.available("result." + str(level.get("id", ""))): return false
		for n in [1,2,3]:
			if not loc.available(str(hs.get_hint(level,n).get("key", ""))): return false
	return loc.available("ui.start") and loc.text("ui.start", "en") != loc.text("ui.start", "tr")
