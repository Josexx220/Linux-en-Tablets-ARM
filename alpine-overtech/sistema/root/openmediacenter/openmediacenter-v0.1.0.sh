#!/bin/sh
export PATH=/system/bin:/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin
export HOME=/root
DATA_DIR=/root/.openmediacente
HISTORY_FILE="$DATA_DIR/history.txt"
TMP_URL=/data/local/tmp/openmediacenter-url.txt
mkdir -p "$DATA_DIR"
touch "$HISTORY_FILE"

pause() {
  echo
  printf "Presioná Enter para continuar..."
  read _
}

open_youtube() {
  clea
  echo "Open Media Center - YouTube"
  echo
  printf "Pegá el enlace: "
  IFS= read -r URL

  case "$URL" in
    http://*|https://*) ;;
    *)
      echo "Enlace inválido."
      pause
      return
      ;;
  esac

  echo
  echo "Resolviendo video..."
  yt-dlp --no-warnings --no-playlist -f '18/best[ext=mp4][height<=360]/best[height<=360]' -g "$URL" | head -n 1 > "$TMP_URL"

  if [ ! -s "$TMP_URL" ]; then
    echo "No se pudo obtener el enlace directo."
    pause
    return
  fi

  printf "%s\n" "$URL" >> "$HISTORY_FILE"
  echo "Abriendo en Android..."
  busybox xargs -r /system/bin/am start -a android.intent.action.VIEW -d < "$TMP_URL"
  pause
}

show_history() {
  clea
  echo "Open Media Center - Historial"
  echo
  if [ -s "$HISTORY_FILE" ]; then
    nl -ba "$HISTORY_FILE" | tail -20
  else
    echo "Todavía no hay elementos."
  fi
  pause
}

while :; do
  clea
  echo "================================="
  echo "       Open Media Center"
  echo "================================="
  echo
  echo "1. Abrir enlace de YouTube"
  echo "2. Ver historial"
  echo "0. Salir"
  echo
  printf "Elegí una opción: "
  read OPTION

  case "$OPTION" in
    1) open_youtube ;;
    2) show_history ;;
    0) exit 0 ;;
    *) echo "Opción inválida."; sleep 1 ;;
  esac
done
