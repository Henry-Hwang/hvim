#!/bin/bash
adb wait-for-device root
adb wait-for-device remount

while true
do
adb shell dmesg -c | rg -ie "$1"
sleep 0.5
done

