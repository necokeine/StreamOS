#!/usr/bin/env bash

function count_lines() {
	echo Counting...
	lcount=0
	for each in `find . -name '*.pp'`
	do
		curcount=`(wc -l $each | awk '{print($1)}')`
		((lcount=lcount+curcount))
	done
	echo Your source code tree has $lcount lines.
}

