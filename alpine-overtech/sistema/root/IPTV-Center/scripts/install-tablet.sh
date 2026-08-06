#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
apk add --no-cache build-base fltk-dev wget
make clean all
install -m 755 iptvcenter /usr/local/bin/iptvcenter
install -m 755 scripts/iptv-play /usr/local/bin/iptv-play
echo 'Instalado. Ejecutá: DISPLAY=:0 iptvcenter'
