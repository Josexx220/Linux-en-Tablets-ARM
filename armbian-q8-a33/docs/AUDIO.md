# Audio de la Q8-A33

La Q8-A33 utiliza el subsistema de audio del Allwinner A33. En el sistema verificado, ALSA detecta la tarjeta `sun8ia33audio` y la integración se completa mediante un overlay de usuario.

## Estado

| Elemento | Estado |
|---|---|
| Tarjeta ALSA | Detectada |
| `sun8i-a33-audio` | Integrado |
| Overlay `a33-audio` | Activo |
| Control de volumen | Integrado en la interfaz |
| Ajustes de rutas/codec | Específicos de esta placa |

## Identificación

La tarjeta observada es:

```text
card 0: sun8ia33audio
sun8i-a33-audio
```

La ruta DAI observada incluye `1c22c00.dai-sun8i-codec-aif1`.

## Overlay

`/boot/armbianEnv.txt` carga:

```text
user_overlays=a33-audio ...
```

Archivo activo:

```text
/boot/overlay-user/a33-audio.dtbo
```

Se conservó localmente una versión anterior denominada `a33-audio.dtbo.antes-hpcom`. Es un punto histórico de comparación, no la versión recomendada.

## Integración de usuario

Para evitar depender de una interfaz pesada se crearon utilidades pequeñas:

```text
/usr/local/bin/q8-volumen-subir
/usr/local/bin/q8-volumen-bajar
/usr/local/bin/q8-volumen-silenciar
```

Q8 Shell utiliza estas acciones para ofrecer controles táctiles de volumen. `alsamixer` continúa disponible para diagnóstico y ajuste manual.

## Comprobaciones

```sh
aplay -l
cat /proc/asound/cards
alsamixer
```

## Precauciones

Los cambios de Device Tree relacionados con codec, amplificador, auriculares o rutas analógicas son específicos de la placa. No se recomienda reutilizar el overlay en otra Q8 sólo por compartir el SoC A33.

Antes de reemplazar `a33-audio.dtbo` debe conservarse la versión activa conocida y mantenerse una vía de recuperación de la microSD.

## Estado público recomendado

**Audio Allwinner A33 funcional e integrado mediante `a33-audio.dtbo`, con controles de volumen adaptados a la interfaz táctil.**
