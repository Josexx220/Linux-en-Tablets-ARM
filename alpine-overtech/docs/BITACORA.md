# Bitácora del proyecto Alpine en Overtech TAB-OV721

## Propósito

Esta bitácora describe cómo se agregó un entorno Linux de escritorio a una tablet Android antigua sin reemplazar Android ni su kernel. Registra la arquitectura, las pruebas realizadas y el estado final respaldado.

## Equipo y sistema final

- Tablet: Overtech TAB-OV721 / dispositivo `astar-m739`.
- Android: 4.4.2 KitKat, con acceso root.
- Hardware: Allwinner `sun8i`, ARMv7.
- Kernel anfitrión: Android Linux 3.4.39.
- Memoria: aproximadamente 508 MiB; swap Android de 384 MiB.
- Alpine: 3.20.3 ARMv7.
- Rootfs: `/data/local/linux/rootfs-jwm`.
- Interfaz gráfica: XSDL en Android, IceWM y PCManFM en Alpine.

## 1. Decisión de arquitectura

Se descartó inicialmente reemplazar Android. Hacerlo habría exigido resolver desde Linux todos los controladores de pantalla, táctil, sonido, Wi-Fi, Bluetooth, batería y botones físicos.

Se eligió un chroot: Alpine ve su propio sistema de archivos, pero comparte el kernel de Android. No es una máquina virtual y no emula otro procesador.

La división final fue:

- Android administra hardware, pantalla, audio y reproducción multimedia;
- Alpine aporta escritorio, herramientas y aplicaciones Linux;
- XSDL muestra las ventanas X11 en Android;
- `am start` entrega contenidos desde Alpine a aplicaciones Android.

Esta decisión fue la base de todo el proyecto.

## 2. Instalación de Alpine

Se identificó `armeabi-v7a`, por lo que se descargó Alpine minirootfs ARMv7 3.20.3. El rootfs se extrajo en `/data/local/linux/rootfs-jwm` y se configuraron repositorios `main` y `community` de la misma rama.

Se prepararon DNS, certificados y zona horaria de San Juan. El inventario final contiene 558 paquetes. Entre los principales quedaron IceWM, PCManFM, LXTerminal, Dillo, Dunst, YAD, FLTK, mpv y, al final del trabajo de respaldo, OpenSSH Server.

Resultado confirmado: Alpine ejecuta binarios ARMv7 y accede a Internet utilizando la red administrada por Android.

## 3. Montajes del chroot

El script `mount-alpine.sh` comparte con Alpine los recursos indispensables del kernel y de Android. A lo largo de las pruebas se corrigieron especialmente `/dev/pts` y los directorios Android visibles desde el chroot.

Los scripts externos al rootfs quedaron en `/data/local/linux` y se respaldaron por separado:

- `start-alpine.sh`;
- `mount-alpine.sh`;
- `auto-start.sh`;
- `open-wifi.sh`;
- `open-bluetooth.sh`;
- variantes históricas de i3, JWM y del inicio automático.

Resultado confirmado: el chroot dispone de `/proc`, `/sys`, `/dev`, terminales y acceso a almacenamiento compartido cuando se ejecuta la secuencia de montaje.

## 4. Evolución del arranque gráfico

Se probaron configuraciones con i3 y JWM antes de consolidar IceWM. Las copias históricas `auto-start-*` registran cambios de idioma, `/dev/pts`, usuario y apertura de Wi-Fi/Bluetooth.

El arranque final sigue este orden:

1. Android y XSDL están activos;
2. se realizan los montajes;
3. se entra al chroot;
4. se exportan `DISPLAY`, `HOME`, rutas e idioma;
5. se configura teclado latinoamericano;
6. arrancan IceWM, PCManFM y las utilidades de sesión.

Resultado confirmado: escritorio Linux visible y manejable en la pantalla de Android sin sustituir el sistema anfitrión.

## 5. IceWM adaptado a una tablet

IceWM fue elegido por el límite de memoria. Se personalizaron menú, barra, inicio, tema JoseXP, fuentes grandes y accesos táctiles. PCManFM administra escritorio e iconos; LXTerminal ofrece terminal local.

Se agregaron accesos a Archivos, Terminal, Wi-Fi, Bluetooth, IPTV Center, Open Media Center, flstream y José IA. Dunst ofrece notificaciones livianas.

También se desarrolló `temperatura-panel.sh`, basado en YAD y Open-Meteo para San Juan. El objetivo fue mostrar información sin instalar un entorno de escritorio completo.

## 6. Dillo y la integración con Android

Dillo funciona como navegador liviano, pero no reproduce video web moderno. Su `dillorc` incorpora una acción externa que envía enlaces a `/usr/local/bin/yt360`.

`yt360` usa yt-dlp para obtener una URL de calidad moderada y luego llama a Android mediante `am start`. VLC Android realiza la decodificación y el sonido.

Esta separación evita exigirle al chroot y a XSDL una tarea multimedia demasiado pesada para 512 MiB.

Resultado confirmado: la acción “Abrir video en VLC” funcionó. Su continuidad depende de que yt-dlp siga siendo compatible con los cambios de los sitios.

## 7. IPTV Center

Se creó una aplicación propia con FLTK para listar canales y entregar su URL a VLC Android. Los componentes incluyeron código fuente C++, Makefile, script de instalación, `iptv-play`, lanzadores e iconos.

El flujo final es:

1. el usuario elige un canal en IPTV Center;
2. `iptv-play` recibe la URL;
3. Android abre la URL;
4. VLC reproduce el stream.

Las listas M3U personales y sus direcciones no se publicaron en este repositorio. Permanecen únicamente en el respaldo local.

## 8. Open Media Center

Open Media Center evolucionó por varias versiones experimentales. Se conservaron ramas 0.3, 0.4 y desarrollo 0.5, además de módulos de diagnóstico, favoritos, historial, YouTube, IPTV, radios y reproducción.

La aplicación separa interfaz, configuración, biblioteca, reproducción y módulos. Se probaron direcciones directas, radios, listas IPTV y entrega de video a VLC Android.

Los historiales, favoritos y playlists fueron excluidos de GitHub por privacidad y por la naturaleza cambiante o potencialmente restringida de sus enlaces.

Estado: aplicación y fuentes respaldadas; la validez de cada servicio o stream debe comprobarse en el momento de uso.

## 9. flstream

Se probó una aplicación FLTK llamada `flstream`. Big Buck Bunny confirmó que la red, FLTK y el camino multimedia funcionaban. Después se trabajó con lanzadores y catálogos experimentales.

Se conservaron código fuente, paquete de trabajo e integración gráfica. El binario compilado quedó excluido de GitHub porque puede reconstruirse desde las fuentes y permanece en el respaldo completo.

## 10. José IA

Se creó un lanzador `jose-ia` basado en `tgpt`, con icono y un perfil personal. Distintos proveedores externos pueden dejar de responder o cambiar su API; durante las pruebas uno devolvió HTTP 404.

El perfil personal fue excluido deliberadamente de GitHub. La integración se conserva, pero no se considera un servicio autónomo ni garantizado.

## 11. Emulación y otras pruebas

Se instalaron o probaron herramientas como RetroArch, InfoNES y utilidades ligeras. EmuCenter fue creado como experimento y luego eliminado del sistema activo. Estas pruebas mostraron qué aplicaciones podían funcionar, pero no todas forman parte del resultado estable.

La prioridad del proyecto siguió siendo escritorio liviano, archivos, terminal e integración con aplicaciones Android.

## 12. Acceso SSH para el respaldo

El chroot inicialmente no tenía servidor SSH. Se instaló OpenSSH Server, se generaron host keys y se creó una clave Ed25519 dedicada en la notebook. El primer intento falló por una ruta duplicada (`root/root/.ssh`) y porque no existían claves del servidor. Luego se corrigió `/root/.ssh/authorized_keys`, se ejecutó `ssh-keygen -A` y se inició `sshd`.

Resultado confirmado: acceso como `root` por SSH con clave dedicada. Las claves privadas, `authorized_keys` y host keys se excluyeron de GitHub y del archivo público de configuración.

## 13. Respaldo

El rootfs se transmitió por SSH hacia la notebook y se comprimió sin incluir claves SSH, cachés, papelera, registros temporales ni montajes de Android.

Archivo local: `rootfs-alpine-overtech-3.20.3-armv7.tar.gz`  
Tamaño aproximado: 916 MiB  
SHA-256: `f45e7b6a8a6a01c17c857716ba49f08853597fae1e7c7b69985ff6edc5b871cd`

Los scripts externos a `/data/local/linux/rootfs-jwm` se copiaron mediante ADB y se incorporaron como archivos legibles al repositorio.

## Estado al cerrar esta bitácora

| Componente | Estado |
|---|---|
| Android 4.4.2 | Conservado y funcional |
| Alpine 3.20.3 ARMv7 | Funcional en chroot |
| XSDL + IceWM | Funcional |
| Teclado latinoamericano | Configurado |
| Dillo | Funcional para navegación liviana |
| Dillo → yt-dlp → VLC Android | Confirmado, dependiente de servicios externos |
| IPTV Center | Aplicación y fuentes respaldadas |
| Open Media Center | Aplicación y fuentes respaldadas |
| flstream | Prueba funcional y fuentes respaldadas |
| José IA | Integración experimental, proveedor variable |
| SSH | Instalado para administración y respaldo |
| Rootfs respaldado | Integridad verificada |

## Limitaciones y pendientes

- Alpine depende del kernel 3.4.39 y del Android anfitrión.
- XSDL debe estar activo para mostrar el escritorio.
- Android puede cerrar procesos cuando falta memoria.
- Video y sonido funcionan mejor delegados a Android.
- yt-dlp, proveedores de IA y streams requieren mantenimiento.
- Una restauración debe rehacer montajes, permisos y arranque externo además de extraer el rootfs.
