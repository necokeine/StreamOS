#!/usr/bin/env bash

function run_qemu() {
	qemu -cdrom $sisoimage -boot d -m 256 -net none -localtime -name StreamOS -clock dynticks -sdl
}

