# Q8 Shell

Q8 Shell es una interfaz gráfica ligera desarrollada específicamente para utilizar la Q8-A33 como tablet Linux de entretenimiento. Se ejecuta sobre el entorno X11 existente y complementa la base IceWM/PCManFM en lugar de reemplazar el sistema Linux subyacente.

## Objetivo

Con sólo unos 457 MiB de RAM, el proyecto evita escritorios completos y prioriza botones grandes, información visible y acceso directo a las funciones que tienen sentido en una pantalla 1024×600.

La implementación principal está en:

```text
~/.local/share/q8-shell/q8-shell.py
```

y existe un lanzador en:

```text
~/.local/bin/q8-shell
```

## Tecnología

- Python 3;
- GTK 3;
- X11;
- integración con scripts y aplicaciones existentes del sistema.

La ventana principal está implementada por la clase `Q8Shell`.

## Diseño

La interfaz utiliza un tema oscuro con acento naranja, tipografía DejaVu Sans y controles dimensionados para uso táctil.

La pantalla se organiza alrededor de una barra superior de estado, un área de lanzadores y una barra inferior de acceso rápido.

### Barra superior

Integra información/controles para:

- Wi-Fi;
- Bluetooth;
- volumen;
- batería;
- temperatura;
- reloj;
- apagado.

### Lanzadores

El entorno ofrece acceso a categorías y aplicaciones como:

- archivos;
- juegos;
- juegos DOS;
- multimedia;
- Internet;
- herramientas;
- terminal;
- controles de volumen.

### Barra inferior

Se mantienen accesos directos visibles a:

```text
Terminal
Teclado
```

Son especialmente importantes en una tablet Linux porque permiten recuperar rápidamente una consola o el teclado en pantalla.

## Evolución

Q8 Shell fue desarrollado mediante numerosas iteraciones conservadas localmente. Hubo ajustes sucesivos sobre:

- tamaños de lanzadores;
- iconos;
- barra superior;
- barra inferior;
- panel de energía;
- estado Wi-Fi y Bluetooth;
- volumen;
- batería;
- calendario;
- temperatura/clima;
- conexión Wi-Fi;
- adaptación a 1024×600.

Los snapshots de desarrollo son útiles para reconstruir decisiones, pero el repositorio público debe priorizar la versión activa y no convertirse en un depósito de todas las copias temporales.

## Relación con IceWM

IceWM sigue siendo una pieza importante del sistema y conserva configuración histórica, menús, preferencias y mecanismos de inicio. Q8 Shell representa la evolución hacia una experiencia más parecida a una interfaz de tablet.

Por eso la documentación distingue:

```text
base gráfica ligera: X11 + IceWM/PCManFM
interfaz principal actual: Q8 Shell
```

## Integración con aplicaciones

Q8 Shell no intenta reimplementar las aplicaciones. Lanza herramientas ya instaladas y scripts adaptados a la Q8. Esto mantiene la interfaz pequeña y permite sustituir una aplicación sin rediseñar todo el shell.

Entre los componentes integrados durante el proyecto se encuentran Dillo, Chromium, Open Media Center, LTv, DOSBox, terminal y utilidades propias.

La existencia de un lanzador no implica que cada juego o aplicación tenga rendimiento perfecto en el hardware A33.

## Tienda Q8

Existe además una tienda de software ligera llamada [**Tienda Q8**](../tienda-q8/README.md). Está diseñada alrededor de APT y una lista controlada de paquetes `armhf`, con una interfaz adecuada para 1024×600.

La versión 1 fue validada el 03/09/2026 mediante instalación, desinstalación y actualización de índices APT. También quedó integrada como acceso lateral de Q8 Shell.

Su diseño evita GNOME Software, Flatpak y Snap para mantener bajo el consumo de recursos y utiliza un helper privilegiado restringido para las operaciones APT autorizadas.

## Filosofía

Q8 Shell sigue cuatro principios:

1. bajo consumo de RAM;
2. controles grandes y simples;
3. conservar acceso directo a herramientas Linux normales;
4. no ocultar las limitaciones reales del hardware.

## Estado público recomendado

**Q8 Shell es una interfaz GTK3 ligera y funcional diseñada para la pantalla táctil 1024×600 de esta Q8-A33. Integra estado del sistema, lanzadores y controles cotidianos sobre una base X11/IceWM. Tienda Q8 v1 está integrada y validada.**
