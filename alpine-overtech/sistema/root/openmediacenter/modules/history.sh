#!/bin/sh

OMC_DATA_DIR=/root/.openmediacenter
OMC_HISTORY_FILE="$OMC_DATA_DIR/history.omc"
OMC_OLD_HISTORY_FILE="$OMC_DATA_DIR/history.txt"
OMC_TMP_HISTORY=/tmp/omc-history-numbered.txt

mkdir -p "$OMC_DATA_DIR"
touch "$OMC_HISTORY_FILE"

if [ -s "$OMC_OLD_HISTORY_FILE" ] && [ ! -s "$OMC_HISTORY_FILE" ]; then
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
    printf "%s|%s|%s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$TITLE" "$URL" >> "$OMC_HISTORY_FILE"
  done < "$OMC_OLD_HISTORY_FILE"
fi

history_item_menu() {
  INDEX="$1"
  LINE="$(sed -n "${INDEX}p" "$OMC_TMP_HISTORY")"
  DATE_TIME="$(printf "%s\n" "$LINE" | cut -d '|' -f1)"
  TITLE="$(printf "%s\n" "$LINE" | cut -d '|' -f2)"
  URL="$(printf "%s\n" "$LINE" | cut -d '|' -f3-)"

  while :; do
    omc_header "Elemento"
    echo "$DATE_TIME"
    echo "$TITLE"
    echo
    echo "1. Reproducir"
    echo "2. Agregar a Favoritos"
    echo "3. Borrar del historial"
    echo "0. Volver"
    echo
    printf "Elegí una opción: "
    read ACTION

    case "$ACTION" in
      1) play_youtube_url "$URL" "$TITLE"; omc_pause ;;
      2) add_favorite "$TITLE" "$URL"; omc_pause ;;
      3)
        awk -v n="$INDEX" 'NR != n' "$OMC_TMP_HISTORY" > "$OMC_TMP_HISTORY.new"
        mv "$OMC_TMP_HISTORY.new" "$OMC_TMP_HISTORY"
        cp "$OMC_TMP_HISTORY" "$OMC_HISTORY_FILE"
        echo "Elemento borrado."
        sleep 1
        return
        ;;
      0) return ;;
      *) echo "Opción inválida."; sleep 1 ;;
    esac
  done
}

history_menu() {
  while :; do
    omc_header "Historial"

    if [ ! -s "$OMC_HISTORY_FILE" ]; then
      echo "Todavía no hay elementos."
      echo
      echo "0. Volver"
      printf "Elegí una opción: "
      read OPTION
      [ "$OPTION" = "0" ] && return
      continue
    fi

    tail -20 "$OMC_HISTORY_FILE" > "$OMC_TMP_HISTORY"

    awk -F '|' '{
      split($1, d, " ");
      printf "%d. %s  %s\n", NR, d[1], $2
    }' "$OMC_TMP_HISTORY"

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
          s|S) : > "$OMC_HISTORY_FILE"; echo "Historial vaciado."; sleep 1 ;;
        esac
        ;;
      ''|*[!0-9]*) echo "Opción inválida."; sleep 1 ;;
      *)
        MAX="$(wc -l < "$OMC_TMP_HISTORY")"
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
