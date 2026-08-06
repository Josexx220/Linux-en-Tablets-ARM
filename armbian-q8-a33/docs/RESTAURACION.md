# Restauración de Armbian Q8-A33

## Restaurar una imagen completa

La forma más fiel es escribir la imagen de la microSD con la tablet apagada. Verificar cuidadosamente el dispositivo de destino antes de usar `dd`.

```sh
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
sudo umount /dev/sdX1
gzip -dc q8-a33-armbian.img.gz | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

`/dev/sdX` es un marcador: nunca copiarlo sin identificar primero la tarjeta correcta.

## Restaurar configuraciones

Los árboles `sistema/` y `home-jose/` reflejan sus rutas originales. Antes de copiarlos sobre otra instalación se deben revisar:

- UUID de `rootdev` en `armbianEnv.txt`.
- Compatibilidad del DTB y overlay.
- Propietario y permisos del usuario `jose`.
- Disponibilidad de Python `evdev`, IceWM, PCManFM, Dillo, MPV y wpa_gui.

Después de copiar servicios:

```sh
sudo systemctl daemon-reload
sudo systemctl enable iniciar-wifi-rtl8723bs.service
sudo systemctl enable reiniciar-bluetooth-rtl8723bs.service
sudo systemctl enable mostrar-ip.service
```

El servicio de táctil relativo es opcional y no debe activarse si se prefiere el táctil absoluto de X11.
