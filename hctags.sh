#!/bin/bash

# This script base on
# https://www.shellscript.sh/tips/getopts/
ADIRS=( 	"hardware/qcom/audio"
			"system/media/audio_route"
			"external/tinyalsa" )

KDIRS=( 	"vendor/qcom/opensource/audio-kernel"
			"kernel/msm-4.14/sound"
			"kernel/msm-4.14/include"
			"kernel/msm-4.14/drivers/base/regmap"
			"kernel/msm-4.14/drivers/mfd" )
usage()
{
	echo ""
	echo "Usage: $0 [-k|-a|-v|-d|-l-c] [ -g PATTEN ]"
	echo ""
	echo "NOTE: 1) Run htag script in Android Root directory"
	echo "      2) Make sure all the directory are there"
	echo "      3) Tags (aktags, atags, ktags) file will be put in Android Root Directory"

	echo ""
	echo "-t : Create ctags file"
	echo "-c : Create Cscope file (no ready yet)"
	echo "-k : Create tag file for audio under kernel"
	echo "-a : Create tag file for audio for android audio hal"
	echo "-f : Specific the tags name"
	echo "-d : Specific the directorys that tags file come from"

	echo ""
	echo "Example:"
	echo "Tag Default: (aktags)"
	echo "    $ htag.sh -t"
	echo "Tag for mutipile directory: (ftags)"
	echo "    $ htag.sh -t -d hardware kernel vendor"
	echo "Tag for audio hal (atags):"
	echo "    $ htag.sh -ta"
	echo "Tag for audio kernel (ktags):"
	echo "    $ htag.sh -tk"
	
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
ctags_audioh_create() {
	local filter=
	local combined=( "${ADIRS[@]}" )
	echo "args: $@"
	
	if [ -z "$TAGDIR" ]; then
		for dir in "${combined[@]}";
		do
			if [ -z "$filter" ]; then
				filter=$(pwd)/$dir
			else
				filter=$filter\ $(pwd)/$dir
			fi
		done
		echo "$filter"
		ctags -R -f atags $filter
	else
		ctags -R -f atags $@
	fi
}
ctags_audiok_create() {
	local filter=
	local combined=( "${KDIRS[@]}" )
	echo "args: $@"
	
	if [ -z "$TAGDIR" ]; then
		for dir in "${combined[@]}";
		do
			if [ -z "$filter" ]; then
				filter=$(pwd)/$dir
			else
				filter=$filter\ $(pwd)/$dir
			fi
		done
		echo "$filter"
		ctags -R -f ktags $filter
	else
		ctags -R -f ktags $@
	fi
}
ctags_default_create() {
	local filter=
	local combined=( "${ADIRS[@]}" "${KDIRS[@]}" )
	#local combined=("${ADIRS[@]}")
	#combined+=("${KDIRS[@]}")
	echo "args: $@"
	
	if [ -z "$TAGDIR" ]; then
		for dir in "${combined[@]}";
		do
			if [ -z "$filter" ]; then
				filter=$(pwd)/$dir
			else
				filter=$filter\ $(pwd)/$dir
			fi
		done
		echo "$filter"
		ctags -R -f aktags $filter
	else
		ctags -R -f aktags $@
	fi
}

####################################################################
# Main script starts here
unset TARGET IMAGE LIBRARY ACTION ACTION_REBOOT

while getopts 'tckaf:d:?h' c
do
case $c in
	# Show remote server information
	t) set_variable ACTION TAGS ;;
	c) set_variable ACTION CSCOPE ;;
	k) set_variable ATTRIBUTE KERNEL ;;
	a) set_variable ATTRIBUTE AUDIO ;;
	d) set_variable TAGDIR $OPTARG ;;
	f) set_variable TAGNAME $OPTARG ;;

	h|?) usage ;; esac
done

#([ -n "$ACTION" ] && [ -n "$TARGET" ]) || usage
#[ -z "$LIBRARY" ] && [ -z "$IMAGE" ] && usage

shift $((OPTIND-2))

case $ACTION in
	TAGS)
		case $ATTRIBUTE in
			AUDIO) ctags_audioh_create $@ ;;
			KERNEL) ctags_audiok_create $@ ;;
			*) ctags_default_create $@ ;;
		esac
		
	;;
	CSCOPE)
		case $ATTRIBUTE in
			AUDIO) ctags_default_create $@ ;;
			KERNEL) ctags_default_create $@ ;;
			*) ctags_default_create $@ ;;
		esac
	;;
	*)
		echo "no support log ACTION : $ACTION"
		usage
	;;
esac
