# Registro de respaldos

## Armbian Q8-A33

| Archivo | Tamaño aproximado | SHA256 |
|---|---:|---|
| `resguardo-armbian-q8-a33.tar.gz` | 5,9 MB | `a4bcee010eafaef11c49ee6d64a959100a2eea138d89e7def90587e36283baa5` |
| `resguardo-escritorio-armbian-q8-a33.tar.gz` | 4,3 KB | `040fb908822f3496d22dd5571103ffe66f733f7af59a73323dece8f55557a41a` |
| `resguardo-recursos-armbian-q8-a33.tar.gz` | 380 KB | `e6f5225056d3da9d6e65f1b42d445a1fde39e7ec4cd1710038d43dd1804f1a35` |

La imagen completa de la microSD de 64 GB queda pendiente. Debe obtenerse con la tablet apagada y la tarjeta conectada directamente a la notebook.

## Alpine Overtech

| Archivo | Tamaño aproximado | SHA256 |
|---|---:|---|
| `rootfs-alpine-overtech-3.20.3-armv7.tar.gz` | 916 MB | `f45e7b6a8a6a01c17c857716ba49f08853597fae1e7c7b69985ff6edc5b871cd` |

El archivo excluye claves SSH, cachés, papelera, registros temporales y montajes de Android. Después de restaurar OpenSSH se regeneran las claves mediante `ssh-keygen -A`.

## Verificación

```sh
sha256sum -c SHA256SUMS
tar -tzf ARCHIVO.tar.gz >/dev/null
```
