# Integración de Tienda Q8 con Q8 Shell

La integración validada añade un único acceso al menú lateral de Q8 Shell. La
tienda continúa como proceso separado y el lanzador evita abrir más de una
instancia.

## 1. Crear un respaldo

```bash
Q8="$HOME/.local/share/q8-shell/q8-shell.py"
cp -a "$Q8" "$Q8.backup-tienda-$(date +%Y%m%d-%H%M%S)"
```

## 2. Añadir el elemento del menú

En la lista `items`, entre **Herramientas** y **Sistema**, agregar:

```python
(
    "Tienda Q8",
    "/usr/share/icons/Adwaita/48x48/legacy/system-software-install.png",
    self.open_store
),
```

## 3. Añadir la función de apertura

Junto a las funciones `open_tools` y `open_system`, agregar:

```python
def open_store(self, *_):
    run("$HOME/.local/bin/tienda-q8")
```

`run()` ejecuta comandos mediante el shell, por lo que `$HOME` se expande al
directorio personal de la sesión gráfica.

## 4. Validar antes de reiniciar

```bash
python3 - "$HOME/.local/share/q8-shell/q8-shell.py" <<'PY'
import ast
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
print("Sintaxis de Q8 Shell: OK")
PY
```

También conviene comprobar que los accesos inferiores continúen presentes:

```bash
grep -n 'Gtk.Button(label="▣ Terminal")' \
  "$HOME/.local/share/q8-shell/q8-shell.py"
grep -n 'Gtk.Button(label="⌨ Teclado")' \
  "$HOME/.local/share/q8-shell/q8-shell.py"
```

## Resultado probado

El 03/09/2026 Q8 Shell fue reiniciado con esta modificación. El acceso lateral
abrió Tienda Q8 correctamente y Terminal y Teclado permanecieron sin cambios.
