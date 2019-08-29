#!/bin/bash
ROOT=C:
#ROOT=/c
export HEXAGON_TOOLS_ROOT=$ROOT\\Qualcomm\\Hexagon_SDK\\3.4.3\\tools\\HEXAGON_Tools\\8.3.02
export HEXAGON_SDK_ROOT=$ROOT\\Qualcomm\\Hexagon_SDK\\3.4.3
export ANDROID_NDK_TOOLS_ROOT=$ROOT\\Qualcomm\\Hexagon_SDK\\3.4.3\\tools\\android-ndk-r14b
export PATH="$PATH:$ROOT\\Qualcomm\\Hexagon_SDK\\3.4.3\\tools\\HEXAGON_Tools\\8.3.02\\Tools\\bin"

export PATH="$PATH:$ROOT\\Qualcomm\\Hexagon_SDK\\3.4.3\\tools\\debug\\mini-dm\\WinNT_Debug"
export PATH="$PATH:$ROOT\\Qualcomm\\Hexagon_SDK\\3.4.3\\tools\\android-ndk-r14b\\toolchains\\arm-linux-androideabi-4.9\\prebuilt\\windows-x86_64\\bin"
#export PATH="$PATH:$ROOT\\ndk\\android-ndk-r20\\toolchains\\arm-linux-androideabi-4.9\\prebuilt\\linux-x86_64\\bin"
export PATH="$PATH:$ROOT\\Qualcomm\\Hexagon_SDK\\3.4.3\\tools\\HEXAGON_Tools\\8.3.02\\Tools\\bin"
make -f Makefile_CAPI_V2_CSPL clean
make -f Makefile_CAPI_V2_CSPL all
