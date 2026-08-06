#!/system/bin/sh
mkdir -p /data/local/linux/rootfs
busybox losetup /dev/block/loop0 /data/local/linux/linux.img 2>/dev/null
busybox mount -t ext2 /dev/block/loop0 /data/local/linux/rootfs 2>/dev/null
busybox mount -t proc proc /data/local/linux/rootfs/proc 2>/dev/null
busybox mount -t sysfs sysfs /data/local/linux/rootfs/sys 2>/dev/null
busybox mount --bind /dev /data/local/linux/rootfs/dev 2>/dev/null
mkdir -p /data/local/linux/rootfs/dev/pts
busybox mount -t devpts devpts /data/local/linux/rootfs/dev/pts 2>/dev/null
