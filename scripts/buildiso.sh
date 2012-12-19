#!/usr/bin/env bash

function build_iso() {
	echo ===Started building ISO-image===
	if [ ! -e "build" ]
	then
		echo Creating build folder...
		mkdir build
	else
		echo Omit creating build folder...
	fi
	cd build
	echo Creating floppy image...
	if [ -e "streamos.img" ]
	then
		echo Removing old floppy image...
		rm streamos.img
	fi
	echo Creating empty floppy image...
	dd if=/dev/zero of=streamos.img bs=512 count=2880
	echo Creating FAT filesystem on floppy image...
	/sbin/mkfs.vfat streamos.img
	echo Making floppy image bootable...
	dd if=../blobs/mbr.bin of=streamos.img conv=notrunc
	echo Creating floppy image structure...
	if [ ! -e "floppy" ]
	then
		echo Creating floppy folder...
		mkdir floppy
	else
		echo Omit creating floppy folder...
	fi
	echo Mounting floppy image...
	sudo mount -o loop streamos.img floppy
	echo Creating floppy image folders structure...
	if [ ! -e "floppy/sys" ]
	then
		echo Creating sys folder...
		sudo mkdir floppy/sys
	else
		echo Omit creating sys folder...
	fi
	if [ ! -e "floppy/sys/drv" ]
	then
		echo Creating drv folder...
		sudo mkdir floppy/sys/drv
	else
		echo Omit creating drv folder...
	fi
	if [ ! -e "floppy/sys/drv/cdrom" ]
	then
		echo Creating cdrom folder...
		sudo mkdir floppy/sys/drv/cdrom
	else
		echo Omit creating cdrom folder...
	fi
	if [ ! -e "floppy/sys/drv/jemmex" ]
	then
		echo Creating jemmex folder...
		sudo mkdir floppy/sys/drv/jemmex
	else
		echo Omit creating jemmex folder...
	fi
	if [ ! -e "floppy/sys/drv/dma" ]
	then
		echo Creating dma folder...
		sudo mkdir floppy/sys/drv/dma
	else
		echo Omit creating dma folder...
	fi

	if [ ! -e "floppy/sys/drv/keyrus" ]
	then
		echo Creating keyrus folder...
		sudo mkdir floppy/sys/drv/keyrus
	else
		echo Omit creating keyrus folder...
	fi
	if [ ! -e "floppy/sys/drv/xmsdisk" ]
	then
		echo Creating xmsdisk folder...
		sudo mkdir floppy/sys/drv/xmsdisk
	else
		echo Omit creating xmsdisk folder...
	fi
	if [ ! -e "floppy/sys/mods" ]
	then
		echo Creating mods folder...
		sudo mkdir floppy/sys/mods
	else
		echo Omit creating mods folder...
	fi
	echo Copying binary files...
	echo Copying FreeDOS kernel...
	sudo cp ../blobs/kernel.sys			floppy/kernel.sys
	sudo cp ../blobs/command.com			floppy/command.com
	echo Copying lowlevel modules...
	sudo cp ../blobs/cwsdpmi.exe			floppy/sys/mods/cwsdpmi.exe
	sudo cp ../mods/findcd.exe			floppy/sys/drv/cdrom/findcd.exe
	echo Copying CDROM drivers...
	sudo cp ../blobs/XDMA32.DLL			floppy/sys/drv/dma/xdma32.dll
	sudo cp ../blobs/XCDROM32.DLL			floppy/sys/drv/cdrom/xcdrom32.dll
	sudo cp ../blobs/shsucdx.exe			floppy/sys/drv/cdrom/shsucdx.exe
	echo Copying misc drivers...
	sudo cp ../blobs/JEMMEX.EXE			floppy/sys/drv/jemmex/jemmex.exe
	sudo cp ../blobs/JLOAD.EXE			floppy/sys/drv/jemmex/jload.exe
	sudo cp ../blobs/keyrus.com			floppy/sys/drv/keyrus/keyrus.com
	sudo cp ../blobs/XMSDSK.EXE			floppy/sys/drv/xmsdisk/xmsdsk.exe
	echo Copying config files...
	sudo cp ../blobs/autoexec.bat			floppy/autoexec.bat
	sudo cp ../blobs/config.sys			floppy/config.sys
	sudo cp ../blobs/cdrom.bat			floppy/sys/drv/cdrom/cdrom.bat
	sudo cp ../blobs/keyrus.bat			floppy/sys/drv/keyrus/keyrus.bat
	sudo cp ../blobs/xmsdisk.bat			floppy/sys/drv/xmsdisk/xmsdisk.bat
	echo Unmounting floppy...
	sudo umount floppy
	echo Preparing ISO-image...
	echo Creating ISO-image structure...
	if [ ! -e "iso" ]
	then
		echo Creating iso folder...
		mkdir iso
	else
		echo Omit creating iso folder...
	fi
	if [ ! -e "iso/floppy" ]
	then
		echo Creating floppy mountpoint folder...
		mkdir iso/floppy
	else
		echo Omit creating floppy mountpoint folder...
	fi
	if [ ! -e "iso/pids" ]
	then
		echo Creating pids mountpoint folder...
		mkdir iso/pids
	else
		echo Omit creating pids mountpoint folder...
	fi
	if [ ! -e "iso/bin" ]
	then
		echo Creating bin folder...
		mkdir iso/bin
	else
		echo Omit creating bin folder...
	fi
	if [ ! -e "iso/etc" ]
	then
		echo Creating etc folder...
		mkdir iso/etc
	else
		echo Omit creating etc folder...
	fi
	if [ ! -e "iso/sys" ]
	then
		echo Creating sys folder...
		mkdir iso/sys
	else
		echo Omit creating sys folder...
	fi
	if [ ! -e "iso/sys/kernel" ]
	then
		echo Creating kernel folder...
		mkdir iso/sys/kernel
	else
		echo Omit creating kernel folder...
	fi
	if [ ! -e "iso/sys/mods" ]
	then
		echo Creating mods folder...
		mkdir iso/sys/mods
	else
		echo Omit creating mods folder...
	fi
	echo Copying lowlevel modules...
	cp ../mods/poweroff.exe				iso/sys/mods/poweroff.exe
	cp ../mods/reboot.exe				iso/sys/mods/reboot.exe
	cp ../mods/suspend.exe				iso/sys/mods/suspend.exe
	echo Copying StreamOS kernel...
	cp ../blobs/DGDI32.DLL				iso/sys/kernel/DGDI32.DLL
	cp ../blobs/DKRNL32.DLL				iso/sys/kernel/DKRNL32.DLL
	cp ../blobs/DPMILD32.EXE			iso/sys/kernel/DPMILD32.EXE
	cp ../blobs/DUSER32.DLL				iso/sys/kernel/DUSER32.DLL
	cp ../blobs/HDPMI32.EXE				iso/sys/kernel/HDPMI32.EXE
	cp ../blobs/OLEAUT32.DLL			iso/sys/kernel/OLEAUT32.DLL
	cp ../streamos.exe				iso/sys/kernel/streamos.exe
	cp ../displays.dll				iso/sys/mods/displays.dll
	cp ../smem.dll					iso/sys/mods/smem.dll
	echo Copying config files...
	cp ../blobs/modules.dep				iso/etc/modules.dep
	cp ../blobs/fstab				iso/etc/fstab
	cp ../blobs/inittab				iso/etc/inittab
	cp ../blobs/shadow				iso/etc/shadow
	echo Copying applications...
	for each in `ls ../apps`; do cp ../apps/$each/$each iso/bin/$each; done
	echo Building ISO-image...
	mv streamos.img iso/streamos.img
	cd iso
	if [ -e "streamos.iso" ]
		then rm streamos.iso
	fi
	mkisofs -input-charset utf-8 -b streamos.img -o streamos.iso .
	cd ../..
	echo ===done===
}

