#!/usr/bin/env bash
# Offline game build pipeline. Fails closed on absent tools; never writes fake installers.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-godot}"
command -v "$GODOT_BIN" >/dev/null || { echo 'ERROR: Godot engine missing, no exports created' >&2; exit 127; }
command -v dpkg-deb >/dev/null || { echo 'ERROR: dpkg-deb missing' >&2; exit 127; }
python3 tools/campaign_validator.py
python3 -m unittest discover -s tests -p 'test_*.py'
"$GODOT_BIN" --headless --editor --path . --quit
"$GODOT_BIN" --headless --path . --script res://tests/runner.gd
"$GODOT_BIN" --headless --path . --script res://tools/validate_levels.gd
mkdir -p build/{linux,windows,android,pardus}
"$GODOT_BIN" --headless --path . --export-release Linux build/linux/algoritma-oyunu.x86_64
"$GODOT_BIN" --headless --path . --export-release Windows build/windows/algoritma-oyunu.exe
[ -s build/linux/algoritma-oyunu.x86_64 ] || exit 1
[ -s build/windows/algoritma-oyunu.exe ] || exit 1
chmod +x build/linux/algoritma-oyunu.x86_64
( cd build/linux && tar -czf ../algoritma-oyunu-linux-portable.tar.gz . )
( cd build/windows && zip -q -r ../algoritma-oyunu-windows-portable.zip . )
sh packaging/pardus/build-deb.sh build/linux/algoritma-oyunu.x86_64
if [[ "${BUILD_ANDROID:-0}" == 1 ]]; then
  [[ -n "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" && -n "${GODOT_ANDROID_KEYSTORE_RELEASE_USER:-}" && -n "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:-}" ]] || { echo 'Android release signing env missing' >&2; exit 1; }
  "$GODOT_BIN" --headless --path . --export-release 'Android ARM64' build/android/algoritma-oyunu-arm64.apk
  "$GODOT_BIN" --headless --path . --export-release 'Android ARM32' build/android/algoritma-oyunu-arm32.apk
  test -s build/android/algoritma-oyunu-arm64.apk
  test -s build/android/algoritma-oyunu-arm32.apk
  # In release QA: inspect AndroidManifest to ensure android.permission.INTERNET is absent.
fi
echo 'Exports created; DEVICE TESTING STILL REQUIRED.'
