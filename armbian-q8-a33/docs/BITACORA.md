# Bitácora del proyecto Armbian Q8-A33

## Propósito

Esta bitácora registra el trabajo realizado para convertir una tablet Q8 basada en Allwinner A33 en un equipo Linux autónomo. No reemplaza las guías de restauración: conserva el camino seguido, las pruebas, los problemas y el estado real alcanzado.

La intención es conservar también los intentos fallidos y las soluciones intermedias. En este proyecto, saber qué no funcionó ha sido tan importante como registrar la configuración final.

## Equipo y sistema actual

- Placa: Q8 A33 Tablet, pantalla 1024×600.
- SoC: Allwinner A33 (`sun8i`), cuatro núcleos Cortex-A7 ARMv7.
- Arquitectura de usuarios: `armhf` (32 bits).
- Memoria utilizable: aproximadamente 457 MiB.
- Medio de arranque: microSD de 64 GB, aproximadamente 58,4 GiB visibles.
- Sistema: Armbian no oficial/user-built, Debian 12 Bookworm.
- Rama de kernel: `legacy`.
- Kernel conservado y verificado el 03/09/2026: `6.12.100-legacy-sunxi`.
- Escritorio base: IceWM, PCManFM y LXTerminal.
- Interfaz principal actual: Q8 Shell, desarrollada específicamente para la pantalla táctil.
- Device Tree: `allwinner/sun8i-a33-q8-tablet.dtb`.
- Clasificación de la imagen: `IMAGE_TYPE=user-built`, `BOARD_TYPE=csc`.

> Este repositorio documenta un trabajo comunitario sobre una Q8-A33 concreta. No debe interpretarse como una imagen oficial ni como garantía de compatibilidad con todas las tablets comercializadas bajo el nombre Q8.

## 1. Arranque desde microSD

La instalación se construyó como una imagen específica para la Q8-A33. El sistema usa una única partición ext4 etiquetada `armbi_root`, cuyo UUID queda configurado en `armbianEnv.txt`.

La configuración selecciona el Device Tree de la tablet y el prefijo de overlays `sun8i-a33`. Durante el bring-up se encontraron también fallos de arranque y configuraciones que no funcionaron; se conservaron respaldos antes de cambios importantes para poder volver atrás.

Resultado confirmado: la tablet inicia Armbian directamente desde la microSD y utiliza esa misma partición como raíz.

Por privacidad y para evitar que una configuración ajena deje de arrancar, el UUID real de la tarjeta no debe publicarse. En la documentación se representa como `<UUID-DE-LA-PARTICION-ROOT>`.

## 2. Escritorio liviano

Con menos de 512 MiB de RAM se descartaron escritorios pesados. Se instaló IceWM como gestor de ventanas, PCManFM para archivos y escritorio, y LXTerminal para administración local.

El archivo `.xinitrc` incorporó ajustes para la sesión gráfica, entre ellos desactivar DPMS, configurar el teclado latinoamericano y aplicar la transformación necesaria al táctil Silead.

Onboard se configuró para poder disponer de teclado virtual cuando no hay teclado externo.

Resultado confirmado: sesión gráfica funcional y utilizable mediante pantalla táctil, teclado virtual o teclado externo.

## 3. Pantalla táctil Silead

El táctil necesitó calibración y adaptación. La primera solución aplicó una matriz de transformación mediante `xinput`. Después se desarrolló `silead-touchpad-relativo.py` y su unidad systemd para disponer también de un modo de puntero relativo.

El desarrollo no fue lineal. Se probaron sucesivamente variantes relacionadas con:

- zona muerta;
- inversión de ejes según orientación;
- espera de la sesión X11;
- filtrado y antivibración;
- acumulación del movimiento;
- protección del clic;
- interacción con dos dedos;
- movimiento más fluido.

Los nombres de las copias `antes-*` y `backup-*` conservadas en la tablet sirven como registro de esas iteraciones, pero no implican que cada variante haya sido exitosa.

Estado actual: el dispositivo físico `silead_ts` funciona en X11 y existe además un dispositivo virtual de puntero relativo generado mediante uinput.

## 4. Wi-Fi RTL8723BS

El módulo combinado RTL8723BS no quedaba operativo solamente cargando el controlador. Fue necesario reproducir una secuencia de alimentación/GPIO específica de esta placa.

Durante el diagnóstico se probaron distintas secuencias sobre PL4, PL6 y PL8. La solución quedó dividida en:

- `iniciar-wifi-rtl8723bs.service`;
- `/usr/local/sbin/iniciar-wifi-rtl8723bs`;
- `/usr/local/sbin/pulso-pl8`;
- herramientas auxiliares de diagnóstico y lectura de registros.

El procedimiento realiza el reprobe de MMC1 y la secuencia necesaria para que aparezca la interfaz inalámbrica.

Resultado confirmado: el módulo `r8723bs` está cargado y `wlan0` funciona. No se publican direcciones IP, MAC ni credenciales Wi-Fi.

## 5. Bluetooth RTL8723BS: etapa inicial

Bluetooth comparte el chip con Wi-Fi y utiliza UART/H5. Se inspeccionaron el nodo Device Tree, `max-speed`, `uart-has-rtscts` y las señales relacionadas con enable/wake. También se compararon variantes de firmware y configuración RTL8723B/BS.

Se probaron reinicios del dispositivo UART mediante unbind/bind, reinicio de BlueZ, cambios de velocidad y configuración RTS/CTS. De ese trabajo surgieron:

- `/usr/local/sbin/reiniciar-bluetooth-rtl8723bs`;
- `reiniciar-bluetooth-rtl8723bs.service`, ejecutado después de la inicialización del Wi-Fi.

En esta primera etapa el controlador podía aparecer encendido, pero los escaneos BR/EDR y LE no eran confiables. Hubo pruebas bloqueadas y momentos en que `bluetoothctl` informó `Pairable: no`.

Este resultado histórico se conserva porque explica por qué la documentación inicial describía Bluetooth como parcial.

## 6. Audio y volumen

Se creó el overlay de usuario `a33-audio.dtbo`. También se conservó una versión anterior al ajuste `hpcom`.

Para el uso cotidiano se agregaron scripts mínimos para subir, bajar y silenciar volumen. La tarjeta detectada actualmente corresponde al audio integrado del A33 (`sun8i-a33-audio`).

Resultado confirmado: audio detectado e integrado con los controles de la interfaz.

## 7. Navegación y multimedia

Dillo fue elegido inicialmente por su bajo consumo. Para video se creó `abrir-en-mpv`, con variantes orientadas a reducir la carga de CPU y memoria en este hardware limitado.

También se experimentó posteriormente con Chromium en modos de pantalla completa/kiosco y con aplicaciones multimedia propias. La reproducción y navegación web modernas siguen condicionadas por los aproximadamente 457 MiB de RAM y por la capacidad del Cortex-A7.

La presencia del módulo `sunxi_cedrus` se ha confirmado, pero eso por sí solo no demuestra que toda la reproducción multimedia esté usando aceleración por hardware. Esa capacidad debe verificarse por separado antes de marcarla como funcional.

## 8. Personalización de IceWM

Se configuraron fondo, iconos, terminal predeterminada, menú, accesos rápidos, batería, temperatura y otros indicadores. Las numerosas copias `antes-*` conservadas localmente documentan la evolución del escritorio.

IceWM continúa siendo la base liviana de la sesión, aunque posteriormente Q8 Shell pasó a ser la interfaz principal visible.

## 9. Respaldo y publicación

El proyecto se respaldó en varias capas:

- configuración del sistema e inventarios;
- configuración del escritorio del usuario;
- recursos externos utilizados por la sesión;
- imagen completa, sector por sector, de la microSD.

La imagen completa se creó el 8 de agosto de 2026 leyendo los 62.723.719.168 bytes del dispositivo de origen, comprimiéndolos con gzip y verificando tanto el CRC como el tamaño descomprimido.

Archivo local: `imagen-completa-armbian-q8-a33-64gb.img.gz`  
SHA-256: `8906f362b0e77c543fab9893a606003211bc68887037675bee808948e6a42fd4`

GitHub conserva documentación, configuraciones y huellas útiles para reproducir el trabajo. La imagen completa, firmware de terceros, datos personales y otros recursos que no corresponde redistribuir permanecen fuera del repositorio público.

## 10. Pantalla 1024×600 y overlays actuales

Con la evolución del proyecto, `armbianEnv.txt` dejó de cargar solamente el overlay de audio. El estado verificado el 03/09/2026 utiliza:

```text
user_overlays=a33-audio q8-panel-1024x600 a33-stk8312 a33-twi2-camaras a33-gc0308-csi
```

Los overlays activos son:

- `a33-audio.dtbo`: audio;
- `q8-panel-1024x600.dtbo`: panel específico 1024×600;
- `a33-stk8312.dtbo`: acelerómetro;
- `a33-twi2-camaras.dtbo`: bus utilizado durante el trabajo con cámaras;
- `a33-gc0308-csi.dtbo`: integración GC0308/CSI.

Se mantienen localmente variantes anteriores de varios overlays para diagnóstico. El repositorio público debe priorizar las versiones reproducibles actuales y documentar las variantes relevantes en lugar de publicar indiscriminadamente todas las copias de trabajo.

## 11. Entretenimiento y pruebas de software

Uno de los objetivos prácticos de la Q8 es convertirla en un dispositivo portátil de entretenimiento aprovechando software compatible con ARMv7 y programas antiguos de bajo consumo.

Se incorporaron y probaron, entre otros:

- DOSBox con lanzadores individuales para juegos DOS;
- un visor propio de controles para esos juegos;
- ScummVM y accesos a aventuras compatibles;
- Chromium en modo aplicación/kiosco para pruebas web;
- Xash3D FWGS para experimentar con Counter-Strike/Half-Life;
- pruebas con FreeAOE;
- aplicaciones multimedia como LTv/Open Media Center.

No todas las pruebas fueron exitosas. En particular, Counter-Strike 1.6 mediante Xash3D llegó a sufrir un `signal 11`, problemas de underrun ALSA y presión de memoria. Esos resultados se conservan como experimentales y no se presentan como soporte estable.

## 12. Acelerómetro STK8312

El acelerómetro fue identificado como STK8312 y se integró mediante `a33-stk8312.dtbo`.

El 03/09/2026 se verificó simultáneamente:

- módulo `stk8312` cargado;
- dispositivo IIO con nombre `stk8312`;
- servicio `orientar-fbcon-stk8312.service`;
- script `/usr/local/sbin/orientar-fbcon-stk8312`.

Durante el desarrollo hubo variantes relacionadas con autorrotación y orientación del táctil. La existencia de esas copias demuestra las pruebas realizadas, no que todas ellas fueran satisfactorias.

Estado actual: sensor detectado e integrado a nivel IIO; existe una solución específica para orientar fbcon. La autorrotación completa de todas las capas de la interfaz debe documentarse por separado cuando quede validada como comportamiento estable.

## 13. Cámara GC0308: identificación e integración

La cámara GC0308 requirió bastante más trabajo que un simple overlay. Se identificó el sensor en I²C y se trabajó sobre el camino completo hacia el controlador CSI del Allwinner A33.

El sistema actual carga:

- `gc0308`;
- `v4l2_cci`;
- `sun6i_csi`;
- infraestructura V4L2/media correspondiente.

El 03/09/2026 existen `/dev/media0`, `/dev/media1`, `/dev/video0`, `/dev/video1`, `/dev/v4l-subdev0` y `/dev/v4l-subdev1`.

El grafo de cámara identificado durante las pruebas enlaza el sensor GC0308 con `sun6i-csi-bridge` y finalmente con `sun6i-csi-capture`.

## 14. Cámara GC0308: experimentación

La integración de cámara pasó por numerosas variantes del overlay, entre ellas pruebas relacionadas con polaridad de PCLK/HSYNC, media-bus y DMA. También se realizaron ajustes experimentales en el controlador GC0308.

Se llegó a obtener una captura de prueba de 320×240 en UYVY. Sin embargo, las inspecciones posteriores mostraron que todavía puede existir desacuerdo entre el formato configurado en el sensor y el configurado en el bridge/capture.

Por ese motivo el estado se define deliberadamente como **funcional/experimental**: el sensor, los módulos y el pipeline aparecen y se consiguió captura, pero todavía no se considera una cámara de uso cotidiano completamente estabilizada.

## 15. Acceso remoto

Durante el proyecto se utilizó SSH de forma intensiva para administrar la tablet desde otra máquina. También se configuraron x11vnc y Tailscale para experimentar con acceso gráfico/remoto fuera de la red local.

Las direcciones LAN, direcciones Tailscale, direcciones MAC y otros identificadores privados se excluyen de la documentación pública.

## 16. Evolución posterior del táctil

A finales de agosto y comienzos de septiembre se retomó el comportamiento del modo relativo Silead. Se hicieron múltiples respaldos antes de cada modificación y se probaron filtros para reducir vibración y mejorar la sensación del puntero.

La versión actual debe considerarse la referencia operativa. Las versiones intermedias permanecen como respaldo local y como fuente para reconstruir el diagnóstico si aparece una regresión.

## 17. Q8 Shell

El 31 de agosto comenzó una etapa nueva de personalización: en lugar de depender visualmente del escritorio clásico de IceWM se desarrolló Q8 Shell, una interfaz propia en Python/GTK3 diseñada específicamente para 1024×600 y uso táctil.

Q8 Shell fue evolucionando mediante cambios pequeños y respaldados. Entre las funciones desarrolladas se encuentran:

- barra superior con estado de Wi-Fi y Bluetooth;
- volumen;
- batería;
- temperatura y clima;
- reloj y calendario;
- menú de energía;
- lanzadores grandes para juegos, multimedia, Internet, herramientas y sistema;
- barra inferior con Terminal y teclado virtual;
- fondo y estética propios de la Q8.

El archivo principal actual se encuentra en `~/.local/share/q8-shell/q8-shell.py`, mientras un lanzador en `~/.local/bin/q8-shell` lo integra con la sesión.

IceWM continúa debajo como gestor de ventanas liviano. Q8 Shell no reemplaza el sistema gráfico completo: proporciona la capa de interfaz diseñada para la tablet.

## 18. Bluetooth RTL8723BS: estado posterior

Las pruebas continuaron después de la primera documentación. Se conservaron nuevas copias del script de reinicio antes de modificaciones realizadas el 01/09/2026.

En la comprobación del 03/09/2026, `bluetoothctl show` informó:

```text
Powered: yes
Discoverable: yes
Pairable: yes
```

Esto corrige el estado antiguo donde `Pairable` podía aparecer desactivado. Sin embargo, estos tres indicadores no bastan para afirmar que cualquier periférico se descubre, empareja y reconecta de forma estable.

Estado actual documentable: **controlador Bluetooth inicializado, encendido, visible y emparejable a nivel BlueZ**. La estabilidad de emparejamiento/reconexión con periféricos concretos continúa siendo una prueba separada.

## 19. Memoria, zram y swap

La escasa RAM física condiciona todo el proyecto. El 03/09/2026 se verificaron aproximadamente 457 MiB de RAM y dos mecanismos de intercambio:

- zram de aproximadamente 229 MiB, con prioridad superior;
- `/swapfile-q8` de aproximadamente 1,33 GiB, con prioridad inferior.

En esa medición el swapfile estaba sin uso y zram contenía alrededor de 52 MiB. La combinación busca absorber picos de memoria sin convertir la microSD en la primera opción de intercambio.

El sistema también utiliza zram para `/var/log` en la configuración Armbian.

## 20. Q8 Armbian Slim

El 31 de agosto se separó conceptualmente un nuevo proyecto: adelgazar la instalación Armbian sin destruir el soporte de hardware conseguido durante las semanas anteriores.

El criterio acordado es conservador:

1. mantener una copia recuperable antes de adelgazar;
2. auditar paquetes, servicios, disco y RAM;
3. eliminar o deshabilitar componentes gradualmente;
4. verificar después de cada etapa;
5. preservar kernel, Device Tree, overlays, firmware y soporte del hardware funcional.

No se considera objetivo perseguir el menor número posible de paquetes a cualquier costo. La prioridad es una Q8 pequeña, rápida y recuperable.

## 21. Tienda Q8 — desarrollo inicial

A comienzos de septiembre comenzó Tienda Q8, una tienda de software liviana pensada para esta tablet. Utiliza APT como backend y una interfaz GTK3 adaptada a 1024×600, evitando incorporar infraestructuras pesadas como GNOME Software, Flatpak o Snap.

La arquitectura incluye:

- interfaz de usuario `tienda-q8`;
- helper privilegiado `/usr/local/sbin/tienda-q8-apt`;
- lista limitada de paquetes autorizados;
- protección explícita de paquetes críticos;
- registro de paquetes instalados mediante la tienda.

El helper y su política de sudo fueron sometidos a pruebas de autorización y rechazo de paquetes no permitidos. Estas pruebas no instalaron ni eliminaron paquetes durante la validación.

Esta fue la etapa inicial del componente. Su validación funcional posterior se
documenta en la sección 23.

## 22. Estado verificado — 03/09/2026

El 03/09/2026 se realizó un nuevo inventario directamente sobre la tablet en funcionamiento.

| Componente | Estado verificado |
|---|---|
| Arranque desde microSD | Funcional |
| Armbian/Debian armhf | Funcional |
| Kernel `6.12.100-legacy-sunxi` | En uso |
| Pantalla 1024×600 | Funcional |
| IceWM / sesión X11 | Funcional |
| Q8 Shell | En uso |
| Táctil Silead | Funcional; modo relativo disponible |
| Wi-Fi RTL8723BS | Funcional |
| Bluetooth RTL8723BS | Powered/Discoverable/Pairable; periféricos concretos requieren validación separada |
| Audio | Detectado e integrado mediante overlay |
| Batería/AXP20x | Detectada |
| STK8312 | Detectado en IIO; integración de orientación presente |
| GC0308 + CSI | Funcional/experimental |
| Cedrus | Módulo detectado; aceleración efectiva no afirmada sin prueba específica |
| zram | Activo |
| swapfile | Activo |
| Acceso SSH | Funcional |
| Tienda Q8 | Versión 1 funcional, validada e integrada con Q8 Shell |
| Imagen completa de respaldo | Creada y verificada previamente |

### Overlays activos

```text
user_overlays=a33-audio q8-panel-1024x600 a33-stk8312 a33-twi2-camaras a33-gc0308-csi
```

### Política de documentación pública

No se deben publicar en ejemplos o inventarios destinados a GitHub:

- UUID real de la partición raíz;
- direcciones IP privadas;
- dirección de Tailscale;
- direcciones MAC;
- contraseñas o PSK Wi-Fi;
- credenciales;
- firmware o recursos de terceros cuya redistribución no corresponda.

## Pendientes actuales

- validar emparejamiento y reconexión Bluetooth con periféricos concretos;
- estabilizar el formato completo del pipeline GC0308/CSI y probar captura repetible;
- comprobar de forma específica el uso real de Cedrus antes de documentar aceleración de vídeo;
- continuar Q8 Armbian Slim mediante cambios pequeños y reversibles;
- ampliar el catálogo de Tienda Q8 solamente después de nuevas simulaciones y pruebas;
- validar una restauración completa de la imagen sobre otra microSD de igual o mayor capacidad;
- actualizar el resto de la documentación y los archivos reproducibles del repositorio para que reflejen este estado.

## 23. Tienda Q8 v1 validada — 03/09/2026

Tienda Q8 completó su primera prueba funcional sobre la Q8-A33. El ayudante APT
restringido fue corregido después de detectar que una simulación segura se
interpretaba erróneamente como una actualización de paquetes existentes.

La validación final incluyó:

- rechazo de paquetes fuera del catálogo;
- protección de aplicaciones que forman parte del entorno Q8;
- instalación real de `ace-of-penguins` sin actualizaciones ni eliminaciones
  laterales;
- desinstalación posterior afectando solamente al paquete de prueba;
- actualización de índices APT sin actualización del sistema;
- comparación del inventario de `dpkg` antes y después de la prueba;
- integración de un acceso **Tienda Q8** en el menú lateral de Q8 Shell;
- conservación de los accesos inferiores de Terminal y Teclado;
- apertura correcta desde Q8 Shell y control de instancia única.

El código, el ayudante, la plantilla `sudoers`, las instrucciones y las capturas
se publican en [`armbian-q8-a33/tienda-q8/`](../tienda-q8/README.md).

La versión 1 sigue siendo específica de la instalación documentada. El catálogo
y las protecciones deben revisarse antes de adaptarla a otro sistema.
