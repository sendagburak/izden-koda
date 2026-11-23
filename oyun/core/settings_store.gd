extends RefCounted
const DEFAULT := {"language": "tr", "layer": "concrete", "high_contrast": false, "large_text": false, "color_blind_mode": false, "reduced_motion": true, "performance": true, "music_volume": 0, "sfx_volume": 35}
func normalize(input: Dictionary) -> Dictionary:
	var out: Dictionary = DEFAULT.duplicate(true)
	for key in DEFAULT:
		if input.has(key):
			out[key] = input[key]
	if out["language"] not in ["tr", "en"]:
		out["language"] = "tr"
	if out["layer"] not in ["concrete", "blocks", "system"]:
		out["layer"] = "concrete"
	return out
