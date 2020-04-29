#!/bin/sh
dir="$(pwd)"
if [ -f "$dir/bin/console" ]; then
    cmd="$dir/bin/console"
elif [ -f "$dir/app/console_debug" ]; then
    cmd="$dir/app/console_debug"
elif [ -f "$dir/app/console" ]; then
    cmd="$dir/app/console"
else
    exit
fi
"$cmd" $@
