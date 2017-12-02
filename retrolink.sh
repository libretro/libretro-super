#!/bin/bash
#RetroLink - Allows a library or executable to link to any symbols, without version restrictions
#Usage: ./retrolink foobar_libretro.so
#http://www.lightofdawn.org/wiki/wiki.cgi/NewAppsOnOldGlibc

start=$(readelf -V "$1" | grep -A1 .gnu.version_r | tail -n1 | cut -d' ' -f6)
pos=$(readelf -V "$1" | grep 'Flags: none' | cut -d' ' -f3 | sed 's/://')
for pos in $pos; do
printf '\x02' | dd if=/dev/stdin of="$1" seek=$((start+pos+4)) count=1 bs=1 conv=notrunc 2> /dev/null
done
