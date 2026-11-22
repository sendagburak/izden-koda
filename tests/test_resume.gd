extends RefCounted
## Runtime assertions for selected world and first unfinished mission.
const App = preload("res://oyun/app/main.gd")
func run() -> bool:
    var app = App.new()
    app.data = {"completed_ids": []}
    if app._resume_target() != {"world": 1, "order": 1}: return false
    app.data = {"completed_ids": ["d1-p1-001", "d1-p4-040", "d2-p1-001"]}
    if app._resume_target() != {"world": 2, "order": 2}: return false
    app.data = {"completed_ids": ["d1-p1-001", "d1-p1-002"]}
    if app._resume_target() != {"world": 1, "order": 3}: return false
    app.free()
    return true
