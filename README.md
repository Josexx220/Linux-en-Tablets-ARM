# Linux en tablets ARM

Resguardo técnico y documentación de dos proyectos para reutilizar tablets ARM antiguas con Linux.

| Proyecto | Equipo | Arquitectura |
|---|---|---|
| [Armbian Q8-A33](armbian-q8-a33/README.md) | Q8 A33 Tablet, 1024×600 | Debian 12/Armbian nativo, kernel 6.12 legacy sunxi |
| [Alpine Overtech](alpine-overtech/README.md) | Overtech TAB-OV721 | Android 4.4.2 + Alpine 3.20 ARMv7 en chroot + XSDL |

Los dos sistemas usan IceWM y fueron adaptados para aproximadamente 512 MB de RAM. No son la misma instalación: Armbian arranca desde una microSD y controla el hardware; Alpine comparte el kernel y los controladores de Android.

## Qué contiene el repositorio

- Configuraciones y scripts personalizados.
- Servicios de arranque y archivos de integración.
- Inventarios de hardware y paquetes.
- Código fuente de aplicaciones propias disponible en los equipos.
- Procedimientos de instalación, respaldo y restauración.

## Qué no contiene

- Contraseñas Wi-Fi, cookies o claves SSH.
- ROM, APK, contenido multimedia ni material protegido.
- Imágenes completas de discos o rootfs comprimidos.
- Binarios descargables o compilables que no conviene versionar.

Los respaldos grandes se conservan fuera del historial de Git y están identificados en [docs/RESPALDOS.md](docs/RESPALDOS.md).

## Advertencia

Los ajustes de GPIO, Device Tree y firmware son específicos de estos modelos y revisiones. No deben aplicarse a otra tablet o TV Box solo porque también utilice un SoC Allwinner.
