#!/bin/sh

RADIOS_FILE="/usr/local/share/omc/radios.txt"

radios_menu() {
    while :; do
        clear
        echo "================================="
        echo " Open Media Center - Radios"
        echo "================================="
        echo

        NUM=1
        while IFS='|' read -r NOMBRE URL
        do
            [ -z "$NOMBRE" ] && continue
            echo "$NUM. $NOMBRE"
            NUM=$((NUM + 1))
        done < "$RADIOS_FILE"

        echo
        echo "0. Volver"
        echo
        printf "Elegí una opción: "
        read OP

        [ "$OP" = "0" ] && return

        case "$OP" in
            *[!0-9]*|"")
                echo "Opción inválida."
                sleep 1
                continue
                ;;
        esac

        LINEA="$(busybox sed -n "${OP}p" "$RADIOS_FILE")"
        NOMBRE="${LINEA%%|*}"
        URL="${LINEA#*|}"

        if [ -z "$LINEA" ] || [ "$LINEA" = "$URL" ]; then
            echo "Opción inválida."
            sleep 2
            continue
        fi

        if [ -z "$URL" ]; then
            echo
            echo "La emisora todavía no tiene una dirección configurada."
            sleep 2
            continue
        fi

        clear
        echo "Abriendo en AIMP: $NOMBRE"
        echo

        android_open_audio "$URL"

        sleep 2
    done
}
