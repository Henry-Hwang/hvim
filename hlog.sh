#!/bin/bash

# This script base on
# https://www.shellscript.sh/tips/getopts/

usage()
{
	echo ""
	echo "Usage: $0 [-k|-a|-v|-d|-l-c] [ -g PATTEN ]"
	echo ""
	echo "-a : Show logcat"
	echo "-k : Show Dmesg"
	echo "-c : Clear log both on screen and deivce"
	echo "-v : Save log and Vim opne it"
	echo "-l : Dmesg with loop print"
	echo "-d : Default setting"
	echo "-g : Grep filter"

	echo ""
	echo "Example:"
	echo "Dmesg Default:"
	echo "    $ hlog.sh -kd -g CSPL cs35l41"
	echo "Dmesg View log with Vim:"
	echo "    $ hlog.sh -kv -g CSPL cs35l41"
	echo "Dmesg loop print:"
	echo "    $ hlog.sh -kl -g CSPL cs35l41"
	echo "Logcat Default:"
	echo "    $ hlog.sh -a -g audio_hw cirrus"
	echo "Logcat to screen and save to file (./logcat.txt):"
	echo "    $ hlog.sh -av -g audio_hw cirrus"
	
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

logcat_default_filter() {
	#adb wait-for-device root
	#adb wait-for-device remount
	local filter=
	echo "args: $@"
	for patten in $@;
	do
		if [ -z "$filter" ]; then
			filter=$patten
		else
			filter=$filter\|$patten
		fi
		echo "$filter"
	done
	

	if [ -z "$GREP" ]; then
		adb shell logcat
	else
		adb shell logcat | grep -iE $filter
	fi
}
logcat_view_filter() {
	#adb wait-for-device root
	#adb wait-for-device remount
	local filter=
	echo "args: $@"
	for patten in $@;
	do
		if [ -z "$filter" ]; then
			filter=$patten
		else
			filter=$filter\|$patten
		fi
		echo "$filter"
	done
	

	if [ -z "$GREP" ]; then
		adb shell logcat | tee logcat.txt
	else
		adb shell logcat | grep -iE $filter | tee logcat.txt
	fi
}
dmesg_default_filter() {
	#adb wait-for-device root
	#adb wait-for-device remount
	local filter=
	echo "args: $@"
	for patten in $@;
	do
		if [ -z "$filter" ]; then
			filter=$patten
		else
			filter=$filter\|$patten
		fi
		echo "$filter"
	done
	
	if [ -z "$GREP" ]; then
		adb shell dmesg | tee dmesg-view.txt
	else
		adb shell dmesg | grep -iE $filter | tee dmesg-view.txt

	fi
}

dmesg_view_filter() {
	#adb wait-for-device root
	#adb wait-for-device remount
	local filter=
	echo "args: $@"
	for patten in $@;
	do
		if [ -z "$filter" ]; then
			filter=$patten
		else
			filter=$filter\|$patten
		fi
		echo "$filter"
	done
	
	if [ -z "$GREP" ]; then
		adb shell dmesg  > dmesg-view.txt
	else
		adb shell dmesg | grep -iE $filter > dmesg-view.txt
	fi
	
	# Show log in vim
	vim dmesg-view.txt
}

dmesg_loop_filter() {
	#adb wait-for-device root
	#adb wait-for-device remount
	local filter=
	echo "args: $@"
	for patten in $@;
	do
		if [ -z "$filter" ]; then
			filter=$patten
		else
			filter=$filter\|$patten
		fi
		echo "$filter"
	done
	
	while true
	do
	
		if [ -z "$GREP" ]; then
			adb shell dmesg -c
		else
			adb shell dmesg -c | grep -iE $filter
		fi
		sleep 1
	done
}
####################################################################
# Main script starts here
unset TARGET IMAGE LIBRARY ACTION ACTION_REBOOT

while getopts 'aklvdcg:?h' c
do
case $c in
	# Show remote server information
	a) set_variable ACTION LOGCAT ;;
	k) set_variable ACTION DMESG ;;
	l) set_variable ATTRIBUTE LOOP ;;
	v) set_variable ATTRIBUTE VIEW ;;
	d) set_variable ATTRIBUTE DEFAULT ;;
	c) set_variable CLEAR RESET ;;
	g) set_variable GREP $OPTARG ;;

	h|?) usage ;; esac
done

#([ -n "$ACTION" ] && [ -n "$TARGET" ]) || usage
#[ -z "$LIBRARY" ] && [ -z "$IMAGE" ] && usage

shift $((OPTIND-2))

adb wait-for-device root
adb wait-for-device remount
case $ACTION in
	LOGCAT)
		if [ -n "$CLEAR" ]; then
			adb shell logcat -c
			reset
		fi
		case $ATTRIBUTE in
			VIEW) logcat_view_filter $@ ;;
			DEFAULT) logcat_default_filter $@ ;;
			*) logcat_default_filter $@ ;;
		esac
		
	;;
	DMESG)
		if [ -n "$CLEAR" ]; then
			adb shell dmesg -c
			reset
		fi
		case $ATTRIBUTE in
			LOOP) dmesg_loop_filter $@ ;;
			VIEW) dmesg_view_filter $@ ;;
			DEFAULT) dmesg_default_filter $@ ;;
			*) dmesg_default_filter $@ ;;
		esac
	;;
	*)
		echo "no support log ACTION : $ACTION"
		usage
	;;
esac
