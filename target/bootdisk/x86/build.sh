
use_isolinux=1
use_mdlbl=1

echo_header "Creating floppy disk images:"
cd $disksdir; mkdir -p boot
cp $base/target/$target/x86/lilo-* boot/
cp $base/target/$target/x86/makeimages.sh .
cp 2nd_stage/boot/memtest86.bin boot/
cp 2nd_stage/boot/vmlinuz boot/
chmod +x makeimages.sh

if [ $use_mdlbl -eq 1 ]
then
	tar --use-compress-program=bzip2 \
	    -xf $base/download/bootdisk/mdlbl-0.1.tar.bz2; cd mdlbl-0.1
	cp ../boot/vmlinuz .; cp ../initrd.img initrd; ./makedisks.sh
	for x in disk*.img; do mv $x ../floppy${x#disk}; done; cd ..
	du -sh floppy*.img | while read x; do echo_status $x; done
else
	tmpfile=`mktemp -p $PWD`
	if sh ./makeimages.sh &> $tmpfile; then
		cat $tmpfile | while read x; do echo_status "$x"; done
	else
		cat $tmpfile | while read x; do echo_error "$x"; done
	fi
	rm -f $tmpfile
	cat > ../isofs_arch.txt <<- EOT
		BOOT	-b ${ROCKCFG_SHORTID}/boot_288.img -c ${ROCKCFG_SHORTID}/boot.catalog
	EOT
fi

if [ $use_isolinux -eq 1 ]
then
	echo_header "Creating isolinux setup:"
	#
	echo_status "Extracting isolinux boot loader."
	mkdir -p isolinux
	tar --use-compress-program=bzip2 \
	    -xf $base/download/bootdisk/syslinux-2.02.tar.bz2 \
	    syslinux-2.02/isolinux.bin -O > isolinux/isolinux.bin
	#
	echo_status "Creating isolinux config file."
	cp $base/target/$target/x86/isolinux.cfg isolinux/
	cp $base/target/$target/x86/help?.txt isolinux/
	#
	echo_status "Copy images to isolinux directory."
	cp boot/memtest86.bin isolinux/memtest86
	cp initrd.img boot/vmlinuz isolinux/
	#
	cat > ../isofs_arch.txt <<- EOT
		BOOT	-b isolinux/isolinux.bin -c isolinux/boot.catalog
		BOOTx	-no-emul-boot -boot-load-size 4 -boot-info-table
		DISK1	build/${ROCKCFG_ID}/bootdisk/isolinux/ isolinux/
	EOT
fi

