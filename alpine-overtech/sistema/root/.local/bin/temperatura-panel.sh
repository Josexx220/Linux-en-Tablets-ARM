#!/bin/sh

URL='https://api.open-meteo.com/v1/forecast?latitude=-31.5375&longitude=-68.5364&current=temperature_2m&timezone=America%2FArgentina%2FSan_Juan'
N=0

while true; do
    JSON="$(wget -qO- "$URL" 2>/dev/null)"
    TEMP="$(printf '%s' "$JSON" | sed -n 's/.*"temperature_2m":\([-0-9.]*\).*/\1/p')"

    if [ -n "$TEMP" ]; then
        REDONDEADA="$(awk -v t="$TEMP" 'BEGIN { printf "%.0f", t }')"
        TEXTO="${REDONDEADA}°"
        AYUDA="San Juan: ${TEMP} °C"
    else
        TEXTO="--°"
        AYUDA="No se pudo consultar la temperatura"
    fi

    ICONO="/tmp/temperatura-${N}.svg"

    printf '%s\n' \
        '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="36" viewBox="0 0 64 36">' \
        '<rect width="64" height="36" rx="4" fill="#245edb"/>' \
        "<text x=\"32\" y=\"24\" text-anchor=\"middle\" font-family=\"DejaVu Sans\" font-size=\"22\" font-weight=\"bold\" fill=\"white\">${TEXTO}</text>" \
        '</svg>' > "$ICONO"

    printf 'icon:%s\n' "$ICONO"
    printf 'tooltip:%s\n' "$AYUDA"
    printf 'visible:true\n'

    N=$((1 - N))
    sleep 900
done
