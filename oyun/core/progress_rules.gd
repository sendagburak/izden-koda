extends RefCounted
## Completes without decrement or punitive score; UI chooses next visible task.
func complete(data: Dictionary, level_id: String) -> Dictionary:
	var out: Dictionary = data.duplicate(true)
	var done: Array = out.get("completed_ids", [])
	if not done.has(level_id):
		done.append(level_id)
	out["completed_ids"] = done
	var rewards: Array = out.get("reward_ids", [])
	var badge: String = "beacon_" + level_id
	if not rewards.has(badge):
		rewards.append(badge)
	out["reward_ids"] = rewards
	return out

func is_unlocked(data: Dictionary, level_order: int) -> bool:
	if level_order <= 1:
		return true
	return data.get("completed_ids", []).has("d1-p1-%03d" % (level_order - 1))
