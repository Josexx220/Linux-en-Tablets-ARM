#!/bin/sh
export PATH=/system/bin:/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin
export HOME=/root

VERSION="0.2.1-alpha"

show_version() {
  echo "Open Media Center"
  echo "Version: $VERSION"
  echo "Backend: Android"
}

doctor() {
  echo "Open Media Center - Diagnostico"
  echo "-------------------------------"
  FAIL=0
  for CMD in yt-dlp busybox awk sed cut; do
    if command -v "$CMD" >/dev/null 2>&1; then
      echo "[OK] $CMD"
    else
      echo "[FALTA] $CMD"
      FAIL=1
    fi
  done

  if [ -e /system/bin/am ]; then
    echo "[OK] Backend Android"
  else
    echo "[FALTA] /system/bin/am"
    FAIL=1
  fi

  if [ -d /root/.openmediacenter ]; then
    echo "[OK] Datos de usuario"
  else
    echo "[FALTA] Datos de usuario"
    FAIL=1
  fi

  echo
  [ "$FAIL" -eq 0 ] && echo "Estado general: correcto" || echo "Estado general: hay problemas"
  return "$FAIL"
}

case "${1:-}" in
  --version|-v|version)
    show_version
    exit 0
    ;;
  doctor|--doctor)
    docto
    exit $?
    ;;
esac

exec /root/openmediacenter/openmediacenter-v0.2.0.sh
