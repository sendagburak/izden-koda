param([string]$GodotExe = "godot.exe")
if (!(Test-Path "export_presets.cfg")) { throw "Configure export_presets.cfg first." }
& $GodotExe --headless --editor --path . --quit
if ($LASTEXITCODE -ne 0) { throw "Import failed" }
& $GodotExe --headless --path . --script res://tests/runner.gd
if ($LASTEXITCODE -ne 0) { throw "Tests failed" }
New-Item -Force -ItemType Directory build/windows | Out-Null
& $GodotExe --headless --path . --export-release Windows build/windows/algoritma-oyunu.exe
