#!/usr/bin/env sh
set -eu
BIN="${1:?Usage: packaging/pardus/build-deb.sh exported-linux-binary}"
PCK="${BIN%.*}.pck"
[ -s "$BIN" ] && [ -s "$PCK" ] || { echo "Missing exported Linux binary or PCK: $BIN and $PCK" >&2; exit 1; }
file -b "$BIN" | grep -Eq '^ELF 64-bit .*x86-64' || { echo "Expected an x86-64 ELF export" >&2; exit 1; }
command -v dpkg-deb >/dev/null || { echo 'dpkg-deb not installed' >&2; exit 1; }
D=$(mktemp -d)
trap 'rm -rf "$D"' EXIT
mkdir -p "$D/DEBIAN" "$D/usr/share/games/algoritma-oyunu" "$D/usr/games" "$D/usr/share/applications" "$D/usr/share/icons/hicolor/256x256/apps" "$D/usr/share/doc/algoritma-oyunu"
cp packaging/pardus/DEBIAN/control "$D/DEBIAN/control"
cp packaging/pardus/algoritma-oyunu.desktop "$D/usr/share/applications/algoritma-oyunu.desktop"
cp varliklar/ui/icon.png "$D/usr/share/icons/hicolor/256x256/apps/algoritma-oyunu.png"
cp packaging/licenses/*.txt varliklar/fonts/*-LICENSE.txt LISANSLAR.md "$D/usr/share/doc/algoritma-oyunu/"
cp "$BIN" "$D/usr/share/games/algoritma-oyunu/algoritma-oyunu"
cp "$PCK" "$D/usr/share/games/algoritma-oyunu/algoritma-oyunu.pck"
cat > "$D/usr/games/algoritma-oyunu" <<'WRAPPER'
#!/bin/sh
exec /usr/share/games/algoritma-oyunu/algoritma-oyunu "$@"
WRAPPER
chmod 755 "$D/usr/games/algoritma-oyunu" "$D/usr/share/games/algoritma-oyunu/algoritma-oyunu"
mkdir -p build/pardus
VERSION="$(sed -n 's/^Version: //p' "$D/DEBIAN/control")"
dpkg-deb --root-owner-group --build "$D" "build/pardus/algoritma-oyunu_${VERSION}_amd64.deb"
