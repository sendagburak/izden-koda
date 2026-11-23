extends RefCounted
func get_hint(level: Dictionary, tier: int) -> Dictionary:
	var hints: Array = level.get("hints", [])
	if tier < 1 or tier > hints.size():
		return {}
	return {"key": str(hints[tier - 1]), "tier": tier, "penalty": 0}
