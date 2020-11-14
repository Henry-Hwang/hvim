@echo off
set HEXAGON_TOOLS_ROOT=C:\qualcomm\hexagon_sdk\3.4.3\tools\hexagon_tools\8.3.02
set HEXAGON_SDK_ROOT=C:\Qualcomm\Hexagon_SDK\3.4.3
set ANDROID_NDK_TOOLS_ROOT=C:\Qualcomm\Hexagon_SDK\3.4.3\tools\android-ndk-r14b
set PATH=%PATH%;C:\Qualcomm\Hexagon_SDK\3.4.3\tools\android-ndk-r14b\toolchains\arm-linux-androideabi-4.9\prebuilt\windows-x86_64\bin
set PATH=%PATH%;C:\qualcomm\hexagon_sdk\3.4.3\tools\hexagon_tools\8.3.02\tools\bin
set PATH=%PATH%;C:\cygwin64\bin
make -f Makefile_CAPI_v2_CSPL clean
make -f Makefile_CAPI_v2_CSPL all
