#!/bin/bash
IP=198.90.140.103
USER=croot
TARGET=m1971 #***
REMOTE_DIR_DROID=/opt/ubt-work/src/customer/meizu/m1971 #***

DTARGET_DIR_HAL=/vendor/lib/hw
DTARGET_DIR_ETC=/vendor/etc
DTARGET_DIR_MODULES=/vendor/lib/modules

DIR_PRODUCT=out/target/product/$TARGET
DIR_HAL=hardware/qcom/audio
DIR_HAL_XML=$DIR_HAL/configs/msmnile #***
DIR_HAL_HW=$DIR_PRODUCT/vendor/lib/hw
DIR_MODULES=$DIR_PRODUCT/vendor/lib/modules

TARGET_BOOT=$DIR_PRODUCT/boot.img
TARGET_DTBO=$DIR_PRODUCT/dtbo.img
TARGET_SYSTEM=$DIR_PRODUCT/system.img
TARGET_HAL_XML=$DIR_HAL_XML/mixer_paths_meizu.xml #***
TARGET_HAL_SO=$DIR_HAL_HW/audio.primary.msmnile.so #***

#***
KOBJECTS=( 	"audio_cs48l32.ko"
			"audio_machine_msmnile.ko"
			"audio_q6.ko"
			"audio_cs35l41.ko" )


