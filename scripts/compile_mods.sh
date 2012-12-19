#!/usr/bin/env bash

. scripts/compile_go32v2.sh

function compile_mods() {
	cd mods
	compile_go32v2 findcd.pp
	compile_go32v2 suspend.pp
	compile_go32v2 reboot.pp
	compile_go32v2 poweroff.pp
	cd ..
}

