# Wi-Fi y Bluetooth RTL8723BS

## Wi-Fi

En este hardware el kernel no obtenía siempre `wlan0` durante el primer intento. El servicio personalizado espera, desenlaza `1c10000.mmc`, ejecuta `pulso-pl8` y vuelve a enlazar MMC1.

La secuencia comprobada manipula PL4, PL6 y PL8 mediante `/dev/mem`. Es específica de esta placa y requiere privilegios root.

```sh
sudo systemctl status iniciar-wifi-rtl8723bs.service
ip -br address show wlan0
```

## Bluetooth

Bluetooth utiliza `hci_uart_h5` con el dispositivo `serial0-0`. El servicio lo desenlaza, vuelve a enlazar y reinicia BlueZ después de inicializar el Wi-Fi.

El firmware activo respaldado es `rtl8723b_fw.bin` junto con `rtl8723b_config.bin`. Se conservaron variantes de prueba para poder reproducir el diagnóstico.

Estado conocido: el controlador puede encenderse, pero `Pairable` y el escaneo BR/EDR no quedaron resueltos de forma estable. No debe presentarse como una función terminada.
