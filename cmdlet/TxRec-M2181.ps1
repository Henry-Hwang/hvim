
adb wait-for-device root
adb wait-for-device remount

adb shell "echo 480c 1 > /d/regmap/3-0030/registers"
adb shell "echo 480c 1 > /d/regmap/3-0031/registers"
adb shell "echo 4808 20200200 > /d/regmap/3-0030/registers"
adb shell "echo 4808 20200200 > /d/regmap/3-0031/registers"

adb shell "tinymix 'RCV TxEcho' 'ASP_TX1'"
adb shell "tinymix 'TxEcho' 'ASP_TX1'"
adb shell "tinymix 'RCV ASP_TX1 Source' 'DSP_TX1'"
adb shell "tinymix 'ASP_TX2 Source' 'DSP_TX1'"
adb shell "tinymix 'MultiMedia1 Mixer TERT_MI2S_TX' 1"
adb shell "tinymix 'TERT_MI2S_TX SampleRate' KHZ_48"
adb shell "tinymix 'TERT_MI2S_TX Format' S24_LE"
adb shell "tinymix 'TERT_MI2S_TX Channels' 'Two'"


adb shell "echo 2014 0 > /d/regmap/3-0030/registers"

adb shell "tinycap /sdcard/Download/rec.wav -D 0 -d 0 -r 48000 -c 2 -T 60"
