
echo_header "Creating initrd data:"
rm -rf $disksdir/initrd
mkdir -p $disksdir/initrd/{dev,proc,tmp,scsi,net,bin}
cd $disksdir/initrd; ln -s bin sbin; ln -s . usr
#
echo_status "Create linuxrc binary."
diet $CC -Wall -Os -s -c $base/misc/isomd5sum/md5.c -o md5.o
diet $CC -Wall -Os -s -c $base/misc/isomd5sum/libcheckisomd5.c \
	-o libcheckisomd5.o
diet $CC -Wall -Os -s -I $base/misc/isomd5sum/ \
	-c $base/target/$target/linuxrc.c \
	-DSTAGE_2_BIG_IMAGE="\"${ROCKCFG_SHORTID}/2nd_stage.tar.gz\"" \
	-DSTAGE_2_SMALL_IMAGE="\"${ROCKCFG_SHORTID}/2nd_stage_small.tar.gz\"" \
	-o linuxrc.o
diet $CC -Os -s linuxrc.o md5.o libcheckisomd5.o -o linuxrc
rm -f linuxrc.o md5.o libcheckisomd5.o
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
if [ "$ROCKCFG_BOOTDISK_USEKISS" = 1 ]; then
	echo_status "Adding kiss shell for expert use to the initrd image."
	cp $build_root/bin/kiss bin/
fi

#
# For each available kernel:
#

for x in `egrep 'X .* KERNEL .*' $base/config/$config/packages |
          cut -d ' ' -f 5-6 | tr ' ' '_'` ; do

  kernel=${x/_*/}
  kernelver=${x/*_/}
  moduledir="`grep lib/modules  $build_root/var/adm/flists/$kernel |
              cut -d ' ' -f 2 | cut -d / -f 1-3 | uniq | head -n 1`"
  initrd="initrd${kernel/linux/}.gz"

  pushd . 2>&1 > /dev/null

  echo_header "Creating linuxrc for $kernel ($kernelver) ..."
  rm -rf lib/modules/ # remove stuff from the last loop

  echo_status "Copy scsi and network kernel modules."
  for x in ../$moduledir/kernel/drivers/{scsi,net}/*.{ko,o} \
      ../$moduledir/kernel/fs/nls/nls_{utf8,iso8859-{1,15}}.{ko,o}
  do
	# this test is needed in case there are no .o or only .ko files
	if [ -f $x ]; then
		xx=${x#../}
		mkdir -p $( dirname $xx ) ; cp $x $xx
		$STRIP --strip-debug $xx # stripping more breaks the object
	fi
  done

  for x in ../$moduledir/modules.{dep,pcimap,isapnpmap} ; do
	cp $x ${x#../} || echo "not found: $x" ;
  done

  for x in lib/modules/*/kernel/drivers/{scsi,net}; do
	ln -s ${x#lib/modules/} lib/modules/
  done
  rm -f lib/modules/[0-9]*/kernel/drivers/scsi/{st,scsi_debug}.{o,ko}
  rm -f lib/modules/[0-9]*/kernel/drivers/net/{dummy,ppp*}.{o,ko}

  cd ..

  echo_status "Creating initrd filesystem image: $initrd"

  ramdisk_size=8192
  #[ $arch = x86 ] && ramdisk_size=4096

  echo_status "Creating temporary files."
  tmpdir=initrd_$$.dir; mkdir -p $disksdir/$tmpdir; cd $disksdir
  dd if=/dev/zero of=initrd.img bs=1024 count=$ramdisk_size &> /dev/null

  echo_status "Writing initrd image file."
  mke2fs -m 0 -N 180 -qF initrd.img &> /dev/null
  mount -t ext2 initrd.img $tmpdir -o loop
  rmdir $tmpdir/lost+found/
  cp -a initrd/* $tmpdir
  umount $tmpdir

  echo_status "Compressing initrd image file."
  gzip -9 initrd.img 
  mv initrd.img.gz $initrd

  echo_status "Removing temporary files."
  rm -rf $tmpdir

  popd 2>&1 > /dev/null
done

