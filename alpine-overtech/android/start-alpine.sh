#!/system/bin/sh
busybox chroot /data/local/linux/rootfs /bin/sh -c 'export PATH=/bin:/sbin:/usr/bin:/usr/sbin; cd /root; exec /bin/sh'
