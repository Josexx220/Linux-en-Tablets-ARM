#!/bin/sh
export PATH=/system/bin:/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin
export HOME=/root

DATA_DIR=/root/.openmediacente
HISTORY_FILE="$DATA_DIR/history.txt"
TMP_URL=/data/local/tmp/openmediacenter-url.txt
TMP_HISTORY=/tmp/omc-history-numbered.txt

mkdir -p "$DATA_DIR"
touch "$HISTORY_FILE"

pause() {
  echo
  printf "Presioná Enter para continuar..."
  read _
}

resolve_and_open() {
  URL="$1"

  case "$URL" in
    http://*|https://*) ;;
    *)
      echo "Enlace inválido."
      pause
      return 1
      ;;
  esac

  echo
  echo "Resolviendo video..."
  yt-dlp --no-warnings --no-playlist \
    -f '18/best[ext=mp4][height<=360]/best[height<=360]' \
    -g "$URL" | head -n 1 > "$TMP_URL"

  if [ ! -s "$TMP_URL" ]; then
    echo "No se pudo obtener el enlace directo."
    pause
    return 1
  fi

  echo "Abriendo en Android..."
  busybox xargs -r /system/bin/am start \
    -a android.intent.action.VIEW \
    -d < "$TMP_URL"
}

open_youtube() {
  while :; do
    clea
    echo "================================="
    echo " Open Media Center - YouTube"
    echo "================================="
    echo
    echo "1. Pegar enlace"
    echo "0. Volver"
    echo
    printf "Elegí una opción: "
    read OPTION

    case "$OPTION" in
      1)
        echo
        printf "Pegá el enlace: "
        IFS= read -r URL
        if resolve_and_open "$URL"; then
          printf "%s\n" "$URL" >> "$HISTORY_FILE"
        fi
        pause
        ;;
      0) return ;;
      *) echo "Opción inválida."; sleep 1 ;;
    esac
  done
}

show_history() {
  while :; do
    clea
    echo "================================="
    echo " Open Media Center - Historial"
    echo "================================="
    echo

    if [ ! -s "$HISTORY_FILE" ]; then
      echo "Todavía no hay elementos."
      echo
      echo "0. Volver"
      printf "Elegí una opción: "
      read OPTION
      [ "$OPTION" = "0" ] && return
      continue
    fi

    tail -20 "$HISTORY_FILE" > "$TMP_HISTORY"
    nl -ba "$TMP_HISTORY"

    echo
    echo "0. Volver"
    echo
    printf "Elegí un número para reproducir: "
    read OPTION

    case "$OPTION" in
      0) return ;;
      ''|*[!0-9]*)
        echo "Opción inválida."
        sleep 1
        ;;
      *)
        URL="$(sed -n "${OPTION}p" "$TMP_HISTORY")"
        if [ -z "$URL" ]; then
          echo "No existe ese elemento."
          sleep 1
        else
          clea
          echo "Reproduciendo:"
          echo "$URL"
          resolve_and_open "$URL"
          pause
        fi
        ;;
    esac
  done
}

while :; do
  clea
  echo "================================="
  echo "       Open Media Center"
  echo "         v0.1.1-alpha"
  echo "================================="
  echo
  echo "1. YouTube"
  echo "2. Historial"
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
