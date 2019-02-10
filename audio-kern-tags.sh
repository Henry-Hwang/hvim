#!/bin/bash
DIR_ROOT=$1
DIR_KERN_AUDIO=$DIR_ROOT/vendor/qcom/opensource/audio-kernel
DIR_KERN_SOUND=$DIR_ROOT/kernel/msm-4.14/sound
DIR_KERN_INCLUDE=$DIR_ROOT/kernel/msm-4.14/include
DIR_KERN_REGMAP=$DIR_ROOT/kernel/msm-4.14/drivers/base/regmap
ctags -R -f $DIR_KERN_AUDIO/tags $DIR_KERN_AUDIO $DIR_KERN_SOUND $DIR_KERN_INCLUDE $DIR_KERN_REGMAP

# generate tag file for lookupfile plugin
echo -e "!_TAG_FILE_SORTED\t2\t/2=foldcase/" > $DIR_KERN_AUDIO/filenametags
find $DIR_KERN_AUDIO -not -regex '.*\.\(png\|gif\)' -type f -printf "%f\t%p\t1\n" | \
    sort -f >> $DIR_KERN_AUDIO/filenametags
find $DIR_KERN_SOUND -not -regex '.*\.\(png\|gif\)' -type f -printf "%f\t%p\t1\n" | \
    sort -f >> $DIR_KERN_AUDIO/filenametags
find $DIR_KERN_INCLUDE -not -regex '.*\.\(png\|gif\)' -type f -printf "%f\t%p\t1\n" | \
    sort -f >> $DIR_KERN_AUDIO/filenametags
find $DIR_KERN_REGMAP -not -regex '.*\.\(png\|gif\)' -type f -printf "%f\t%p\t1\n" | \
    sort -f >> $DIR_KERN_AUDIO/filenametags
