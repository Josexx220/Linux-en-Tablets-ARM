# IPTV Center 0.1-experimento

Prototipo liviano en FLTK para la Overtech TAB-OV721. Descarga o abre una
lista M3U, permite buscar canales y envía el stream a VLC instalado en Android.

## Instalación en el Alpine de la tablet

Copiar la carpeta a `/root/IPTV-Center`, entrar al chroot y ejecutar:

```sh
cd /root/IPTV-Center
chmod +x scripts/*.sh scripts/iptv-play
./scripts/install-tablet.sh
DISPLAY=:0 iptvcenter
```

La lista de prueba ya configurada es:
`https://iptv-org.github.io/iptv/languages/spa.m3u`

Si VLC no abre un canal, consultar `/tmp/iptv-play.log`. Algunos enlaces de
listas públicas pueden estar caídos; eso no implica que el programa falle.
