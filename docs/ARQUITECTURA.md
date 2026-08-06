# Arquitectura general

## Armbian Q8-A33

Armbian se ejecuta de forma nativa desde la microSD. El kernel controla pantalla, táctil, audio, Wi-Fi, Bluetooth, batería y almacenamiento. La personalización incluye un overlay de audio, secuencias GPIO para inicializar el RTL8723BS y traducción del táctil Silead a movimiento relativo.

## Alpine Overtech

Alpine vive en `/data/local/linux/rootfs-jwm` dentro de Android. El chroot no virtualiza el equipo ni aporta otro kernel. Android 4.4.2 sigue controlando el hardware; XSDL muestra las aplicaciones X11 y las órdenes `am start` entregan el contenido multimedia a aplicaciones Android.

```text
Aplicación Alpine → IceWM/X11 → XSDL → pantalla Android
Enlace multimedia → script Alpine → am start → VLC Android
```

Esta separación permite ejecutar un escritorio liviano sin reemplazar los controladores del fabricante.
