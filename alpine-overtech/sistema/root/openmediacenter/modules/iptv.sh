#!/bin/sh

PLAYLIST_DIR=/root/.openmediacenter/playlists
PLAYLIST_AR="$PLAYLIST_DIR/ar.m3u"

ANDROID_DIR=/data/media/0/OpenMediaCenter/playlists
ANDROID_PLAYLIST="$ANDROID_DIR/argentina.m3u"
ANDROID_URI="file:///storage/emulated/0/OpenMediaCenter/playlists/argentina.m3u"

mkdir -p "$PLAYLIST_DIR"
mkdir -p "$ANDROID_DIR"

download_argentina() {
    omc_header "IPTV"

    echo "Descargando lista pública de Argentina..."
    echo

    if wget -O "$PLAYLIST_AR" \
        "https://iptv-org.github.io/iptv/countries/ar.m3u"
    then
        cp "$PLAYLIST_AR" "$ANDROID_PLAYLIST"
        chmod 666 "$ANDROID_PLAYLIST"

        echo
        echo "Lista descargada correctamente."
        echo "Guardada para VLC."
    else
        echo
        echo "Error al descargar la lista."
        rm -f "$PLAYLIST_AR"
    fi

    omc_pause
}

open_argentina() {
    if [ ! -s "$ANDROID_PLAYLIST" ]; then
        echo
        echo "La lista no existe o está vacía."
        echo "Primero elegí la opción 1."
        omc_pause
        return
    fi

    /system/bin/am start \
        -a android.intent.action.VIEW \
        -d "$ANDROID_URI" \
        -t "audio/x-mpegurl"
}

iptv_menu() {
    while true
    do
        omc_header "IPTV"

        echo "1. Actualizar lista Argentina"
        echo "2. Abrir lista Argentina en VLC"
        echo
        echo "0. Volver"
        echo

        printf "Elegí una opción: "
        read OPCION

        case "$OPCION" in
            1)
                download_argentina
                ;;
            2)
                open_argentina
                ;;
            0)
                return
                ;;
            *)
                echo
                echo "Opción inválida."
                omc_pause
                ;;
        esac
    done
}
