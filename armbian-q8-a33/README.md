# Armbian en Q8-A33

Sistema Linux nativo para una tablet Q8 con Allwinner A33, cuatro Cortex-A7 y unos 457 MiB utilizables. Arranca desde una microSD de 64 GB.

## Estado documentado

- Armbian unofficial 26.08 trunk, basado en Debian 12 Bookworm.
- Kernel `6.12.100-legacy-sunxi` ARMv7.
- IceWM + PCManFM, inicio mediante `.xinitrc`.
- Wi-Fi RTL8723BS inicializado mediante una secuencia GPIO y reprobe de MMC1.
- Bluetooth RTL8723BS conectado por UART H5; la inicialización funciona, pero el escaneo y emparejamiento siguen en investigación.
- Táctil Silead calibrado para X11 y servicio opcional de touchpad relativo.
- Audio mediante overlay personalizado `a33-audio.dtbo`.
- Indicadores de batería, red, volumen e IP adaptados a la tablet.

## Arranque

`/boot/armbianEnv.txt` selecciona `sun8i-a33-q8-tablet.dtb`, el overlay de audio y la partición ext4. No se debe copiar el UUID a otra tarjeta sin actualizar `rootdev`.

## Componentes principales

| Componente | Función |
|---|---|
| `iniciar-wifi-rtl8723bs.service` | Ejecuta la secuencia GPIO y vuelve a enlazar MMC1 |
| `reiniciar-bluetooth-rtl8723bs.service` | Reinicia UART H5 después del Wi-Fi |
| `silead-touchpad-relativo.service` | Traduce eventos absolutos a mouse relativo |
| `mostrar-ip.service` | Muestra IP y comando SSH en tty1 |
| `.xinitrc` | Desactiva DPMS, aplica teclado latam y calibración táctil |
| `.icewm/` | Escritorio, panel, accesos e indicadores |

Más detalles: [docs/HARDWARE.md](docs/HARDWARE.md), [docs/WIFI-BLUETOOTH.md](docs/WIFI-BLUETOOTH.md) y [docs/RESTAURACION.md](docs/RESTAURACION.md).

## Bitácora

- [Historia, pruebas, resultados y pendientes](docs/BITACORA.md)
