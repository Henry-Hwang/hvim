#!/bin/bash
adb wait-for-device root
adb wait-for-device remount
adb wait-for-device shell setenforce 0
adb shell setprop sys.usb.config diag,adb
adb shell getprop sys.usb.confug
