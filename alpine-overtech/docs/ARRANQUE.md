# Arranque de Alpine y XSDL

El script activo es `/data/local/linux/auto-start.sh`.

1. Espera 30 segundos después del inicio de Android.
2. Abre XSDL (`x.org.server/.MainActivity`).
3. Espera 35 segundos a que el servidor X quede disponible.
4. Monta `/dev`, `/dev/pts`, `/proc`, `/sys`, `/system` y `/data` dentro del rootfs.
5. Ejecuta el chroot con `DISPLAY=:0`, zona horaria de San Juan y locale español.
6. Inicia PCManFM, Dunst e IceWM.

Los scripts `mount-alpine.sh` y `start-alpine.sh` corresponden a una instalación anterior basada en `linux.img` y `/data/local/linux/rootfs`. Se conservan como antecedente, pero no describen el rootfs activo `rootfs-jwm`.

## Inicio manual desde ADB

Para diagnóstico se recomienda ejecutar por separado los montajes del script activo y después:

```sh
busybox chroot /data/local/linux/rootfs-jwm /bin/sh
export HOME=/root DISPLAY=:0
exec /usr/bin/icewm-session
```

XSDL debe estar abierto antes de iniciar IceWM.
