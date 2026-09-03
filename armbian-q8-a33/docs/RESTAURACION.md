# Restauración de Armbian Q8-A33

Esta guía describe rutas de recuperación del sistema. Antes de restaurar configuraciones parciales conviene leer `DEVICE-TREE.md` y `HARDWARE.md`, porque esta Q8 utiliza varios overlays y servicios específicos de la placa.

## 1. Restaurar una imagen completa

La forma más fiel de regresar a un estado conocido es escribir una imagen completa de la microSD con la tablet apagada.

# ¡ATENCIÓN!

**`dd` sobrescribe el dispositivo indicado. Identificar la microSD por tamaño y modelo antes de ejecutar el comando. No copiar literalmente `/dev/sdX`.**

```sh
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
sudo umount /dev/sdX1
gzip -dc q8-a33-armbian.img.gz | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Después conviene volver a ejecutar `lsblk` y comprobar que la tarjeta contiene la partición esperada.

La imagen completa verificada durante el proyecto se conserva fuera del repositorio GitHub por su tamaño.

## 2. UUID de la raíz

Una tarjeta restaurada o una instalación reconstruida puede tener un UUID diferente. La configuración pública utiliza deliberadamente:

```text
rootdev=UUID=<UUID-DE-LA-PARTICION-ROOT>
```

Para conocer el UUID real de la nueva tarjeta:

```sh
blkid
```

Debe actualizarse `rootdev` en `/boot/armbianEnv.txt` cuando corresponda.

## 3. Device Tree y overlays

La instalación verificada utiliza:

```text
fdtfile=allwinner/sun8i-a33-q8-tablet.dtb
user_overlays=a33-audio q8-panel-1024x600 a33-stk8312 a33-twi2-camaras a33-gc0308-csi
```

No debe suponerse que estos overlays son compatibles con otra revisión Q8.

Antes de reemplazar DTB u overlays hay que conservar una copia funcional y, preferentemente, disponer de otra computadora capaz de montar y editar la microSD.

## 4. Restaurar configuraciones

Los árboles `sistema/` y `home-jose/` reflejan rutas del sistema documentado, pero el snapshot público puede ir por detrás del estado de la tablet. Deben revisarse archivo por archivo y no copiarse a ciegas sobre `/`.

Comprobar especialmente:

- UUID de `rootdev`;
- DTB y overlays;
- permisos y propietarios;
- usuario de destino;
- servicios systemd;
- dependencias Python/GTK/evdev;
- configuración X11/IceWM/Q8 Shell;
- firmware RTL8723BS.

## 5. Servicios principales

Después de restaurar unidades compatibles con el sistema:

```sh
sudo systemctl daemon-reload
sudo systemctl enable iniciar-wifi-rtl8723bs.service
sudo systemctl enable reiniciar-bluetooth-rtl8723bs.service
```

Según la configuración restaurada también pueden existir:

```text
mostrar-ip.service
silead-touchpad-relativo.service
orientar-fbcon-stk8312.service
```

El touchpad relativo es opcional y no debe activarse si se desea utilizar únicamente el comportamiento táctil absoluto de X11.

## 6. Orden recomendado de verificación

Después de una restauración, probar de menor a mayor complejidad:

1. arranque y consola;
2. almacenamiento y raíz correcta;
3. pantalla 1024×600;
4. red Wi-Fi;
5. acceso SSH;
6. táctil;
7. audio;
8. batería;
9. STK8312/orientación;
10. Bluetooth;
11. entorno gráfico/Q8 Shell;
12. cámara GC0308.

Este orden permite conservar una vía remota de recuperación antes de probar componentes más experimentales.

## 7. Qué no actualizar durante una recuperación

Si el objetivo es recuperar una instalación conocida, evitar inicialmente:

```text
apt full-upgrade
apt dist-upgrade
cambio de kernel
cambio de DTB
cambio de firmware
```

Primero debe recuperarse el estado funcional. Las actualizaciones pueden evaluarse después y de forma separada.

## 8. Privacidad

No copiar desde documentación pública valores de ejemplo como si fueran valores reales. El repositorio no publica UUID, IP privadas, Tailscale, MAC, SSID ni contraseñas.

## 9. Respaldo antes de experimentar

La filosofía del proyecto es sencilla:

```text
estado funcional
      -> respaldo
      -> un cambio
      -> prueba
      -> conservar o revertir
```

Esto es especialmente importante para Wi-Fi, Device Tree, pantalla/táctil y cámara, porque un error puede dificultar la recuperación directamente desde la tablet.
