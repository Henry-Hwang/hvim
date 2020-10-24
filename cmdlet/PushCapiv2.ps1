adb wait-for-device root
adb wait-for-device remount

adb push capi_v2_cirrus_sp.so /vendor/lib/rfsa/adsp
