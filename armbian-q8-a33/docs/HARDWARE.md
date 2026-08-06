# Hardware y sistema

| Elemento | Valor observado |
|---|---|
| Modelo DT | Q8 A33 Tablet |
| SoC | Allwinner A33 / `sun8i` |
| CPU | 4 × Cortex-A7, 120–1008 MHz |
| RAM visible | 457 MiB |
| Almacenamiento | microSD 58,4 GiB; ext4 `armbi_root` |
| Raíz | `/dev/mmcblk0p1` |
| Wi-Fi/Bluetooth | Realtek RTL8723BS |
| Táctil | Silead (`silead_ts`) |
| Device Tree | `allwinner/sun8i-a33-q8-tablet.dtb` |
| Overlay propio | `/boot/overlay-user/a33-audio.dtbo` |

La instalación usa zram para swap y `/var/log`. El inventario exacto se conserva en `inventario/`.
