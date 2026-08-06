#!/bin/sh

OMC_DATA_DIR="${OMC_DATA_DIR:-/root/.openmediacenter}"
OMC_HISTORY_FILE="$OMC_DATA_DIR/history.omc"
OMC_FAVORITES_FILE="$OMC_DATA_DIR/favorites.omc"

mkdir -p "$OMC_DATA_DIR"
touch "$OMC_HISTORY_FILE" "$OMC_FAVORITES_FILE"

omc_history_add() {
    URL="$1"
    TITLE="$2"

    [ -z "$URL" ] && return 1
    [ -z "$TITLE" ] && TITLE="$URL"

    printf '%s|%s|%s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$TITLE" \
        "$URL" >> "$OMC_HISTORY_FILE"
}

omc_favorite_add() {
    TITLE="$1"
    URL="$2"

    [ -z "$URL" ] && return 1
    [ -z "$TITLE" ] && TITLE="$URL"

    if busybox grep -Fq "|$URL" "$OMC_FAVORITES_FILE"; then
        echo "Ese elemento ya está en Favoritos."
        return 0
    fi

    printf '%s|%s|%s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$TITLE" \
        "$URL" >> "$OMC_FAVORITES_FILE"

    echo "Agregado a Favoritos."
}

omc_history_clean_expired() {
    TMP_FILE="/tmp/omc-history-clean.$$"

    busybox grep -v 'googlevideo.com' \
        "$OMC_HISTORY_FILE" > "$TMP_FILE" 2>/dev/null

    cat "$TMP_FILE" > "$OMC_HISTORY_FILE"
    rm -f "$TMP_FILE"
}
