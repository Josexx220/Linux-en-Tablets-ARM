# Restauración de Alpine Overtech

## Requisitos

- Android 4.4.2 con acceso root y BusyBox.
- Rootfs ARMv7 en `/data/local/linux/rootfs-jwm`.
- XSDL y VLC Android.
- Espacio suficiente en `/data`.

## Extraer el respaldo

Detener Alpine y desmontar primero los bind mounts. Después crear la carpeta y extraer como root preservando permisos.

```sh
mkdir -p /data/local/linux/rootfs-jwm
tar -xzf rootfs-alpine-overtech-3.20.3-armv7.tar.gz \
  -C /data/local/linux/rootfs-jwm
```

Copiar los scripts de `android/` a `/data/local/linux/`, aplicar permisos ejecutables y revisar que `auto-start.sh` apunte a `rootfs-jwm`.

## Regenerar SSH

Las claves privadas no forman parte del respaldo:

```sh
busybox chroot /data/local/linux/rootfs-jwm ssh-keygen -A
mkdir -p /data/local/linux/rootfs-jwm/run/sshd
```

Agregar una clave pública propia a `/root/.ssh/authorized_keys`; nunca publicar la clave privada.

## Validación

```sh
busybox chroot /data/local/linux/rootfs-jwm /bin/sh -c 'cat /etc/alpine-release'
busybox chroot /data/local/linux/rootfs-jwm /bin/sh -c 'apk info | wc -l'
```

Luego abrir XSDL, ejecutar el arranque y probar PCManFM, IceWM, Dillo y la entrega de una URL directa a VLC Android.
