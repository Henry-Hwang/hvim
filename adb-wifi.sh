#!/bin/sh
su
setenforce 0
setprop service.adb.tcp.port 5555
stop adbd
start adbd
ifconfig
echo "================================="
echo "adb connect IP:5555"
echo "adb disconnect IP:5555"

