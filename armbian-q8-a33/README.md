# Armbian en Q8-A33

Port comunitario/user-built de Armbian para una tablet Q8 basada en Allwinner A33, pantalla 1024×600 y aproximadamente 457 MiB de RAM utilizables.

> **Estado del proyecto:** placa CSC / imagen construida por el usuario. Este repositorio documenta una Q8 concreta y no representa soporte oficial de Armbian ni garantiza compatibilidad con todas las revisiones comercializadas como “Q8”.

## Sistema verificado

| Elemento | Estado |
|---|---|
| SoC | Allwinner A33, 4 × Cortex-A7 ARMv7 |
| Arquitectura | `armhf`, 32 bits |
| Sistema | Debian 12 Bookworm / Armbian user-built |
| Kernel | `6.12.100-legacy-sunxi` |
| Arranque | microSD, ext4 `armbi_root` |
| Pantalla | 1024×600 funcional |
| Táctil | Silead funcional |
| Wi-Fi | RTL8723BS funcional |
| Bluetooth | Inicializado, discoverable y pairable; validación de periféricos en curso |
| Audio | Integrado mediante overlay propio |
| Batería | AXP20x funcional |
| Acelerómetro | STK8312 detectado |
| Cámara | GC0308 integrada con CSI a nivel experimental |
| Interfaz | Q8 Shell sobre base X11/IceWM |

Estado actualizado al **03/09/2026**.

## Device Tree y overlays

DTB base:

```text
allwinner/sun8i-a33-q8-tablet.dtb
```

Overlays activos:

```text
a33-audio
q8-panel-1024x600
a33-stk8312
a33-twi2-camaras
a33-gc0308-csi
```

El UUID real de la raíz no se publica. En documentación se utiliza:

```text
rootdev=UUID=<UUID-DE-LA-PARTICION-ROOT>
```

## Componentes propios

| Componente | Función |
|---|---|
| `iniciar-wifi-rtl8723bs.service` | Inicializa RTL8723BS y reprobe de MMC1 |
| `reiniciar-bluetooth-rtl8723bs.service` | Reinicializa Bluetooth UART/H5 después de Wi-Fi |
| `silead-touchpad-relativo.service` | Convierte el Silead en puntero relativo opcional |
| `orientar-fbcon-stk8312.service` | Utiliza STK8312 para orientación de consola |
| `mostrar-ip.service` | Herramienta de acceso/diagnóstico en tty1 |
| Q8 Shell | Interfaz táctil ligera específica de la tablet |
| [Tienda Q8](tienda-q8/README.md) | Tienda APT ligera, versión 1 funcional y validada |

## Documentación

- [Hardware y estado del sistema](docs/HARDWARE.md)
- [Wi-Fi y Bluetooth RTL8723BS](docs/WIFI-BLUETOOTH.md)
- [Pantalla, táctil y STK8312](docs/DISPLAY-TOUCH.md)
- [Audio](docs/AUDIO.md)
- [Cámara GC0308 y CSI](docs/CAMERA-GC0308.md)
- [Device Tree y overlays](docs/DEVICE-TREE.md)
- [Q8 Shell](docs/Q8-SHELL.md)
- [Tienda Q8](tienda-q8/README.md)
- [Restauración](docs/RESTAURACION.md)
- [Bitácora completa del proyecto](docs/BITACORA.md)

## Qué está realmente cerrado

Arranque, pantalla, táctil, Wi-Fi, audio y lectura de batería forman actualmente la base funcional de la tablet. Bluetooth ha avanzado hasta un controlador encendido, visible y pairable, pero los periféricos deben validarse individualmente.

La cámara GC0308 dispone de sensor detectado, media graph y capturas experimentales; todavía hay trabajo sobre negociación de formatos y estabilidad. La autorrotación gráfica completa tampoco se presenta como terminada.

## Entorno y entretenimiento

La tablet utiliza una base gráfica deliberadamente ligera. Q8 Shell organiza accesos a archivos, Internet, multimedia, terminal y juegos. Durante el proyecto se experimentó con DOSBox, ScummVM, Xash3D/Half-Life/Counter-Strike, FreeAOE y otras aplicaciones ARM/Linux.

Estos experimentos se documentan como tales: la existencia de un lanzador no significa que cada título sea estable o tenga rendimiento adecuado.

## Optimización

`Q8 Armbian Slim` es la fase de reducción y optimización del sistema. La estrategia es conservar kernel, DTB, firmware y hardware ya funcional, crear respaldos antes de cambios y retirar componentes de forma gradual y verificable.

No se recomienda ejecutar actualizaciones masivas de kernel/DTB/firmware sobre una instalación estable sin un plan de recuperación.

## Privacidad

El repositorio público no debe contener:

- contraseñas o credenciales;
- SSID privados;
- direcciones IP privadas o Tailscale;
- direcciones MAC;
- UUID reales de la instalación;
- datos personales innecesarios.

## Filosofía de la documentación

La bitácora conserva tanto los resultados exitosos como los intentos fallidos. El objetivo no es hacer parecer que el port funcionó al primer intento, sino dejar información útil para reproducir, depurar y mejorar el soporte de estas tablets A33.
