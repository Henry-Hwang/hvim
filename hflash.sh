#!/bin/bash

# This script base on
# https://www.shellscript.sh/tips/getopts/

show_target_info() {
	if [ ! -f ~/hfconf.sh]; then
		echo "Error: hfconf.sh is not found!"
		usage
	fi
		
	cat ~/hfconf.sh
}

usage()
{
	echo ""
	echo "NOTE: "
	echo "1) Before all, you need to compelete the hfconf.sh"
	echo "2) Copy hfconf.sh to \"~\" - /home/username/"
	echo "3) \"-i/-l\" always the lass one in command line"

	echo ""

	echo "Usage: $0 [-f|-p|r|-s|-b] [ -d DIR ] [ -i|-l IMAGE/LIB ]"

	echo ""
	echo "-f : Flash image to device"
	echo "-p : Pull image from server"
	echo "-r : Pull image/lib from server then flashing"
	echo "-s : Show target information"
	echo "-b : Reboot device"
	echo "-d : Specific a directory with the image/lib in side for flashing"
	echo "-i : Follow by the sector (boot, dtbo, system, etc.)"
	echo "-l : Follow by the libs (so, ko, xml, etc.)"

	echo ""
	echo "Example:"
	echo "./croot.sh -p -i dtbo"
	echo "./croot.sh -rbf -l xml hal"
	echo "./croot.sh -rf -i boot dtbo"
	echo "./croot.sh -f -i boot dtbo"
	
	exit 2
}

set_variable()
{
	local varname=$1
	shift
	if [ -z "${!varname}" ]; then
		eval "$varname=\"$@\""
	else
		echo "Error: $varname already set"
		usage
	fi
}

ssh_pull_stuff() {
	local dir_product=$REMOTE_DIR_DROID/$DIR_PRODUCT
	local target_hal_xml=$REMOTE_DIR_DROID/$TARGET_HAL_XML
	local target_hal_so=$REMOTE_DIR_DROID/$TARGET_HAL_SO
	local dir_modules=$REMOTE_DIR_DROID/$DIR_MODULES

	echo "args: $@"
	for image in $@;
	do
		case $image in
			boot)
				scp $USER@$IP:$dir_product/boot.img $DIR_PRODUCT
				;;
			system)
				scp $USER@$IP:$dir_product/system.img $DIR_PRODUCT
				;;
			dtbo)
				scp $USER@$IP:$dir_product/dtbo.img $DIR_PRODUCT
				;;
			xml)
				scp $USER@$IP:$target_hal_xml $DIR_HAL_XML
				;;
			modules)
				scp -r $USER@$IP:$dir_modules $DIR_MODULES/../
				;;
			hal)
				scp $USER@$IP:$target_hal_so $DIR_HAL_HW
				;;
			kos)
				for ko in "${KOBJECTS[@]}";
				do
					scp $USER@$IP:$dir_modules/$ko $DIR_MODULES
				done
				;;
			*)
				echo "Error: $image not found!"
		esac
	#fastboot flash img ..
	done
}

flash_to_device() {

	if [ -z "$SPECDIR" ]; then
		local dir_product=$DIR_PRODUCT
	else
		local dir_product=$SPECDIR/$DIR_PRODUCT
	fi

	adb wait-for-device root
	adb wait-for-device remount
	adb reboot bootloader
	
	echo "args: $@"
	for image in $@;
	do
		case $image in
			boot)
				fastboot flash boot $dir_product/boot.img
				;;
			system)
				fastboot flash boot $dir_product/system.img
				;;
			dtbo)
				fastboot flash dtbo $dir_product/dtbo.img
				;;
			*)
				echo "Error: $image - sector not found!"
				usage
				;;
		esac

	done
	fastboot reboot
}
push_to_device() {
	if [ -z "$SPECDIR" ]; then
		local target_hal_xml=$TARGET_HAL_XML
		local target_hal_so=$TARGET_HAL_HW
		local dir_modules=$DIR_MODULES
	else
		local target_hal_xml=$SPECDIR/$TARGET_HAL_XML
		local target_hal_so=$SPECDIR/$TARGET_HAL_HW
		local dir_modules=$SPECDIR/$DIR_MODULES
	fi
	#echo $target_hal_xml
	#exit 0
	adb wait-for-device root
	adb wait-for-device remount
	
	echo "args: $@"
	for lib in $@;
	do
		case $lib in
			hal)
				echo "$target_hal_so --> $DEVICE_DIR_HAL"
				adb push $target_hal_so $DEVICE_DIR_HAL
				;;
			xml)
				adb push $target_hal_xml $DEVICE_DIR_ETC
				;;
			modules)
				adb push $dir_modules $DEVICE_DIR_MODULES/../
				;;
			kos)
				for ko in "${KOBJECTS[@]}";
				do
					adb push $dir_modules/$ko $DEVICE_DIR_MODULES
				done
				;;
			*)
				echo "Error: $lib - lib not found!"
				usage
				;;
		esac

	done
}

initial() {
	#load hfconf.sh
	if [ -f ~/hfconf.sh ]; then
		source ~/hfconf.sh
	else
		echo "Error: miss ~/hfconf.sh file"
		usage
	fi
	
	#create mirror dir
	if [ ! -d $DIR_MODULES ]; then
		mkdir -p $DIR_MODULES
	fi
	if [ ! -d $DIR_HAL_HW ]; then
		mkdir -p $DIR_HAL_HW
	fi
	if [ ! -d $DIR_HAL_XML ]; then
		mkdir -p $DIR_HAL_XML
	fi
}
####################################################################
# Main script starts here
unset TARGET IMAGE LIBRARY ACTION ACTION_REBOOT

while getopts 'rbfpsd:i:l:?h' c
do
case $c in
	# Show remote server information
	f) set_variable ACTION FLASH ;;
	p) set_variable ACTION PULL ;;
	b) set_variable ACTION_REBOOT REBOOT ;;
	r) set_variable ACTION_REMOTE REMOTE ;;
	s) set_variable ACTION SHOW ;;
	i) set_variable IMAGE $OPTARG ;;
	l) set_variable LIBRARY $OPTARG ;;
	d) set_variable SPECDIR $OPTARG ;;

	h|?) usage ;; esac
done

#([ -n "$ACTION" ] && [ -n "$TARGET" ]) || usage
#[ -z "$LIBRARY" ] && [ -z "$IMAGE" ] && usage

shift $((OPTIND-2))

if [ -z "$SPECDIR" ]; then
	initial
fi

case $ACTION in
	FLASH)

		if [ -n "$ACTION_REMOTE" ]; then
			ssh_pull_stuff $@
		fi

		if [ -n "$IMAGE" ]; then
			flash_to_device $@
		elif [ -n "$LIBRARY" ]; then
			push_to_device $@
		else
			echo "Error: flash miss args: -i/-l"
			usage
		fi
	;;
	PULL)
		if [ -z "$LIBRARY" ] && [ -z "$IMAGE" ]; then
			echo "Error: pull miss args: -i/-l"
			usage
		fi
		ssh_pull_stuff $@
	;;
	SHOW)
		show_target_info
	;;	
	*)
		echo "Error: action miss args: -f/-p/-s"
		usage
	;;
		
esac

# Always the last step
if [ -n "$ACTION_REBOOT" ]; then
	echo "reboot"
	adb reboot
fi
