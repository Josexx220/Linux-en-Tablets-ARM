#!/system/bin/sh
echo '=== Alpine JWM autostart ===' > /data/local/linux/autostart.log
date >> /data/local/linux/autostart.log

sleep 15
am start -n x.org.server/.MainActivity >> /data/local/linux/autostart.log 2>&1

sleep 35

mkdir -p /data/local/linux/rootfs-jwm/dev
mkdir -p /data/local/linux/rootfs-jwm/proc
mkdir -p /data/local/linux/rootfs-jwm/sys
mkdir -p /data/local/linux/rootfs-jwm/system
mkdir -p /data/local/linux/rootfs-jwm/data

mount -o bind /dev /data/local/linux/rootfs-jwm/dev >> /data/local/linux/autostart.log 2>&1
mkdir -p /data/local/linux/rootfs-jwm/dev/pts
mount -t devpts -o mode=666 devpts /data/local/linux/rootfs-jwm/dev/pts >> /data/local/linux/autostart.log 2>&1
mount -t proc proc /data/local/linux/rootfs-jwm/proc >> /data/local/linux/autostart.log 2>&1
mount -t sysfs sysfs /data/local/linux/rootfs-jwm/sys >> /data/local/linux/autostart.log 2>&1
mount -o bind /system /data/local/linux/rootfs-jwm/system >> /data/local/linux/autostart.log 2>&1
mount -o bind /data /data/local/linux/rootfs-jwm/data >> /data/local/linux/autostart.log 2>&1

busybox chroot /data/local/linux/rootfs-jwm /bin/sh -c 'export PATH=/system/bin:/bin:/sbin:/usr/bin:/usr/sbin; export LANG=es_AR.UTF-8; export LANGUAGE=es_AR:es; export TZ=America/Argentina/San_Juan; export DISPLAY=:0; export HOME=/root; pcmanfm --desktop >/tmp/pcmanfm-desktop.log 2>&1 & exec jwm -f /root/.jwmrc' >> /data/local/linux/autostart.log 2>&1
