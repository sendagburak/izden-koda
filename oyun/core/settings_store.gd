extends RefCounted
const DEFAULT := {"language": "tr", "layer": "concrete", "high_contrast": false, "text_size": 0, "readable_font": false, "color_blind_mode": false, "reduced_motion": false, "performance": true, "music_volume": 0, "sfx_volume": 35}
func normalize(input: Dictionary) -> Dictionary:
	var out: Dictionary = DEFAULT.duplicate(true)
	for key in DEFAULT:
		if input.has(key):
			out[key] = input[key]
	if out["language"] not in ["tr", "en"]:
		out["language"] = "tr"
	if out["layer"] not in ["concrete", "blocks", "system"]:
		out["layer"] = "concrete"
	out["text_size"] = clampi(int(input.get("text_size", 1 if input.get("large_text", false) else 0)), 0, 2)
	return out
