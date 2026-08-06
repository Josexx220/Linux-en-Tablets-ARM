# Alpine en Overtech TAB-OV721

Alpine Linux 3.20 ARMv7 instalado en un chroot dentro de Android 4.4.2. Android conserva el kernel 3.4.39 y el control del hardware; Alpine proporciona IceWM, herramientas Linux y aplicaciones propias.

## Hardware observado

| Elemento | Valor |
|---|---|
| Modelo | Overtech TAB-OV721 |
| Device | `astar-m739` |
| SoC | Allwinner `sun8i`, Cortex-A7 |
| ABI | `armeabi-v7a` |
| RAM | 507688 KiB |
| Swap | 384 MiB |
| Android | 4.4.2 |
| Alpine | 3.20.3, 558 paquetes inventariados |
| Rootfs | `/data/local/linux/rootfs-jwm` |

## Escritorio

- XSDL como servidor X11 en Android.
- IceWM 3.5.0 y PCManFM.
- Fuentes DejaVu Sans grandes para uso táctil.
- Teclado latinoamericano.
- Indicador meteorológico de San Juan mediante Open-Meteo y YAD.
- Tema `JoseXP` y accesos para Dillo, Open Media Center, flstream e IPTV Center.

## Integración con Android

Los scripts agregan `/system/bin` al `PATH`. `iptv-play` y `yt360` llaman a `/system/bin/am` para entregar streams a VLC Android. Alpine organiza y resuelve el contenido; Android lo reproduce.

## Aplicaciones propias preservadas

- IPTV Center: fuente C++/FLTK y script de reproducción.
- Open Media Center 0.4.0-alpha, con YouTube, Kick, IPTV, radios, historial, favoritos y diagnóstico.
- Rama de desarrollo 0.5.
- flstream: fuente FLTK y lanzador.
- José IA: interfaz para `tgpt` y Pollinations; el perfil personal no debe publicarse.

Consultá [docs/ARRANQUE.md](docs/ARRANQUE.md), [docs/MULTIMEDIA.md](docs/MULTIMEDIA.md) y [docs/RESTAURACION.md](docs/RESTAURACION.md).
