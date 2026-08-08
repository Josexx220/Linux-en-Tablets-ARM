# Bitácora del proyecto Armbian Q8-A33

## Propósito

Esta bitácora registra el trabajo realizado para convertir una tablet Q8 basada en Allwinner A33 en un equipo Linux autónomo. No reemplaza las guías de restauración: conserva el camino seguido, las pruebas, los problemas y el estado real alcanzado.

## Equipo y sistema final

- Placa: Q8 A33 Tablet, pantalla 1024×600.
- SoC: Allwinner A33 (`sun8i`), cuatro núcleos Cortex-A7 ARMv7.
- Memoria utilizable: aproximadamente 457 MiB.
- Medio de arranque: microSD de 64 GB.
- Sistema: Armbian no oficial 26.08.0-trunk, Debian 12 Bookworm.
- Kernel conservado: `6.12.100-legacy-sunxi`.
- Escritorio: IceWM, PCManFM y LXTerminal.
- Device Tree: `allwinner/sun8i-a33-q8-tablet.dtb`.

## 1. Arranque desde microSD

La instalación se construyó como una imagen específica para la Q8-A33. El sistema usa una única partición ext4 etiquetada `armbi_root`, cuyo UUID quedó fijado en `armbianEnv.txt`.

La configuración final selecciona el Device Tree de la tablet, el prefijo de overlays `sun8i-a33` y el overlay de audio `a33-audio`. Se conservaron copias anteriores de archivos de arranque para poder comparar cambios.

Resultado confirmado: la tablet inicia Armbian directamente desde la microSD y utiliza esa misma partición como raíz.

## 2. Escritorio liviano

Con menos de 512 MiB de RAM se descartaron escritorios pesados. Se instaló IceWM como gestor de ventanas, PCManFM para archivos y escritorio, y LXTerminal para administración local.

El archivo `.xinitrc` realiza tres ajustes esenciales antes de abrir la sesión:

1. desactiva el protector y DPMS;
2. configura el teclado latinoamericano;
3. aplica la matriz de transformación del táctil Silead.

La barra de IceWM quedó con accesos a Archivos, LXTerminal, Dillo, configuración Wi-Fi y controles de volumen. También muestra red y batería. Onboard se inicia solamente cuando no se detecta teclado externo.

Resultado confirmado: sesión gráfica funcional y utilizable con pantalla táctil, teclado virtual o teclado externo.

## 3. Pantalla táctil Silead

El táctil necesitó calibración y adaptación. La primera solución aplicó una matriz de transformación mediante `xinput` dentro de `.xinitrc`. Además se desarrolló `silead-touchpad-relativo.py` y su unidad systemd para disponer de un modo de puntero relativo, con copias previas antes de ajustar la zona muerta.

Se conservaron:

- script final;
- versión anterior a la zona muerta;
- unidad `silead-touchpad-relativo.service`;
- matriz aplicada al dispositivo `silead_ts`.

Resultado confirmado: el dispositivo es detectado y puede usarse en la sesión X. La calibración depende de la orientación y de la matriz guardada.

## 4. Wi-Fi RTL8723BS

El módulo combinado RTL8723BS no quedaba operativo solamente cargando el controlador. Fue necesario reproducir una secuencia de alimentación y GPIO propia de la placa.

Durante el diagnóstico se probaron distintas secuencias sobre PL4, PL6 y PL8. Se conservaron scripts anteriores para documentar esas variantes. La solución final quedó dividida en:

- `iniciar-wifi-rtl8723bs.service`;
- `/usr/local/sbin/iniciar-wifi-rtl8723bs`;
- `/usr/local/sbin/pulso-pl8`;
- herramientas para leer registros y guardar diagnóstico.

El servicio se ejecuta antes de `wpa_supplicant`, la red y `network-online.target`. También se creó `mostrar-ip.service` para mostrar la dirección obtenida en `tty1`.

Resultado confirmado: `wlan0` inicia y obtiene conexión. En el inventario del respaldo quedó registrada la dirección local que tenía al documentar el sistema, pero no se guardaron contraseñas Wi-Fi.

## 5. Bluetooth RTL8723BS

Bluetooth comparte el chip con Wi-Fi y utiliza UART/H5. Se inspeccionaron el nodo Device Tree, `max-speed`, `uart-has-rtscts` y las señales enable, host-wake y device-wake. También se compararon variantes de firmware y configuración RTL8723B/BS.

Se probaron reinicios del dispositivo UART mediante unbind/bind, reinicio de `bluetooth.service`, cambios de velocidad y configuración RTS/CTS. Finalmente se creó:

- `/usr/local/sbin/reiniciar-bluetooth-rtl8723bs`;
- `reiniciar-bluetooth-rtl8723bs.service`, ejecutado después del servicio de Wi-Fi.

El controlador llegó a aparecer encendido, conectable, visible y bondable. Sin embargo, los escaneos BR/EDR y LE no dieron un resultado estable; algunas pruebas con `btmgmt find -b` quedaron bloqueadas y `bluetoothctl` llegó a informar `Pairable: no`.

Estado real: inicialización parcial confirmada; descubrimiento y emparejamiento confiables siguen pendientes. No debe documentarse Bluetooth como completamente resuelto.

## 6. Audio y volumen

Se creó un overlay de usuario `a33-audio.dtbo` y se activó con `user_overlays=a33-audio`. También se conservó una versión anterior al ajuste `hpcom`.

Para el uso cotidiano se agregaron tres scripts mínimos: subir volumen, bajar volumen y silenciar. IceWM los invoca desde botones con iconos grandes.

Resultado confirmado: integración del control de volumen en el escritorio. La configuración exacta de codec y rutas depende del overlay incluido en el respaldo.

## 7. Navegación y multimedia

Dillo fue elegido por su bajo consumo. Para video se creó `abrir-en-mpv`, llamado desde Dillo. El script convierte enlaces de s60Tube en enlaces de YouTube y ejecuta mpv con opciones orientadas a este hardware:

- calidad preferida de 240p o 360p;
- descarte de cuadros;
- decodificación rápida;
- filtros reducidos;
- caché limitada.

Se conservó la versión anterior a la optimización para comparar comportamiento.

Resultado: navegación liviana y reproducción externa posible, condicionada por la vigencia de los enlaces, yt-dlp y la carga de CPU.

## 8. Personalización de IceWM

Se configuraron fondo escalado, iconos de 24/32 píxeles, terminal predeterminada, menú dinámico, accesos rápidos y texto de batería. Varias copias `antes-*` registran pruebas con iconos y representación de batería.

El fondo personal y los binarios recuperables de Dillo quedaron fuera de GitHub, pero permanecen en los respaldos locales.

## 9. Respaldo y publicación

El proyecto se respaldó en varias capas:

- configuración del sistema e inventarios;
- configuración del escritorio de `jose`;
- recursos externos utilizados por la sesión;
- imagen completa, sector por sector, de la microSD.

La imagen completa se creó el 8 de agosto de 2026 leyendo los 62.723.719.168 bytes de `/dev/sdd`, comprimiéndolos con gzip y verificando tanto el CRC como el tamaño descomprimido.

Archivo local: `imagen-completa-armbian-q8-a33-64gb.img.gz`  
SHA-256: `8906f362b0e77c543fab9893a606003211bc68887037675bee808948e6a42fd4`

GitHub conserva documentación, configuraciones y huellas. La imagen, firmware de terceros, datos personales y binarios recuperables permanecen únicamente en el respaldo local.

## Estado al cerrar esta bitácora

| Componente | Estado |
|---|---|
| Arranque desde microSD | Funcional |
| Debian/Armbian | Funcional |
| IceWM y PCManFM | Funcional |
| Wi-Fi RTL8723BS | Funcional |
| Táctil Silead | Funcional con configuración guardada |
| Audio y volumen | Integrados mediante overlay y scripts |
| Bluetooth | Inicialización parcial; escaneo/emparejamiento pendientes |
| Respaldo de configuraciones | Verificado |
| Imagen completa de microSD | Verificada |

## Pendientes

- estabilizar el escaneo y emparejamiento Bluetooth;
- validar restauración de la imagen completa sobre otra microSD de igual o mayor capacidad;
- seguir midiendo consumo y rendimiento multimedia sin alterar la copia estable.
