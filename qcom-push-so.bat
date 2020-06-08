@echo off
adb wait-for-device root
adb wait-for-device remount
adb shell setenforce 0
adb wait-for-device push capi_v2_cirrus_cspl.so /vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so
adb shell "md5sum /vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so"
adb sync
pause
