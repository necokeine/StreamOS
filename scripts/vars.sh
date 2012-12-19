#!/usr/bin/env bash

function setvars() {
	CPU="386"
	FPU="X87"
	GO32FLAGS="-Sc -S2 -O- -Cp$CPU -Cf$FPU"
	WIN32FLAGS="-Sc -S2 -O- -Cp$CPU -Cf$FPU -Fu./include -Fi./include"
	APPSFLAGS="-Sc -S2 -O- -Cp$CPU -Cf$FPU -Fu../../include -Fi../../include"
	sisoimage="build/iso/streamos.iso"
}

