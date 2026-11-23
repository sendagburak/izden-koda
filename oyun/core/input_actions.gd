extends RefCounted
const KEY_COMMANDS := {KEY_UP: "U", KEY_DOWN: "D", KEY_LEFT: "L", KEY_RIGHT: "R", KEY_W: "U", KEY_S: "D", KEY_A: "L", KEY_D: "R"}
func from_key(keycode: int) -> Dictionary:
	if KEY_COMMANDS.has(keycode):
		return {"command": KEY_COMMANDS[keycode]}
	return {}
func from_button(command: String) -> Dictionary:
	return {"command": command}
