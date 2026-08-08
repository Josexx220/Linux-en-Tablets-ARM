# Cronología general: Linux en tablets ARM

## Alcance

Este documento relaciona los dos proyectos conservados en el repositorio: Alpine dentro de Android en la Overtech TAB-OV721 y Armbian nativo en la Q8-A33. Las fechas exactas de cada prueba no siempre quedaron registradas; el orden refleja la evolución técnica comprobable.

## Dos estrategias para un mismo objetivo

El objetivo común fue recuperar tablets ARM antiguas y convertirlas en equipos Linux útiles con alrededor de 512 MiB de RAM.

| Proyecto | Estrategia | Ventaja principal | Dificultad principal |
|---|---|---|---|
| Alpine Overtech | chroot dentro de Android | Android conserva todos sus controladores | depende de Android, XSDL y su kernel antiguo |
| Armbian Q8-A33 | Linux nativo desde microSD | sistema Linux autónomo y kernel moderno | cada componente de hardware debe resolverse en Linux |

## Etapa 1: Alpine como prueba de concepto

La Overtech conservó Android 4.4.2. Sobre él se instaló Alpine ARMv7 en `/data/local/linux/rootfs-jwm`. Esta etapa demostró que era posible ejecutar un escritorio Linux sin borrar Android.

Se resolvieron los montajes del chroot, XSDL, el teclado latinoamericano y distintas pruebas de gestores de ventanas. IceWM terminó siendo la opción estable por consumo y facilidad de personalización.

## Etapa 2: escritorio y aplicaciones ligeras

Se integraron PCManFM, LXTerminal, Dillo, Dunst y YAD. El tamaño de fuentes y controles se adaptó al uso táctil. Los scripts de inicio evolucionaron desde pruebas con i3 y JWM hasta una sesión IceWM consolidada.

## Etapa 3: arquitectura multimedia híbrida

Intentar reproducir todo dentro del chroot era costoso y el sonido seguía controlado por Android. La solución fue delegar reproducción a VLC Android mediante `am start`.

De esa idea surgieron la acción de Dillo, `yt360`, IPTV Center, Open Media Center y las pruebas con flstream. Alpine organiza y selecciona; Android reproduce.

## Etapa 4: aplicaciones propias y experimentos

Se desarrollaron interfaces FLTK, módulos de medios, lanzadores e integración con servicios externos. José IA añadió una interfaz a proveedores de IA mediante terminal. RetroArch, InfoNES y EmuCenter sirvieron para explorar los límites del equipo.

No todas las pruebas se consideran parte estable: los servicios externos, enlaces multimedia y proveedores pueden cambiar.

## Etapa 5: Armbian nativo en la Q8-A33

El segundo proyecto cambió la estrategia: Armbian arranca directamente desde una microSD y controla la tablet sin Android. Se utilizó una compilación no oficial para Q8-A33 con Debian Bookworm y kernel legacy sunxi 6.12.

La experiencia de Alpine influyó en la elección de IceWM, PCManFM, LXTerminal, Dillo y una interfaz liviana.

## Etapa 6: adaptación del hardware Q8-A33

Se configuraron Device Tree y overlays. El táctil Silead necesitó calibración y un modo relativo. El audio requirió un overlay específico. El Wi-Fi RTL8723BS necesitó una secuencia de GPIO y un servicio que se ejecuta antes de la red.

Bluetooth fue el componente más difícil. El controlador llegó a inicializarse, pero el escaneo y emparejamiento no quedaron estables. Esta limitación se conserva explícitamente en la documentación.

## Etapa 7: escritorio final de Armbian

IceWM quedó con accesos táctiles, indicadores de batería y red, controles de volumen, Onboard condicionado a la ausencia de teclado físico y reproducción de video mediante mpv en calidad moderada.

## Etapa 8: inventario, limpieza y privacidad

Antes de publicar se recopilaron versiones, paquetes, servicios, scripts y configuraciones. Se excluyeron:

- contraseñas y configuraciones Wi-Fi;
- claves SSH y claves de servidor;
- cookies e identificadores locales;
- perfiles personales;
- listas M3U/M3U8;
- historiales y favoritos;
- firmware de terceros;
- binarios recuperables o recompilables;
- fondos personales;
- archivos de respaldo de gran tamaño.

## Etapa 9: respaldos de Alpine

Se habilitó temporalmente OpenSSH dentro del chroot y se creó una clave dedicada. El rootfs fue transmitido hacia la notebook, comprimido y verificado. Los scripts Android externos al rootfs se copiaron mediante ADB.

## Etapa 10: respaldos de Armbian

Se generaron tres archivos para configuración, escritorio y recursos. Después se apagó la Q8-A33, se conectó la microSD a la notebook y se identificó inequívocamente como `/dev/sdd`, etiqueta `armbi_root`, antes de leerla.

El 8 de agosto de 2026 se creó una imagen completa de 62.723.719.168 bytes. La imagen gzip mide aproximadamente 2,0 GB. Se verificaron CRC, SHA-256 y coincidencia exacta del tamaño descomprimido.

## Etapa 11: resguardo en GitHub

Se creó el repositorio privado `Josexx220/Linux-en-Tablets-ARM`. La rama `main` quedó sincronizada primero en el commit `073ba46`. La huella de la imagen completa se agregó después en el commit `b8a0550`.

GitHub funciona como resguardo de documentación, scripts y configuración legible. Los archivos grandes permanecen en la notebook y se autentican con `SHA256SUMS`.

## Resumen de respaldos verificados

| Sistema | Respaldo | SHA-256 |
|---|---|---|
| Armbian | configuración | `a4bcee010eafaef11c49ee6d64a959100a2eea138d89e7def90587e36283baa5` |
| Armbian | escritorio | `040fb908822f3496d22dd5571103ffe66f733f7af59a73323dece8f55557a41a` |
| Armbian | recursos | `e6f5225056d3da9d6e65f1b42d445a1fde39e7ec4cd1710038d43dd1804f1a35` |
| Armbian | imagen completa microSD | `8906f362b0e77c543fab9893a606003211bc68887037675bee808948e6a42fd4` |
| Alpine | rootfs completo depurado | `f45e7b6a8a6a01c17c857716ba49f08853597fae1e7c7b69985ff6edc5b871cd` |

## Estado global

Los dos proyectos están respaldados y documentados. Alpine representa la estrategia híbrida que aprovecha Android; Armbian representa el sistema nativo que controla directamente la Q8-A33. El pendiente técnico principal es Bluetooth estable en Armbian. El pendiente de mantenimiento principal es revisar periódicamente integraciones dependientes de servicios web.
