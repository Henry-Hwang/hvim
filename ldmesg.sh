#!/bin/bash
reset
adb wait-for-device root
adb wait-for-device remount

while true
do
	if [ ! -n "$1" ]; then
		adb shell dmesg -c
	else
		adb shell dmesg -c | grep $1
	fi

done
