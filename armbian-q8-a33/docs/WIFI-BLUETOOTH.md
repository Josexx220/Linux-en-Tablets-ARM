# Wi-Fi y Bluetooth RTL8723BS

La Q8-A33 utiliza un módulo combinado Realtek RTL8723BS. En esta placa, disponer del driver y del firmware no fue suficiente: Wi-Fi y Bluetooth necesitaron una secuencia de inicialización específica y coordinada.

Este documento describe el estado verificado del sistema y conserva las limitaciones conocidas. Los detalles cronológicos de pruebas y fallos se mantienen en `BITACORA.md`.

## Wi-Fi

### Problema original

Durante el bring-up, el kernel no obtenía `wlan0` de forma confiable sólo cargando el controlador. El RTL8723BS depende de señales de alimentación/GPIO de la placa y del controlador MMC1.

Se ensayaron distintas secuencias con PL4, PL6 y PL8. Algunas quedaron conservadas en la tablet como archivos `antes-*` para poder reconstruir el diagnóstico.

### Solución utilizada

La configuración actual se apoya principalmente en:

- `iniciar-wifi-rtl8723bs.service`;
- `/usr/local/sbin/iniciar-wifi-rtl8723bs`;
- `/usr/local/sbin/pulso-pl8`;
- `/usr/local/sbin/leer-registros-wifi`.

El procedimiento espera el momento apropiado del arranque, manipula las señales necesarias, desenlaza/re-enlaza `1c10000.mmc` y permite que el RTL8723BS vuelva a ser detectado.

La manipulación de PL4/PL6/PL8 mediante acceso de bajo nivel es específica de esta placa Q8-A33 y requiere privilegios de administrador. No debe copiarse a otra variante Q8 sin comprobar primero su Device Tree y cableado.

### Comprobación

```sh
sudo systemctl status iniciar-wifi-rtl8723bs.service
ip -br address show wlan0
iw dev wlan0 link
```

Estado actual: **Wi-Fi funcional**.

No se publican SSID privados, claves Wi-Fi, direcciones MAC ni direcciones IP del equipo.

## Bluetooth

### Arquitectura

Bluetooth comparte el RTL8723BS con Wi-Fi y utiliza UART/H5. Durante el diagnóstico se revisaron, entre otros puntos:

- el dispositivo UART;
- `max-speed`;
- RTS/CTS;
- señales de enable/wake;
- firmware y configuración RTL8723B/BS;
- orden de inicialización respecto de Wi-Fi.

La configuración utilizada conserva `rtl8723b_fw.bin` y `rtl8723b_config.bin` en el sistema. Las variantes experimentales no deben confundirse con los archivos activos.

### Reinicialización después de Wi-Fi

El estado actual utiliza:

- `/usr/local/sbin/reiniciar-bluetooth-rtl8723bs`;
- `reiniciar-bluetooth-rtl8723bs.service`.

El servicio se ejecuta después de la inicialización del Wi-Fi y reinicializa la ruta UART/H5 y BlueZ cuando corresponde.

Esta relación es importante: Wi-Fi y Bluetooth no se documentan como dos subsistemas completamente independientes porque comparten el mismo módulo físico y parte de la secuencia de encendido.

## Evolución del diagnóstico Bluetooth

En una etapa anterior el controlador podía aparecer encendido, pero el descubrimiento y emparejamiento eran inconsistentes. Se observaron, entre otros síntomas:

- `Pairable: no` en algunas pruebas;
- búsquedas BR/EDR o LE que no daban resultados confiables;
- comandos de búsqueda que podían quedar esperando;
- necesidad de reiniciar el dispositivo UART y BlueZ.

Esos resultados históricos siguen siendo válidos como registro de la evolución del port y no se eliminan de la bitácora.

### Estado verificado el 03/09/2026

Una comprobación posterior con `bluetoothctl show` devolvió:

```text
Name: q8-a33
Powered: yes
Discoverable: yes
Pairable: yes
```

Por lo tanto, la afirmación antigua de que `Pairable` seguía sin resolverse ya no describe el estado actual.

Estado actual: **controlador Bluetooth inicializado, encendido, visible y pairable**.

Sin embargo, esto no equivale todavía a afirmar compatibilidad estable con todos los periféricos. El emparejamiento, reconexión y uso prolongado deben validarse por dispositivo antes de marcar Bluetooth como completamente resuelto.

## Orden lógico de arranque

De forma simplificada, el sistema sigue esta relación:

```text
arranque del sistema
      |
      v
inicialización RTL8723BS / MMC1
      |
      v
Wi-Fi disponible
      |
      v
reinicialización Bluetooth UART/H5
      |
      v
BlueZ / controlador HCI
```

Este orden refleja el comportamiento de esta Q8 concreta y no pretende ser una receta universal para cualquier placa con RTL8723BS.

## Archivos importantes

| Archivo | Función |
|---|---|
| `iniciar-wifi-rtl8723bs.service` | Inicialización de Wi-Fi durante el arranque |
| `/usr/local/sbin/iniciar-wifi-rtl8723bs` | Lógica principal de inicialización Wi-Fi |
| `/usr/local/sbin/pulso-pl8` | Secuencia GPIO utilizada por la placa |
| `/usr/local/sbin/leer-registros-wifi` | Ayuda de diagnóstico |
| `reiniciar-bluetooth-rtl8723bs.service` | Ordena la reinicialización Bluetooth |
| `/usr/local/sbin/reiniciar-bluetooth-rtl8723bs` | Lógica de reinicio UART/H5/BlueZ |

## Qué falta validar

Para considerar Bluetooth completamente cerrado todavía conviene comprobar de forma reproducible:

1. descubrimiento BR/EDR y LE después de un arranque limpio;
2. emparejamiento con periféricos reales;
3. reconexión después de reiniciar la tablet;
4. coexistencia Wi-Fi + Bluetooth durante uso prolongado;
5. ausencia de regresiones después de cambios de kernel, firmware o Device Tree.

Hasta completar esas pruebas, la descripción pública recomendada es: **Wi-Fi funcional; Bluetooth inicializado, discoverable y pairable, con validación de periféricos todavía en curso**.
