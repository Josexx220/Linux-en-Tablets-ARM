#!/bin/sh

OMC_DATA_DIR=/root/.openmediacenter
OMC_HISTORY_FILE="$OMC_DATA_DIR/history.omc"
OMC_TMP_SEARCH=/tmp/omc-search-results.txt

mkdir -p "$OMC_DATA_DIR"
touch "$OMC_HISTORY_FILE"

save_history() {
  URL="$1"
  TITLE="$2"
  [ -z "$TITLE" ] && TITLE="$URL"
  printf "%s|%s|%s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$TITLE" "$URL" >> "$OMC_HISTORY_FILE"
}

play_youtube_url() {
  URL="$1"
  TITLE="$2"

  echo
  echo "Resolviendo video a ${VIDEO_QUALITY}p..."
  DIRECT_URL="$(resolve_youtube_url "$URL")"

  if [ -z "$DIRECT_URL" ]; then
    printf "%sNo se pudo obtener el enlace directo.%s\n" "$C_ERROR" "$C_RESET"
    return 1
  fi

  echo "Abriendo en Android..."
  android_open_url "$DIRECT_URL"

  if [ -n "$TITLE" ]; then
    save_history "$URL" "$TITLE"
  else
    FOUND_TITLE="$(yt-dlp --no-warnings --no-playlist --print '%(title)s' "$URL" 2>/dev/null | head -n 1)"
    save_history "$URL" "$FOUND_TITLE"
  fi
}

paste_youtube_link() {
  omc_header "Enlace"
  printf "Pegá el enlace: "
  IFS= read -r URL

  case "$URL" in
    http://*|https://*) play_youtube_url "$URL" "" ;;
    *) echo "Enlace inválido." ;;
  esac

  omc_pause
}

search_youtube() {
  while :; do
    omc_header "Buscar"
    printf "Buscar en YouTube (vacío para volver): "
    IFS= read -r QUERY
    [ -z "$QUERY" ] && return

    echo
    echo "Buscando..."
    yt-dlp --flat-playlist --no-warnings \
      --print '%(title)s	%(id)s' \
      "ytsearch${SEARCH_RESULTS}:$QUERY" > "$OMC_TMP_SEARCH"

    if [ ! -s "$OMC_TMP_SEARCH" ]; then
      echo "No se encontraron resultados."
      omc_pause
      continue
    fi

    omc_header "Resultados"
    awk -F '\t' '{printf "%d. %s\n", NR, $1}' "$OMC_TMP_SEARCH"
    echo
    echo "0. Volver"
    echo
    printf "Elegí un video: "
    read OPTION

    case "$OPTION" in
      0) return ;;
      ''|*[!0-9]*) echo "Opción inválida."; sleep 1 ;;
      *)
        LINE="$(sed -n "${OPTION}p" "$OMC_TMP_SEARCH")"
        TITLE="$(printf "%s\n" "$LINE" | cut -f1)"
        VIDEO_ID="$(printf "%s\n" "$LINE" | cut -f2)"

        if [ -z "$VIDEO_ID" ]; then
          echo "No existe ese resultado."
          sleep 1
        else
          play_youtube_url "https://www.youtube.com/watch?v=$VIDEO_ID" "$TITLE"
          omc_pause
        fi
        ;;
    esac
  done
}

youtube_menu() {
  while :; do
    omc_header "YouTube"
    echo "1. Pegar enlace"
    echo "2. Buscar videos"
    echo "0. Volver"
    echo
    printf "Elegí una opción: "
    read OPTION

    case "$OPTION" in
      1) paste_youtube_link ;;
      2) search_youtube ;;
      0) return ;;
      *) echo "Opción inválida."; sleep 1 ;;
    esac
  done
}
