# Hardware y sistema de la Q8-A33

Este documento resume el hardware detectado y el estado comprobado del port Armbian para la tablet Q8-A33 1024×600. Los datos corresponden al sistema verificado el 3 de septiembre de 2026.

> Este es un port comunitario/user-built para una placa CSC. No debe interpretarse como una imagen oficialmente soportada por Armbian ni como una descripción universal de todas las tablets vendidas bajo el nombre Q8.

## Plataforma

| Elemento | Valor observado | Estado |
|---|---|---|
| Placa / DT | Q8 A33 Tablet 1024×600 | Funcional |
| SoC | Allwinner A33 (`sun8i`) | Funcional |
| CPU | 4 × Cortex-A7 ARMv7, 120–1008 MHz | Funcional |
| Arquitectura | ARMv7 / `armhf`, 32 bits | Funcional |
| RAM visible | ~457 MiB | Funcional |
| Almacenamiento | microSD ~58,4 GiB visibles, ext4 `armbi_root` | Funcional |
| Raíz | `/dev/mmcblk0p1` | Funcional |
| Device Tree | `allwinner/sun8i-a33-q8-tablet.dtb` | Funcional |
| Kernel verificado | `6.12.100-legacy-sunxi` | Funcional |
| Sistema | Debian 12 Bookworm / Armbian user-built | Funcional |

El sistema fue construido como `IMAGE_TYPE=user-built`, `BOARD_TYPE=csc`, familia `sunxi` y rama de kernel `legacy`.

## Pantalla y entrada

| Componente | Identificación | Estado |
|---|---|---|
| Pantalla LCD | Panel 1024×600 | Funcional |
| Overlay de panel | `q8-panel-1024x600.dtbo` | Activo |
| Táctil | Silead / `silead_ts` | Funcional |
| Puntero relativo | `silead-touchpad-relativo.py` + uinput | Funcional/opcional |
| Acelerómetro | STK8312 | Detectado por IIO |
| Orientación de consola | `orientar-fbcon-stk8312` | Implementada |

El STK8312 aparece actualmente como dispositivo IIO. También se detecta el sensor térmico del SoC como otro dispositivo IIO.

## Red inalámbrica

| Componente | Identificación | Estado |
|---|---|---|
| Wi-Fi | Realtek RTL8723BS | Funcional mediante inicialización específica de la placa |
| Bluetooth | Realtek RTL8723BS, UART/H5 | Controlador inicializado |

Wi-Fi requiere una secuencia propia de alimentación/GPIO y reprobe de MMC1. Bluetooth se reinicializa después de Wi-Fi mediante un servicio específico.

En la comprobación del 03/09/2026 BlueZ informó el controlador como `Powered: yes`, `Discoverable: yes` y `Pairable: yes`. Esto confirma una mejora respecto de etapas anteriores del proyecto; todavía no se generaliza esa comprobación como garantía de funcionamiento estable con cualquier periférico.

## Audio

| Componente | Identificación | Estado |
|---|---|---|
| Tarjeta ALSA | `sun8ia33audio` | Detectada/funcional |
| Codec/ruta | `sun8i-a33-audio` | Integrado |
| Overlay | `a33-audio.dtbo` | Activo |

Se conservó localmente una variante anterior al ajuste `hpcom` para diagnóstico histórico. Los controles de volumen del entorno gráfico utilizan scripts pequeños para subir, bajar y silenciar el audio.

## Alimentación y batería

| Componente | Identificación | Estado |
|---|---|---|
| Batería | `axp20x-battery` | Funcional |
| Alimentación USB | `axp20x-usb-power` | Detectada |
| ADC/PMIC | familia AXP20x | Detectada |

El nivel y estado de batería se leen desde sysfs y se integran en la interfaz de la tablet.

## Cámara y vídeo

| Componente | Identificación | Estado |
|---|---|---|
| Sensor de cámara | GalaxyCore GC0308, I²C `2-0021` | Detectado; experimental |
| Driver sensor | `gc0308` + `v4l2_cci` | Cargado |
| CSI | `sun6i_csi` | Detectado |
| Captura | `/dev/video1`, `/dev/media1` | Disponible; experimental |
| Subdispositivos | `/dev/v4l-subdev0`, `/dev/v4l-subdev1` | Disponibles |
| Cedrus VPU | `sunxi_cedrus` | Detectado |

La cámara llegó a producir capturas de prueba, pero su integración sigue siendo experimental. La topología V4L2 actual todavía requiere coordinación de formatos entre sensor, bridge y captura. Por ese motivo no se marca como cámara completamente resuelta.

La presencia de `sunxi_cedrus` sólo se documenta como detección del dispositivo/controlador; no implica que la aceleración de vídeo haya sido validada para todas las aplicaciones.

## Device Tree y overlays activos

La configuración verificada usa:

```text
fdtfile=allwinner/sun8i-a33-q8-tablet.dtb
user_overlays=a33-audio q8-panel-1024x600 a33-stk8312 a33-twi2-camaras a33-gc0308-csi
```

Overlays activos:

| Overlay | Función |
|---|---|
| `a33-audio.dtbo` | Audio A33 |
| `q8-panel-1024x600.dtbo` | Panel LCD de la tablet |
| `a33-stk8312.dtbo` | Acelerómetro STK8312 |
| `a33-twi2-camaras.dtbo` | Bus I²C/TWI utilizado por cámaras |
| `a33-gc0308-csi.dtbo` | Sensor GC0308 y conexión CSI |

Los archivos de trabajo conservados en la tablet incluyen versiones intermedias del overlay GC0308. Esas variantes son evidencia de las pruebas realizadas, pero no todas deben considerarse configuraciones válidas o recomendadas.

## Memoria virtual

Debido a los ~457 MiB de RAM física, el sistema utiliza dos niveles de intercambio:

| Recurso | Tamaño aproximado | Prioridad observada |
|---|---:|---:|
| zram swap | 229 MiB | 5 |
| `/swapfile-q8` | 1,33 GiB | 1 |

Además, Armbian utiliza zram para `/var/log`. La prioridad superior de zram permite usar primero la memoria comprimida antes del swapfile de la microSD.

## Estado resumido

| Subsistema | Estado actual |
|---|---|
| Arranque microSD | Funcional |
| Pantalla 1024×600 | Funcional |
| Táctil Silead | Funcional |
| Wi-Fi RTL8723BS | Funcional |
| Bluetooth RTL8723BS | Inicializado, visible y pairable; periféricos aún deben validarse individualmente |
| Audio | Funcional/integrado |
| Batería/PMIC | Funcional |
| STK8312 | Detectado e integrado en herramientas de orientación |
| GC0308 | Funcional a nivel experimental |
| Cedrus | Detectado; aceleración no certificada |
| Q8 Shell | Funcional |

## Privacidad y reproducibilidad

La documentación pública no debe contener direcciones IP privadas, direcciones Tailscale, MAC, contraseñas, credenciales ni el UUID real de la partición raíz.

Cuando sea necesario mostrar `armbianEnv.txt`, se debe usar un marcador como:

```text
rootdev=UUID=<UUID-DE-LA-PARTICION-ROOT>
```

Los inventarios más extensos y los archivos reproducibles del sistema se mantienen en los directorios `inventario/` y `sistema/` del proyecto.