#!/system/bin/sh
echo '=== Alpine autostart ===' > /data/local/linux/autostart.log
date >> /data/local/linux/autostart.log
sleep 15
am start -n x.org.server/.MainActivity >> /data/local/linux/autostart.log 2>&1
sleep 35
/data/local/linux/mount-alpine.sh >> /data/local/linux/autostart.log 2>&1
busybox chroot /data/local/linux/rootfs /bin/sh -c 'export PATH=/bin:/sbin:/usr/bin:/usr/sbin; export DISPLAY=:0; exec /root/.xinitrc' >> /data/local/linux/autostart.log 2>&1
