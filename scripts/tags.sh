#!/usr/bin/env bash

if [ ! $CTAGS_BIN ]; then
	CTAGS_BIN="/usr/bin/env ctags"
fi

CTAGS="$CTAGS_BIN --language-force=pascal -R ."

function gen_tags() {
	echo Generating tags...
	eval $CTAGS
	echo done.
}
