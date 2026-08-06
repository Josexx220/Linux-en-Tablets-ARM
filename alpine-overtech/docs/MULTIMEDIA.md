# Multimedia híbrida Alpine–Android

La reproducción dentro de XSDL era costosa y no aprovechaba correctamente el hardware. Por eso las aplicaciones Linux envían el contenido a Android.

## Dillo y YouTube

`dillorc` agrega la acción “Abrir video en VLC”. `yt360` normaliza enlaces compatibles, usa `yt-dlp` para obtener un MP4 combinado de hasta 360p y abre la URL mediante `am start`.

## IPTV Center

La interfaz está escrita en C++ con FLTK. `iptv-play` recibe una URL y la entrega a una aplicación Android capaz de reproducir `video/*`.

## Open Media Center

La versión activa es 0.4.0-alpha. El menú integra YouTube, Kick, IPTV, radios, historial, favoritos, configuración y diagnóstico. La carpeta `openmediacenter-v0.5-dev` conserva el trabajo de la siguiente arquitectura.

## Limitaciones

- YouTube y Kick pueden cambiar sus mecanismos y exigir actualizaciones.
- Las listas públicas pueden contener streams caídos o georrestringidos.
- El repositorio no debe redistribuir episodios, ROM ni contenido protegido.
- Los binarios ARM se conservan en el respaldo completo; Git prioriza fuentes y scripts.
