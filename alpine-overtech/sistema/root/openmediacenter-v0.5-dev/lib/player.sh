#!/bin/sh

# Núcleo de reproducción de Open Media Center 0.5

omc_vlc_open() {
    MEDIA_URL="$1"
    MIME_TYPE="${2:-video/*}"

    if [ -z "$MEDIA_URL" ]; then
        echo "Error: no se recibió ningún medio."
        return 1
    fi

    PATH=/system/bin:/bin:/sbin:/usr/bin:/usr/sbin \
    /system/bin/am start \
        -n org.videolan.vlc/.gui.video.VideoPlayerActivity \
        -a android.intent.action.VIEW \
        -d "$MEDIA_URL" \
        -t "$MIME_TYPE"
}

omc_play() {
    MEDIA_TYPE="$1"
    MEDIA_SOURCE="$2"

    case "$MEDIA_TYPE" in
        youtube)
            echo "Resolviendo YouTube a ${VIDEO_QUALITY:-360}p..."

            DIRECT_URL="$(resolve_youtube_url "$MEDIA_SOURCE")"

            if [ -z "$DIRECT_URL" ]; then
                echo "No se pudo obtener el enlace directo."
                return 1
            fi

            omc_vlc_open "$DIRECT_URL" "video/*"
            ;;

        iptv-list|m3u)
            omc_vlc_open "$MEDIA_SOURCE" "audio/x-mpegurl"
            ;;

        stream|m3u8|video)
            omc_vlc_open "$MEDIA_SOURCE" "video/*"
            ;;

        audio|radio)
            omc_vlc_open "$MEDIA_SOURCE" "audio/*"
            ;;

        *)
            echo "Tipo de medio no compatible: $MEDIA_TYPE"
            return 1
            ;;
    esac
}
