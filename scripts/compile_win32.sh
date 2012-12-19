#!/usr/bin/env bash

function compile_win32() {
	echo Compiling $1...
	fpc $1 -Twin32 $WIN32FLAGS
}

