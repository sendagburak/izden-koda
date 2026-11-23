#!/usr/bin/env sh
set -eu
GODOT_BIN="${GODOT_BIN:-godot}"
command -v "$GODOT_BIN" >/dev/null || { echo 'Godot not installed; no exports produced.' >&2; exit 1; }
[ -f export_presets.cfg ] || { echo 'Configure export_presets.cfg first.' >&2; exit 1; }
"$GODOT_BIN" --headless --editor --path . --quit
"$GODOT_BIN" --headless --path . --script res://tests/runner.gd
mkdir -p build/linux build/windows
"$GODOT_BIN" --headless --path . --export-release Linux build/linux/algoritma-oyunu.x86_64
"$GODOT_BIN" --headless --path . --export-release Windows build/windows/algoritma-oyunu.exe
