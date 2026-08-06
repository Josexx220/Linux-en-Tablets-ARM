#!/bin/sh

OMC_CONFIG_DIR=/root/openmediacenter/config
OMC_CONFIG_FILE="$OMC_CONFIG_DIR/settings.conf"

mkdir -p "$OMC_CONFIG_DIR"

if [ ! -f "$OMC_CONFIG_FILE" ]; then
cat > "$OMC_CONFIG_FILE" <<'EOF'
VIDEO_QUALITY=360
USE_COLORS=1
SEARCH_RESULTS=5
EOF
fi

. "$OMC_CONFIG_FILE"

save_setting() {
  KEY="$1"
  VALUE="$2"

  if grep -q "^${KEY}=" "$OMC_CONFIG_FILE"; then
    sed -i "s#^${KEY}=.*#${KEY}=${VALUE}#" "$OMC_CONFIG_FILE"
  else
    printf "%s=%s\n" "$KEY" "$VALUE" >> "$OMC_CONFIG_FILE"
  fi
}

config_menu() {
  while :; do
    omc_header "Configuración"
    echo "Calidad actual: ${VIDEO_QUALITY}p"
    echo "Colores: $([ "$USE_COLORS" = "1" ] && echo Activados || echo Desactivados)"
    echo "Resultados de búsqueda: $SEARCH_RESULTS"
    echo
    echo "1. Calidad de video"
    echo "2. Activar/desactivar colores"
    echo "3. Cantidad de resultados"
    echo "0. Volver"
    echo
    printf "Elegí una opción: "
    read OPTION

    case "$OPTION" in
      1)
        omc_header "Calidad de video"
        echo "1. 144p"
        echo "2. 240p"
        echo "3. 360p"
        echo "0. Volver"
        echo
        printf "Elegí una opción: "
        read QUALITY_OPTION
        case "$QUALITY_OPTION" in
          1) VIDEO_QUALITY=144; save_setting VIDEO_QUALITY 144 ;;
          2) VIDEO_QUALITY=240; save_setting VIDEO_QUALITY 240 ;;
          3) VIDEO_QUALITY=360; save_setting VIDEO_QUALITY 360 ;;
          0) ;;
          *) echo "Opción inválida."; sleep 1 ;;
        esac
        ;;
      2)
        if [ "$USE_COLORS" = "1" ]; then
          USE_COLORS=0
        else
          USE_COLORS=1
        fi
        save_setting USE_COLORS "$USE_COLORS"
        ;;
      3)
        omc_header "Resultados de búsqueda"
        echo "1. 5 resultados"
        echo "2. 10 resultados"
        echo "0. Volver"
        echo
        printf "Elegí una opción: "
        read RESULTS_OPTION
        case "$RESULTS_OPTION" in
          1) SEARCH_RESULTS=5; save_setting SEARCH_RESULTS 5 ;;
          2) SEARCH_RESULTS=10; save_setting SEARCH_RESULTS 10 ;;
          0) ;;
          *) echo "Opción inválida."; sleep 1 ;;
        esac
        ;;
      0) return ;;
      *) echo "Opción inválida."; sleep 1 ;;
    esac
  done
}
