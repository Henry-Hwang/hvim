Function Reload-K10A {
    param([String]$RCV, $SPK)

    adb wait-for-device root
    adb wait-for-device remount
    adb shell "input keyevent 85"
    sleep 4

    if ($SPK) {
        echo "reload SPK tuning"
        adb push $SPK /vendor/firmware/cs35l41-dsp1-spk-prot.bin
        adb shell "tinymix 'DSP1 Preload Switch' '0'"
        adb shell "tinymix 'DSP1 Boot Switch' '0'"
        sleep 0.5
        adb shell "tinymix 'DSP1 Preload Switch' '1'"
        adb shell "tinymix 'DSP1 Boot Switch' '1'"
    }


    if ($RCV) {
        echo "reload RCV tuning"
        adb push $RCV /vendor/firmware/RCV-cs35l41-dsp1-spk-prot.bin
        adb shell "tinymix 'RCV DSP1 Preload Switch' '0'"
        adb shell "tinymix 'RCV DSP1 Boot Switch' '0'"
        sleep 0.5
        adb shell "tinymix 'RCV DSP1 Preload Switch' '1'"
        adb shell "tinymix 'RCV DSP1 Boot Switch' '1'"
    }

    sleep 2
    adb shell "input keyevent 85"
}
