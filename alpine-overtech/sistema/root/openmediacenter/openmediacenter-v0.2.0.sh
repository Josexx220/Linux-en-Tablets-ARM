#!/bin/sh
export PATH=/system/bin:/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin
export HOME=/root

VERSION="0.2.0-alpha"
DATA_DIR=/root/.openmediacente
HISTORY_FILE="$DATA_DIR/history.txt"
TMP_URL=/data/local/tmp/openmediacenter-url.txt
TMP_HISTORY=/tmp/omc-history-numbered.txt
TMP_SEARCH=/tmp/omc-search-results.txt

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

save_history() {
  URL="$1"
  TITLE="$2"

  if [ -n "$TITLE" ]; then
    printf "%s\t%s\n" "$TITLE" "$URL" >> "$HISTORY_FILE"
  else
    printf "%s\n" "$URL" >> "$HISTORY_FILE"
  fi
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
    yt-dlp --flat-playlist --no-warnings \
      --print '%(title)s	%(id)s' \
      "ytsearch5:$QUERY" > "$TMP_SEARCH"

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
    echo
    printf "Elegí un video: "
    read OPTION

    case "$OPTION" in
      0) return ;;
      ''|*[!0-9]*)
        echo "Opción inválida."
        sleep 1
        ;;
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
          echo "Reproduciendo:"
          echo "$TITLE"
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

    awk -F '\t' '{
      if (NF >= 2) printf "%d. %s\n", NR, $1;
      else printf "%d. %s\n", NR, $1
    }' "$TMP_HISTORY"

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
        LINE="$(sed -n "${OPTION}p" "$TMP_HISTORY")"
        TITLE="$(printf "%s\n" "$LINE" | cut -f1)"
        URL="$(printf "%s\n" "$LINE" | cut -f2)"

        if [ -z "$URL" ]; then
          URL="$TITLE"
          TITLE=""
        fi

        if [ -z "$URL" ]; then
          echo "No existe ese elemento."
          sleep 1
        else
          clea
          [ -n "$TITLE" ] && echo "$TITLE"
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
  echo "         v$VERSION"
  echo "================================="
  echo
  echo "1. YouTube"
  echo "2. Historial"
  echo "0. Salir"
  echo
  printf "Elegí una opción: "
  read OPTION

  case "$OPTION" in
    1) youtube_menu ;;
    2) show_history ;;
    0) exit 0 ;;
    *) echo "Opción inválida."; sleep 1 ;;
  esac
done
