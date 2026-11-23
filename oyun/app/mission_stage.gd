extends Control
## Presents puzzle state. Walkability, goals and playback states come from the runner.

const DIRECTIONS := {"U": Vector2.UP, "R": Vector2.RIGHT, "D": Vector2.DOWN, "L": Vector2.LEFT}
const GROUND := [Color("#47734e"), Color("#694b52"), Color("#42726b"), Color("#69504b"),
	Color("#80604a"), Color("#47667c"), Color("#365679")]
const NIGHT := Color("#10202d")
const GOLD := Color("#ffcb69")
const SPARK := Color("#fff0b0")

var backdrop: Texture2D
var art: Dictionary
var route: Dictionary
var state: Dictionary
var district := 1
var order := 1
var reduced := false
var low_detail := false
var robot := false
var high_contrast := false
var facing_left := false
var completed := false
var actor := Vector2.ZERO
var clock := 0.0
var effect := ""
var effect_amount := 0.0
var effect_at := Vector2.ZERO
var hop := 0.0

func setup(image: Texture2D, sprites: Dictionary, map: Dictionary, snapshot: Dictionary,
		world: int, mission: int, scanned_robot: bool, preferences: Dictionary, solved: bool) -> void:
	backdrop = image
	art = sprites
	route = map
	state = snapshot
	district = clampi(world, 1, GROUND.size())
	order = mission
	robot = scanned_robot
	completed = solved
	reduced = bool(preferences.get("reduced_motion", false))
	low_detail = bool(preferences.get("performance", true))
	high_contrast = bool(preferences.get("high_contrast", false))
	actor = _point(state.get("position", route.get("start", [0, 0])))
	custom_minimum_size.y = 234 if not route.is_empty() else 107
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	resized.connect(queue_redraw)
	set_process(not reduced and DisplayServer.get_name() != "headless")
	queue_redraw()

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _point(coords: Array) -> Vector2:
	return Vector2(float(coords[0]), float(coords[1]))

func _draw() -> void:
	if backdrop == null or size.x <= 1.0 or size.y <= 1.0:
		return
	var frame := Rect2(Vector2.ZERO, size)
	_draw_backdrop(frame)
	if route.is_empty():
		_draw_ambient(frame)
		_draw_effect(size * Vector2(0.78, 0.64), 28.0)
		return

	var dimensions := _point(route["size"])
	var cell := floorf(minf((size.x - 26.0) / dimensions.x, (size.y - 22.0) / dimensions.y))
	if cell < 1.0:
		return
	var grid_size := dimensions * cell
	var origin := ((size - grid_size) * Vector2(0.5, 0.55)).floor()
	var field := Rect2(origin, grid_size)
	_draw_ambient(frame)
	if origin.x > 38.0 and district == 1:
		_sprite("tree", Vector2(origin.x * 0.46, size.y * 0.72), minf(origin.x * 0.90, 73.0), 0.0)
		_sprite("flowers", Vector2(size.x - origin.x * 0.38, size.y * 0.82), minf(origin.x * 0.77, 45.0), 0.0)
	elif origin.x > 38.0 and robot:
		_sprite("relay", Vector2(size.x - origin.x * 0.46, size.y * 0.70), minf(origin.x * 0.87, 62.0), 0.0)
	draw_rect(Rect2(field.position + Vector2(-5, -1), field.size + Vector2(10, 10)), Color(0.03, 0.07, 0.10, 0.45))
	draw_rect(field.grow(4.0), Color("#493d37"), false, 5.0)
	draw_rect(field.grow(3.0), Color("#cea265"), false, 2.0)
	_draw_terrain(origin, dimensions, cell)
	_draw_pieces(origin, cell)
	_draw_effect(_cell_center(origin, effect_at, cell), cell)

func _draw_backdrop(frame: Rect2) -> void:
	var pixels := backdrop.get_size()
	if pixels.x < 1.0 or pixels.y < 1.0:
		return
	var zoom := maxf(frame.size.x / pixels.x, frame.size.y / pixels.y)
	var window := frame.size / zoom
	var focus := Vector2(0.26 + float((order * 7) % 13) * 0.035, 0.32 + float((order - 1) / 10) * 0.06)
	var crop := Rect2((pixels - window) * focus, window)
	draw_texture_rect_region(backdrop, frame, crop)
	draw_rect(frame, Color(0.02, 0.07, 0.10, 0.28 if high_contrast else 0.07))
	draw_rect(frame, Color("#a47b52"), false, 1.0)

func _draw_ambient(frame: Rect2) -> void:
	var count := 9 if low_detail else 18
	for index in range(count):
		var x := fposmod(float(index * 197 + order * 31), maxf(1.0, frame.size.x))
		var y := fposmod(float(index * 113 + order * 19), maxf(1.0, frame.size.y))
		var drift := 0.0 if reduced else sin(clock * 0.95 + index) * 3.0
		var alpha := 0.36 if reduced else 0.36 + 0.27 * sin(clock * 1.85 + index)
		draw_rect(Rect2(Vector2(x + drift, y - drift).floor(), Vector2(2, 2)), Color(GOLD, alpha))

func _cell_center(origin: Vector2, coords: Vector2, cell: float) -> Vector2:
	return origin + (coords + Vector2.ONE * 0.5) * cell

func _draw_terrain(origin: Vector2, dimensions: Vector2, cell: float) -> void:
	var soil: Color = GROUND[district - 1]
	if high_contrast:
		soil = soil.darkened(0.28)
	for y in range(int(dimensions.y)):
		for x in range(int(dimensions.x)):
			var tile := Rect2(origin + Vector2(x, y) * cell, Vector2.ONE * cell)
			var grain := (x * 13 + y * 7 + order * 5) % 11
			draw_rect(tile, Color(soil.lightened(float(grain) * 0.017), 0.97 if high_contrast else 0.80))
			draw_rect(tile.grow(-0.5), Color(0.06, 0.14, 0.17, 0.58 if high_contrast else 0.33), false, 1.0)
			var pebble := tile.position + Vector2(4 + grain, 4 + ((x + y + grain) % 8))
			draw_rect(Rect2(pebble, Vector2(3, 2)), soil.lightened(0.21))
			draw_rect(Rect2(pebble + Vector2(5, 3), Vector2(2, 2)), soil.darkened(0.18))
	for coords in state.get("trail", []):
		var center := _cell_center(origin, _point(coords), cell).floor()
		draw_rect(Rect2(center - Vector2(4, 2), Vector2(3, 4)), Color(GOLD, 0.67))
		draw_rect(Rect2(center + Vector2(2, -4), Vector2(3, 4)), Color(GOLD, 0.46))

func _draw_pieces(origin: Vector2, cell: float) -> void:
	var start := _cell_center(origin, _point(route["start"]), cell)
	var target := _cell_center(origin, _point(route["goal"]), cell)
	var pulse := 0.0 if reduced else sin(clock * 2.8) * 0.045
	draw_circle(start, cell * 0.24, Color("#8adccc"), false, 2.0)
	draw_circle(target, cell * (0.43 + pulse), Color(0.98, 0.67, 0.20, 0.25))
	draw_circle(target, cell * (0.32 + pulse), GOLD, false, 1.5)
	_sprite("open" if completed else "goal", target, cell * (0.82 + pulse), 0.0)
	for rock in route.get("rocks", []):
		var center := _cell_center(origin, _point(rock), cell)
		draw_rect(Rect2(center - Vector2(cell * 0.36, cell * 0.30), Vector2(cell * 0.72, cell * 0.63)),
			Color(0.07, 0.12, 0.15, 0.65))
		_sprite("rock", center, cell * 0.92, 0.0)
	var actor_center := _cell_center(origin, actor, cell)
	draw_rect(Rect2(actor_center + Vector2(-cell * 0.26, cell * 0.24), Vector2(cell * 0.52, cell * 0.12)),
		Color(0.05, 0.09, 0.12, 0.50))
	_sprite("robot" if robot else "explorer", actor_center, cell * 1.10, hop, facing_left)

func _sprite(key: String, center: Vector2, extent: float, lift: float, flip := false) -> void:
	var icon: Texture2D = art.get(key)
	if icon == null:
		return
	var pixels := icon.get_size()
	var draw_size := (pixels * extent / maxf(pixels.x, pixels.y)).round()
	draw_set_transform((center - Vector2(0, lift)).floor(), 0.0, Vector2(-1, 1) if flip else Vector2.ONE)
	draw_texture_rect(icon, Rect2(draw_size * -0.5, draw_size), false)
	draw_set_transform(Vector2.ZERO)

func _draw_effect(center: Vector2, cell: float) -> void:
	if effect_amount <= 0.0:
		return
	var color := Color("#ff947d") if effect == "blocked" else (Color("#8adccc") if effect == "scan" else SPARK)
	var age := 1.0 - effect_amount
	if reduced:
		draw_circle(center, cell * 0.34, Color(color, effect_amount * 0.75), false, 2.0)
		return
	var reach := cell * (0.56 if effect == "success" else 0.29)
	var count := 15 if effect == "success" else 6
	draw_circle(center, cell * 0.14 + reach * age, Color(color, effect_amount * 0.8), false, 2.0)
	for index in range(count):
		var angle := float(index) * TAU / float(count)
		var point := center + Vector2.from_angle(angle) * (cell * 0.12 + reach * age)
		var pixel := 4.0 if index % 3 == 0 else 2.0
		draw_rect(Rect2(point.floor(), Vector2.ONE * pixel), Color(color, effect_amount))

func reset_trace(snapshot: Dictionary) -> void:
	state = snapshot
	completed = false
	actor = _point(state.get("position", route.get("start", [0, 0])))
	effect_amount = 0.0
	queue_redraw()

func play_step(snapshot: Dictionary, events: Array, symbol: String, duration: float) -> void:
	var from := actor
	var next := _point(snapshot.get("position", route.get("start", [0, 0])))
	var direction: Vector2 = DIRECTIONS.get(symbol, Vector2.ZERO)
	if direction.x != 0.0:
		facing_left = direction.x < 0.0
	effect = "blocked" if events.has("blocked") or events.has("limit") else ("scan" if events.has("scanned") else "step")
	effect_at = from + direction * 0.26 if effect == "blocked" else from
	effect_amount = 1.0
	var tween := create_tween()
	tween.tween_method(func(fraction: float):
		if effect == "blocked":
			actor = from + direction * sin(fraction * PI) * (0.23 if not reduced else 0.0)
		elif not reduced:
			actor = from.lerp(next, fraction)
			hop = sin(fraction * PI) * 3.0 if from != next else 0.0
		else:
			actor = next
		effect_amount = 1.0 - fraction * 0.62
		queue_redraw()
	, 0.0, 1.0, duration)
	await tween.finished
	hop = 0.0
	actor = next
	state = snapshot
	queue_redraw()

func play_outcome(solved: bool) -> void:
	completed = solved
	effect_at = actor
	if solved:
		effect = "success"
	var tween := create_tween()
	tween.tween_method(func(fraction: float):
		effect_amount = (1.0 - fraction) * (1.0 if solved else 0.42)
		hop = sin(fraction * PI) * 8.0 if solved and not reduced else 0.0
		queue_redraw()
	, 0.0, 1.0, 0.44 if solved and not reduced else 0.21)
	await tween.finished
