#!/usr/bin/env bash

function compile_app() {
	echo Compiling $1...
	fpc $1 -Twin32 $APPSFLAGS
}

