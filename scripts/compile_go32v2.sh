#!/usr/bin/env bash

function compile_go32v2() {
	echo Compiling $1...
	fpc $1 -Tgo32v2 $GO32FLAGS
}

