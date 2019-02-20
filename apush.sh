#!/bin/bash
adb wait-for-device root
adb wait-for-device remount
adb push $1 $2
