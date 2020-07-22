#!/bin/bash
DROID=.
BIN=$DROID/prebuilts/build-tools/linux-x86/bin
NINJA_FILE=$DROID/out/combined-gauguin.ninja
TARGET=audio_cs35l41.ko

$BIN/ninja -f $NINJA_FILE $TARGET

#adb wait-for-device root
#adb wait-for-device remount
#adb push out/target/product/dlkm/lib/modules/audio_cs35l41.ko /vendor/lib/modules/audio_cs35l41.ko
#adb reboot
