#!/bin/bash
TARGET=/dev/block/by-name
DIR=$1
adb wait-for-device root
adb wait-for-device remount

for image in $(adb shell ls $TARGET);
do

if [ "userdata" = $image ]; then
	echo "skip $image"
	continue
fi

echo $image
adb pull $TARGET/$image $DIR/$image.img

done
