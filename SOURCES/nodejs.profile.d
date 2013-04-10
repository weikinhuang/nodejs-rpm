#!/bin/sh

if type npm &> /dev/null; then
	export NODE_PATH="$(/usr/bin/npm root -g)"
else
	export NODE_PATH="${_prefix}/lib/node_modules"
fi
