#!/bin/bash
DIR_ROOT=$1
DIR_HAL_AUDIO=$DIR_ROOT/hardware/qcom/audio
DIR_SYS_ROUTE=$DIR_ROOT/system/media/audio_route
DIR_TINYALSA=$DIR_ROOT/external/tinyalsa
ctags -R -f $DIR_AUIO_HAL/tags $DIR_HAL_AUDIO $DIR_SYS_ROUTE $DIR_TINYALSA

# generate tag file for lookupfile plugin
echo -e "!_TAG_FILE_SORTED\t2\t/2=foldcase/" > $DIR_HAL_AUDIO/filenametags
find $DIR_HAL_AUDIO -not -regex '.*\.\(png\|gif\)' -type f -printf "%f\t%p\t1\n" | \
    sort -f >> $DIR_HAL_AUDIO/filenametags
find $DIR_SYS_ROUTE -not -regex '.*\.\(png\|gif\)' -type f -printf "%f\t%p\t1\n" | \
    sort -f >> $DIR_HAL_AUDIO/filenametags
find $DIR_TINYALSA -not -regex '.*\.\(png\|gif\)' -type f -printf "%f\t%p\t1\n" | \
    sort -f >> $DIR_HAL_AUDIO/filenametags
