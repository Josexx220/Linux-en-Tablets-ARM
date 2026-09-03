# Pantalla, táctil y orientación de la Q8-A33

Este documento reúne la configuración de la pantalla 1024×600, el táctil Silead y el acelerómetro STK8312 de la Q8-A33.

El objetivo es distinguir tres capas que durante el desarrollo estuvieron relacionadas pero no son lo mismo:

1. panel LCD y orientación de imagen;
2. coordenadas del táctil;
3. orientación física detectada por el acelerómetro.

## Estado resumido

| Elemento | Estado |
|---|---|
| Panel LCD 1024×600 | Funcional |
| Sesión X11 1024×600 | Funcional |
| Táctil Silead | Funcional |
| Calibración táctil | Aplicada para la orientación utilizada |
| Puntero relativo por uinput | Funcional/opcional |
| STK8312 | Detectado mediante IIO |
| Orientación de fbcon con STK8312 | Implementada |
| Autorrotación gráfica completa | No se documenta como cerrada |

## Pantalla 1024×600

La tablet utiliza un panel de 1024×600. En la sesión gráfica, `xrandr` informa actualmente una salida primaria de 1024×600.

La configuración de arranque utiliza:

```text
fdtfile=allwinner/sun8i-a33-q8-tablet.dtb
```

y el overlay:

```text
q8-panel-1024x600
```

El archivo activo es:

```text
/boot/overlay-user/q8-panel-1024x600.dtbo
```

La presencia de `disp_mode=1920x1080p60` en configuraciones heredadas de `armbianEnv.txt` no debe interpretarse como la resolución física del LCD. La resolución verificada de esta tablet es 1024×600.

## Táctil Silead

El controlador táctil aparece como dispositivo Silead, manejado por `silead_ts`.

Durante el desarrollo se utilizó una matriz de transformación de X11 para hacer coincidir las coordenadas absolutas del panel táctil con la orientación visible de la pantalla.

Esto es importante: girar la imagen no corrige automáticamente las coordenadas del táctil. Pantalla y entrada deben mantenerse coordinadas.

## Dos modos de uso del táctil

### Entrada absoluta

Es el comportamiento natural de una pantalla táctil: tocar una posición física corresponde a una posición concreta del escritorio.

Este modo depende de la calibración/matriz aplicada en X11.

### Puntero relativo

También se desarrolló:

```text
/usr/local/sbin/silead-touchpad-relativo.py
```

junto con:

```text
silead-touchpad-relativo.service
```

El script toma eventos absolutos del Silead y crea mediante `python-evdev`/uinput un dispositivo virtual denominado:

```text
Silead Touchpad Virtual
```

Ese dispositivo genera movimiento relativo, permitiendo utilizar la superficie de una forma más parecida a un touchpad.

## Evolución del filtro de movimiento

El modo relativo pasó por numerosas iteraciones. En la tablet se conservaron copias anteriores relacionadas con:

- zona muerta;
- orientación;
- inversión vertical;
- espera de X11;
- antivibración;
- filtros de movimiento;
- acumulación de movimiento;
- protección de clic;
- interacción con dos dedos;
- búsqueda de movimiento más fluido.

Los nombres de esas copias son evidencia del proceso de desarrollo, no una garantía de que cada variante haya sido funcional. La versión activa es la que debe tomarse como referencia.

## Acelerómetro STK8312

El acelerómetro identificado es un STK8312.

El sistema actual lo expone mediante IIO como:

```text
/sys/bus/iio/devices/iio:device0
```

con nombre:

```text
stk8312
```

También existe un dispositivo IIO asociado al sensor térmico del SoC; por ello no se debe asumir que todo `iio:deviceN` corresponde al acelerómetro. Es preferible comprobar siempre el archivo `name`.

## Device Tree del STK8312

La configuración activa incluye:

```text
a33-stk8312
```

correspondiente a:

```text
/boot/overlay-user/a33-stk8312.dtbo
```

Este overlay permite describir el sensor para que el kernel pueda detectarlo correctamente.

## Orientación de la consola

Se desarrolló:

```text
/usr/local/sbin/orientar-fbcon-stk8312
```

junto con:

```text
orientar-fbcon-stk8312.service
```

Su función es utilizar la información del STK8312 para adaptar la orientación de la consola framebuffer (`fbcon`).

La presencia de este servicio es posterior al primer respaldo público del repositorio, por lo que las versiones antiguas de `sistema/etc/systemd/system/` pueden no contenerlo todavía.

## Autorrotación: alcance real

Durante el desarrollo existieron experimentos relacionados con autorrotación y con la coordinación entre orientación y táctil.

No se debe confundir:

```text
acelerómetro detectado
        !=
autorrotación completa del escritorio
```

Para una autorrotación completa hacen falta, como mínimo, decisiones coordinadas sobre:

```text
STK8312
   |
   +--> orientación de pantalla
   |
   +--> transformación del táctil
   |
   +--> orientación de fbcon
```

Actualmente se documenta como comprobado el STK8312 y la herramienta de orientación de fbcon. No se presenta una autorrotación gráfica universal como función terminada.

## Comprobaciones útiles

### Resolución X11

```sh
xrandr --current
```

### Dispositivos de entrada

```sh
xinput list
```

### IIO

```sh
for d in /sys/bus/iio/devices/iio:device*; do
    printf '%s: ' "$d"
    cat "$d/name" 2>/dev/null || echo '?'
done
```

### Servicios

```sh
systemctl status silead-touchpad-relativo.service
systemctl status orientar-fbcon-stk8312.service
```

## Riesgo al cambiar orientación

Un cambio que hace que la pantalla se vea correctamente puede dejar el táctil invertido, rotado o desplazado. Antes de modificar matrices de X11, overlays del panel o scripts de orientación conviene mantener acceso SSH y una copia de la configuración anterior.

En una tablet sin teclado físico, perder simultáneamente la orientación correcta y el táctil puede dificultar mucho la recuperación local.

## Estado público recomendado

**Panel LCD 1024×600 funcional; táctil Silead funcional y calibrado para la orientación utilizada; modo de puntero relativo disponible; acelerómetro STK8312 detectado e integrado en la orientación de fbcon. La autorrotación gráfica completa continúa tratándose como trabajo experimental.**
