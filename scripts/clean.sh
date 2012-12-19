#!/usr/bin/env bash

function clean_all() {
	rm displays.dll > /dev/null 2>&1
	rm smem.dll > /dev/null 2>&1
	rm streamos.exe > /dev/null 2>&1
	rm tags > /dev/null 2>&1
	rm *.o > /dev/null 2>&1
	rm *.ppu > /dev/null 2>&1
	rm include/*.o > /dev/null 2>&1
	rm include/*.ppu > /dev/null 2>&1
	rm include/*.a > /dev/null 2>&1
	rm mods/*.exe > /dev/null 2>&1
	rm mods/*.o > /dev/null 2>&1
	rm mods/*.ppu > /dev/null 2>&1
	rm build -rf > /dev/null 2>&1
	cd apps
	for each in `ls`
	do
		cd $each
		rm *.o > /dev/null 2>&1
		rm *.ppu > /dev/null 2>&1
		rm $each > /dev/null 2>&1
		cd ..
	done
	cd ..
}

