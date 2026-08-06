#!/bin/sh

KICK_QUALITY="${KICK_QUALITY:-360}"

play_kick_url() {
  URL="$1"

  echo
  echo "Resolviendo contenido de Kick a ${KICK_QUALITY}p..."

  DIRECT_URL="$(
    yt-dlp --no-warnings --no-playlist \
      -f "${KICK_QUALITY}p/best[height<=${KICK_QUALITY}]/best" \
      -g "$URL" 2>/tmp/omc-kick-error.log |
      head -n 1
  )"

  if [ -z "$DIRECT_URL" ]; then
    if grep -q "not currently live" /tmp/omc-kick-error.log 2>/dev/null; then
      printf "%sEl canal no está transmitiendo en este momento.%s\n" \
        "$C_ERROR" "$C_RESET"
    else
      printf "%sNo se pudo obtener el video de Kick.%s\n" \
        "$C_ERROR" "$C_RESET"
      cat /tmp/omc-kick-error.log
    fi
    return 1
  fi

  echo "Abriendo en VLC Android..."
  android_open_url "$DIRECT_URL"

  TITLE="$(
    yt-dlp --no-warnings --no-playlist \
      --print '%(title)s' "$URL" 2>/dev/null |
      head -n 1
  )"

  if command -v omc_history_add >/dev/null 2>&1; then
    omc_history_add "$URL" "$TITLE"
  fi
}

kick_ask_url() {
  HEADER="$1"
  MESSAGE="$2"

  omc_header "$HEADER"
  printf "%s" "$MESSAGE"
  IFS= read -r URL

  case "$URL" in
    https://kick.com/*|http://kick.com/*)
      play_kick_url "$URL"
      ;;
    "")
      return
      ;;
    *)
      echo "El enlace no parece pertenecer a Kick."
      ;;
  esac

  omc_pause
}

kick_menu() {
  while :; do
    omc_header "Kick"
    echo "1. Pegar enlace"
    echo "2. Abrir canal en vivo"
    echo "3. Abrir video o clip"
    echo "0. Volver"
    echo
    printf "Elegí una opción: "
    read OPTION

    case "$OPTION" in
      1)
        kick_ask_url \
          "Enlace de Kick" \
          "Pegá el enlace del canal, video o clip: "
        ;;
      2)
        kick_ask_url \
          "Canal en vivo" \
          "Pegá el enlace del canal: "
        ;;
      3)
        kick_ask_url \
          "Video de Kick" \
          "Pegá el enlace del video o clip: "
        ;;
      0)
        return
        ;;
      *)
        echo "Opción inválida."
        sleep 1
        ;;
    esac
  done
}
