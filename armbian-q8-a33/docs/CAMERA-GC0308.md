# Cámara GC0308 y pipeline CSI

Este documento registra el estado experimental de la cámara GalaxyCore GC0308 en la Q8-A33. El objetivo es separar los hechos comprobados de las hipótesis y de los ajustes todavía en investigación.

## Estado resumido

| Elemento | Estado |
|---|---|
| Sensor GC0308 | Detectado |
| Bus I²C/TWI | Detectado en `2-0021` |
| Driver `gc0308` | Cargado |
| `v4l2_cci` | Cargado |
| Controlador `sun6i_csi` | Detectado |
| Media controller | Disponible |
| Nodos V4L2 | Disponibles |
| Captura de prueba | Conseguida durante el desarrollo |
| Integración de formatos | Todavía experimental |
| Uso cotidiano como webcam/cámara | No validado |

La cámara no debe describirse todavía como completamente resuelta.

## Hardware identificado

El sensor detectado es un GalaxyCore GC0308 conectado al bus I²C/TWI con dirección:

```text
2-0021
```

En el sistema se utilizan los módulos:

```text
gc0308
v4l2_cci
sun6i_csi
```

También está presente `sunxi_cedrus`, pero su detección se documenta por separado: no implica que la cámara utilice automáticamente aceleración de vídeo ni que todos los flujos multimedia estén acelerados.

## Device Tree y overlays

La configuración actual de `/boot/armbianEnv.txt` incluye dos overlays relacionados directamente con la cámara:

```text
user_overlays=... a33-twi2-camaras a33-gc0308-csi
```

Archivos activos:

```text
/boot/overlay-user/a33-twi2-camaras.dtbo
/boot/overlay-user/a33-gc0308-csi.dtbo
```

`a33-twi2-camaras` habilita/configura el bus necesario y `a33-gc0308-csi` describe la integración del sensor con el subsistema CSI de la Q8.

Durante el desarrollo se generaron múltiples variantes del overlay GC0308. Se conservaron localmente versiones anteriores a cambios de DMA, media-bus y polaridad/señales de reloj. Esas copias sirven para reconstruir el diagnóstico; no deben presentarse como overlays alternativos recomendados.

## Nodos detectados

En el estado actual aparecen:

```text
/dev/media0
/dev/media1
/dev/v4l-subdev0
/dev/v4l-subdev1
/dev/video0
/dev/video1
```

El pipeline de interés para GC0308 se observó en `media1`, identificado como:

```text
driver: sun6i-csi
model: Allwinner A31 CSI Device
bus: platform:1cb0000.camera
```

El nombre histórico "A31 CSI" proviene del controlador del kernel y no significa que la tablet utilice un SoC A31; la placa sigue siendo Allwinner A33.

## Topología observada

De forma simplificada:

```text
GC0308 (I²C 2-0021)
        |
        v
sun6i-csi-bridge
        |
        v
sun6i-csi-capture
        |
        v
/dev/video1
```

Durante las inspecciones se observaron:

- `gc0308 2-0021` como subdispositivo V4L2;
- `sun6i-csi-bridge` como bridge;
- `sun6i-csi-capture` como nodo de captura;
- enlace habilitado entre sensor y bridge;
- enlace habilitado/inmutable desde el bridge hacia capture.

## Formatos observados

Aquí se encuentra una de las partes todavía no resueltas del pipeline.

En una inspección del sensor se observó:

```text
GC0308:
UYVY8_2X8
640x480
sRGB
```

Mientras que el bridge/capture llegó a quedar configurado como:

```text
SBGGR8_1X8
1280x720
```

Y `/dev/video1` mostró un formato Bayer `BA81` de 1280×720.

Esta discrepancia es importante: el sensor y el resto del pipeline no estaban describiendo el mismo formato/resolución. Que los nodos existan y los enlaces estén habilitados no garantiza por sí solo una imagen correcta.

## Capturas de prueba

Durante el desarrollo se consiguió generar una captura de prueba de 320×240 UYVY cuyo archivo resultante tuvo aproximadamente 150 KiB.

Eso demostró que existía actividad real en la ruta de captura, pero no es suficiente para considerar finalizada la integración. Una cámara terminada debería permitir seleccionar un formato coherente, iniciar streaming de manera repetible y producir imágenes correctas sin ajustes manuales especiales.

## Trabajo sobre el driver GC0308

Además del Device Tree se experimentó con parámetros del driver `gc0308.c`. Entre los valores probados durante el diagnóstico quedaron registrados:

```text
RSH_WIDTH          0x26
SAMPLE_HOLD_DELAY  0x2a
ROW_TAIL_WIDTH     0x00
CISCTL_MODE1       0x11
PAD_DRV            0x00
```

Estos valores documentan el estado de una etapa de pruebas. No deben interpretarse como parámetros universales para todos los módulos GC0308 ni copiarse a ciegas a otra placa.

## Por qué sigue marcado como experimental

Actualmente están comprobados el sensor, su presencia en I²C, los módulos del kernel, los nodos V4L2 y el pipeline CSI. También se consiguió al menos una captura durante el desarrollo.

Todavía quedan por cerrar, de manera reproducible:

1. acordar el mismo media-bus format entre GC0308 y `sun6i-csi-bridge`;
2. acordar resolución entre sensor, bridge y capture;
3. verificar polaridad de PCLK/HSYNC/VSYNC según el hardware real;
4. confirmar streaming repetible después de un arranque limpio;
5. comprobar que la imagen tenga colores, geometría y sincronización correctos;
6. determinar qué cambios del driver son realmente necesarios y cuáles fueron sólo experimentales;
7. probar aplicaciones de usuario una vez estabilizado V4L2.

## Comandos de diagnóstico útiles

Estos comandos son de inspección y no modifican el hardware:

```sh
ls -l /dev/video* /dev/media* /dev/v4l-subdev* 2>/dev/null
media-ctl -d /dev/media1 -p
v4l2-ctl -d /dev/video1 --all
v4l2-ctl -d /dev/video1 --list-formats-ext
```

Para inspeccionar formatos de los subdispositivos puede utilizarse `media-ctl` antes de intentar cambiar nada.

## Precaución con los overlays experimentales

Los overlays de cámara afectan el Device Tree de arranque. Una variante incorrecta puede impedir que el sensor aparezca, producir un pipeline inválido o introducir otros problemas de hardware.

Antes de reemplazar un overlay activo se debe conservar una copia conocida como funcional y mantener disponible una forma de editar la microSD desde otra máquina.

## Objetivo de cierre

La cámara se considerará funcional de forma estable cuando, tras un arranque limpio, pueda recorrerse esta cadena sin intervención especial:

```text
boot
  -> GC0308 detectado
  -> media graph correcto
  -> formatos coherentes
  -> streaming V4L2
  -> imagen válida
  -> aplicación de usuario
```

Hasta entonces, el estado público recomendado es:

**GC0308 detectada e integrada con sun6i-csi a nivel experimental; pipeline V4L2 presente y capturas de prueba conseguidas, con negociación de formatos y estabilidad todavía en investigación.**
