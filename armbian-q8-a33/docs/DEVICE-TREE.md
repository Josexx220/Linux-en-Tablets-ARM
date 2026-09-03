# Device Tree y overlays de la Q8-A33

Este documento describe la configuración de Device Tree verificada en la Q8-A33. Los overlays son específicos de esta variante de hardware y no deben aplicarse a otra tablet Q8 sin comparar previamente placa, periféricos y cableado.

## Configuración de arranque

La parte relevante de `/boot/armbianEnv.txt` es:

```text
verbosity=1
bootlogo=false
console=both
disp_mode=1920x1080p60
overlay_prefix=sun8i-a33
fdtfile=allwinner/sun8i-a33-q8-tablet.dtb
rootdev=UUID=<UUID-DE-LA-PARTICION-ROOT>
rootfstype=ext4
user_overlays=a33-audio q8-panel-1024x600 a33-stk8312 a33-twi2-camaras a33-gc0308-csi
```

El UUID real no se publica.

## DTB base

```text
allwinner/sun8i-a33-q8-tablet.dtb
```

El DTB proporciona la descripción base de la placa y los overlays añaden o ajustan componentes concretos descubiertos durante el bring-up.

## Overlays activos

| Overlay | Función | Estado |
|---|---|---|
| `a33-audio` | Audio A33 | Activo |
| `q8-panel-1024x600` | Panel LCD | Activo |
| `a33-stk8312` | Acelerómetro STK8312 | Activo |
| `a33-twi2-camaras` | Bus TWI/I²C de cámaras | Activo |
| `a33-gc0308-csi` | GC0308 y CSI | Activo/experimental |

Los binarios se encuentran en `/boot/overlay-user/` con extensión `.dtbo`.

## Qué no debe inferirse

Que un overlay cargue sin error no demuestra que el periférico esté completamente resuelto. Por ejemplo, el overlay de GC0308 permite construir el pipeline CSI, pero la negociación de formatos continúa en investigación.

Del mismo modo, estos overlays no son genéricos para cualquier tablet llamada Q8. Ese nombre comercial cubre múltiples revisiones de placa.

## Historial de experimentos

La tablet conserva copias anteriores de algunos overlays, especialmente los relacionados con GC0308. Sus nombres registran etapas como cambios de DMA, media-bus, PCLK y sincronización.

Esas copias son evidencia de trabajo experimental. Para publicación se priorizan la configuración activa y los archivos reproducibles; no se recomienda subir indiscriminadamente todas las variantes antiguas.

## Reglas de trabajo

1. conservar una copia del overlay activo antes de reemplazarlo;
2. modificar un subsistema por vez;
3. comprobar el arranque después de cada cambio;
4. verificar el periférico afectado y también posibles regresiones;
5. mantener una forma externa de editar la microSD;
6. no actualizar kernel/DTB/firmware de forma casual en una instalación estable.

## Privacidad

En ejemplos públicos debe utilizarse:

```text
rootdev=UUID=<UUID-DE-LA-PARTICION-ROOT>
```

y nunca el UUID real de la instalación.

## Relación con otros documentos

- `HARDWARE.md`: inventario general.
- `DISPLAY-TOUCH.md`: panel, Silead y STK8312.
- `AUDIO.md`: audio y overlay correspondiente.
- `CAMERA-GC0308.md`: overlays TWI/GC0308 y pipeline CSI.
- `BITACORA.md`: evolución cronológica y experimentos.
