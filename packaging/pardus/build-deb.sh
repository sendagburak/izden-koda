#!/usr/bin/env sh
set -eu
BIN="${1:?Usage: packaging/pardus/build-deb.sh exported-linux-binary}"
[ -f "$BIN" ] || { echo "Missing exported Linux binary: $BIN" >&2; exit 1; }
command -v dpkg-deb >/dev/null || { echo 'dpkg-deb not installed' >&2; exit 1; }
D=$(mktemp -d)
trap 'rm -rf "$D"' EXIT
mkdir -p "$D/DEBIAN" "$D/usr/share/games/algoritma-oyunu" "$D/usr/games" "$D/usr/share/applications" "$D/usr/share/icons/hicolor/192x192/apps"
cp packaging/pardus/DEBIAN/control "$D/DEBIAN/control"
cp packaging/pardus/algoritma-oyunu.desktop "$D/usr/share/applications/algoritma-oyunu.desktop"
cp varliklar/ui/icon.png "$D/usr/share/icons/hicolor/192x192/apps/algoritma-oyunu.png"
cp "$BIN" "$D/usr/share/games/algoritma-oyunu/algoritma-oyunu"
PCK="${BIN%.*}.pck"
[ ! -f "$PCK" ] || cp "$PCK" "$D/usr/share/games/algoritma-oyunu/algoritma-oyunu.pck"
cat > "$D/usr/games/algoritma-oyunu" <<'WRAPPER'
#!/bin/sh
cd /usr/share/games/algoritma-oyunu
exec ./algoritma-oyunu "$@"
WRAPPER
chmod 755 "$D/usr/games/algoritma-oyunu" "$D/usr/share/games/algoritma-oyunu/algoritma-oyunu"
mkdir -p build/pardus
dpkg-deb --build "$D" build/pardus/algoritma-oyunu_0.5.0-preview1_amd64.deb
