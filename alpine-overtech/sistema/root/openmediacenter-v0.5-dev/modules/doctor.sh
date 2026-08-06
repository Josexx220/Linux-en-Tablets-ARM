#!/bin/sh

omc_doctor() {
  echo "Open Media Center - Diagnóstico"
  echo "--------------------------------"
  FAIL=0

  for CMD in yt-dlp busybox awk sed cut; do
    if command -v "$CMD" >/dev/null 2>&1; then
      echo "[OK] $CMD"
    else
      echo "[FALTA] $CMD"
      FAIL=1
    fi
  done

  [ -e /system/bin/am ] && echo "[OK] Backend Android" || { echo "[FALTA] Backend Android"; FAIL=1; }
  [ -w /root/.openmediacenter ] && echo "[OK] Datos de usuario" || { echo "[FALTA] Datos de usuario"; FAIL=1; }

  echo
  [ "$FAIL" -eq 0 ] && echo "Estado general: correcto" || echo "Estado general: hay problemas"
  return "$FAIL"
}
