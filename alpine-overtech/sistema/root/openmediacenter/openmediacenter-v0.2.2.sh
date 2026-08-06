#!/bin/sh
export PATH=/system/bin:/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin
export HOME=/root

VERSION="0.2.2-alpha"
DATA_DIR=/root/.openmediacente
HISTORY_FILE="$DATA_DIR/history.omc"
OLD_HISTORY_FILE="$DATA_DIR/history.txt"
TMP_URL=/data/local/tmp/openmediacenter-url.txt
TMP_HISTORY=/tmp/omc-history-numbered.txt
TMP_SEARCH=/tmp/omc-search-results.txt

mkdir -p "$DATA_DIR"
touch "$HISTORY_FILE"

if [ -s "$OLD_HISTORY_FILE" ] && [ ! -s "$HISTORY_FILE" ]; then
  while IFS= read -r LINE; do
    case "$LINE" in
      *"	"*)
        TITLE="$(printf "%s\n" "$LINE" | cut -f1)"
        URL="$(printf "%s\n" "$LINE" | cut -f2)"
        ;;
      *)
        TITLE="$LINE"
        URL="$LINE"
        ;;
    esac
    printf "%s|%s|%s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$TITLE" "$URL" >> "$HISTORY_FILE"
  done < "$OLD_HISTORY_FILE"
fi

pause() {
  echo
  printf "Presioná Enter para continuar..."
  read _
}

resolve_and_open() {
  URL="$1"
  case "$URL" in
    http://*|https://*) ;;
    *) echo "Enlace inválido."; return 1 ;;
  esac

  echo
  echo "Resolviendo video..."
  yt-dlp --no-warnings --no-playlist \
    -f '18/best[ext=mp4][height<=360]/best[height<=360]' \
    -g "$URL" | head -n 1 > "$TMP_URL"

  if [ ! -s "$TMP_URL" ]; then
    echo "No se pudo obtener el enlace directo."
    return 1
  fi

  echo "Abriendo en Android..."
  busybox xargs -r /system/bin/am start -a android.intent.action.VIEW -d < "$TMP_URL"
}

save_history() {
  URL="$1"
  TITLE="$2"
  [ -z "$TITLE" ] && TITLE="$URL"
  printf "%s|%s|%s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$TITLE" "$URL" >> "$HISTORY_FILE"
}

paste_link() {
  clea
  echo "================================="
  echo " Open Media Center - Enlace"
  echo "================================="
  echo
  printf "Pegá el enlace: "
  IFS= read -r URL
  if resolve_and_open "$URL"; then
    TITLE="$(yt-dlp --no-warnings --no-playlist --print '%(title)s' "$URL" 2>/dev/null | head -n 1)"
    save_history "$URL" "$TITLE"
  fi
  pause
}

search_youtube() {
  while :; do
    clea
    echo "================================="
    echo " Open Media Center - Buscar"
    echo "================================="
    echo
    printf "Buscar en YouTube (vacío para volver): "
    IFS= read -r QUERY
    [ -z "$QUERY" ] && return

    echo
    echo "Buscando..."
    yt-dlp --flat-playlist --no-warnings --print '%(title)s	%(id)s' "ytsearch5:$QUERY" > "$TMP_SEARCH"

    if [ ! -s "$TMP_SEARCH" ]; then
      echo "No se encontraron resultados."
      pause
      continue
    fi

    clea
    echo "================================="
    echo " Resultados para: $QUERY"
    echo "================================="
    echo
    awk -F '\t' '{printf "%d. %s\n", NR, $1}' "$TMP_SEARCH"
    echo
    echo "0. Volver"
    printf "Elegí un video: "
    read OPTION

    case "$OPTION" in
      0) return ;;
      ''|*[!0-9]*) echo "Opción inválida."; sleep 1 ;;
      *)
        LINE="$(sed -n "${OPTION}p" "$TMP_SEARCH")"
        TITLE="$(printf "%s\n" "$LINE" | cut -f1)"
        VIDEO_ID="$(printf "%s\n" "$LINE" | cut -f2)"
        if [ -z "$VIDEO_ID" ]; then
          echo "No existe ese resultado."
          sleep 1
        else
          URL="https://www.youtube.com/watch?v=$VIDEO_ID"
          clea
          echo "Reproduciendo: $TITLE"
          if resolve_and_open "$URL"; then
            save_history "$URL" "$TITLE"
          fi
          pause
        fi
        ;;
    esac
  done
}

youtube_menu() {
  while :; do
    clea
    echo "================================="
    echo " Open Media Center - YouTube"
    echo "================================="
    echo
    echo "1. Pegar enlace"
    echo "2. Buscar videos"
    echo "0. Volver"
    echo
    printf "Elegí una opción: "
    read OPTION
    case "$OPTION" in
      1) paste_link ;;
      2) search_youtube ;;
      0) return ;;
      *) echo "Opción inválida."; sleep 1 ;;
    esac
  done
}

history_item_menu() {
  INDEX="$1"
  LINE="$(sed -n "${INDEX}p" "$TMP_HISTORY")"
  DATE_TIME="$(printf "%s\n" "$LINE" | cut -d '|' -f1)"
  TITLE="$(printf "%s\n" "$LINE" | cut -d '|' -f2)"
  URL="$(printf "%s\n" "$LINE" | cut -d '|' -f3-)"

  while :; do
    clea
    echo "================================="
    echo " Open Media Center - Elemento"
    echo "================================="
    echo
    echo "$DATE_TIME"
    echo "$TITLE"
    echo
    echo "1. Reproducir"
    echo "2. Borrar"
    echo "0. Volver"
    echo
    printf "Elegí una opción: "
    read ACTION
    case "$ACTION" in
      1) resolve_and_open "$URL"; pause ;;
      2)
        awk -v n="$INDEX" 'NR != n' "$TMP_HISTORY" > "$TMP_HISTORY.new"
        mv "$TMP_HISTORY.new" "$TMP_HISTORY"
        cp "$TMP_HISTORY" "$HISTORY_FILE"
        echo "Elemento borrado."
        sleep 1
        return
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
    awk -F '|' '{split($1,d," "); printf "%d. %s  %s\n", NR, d[1], $2}' "$TMP_HISTORY"

    echo
    echo "L. Limpiar historial"
    echo "0. Volver"
    echo
    printf "Elegí un número: "
    read OPTION

    case "$OPTION" in
      0) return ;;
      l|L)
        printf "¿Vaciar todo el historial? (s/N): "
        read CONFIRM
        case "$CONFIRM" in
          s|S) : > "$HISTORY_FILE"; echo "Historial vaciado."; sleep 1 ;;
        esac
        ;;
      ''|*[!0-9]*) echo "Opción inválida."; sleep 1 ;;
      *)
        MAX="$(wc -l < "$TMP_HISTORY")"
        if [ "$OPTION" -ge 1 ] 2>/dev/null && [ "$OPTION" -le "$MAX" ] 2>/dev/null; then
          history_item_menu "$OPTION"
        else
          echo "No existe ese elemento."
          sleep 1
        fi
        ;;
    esac
  done
}

show_version() {
  echo "Open Media Center"
  echo "Versión: $VERSION"
  echo "Backend: Android"
}

doctor() {
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
  [ -w "$DATA_DIR" ] && echo "[OK] Datos de usuario" || { echo "[FALTA] Datos de usuario"; FAIL=1; }
  echo
  [ "$FAIL" -eq 0 ] && echo "Estado general: correcto" || echo "Estado general: hay problemas"
  return "$FAIL"
}

case "${1:-}" in
  --version|-v|version) show_version; exit 0 ;;
  doctor|--doctor) doctor; exit $? ;;
esac

while :; do
  clea
  echo "================================="
  echo "       Open Media Center"
  echo "         v$VERSION"
  echo "================================="
  echo
  echo "1. YouTube"
  echo "2. Historial"
  echo "3. Diagnóstico"
  echo "0. Salir"
  echo
  printf "Elegí una opción: "
  read OPTION
  case "$OPTION" in
    1) youtube_menu ;;
    2) show_history ;;
    3) clear; doctor; pause ;;
    0) exit 0 ;;
    *) echo "Opción inválida."; sleep 1 ;;
  esac
done
