
echo_header "Creating initrd data:"
rm -rf $disksdir/initrd
mkdir -p $disksdir/initrd/{dev,proc,tmp,scsi,net,bin}
cd $disksdir/initrd; ln -s bin sbin; ln -s . usr
#
echo_status "Create linuxrc binary."
diet $CC $base/target/$target/linuxrc.c -Wall \
	-DSTAGE_2_BIG_IMAGE="\"${ROCKCFG_SHORTID}/2nd_stage.tar.gz\"" \
	-DSTAGE_2_SMALL_IMAGE="\"${ROCKCFG_SHORTID}/2nd_stage_small.tar.gz\"" \
	-o linuxrc # > $disksdir/tmp 2>&1
#
echo_status "Copy various helper applications."
cp ../2nd_stage/bin/{tar,gzip} bin/
cp ../2nd_stage/sbin/{ip,hwscan} bin/
cp ../2nd_stage/usr/bin/{wget,gawk} bin/
for x in modprobe.static modprobe.static.old \
         insmod.static insmod.static.old
do
	if [ -f ../2nd_stage/sbin/${x/.static/} ]; then
		rm -f bin/${x/.static/}
		cp -a ../2nd_stage/sbin/${x/.static/} bin/
	fi
	if [ -f ../2nd_stage/sbin/$x ]; then
		rm -f bin/$x bin/${x/.static/}
		cp -a ../2nd_stage/sbin/$x bin/
		ln -sf $x bin/${x/.static/}
	fi
done
#
echo_status "Copy scsi and network kernel modules."
for x in ../2nd_stage/lib/modules/*/kernel/drivers/{scsi,net}/*.o; do
	xx=${x#../2nd_stage/}
	mkdir -p $( dirname $xx ) ; cp $x $xx
	strip $xx # --strip-debug --strip-unneeded $xx
done
#
for x in ../2nd_stage/lib/modules/*/modules.{dep,pcimap,isapnpmap} ; do
	cp $x ${x#../2nd_stage/}
done
#
for x in lib/modules/*/kernel/drivers/{scsi,net}; do
	ln -s ${x#lib/modules/} lib/modules/
done
rm -f lib/modules/[0-9]*/kernel/drivers/scsi/{st,scsi_debug}.o
rm -f lib/modules/[0-9]*/kernel/drivers/net/{dummy,ppp*}.o
#
if [ "$ROCKCFG_BOOTDISK_USEKISS" = 1 ]; then
	echo_status "Adding kiss shell for expert use of the initrd image."
	cp $build_dir/root/bin/kiss bin/
	#mv linuxrc bin/; ln -s bin/kiss linuxrc
	#rm -f lib/modules/[0-9]*/kernel/drivers/net/{dgrx,acenic}.o
	#rm -f lib/modules/[0-9]*/kernel/drivers/scsi/{advansys,qla1280}.o
fi
cd ..

echo_header "Creating initrd filesystem image: "

ramdisk_size=8192
[ $arch = x86 ] && ramdisk_size=4096

echo_status "Creating temporary files."
tmpdir=initrd_$$.dir; mkdir -p $disksdir/$tmpdir; cd $disksdir
dd if=/dev/zero of=initrd.img bs=1024 count=$ramdisk_size &> /dev/null
tmpdev=""
for x in /dev/loop/* ; do
        if losetup $x initrd.img 2> /dev/null ; then
                tmpdev=$x ; break
        fi
done
if [ -z "$tmpdev" ] ; then
        echo_error "No free loopback device found!"
        rm -f $tmpfile ; rmdir $tmpdir; exit 1
fi
echo_status "Using loopback device $tmpdev."
#
echo_status "Writing initrd image file."
mke2fs -m 0 -N 180 -q $tmpdev &> /dev/null
mount -t ext2 $tmpdev $tmpdir
rmdir $tmpdir/lost+found/
cp -a initrd/* $tmpdir
umount $tmpdir
#
echo_status "Removing temporary files."
losetup -d $tmpdev
rm -rf $tmpdir
