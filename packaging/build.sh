#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-godot}"
command -v "$GODOT_BIN" >/dev/null || { echo 'ERROR: Godot engine missing, no exports created' >&2; exit 127; }
command -v dpkg-deb >/dev/null || { echo 'ERROR: dpkg-deb missing' >&2; exit 127; }
case "${BUILD_ANDROID:-0}" in
  0) android_mode='' ;;
  debug) android_mode=debug ;;
  1|release)
    : "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:?Android release keystore path required}"
    : "${GODOT_ANDROID_KEYSTORE_RELEASE_USER:?Android release key alias required}"
    : "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:?Android release keystore password required}"
    android_mode=release
    ;;
  *) echo 'BUILD_ANDROID must be 0, debug or release (1 also selects release)' >&2; exit 2 ;;
esac

godot_log="$(mktemp)"
profile_dir="$(mktemp -d)"
trap 'rm -f "$godot_log"; rm -rf "$profile_dir"' EXIT
run_godot() {
  "$GODOT_BIN" --headless --path . "$@" 2>&1 | tee "$godot_log"
  if grep -Eq '^(SCRIPT ERROR|ERROR):' "$godot_log"; then
    echo 'ERROR: Godot reported errors in the command output' >&2
    return 1
  fi
}

python3 tools/campaign_validator.py
python3 -m unittest discover -s tests -p 'test_*.py'
run_godot --editor --import
XDG_DATA_HOME="$profile_dir" run_godot --script res://tests/runner.gd
run_godot --script res://tools/validate_levels.gd
mkdir -p build/{linux,windows,android,pardus}
rm -f build/linux/algoritma-oyunu.{x86_64,pck} build/windows/algoritma-oyunu.{exe,pck}
run_godot --export-release Linux build/linux/algoritma-oyunu.x86_64
run_godot --export-release Windows build/windows/algoritma-oyunu.exe
for path in build/linux/algoritma-oyunu.{x86_64,pck} build/windows/algoritma-oyunu.{exe,pck}; do
  [[ -s "$path" ]] || { echo "ERROR: Export missing $path" >&2; exit 1; }
done
chmod +x build/linux/algoritma-oyunu.x86_64
for platform in linux windows; do
  mkdir -p "build/$platform/licenses"
  cp packaging/licenses/*.txt varliklar/fonts/*-LICENSE.txt LISANSLAR.md "build/$platform/licenses/"
done
( cd build/linux && tar -czf ../algoritma-oyunu-linux-portable.tar.gz algoritma-oyunu.x86_64 algoritma-oyunu.pck licenses )
rm -f build/algoritma-oyunu-windows-portable.zip
( cd build/windows && zip -q -r ../algoritma-oyunu-windows-portable.zip algoritma-oyunu.exe algoritma-oyunu.pck licenses )
sh packaging/pardus/build-deb.sh build/linux/algoritma-oyunu.x86_64
if [[ -n "$android_mode" ]]; then
  android_suffix=''
  [[ "$android_mode" != debug ]] || android_suffix=-debug
  for bits in 64 32; do
    output="build/android/algoritma-oyunu-arm${bits}${android_suffix}.apk"
    rm -f "$output"
    run_godot "--export-$android_mode" "Android ARM$bits" "$output"
    [[ -s "$output" ]] || { echo "ERROR: Export missing $output" >&2; exit 1; }
  done
fi
