#!/bin/bash
IP=198.90.140.103
USER=croot
TARGET=m1971 #***
REMOTE_DIR_DROID=/opt/ubt-work/src/customer/meizu/m1971 #***

DEVICE_DIR_HAL=/vendor/lib/hw
DEVICE_DIR_ETC=/vendor/etc
DEVICE_DIR_MODULES=/vendor/lib/modules
DEVICE_DIR_SYS_LIB=/system/lib
DEVICE_DIR_SYS_LIB64=/system/lib64
DEVICE_DIR_SYS_LIB_VNDK=/system/lib/vndk-28

DIR_PRODUCT=out/target/product/$TARGET
DIR_HAL=hardware/qcom/audio
DIR_HAL_XML=$DIR_HAL/configs/msmnile #***
DIR_HAL_HW=$DIR_PRODUCT/vendor/lib/hw
DIR_SYS_LIB=$DIR_PRODUCT/system/lib
DIR_SYS_LIB64=$DIR_PRODUCT/system/lib64
DIR_SYS_LIB_VNDK=$DIR_PRODUCT/system/lib/vndk-28
DIR_MODULES=$DIR_PRODUCT/dlkm/lib/modules

TARGET_BOOT=$DIR_PRODUCT/boot.img
TARGET_DTBO=$DIR_PRODUCT/dtbo.img
TARGET_SYSTEM=$DIR_PRODUCT/system.img
TARGET_HAL_XML=$DIR_HAL_XML/mixer_paths_meizu.xml #***
TARGET_HAL_HW=$DIR_HAL_HW/audio.primary.msmnile.so #***

#***
SYSLIBS_VNDK=(
		libaudioroute.so
		#tspp.ko
 		 )

#***
SYSLIBS64=(
		libaudioroute.so
		#tspp.ko
 		 )

#***
SYSLIBS=(
		libaudioroute.so
		#tspp.ko
 		 )


#***
XMLS=(
		mixer_paths_meizu.xml
		#audio_platform_info.xml
		#tspp.ko
 		 )

#***
KOBJECTS=(
		#atomic64_test.ko
		#audio_adsp_loader.ko
		#audio_apr.ko
		#audio_cs35l41.ko
		#audio_cs48l32.ko
		#audio_hdmi.ko
		#audio_machine_msmnile.ko
		#audio_mbhc.ko
		#audio_native.ko
		#audio_pinctrl_wcd.ko
		#audio_platform.ko
		audio_q6.ko
		#audio_q6_notifier.ko
		#audio_q6_pdr.ko
		#audio_stub.ko
		#audio_swr.ko
		#audio_swr_ctrl.ko
		#audio_tacna_extcon.ko
		#audio_tacna_gpio.ko
		#audio_tacna_irq.ko
		#audio_tacna_mfd.ko
		#audio_tacna_pinctrl.ko
		#audio_tacna_regulator.ko
		#audio_usf.ko
		#audio_wcd934x.ko
		#audio_wcd9360.ko
		#audio_wcd9xxx.ko
		#audio_wcd_core.ko
		#audio_wcd_spi.ko
		#audio_wglink.ko
		#audio_wsa881x.ko
		#br_netfilter.ko
		#gspca_main.ko
		#lcd.ko
		#lkdtm.ko
		#llcc_perfmon.ko
		#locktorture.ko
		#mpq-adapter.ko
		#mpq-dmx-hw-plugin.ko
		#msm-geni-ir.ko
		#mz_stability_test.ko
		#qca_cld3_wlan.ko
		#rcutorture.ko
		#rdbg.ko
		#rmnet_perf.ko
		#rmnet_shs.ko
		#test_user_copy.ko
		#torture.ko
		#tspp.ko
 		 )

