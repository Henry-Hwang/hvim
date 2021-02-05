Function BS_P_SwapChannel {
    adb shell "tinymix 'DSP1X Protection cd CH_BAL' 00 40 00 00"
    adb shell "tinymix 'RCV DSP1X Protection cd CH_BAL' 00 40 00 00"
    adb shell "cat /d/regmap/2-0040/registers | grep 2800374"
    adb shell "cat /d/regmap/2-0040/registers | grep 2800374"
    
    adb shell "tinymix 'DSP1X Protection cd CH_BAL' 00 00 00 00"
    adb shell "tinymix 'RCV DSP1X Protection cd CH_BAL' 00 00 00 00"
    adb shell "cat /d/regmap/2-0040/registers | grep 2800374"
    adb shell "cat /d/regmap/2-0040/registers | grep 2800374"
}
Function DRelease_Crussp {
    cp C:\work\src\audio-hal\libs\arm64-v8a\cstool          C:\work\customer\xiaomi\Heisha\calibration\lib
    cp C:\work\src\audio-hal\libs\arm64-v8a\libcrussp.so    C:\work\customer\xiaomi\Heisha\calibration\lib
    cp C:\work\src\audio-hal\shared\libstdc++.so               C:\work\customer\xiaomi\Heisha\calibration\lib
    cp C:\work\src\audio-hal\script\push.ps1                   C:\work\customer\xiaomi\Heisha\calibration\lib
}
Function BS_PENROSE_Tinyplay {
    adb shell "tinymix 'TERT_TDM_RX_0 Audio Mixer MultiMedia1', '1'"
    adb shell "tinymix 'TERT_TDM_RX_0 SampleRate', 'KHZ_96'"
    adb shell "tinymix 'TERT_TDM_RX_0 Channels', 'Two'"
    adb shell "tinymix 'TERT_TDM_RX_0 Format', 'S24_LE'"
    adb shell "tinymix 'PCM Source', 'DSP'"
    adb shell "tinymix 'RCV PCM Source', 'DSP'"
    adb shell "tinymix 'AMP PCM Gain', '18'"
    adb shell "tinymix 'RCV AMP PCM Gain', '18'"
    adb shell "tinymix 'DRE DRE Switch', '1'"
    adb shell "tinymix 'RCV DRE DRE Switch', '1'"
    adb shell "tinymix 'DSP RX1 Source', 'ASPRX1'"
    adb shell "tinymix 'DSP RX2 Source', 'ASPRX1'"
    adb shell "tinymix 'RCV DSP RX1 Source', 'ASPRX1'"
    adb shell "tinymix 'RCV DSP RX2 Source', 'ASPRX2'"
    adb shell "tinymix 'RCV ASPRX1 Slot Position', '0'"
    adb shell "tinymix 'RCV ASPRX2 Slot Position', '2'"
    adb shell "tinymix 'ASP TX1 Source', 'DSPTX1'"
    adb shell "tinymix 'ASP TX2 Source', 'Zero'"
    adb shell "tinymix 'RCV ASP TX1 Source', 'Zero'"
    adb shell "tinymix 'RCV ASP TX2 Source', 'DSPTX1'"
    adb shell "tinyplay /vendor/etc/silent-sec.wav"
}
Function BS_PENROSE_Calibration {

    adb shell "tinymix 'DSP Booted' '0'"
    adb shell "tinymix 'DSP1 Preload Switch' '0'"
    adb shell "tinymix 'RCV DSP Booted' '0'"
    adb shell "tinymix 'RCV DSP1 Preload Switch' '0'"
    adb shell "tinymix 'TERT_TDM_RX_0 Audio Mixer MultiMedia1' '0'"

    sleep 1

    adb shell "tinymix 'TERT_TDM_RX_0 Audio Mixer MultiMedia1' '1'"
    adb shell "tinymix 'TERT_TDM_RX_0 SampleRate' 'KHZ_96'"
    adb shell "tinymix 'TERT_TDM_RX_0 Channels' 'Two'"
    adb shell "tinymix 'TERT_TDM_RX_0 Format' 'S24_LE'"

    adb shell "tinymix 'DSP Set AMBIENT' '28'"
    adb shell "tinymix 'RCV DSP Set AMBIENT' '28'"

    adb shell "tinymix 'DSP1 Firmware' 'Calibration'"
    adb shell "tinymix 'DSP1 Preload Switch' '1'"
    adb shell "tinymix 'RCV DSP1 Firmware' 'Calibration'"
    adb shell "tinymix 'RCV DSP1 Preload Switch' '1'"

    adb shell "tinymix 'PCM Source' 'DSP'"
    adb shell "tinymix 'RCV PCM Source' 'DSP'"
    adb shell "tinymix 'Digital PCM Volume' '817'"
    adb shell "tinymix 'RCV Digital PCM Volume' '817'"
    adb shell "tinymix 'AMP PCM Gain' '18'"
    adb shell "tinymix 'RCV AMP PCM Gain' '18'"
    adb shell "tinymix 'DSP RX1 Source' 'ASPRX1'"
    adb shell "tinymix 'DSP RX2 Source' 'ASPRX1'"
    adb shell "tinymix 'RCV DSP RX1 Source' 'ASPRX1'"
    adb shell "tinymix 'RCV DSP RX2 Source' 'ASPRX2'"
    adb shell "tinymix 'RCV ASPRX1 Slot Position' '0'"
    adb shell "tinymix 'RCV ASPRX2 Slot Position' '2'"


    sleep 4

    tinyplay /vendor/etc/silent-3sec.wav

    sleep 4

    echo "----------------------------------"
    adb shell "tinymix 'DSP1 Calibration cd CAL_R'"
    adb shell "tinymix 'DSP1 Calibration cd CAL_STATUS'"
    adb shell "tinymix 'DSP1 Calibration cd CAL_CHECKSUM'"
    adb shell "tinymix 'DSP1 Calibration cd CAL_AMBIENT'"
    adb shell "tinymix 'DSP1 Calibration cd DIAG_F0_STATUS'"
    adb shell "tinymix 'DSP1 Calibration cd DIAG_F0'"
    adb shell "tinymix 'DSP1 Calibration cd DIAG_Z_LOW_DIFF'"
    adb shell "tinymix 'DSP1 Calibration cd CSPL_STATE'"
    echo "----------------------------------"
    adb shell "tinymix 'RCV DSP1 Calibration cd CAL_R'"
    adb shell "tinymix 'RCV DSP1 Calibration cd CAL_STATUS'"
    adb shell "tinymix 'RCV DSP1 Calibration cd CAL_CHECKSUM'"
    adb shell "tinymix 'RCV DSP1 Calibration cd CAL_AMBIENT'"
    adb shell "tinymix 'RCV DSP1 Calibration cd DIAG_F0_STATUS'"
    adb shell "tinymix 'RCV DSP1 Calibration cd DIAG_F0'"
    adb shell "tinymix 'RCV DSP1 Calibration cd DIAG_Z_LOW_DIFF'"
    adb shell "tinymix 'RCV DSP1 Calibration cd CSPL_STATE'"
    echo "----------------------------------"

    adb shell "tinymix" > cali-tinymix.txt
    adb shell logcat -d > cali-logcat.txt
    adb shell dmesg > cali-dmesg.txt
    adb shell "cat /d/regmap/1-0040/registers" > cali-regs-40.txt
    adb shell "cat /d/regmap/1-0041/registers" > cali-regs-41.txt

    adb shell "tinymix 'DSP Booted' '0'"
    adb shell "tinymix 'DSP1 Preload Switch' '0'"
    adb shell "tinymix 'RCV DSP Booted' '0'"
    adb shell "tinymix 'RCV DSP1 Preload Switch' '0'"

    adb shell "tinymix 'TERT_TDM_RX_0 Audio Mixer MultiMedia1' '0'"

    adb shell "tinymix 'DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'DSP1 Preload Switch' '1'"
    adb shell "tinymix 'RCV DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'RCV DSP1 Preload Switch' '1'"

}

Function BS_PENROSE_Diagnostic {

    adb shell "tinymix 'DSP Booted' '0'"
    adb shell "tinymix 'DSP1 Preload Switch' '0'"
    adb shell "tinymix 'RCV DSP Booted' '0'"
    adb shell "tinymix 'RCV DSP1 Preload Switch' '0'"
    adb shell "tinymix 'TERT_TDM_RX_0 Audio Mixer MultiMedia1' '0'"

    sleep 1

    adb shell "tinymix 'TERT_TDM_RX_0 Audio Mixer MultiMedia1' '1'"
    adb shell "tinymix 'TERT_TDM_RX_0 SampleRate' 'KHZ_96'"
    adb shell "tinymix 'TERT_TDM_RX_0 Channels' 'Two'"
    adb shell "tinymix 'TERT_TDM_RX_0 Format' 'S24_LE'"

    adb shell "tinymix 'DSP Set AMBIENT' '28'"
    adb shell "tinymix 'RCV DSP Set AMBIENT' '28'"

    adb shell "tinymix 'DSP1 Firmware' 'Diagnostic'"
    adb shell "tinymix 'DSP1 Preload Switch' '1'"
    adb shell "tinymix 'RCV DSP1 Firmware' 'Diagnostic'"
    adb shell "tinymix 'RCV DSP1 Preload Switch' '1'"

    adb shell "tinymix 'PCM Source' 'DSP'"
    adb shell "tinymix 'RCV PCM Source' 'DSP'"
    adb shell "tinymix 'Digital PCM Volume' '817'"
    adb shell "tinymix 'RCV Digital PCM Volume' '817'"
    adb shell "tinymix 'AMP PCM Gain' '18'"
    adb shell "tinymix 'RCV AMP PCM Gain' '18'"
    adb shell "tinymix 'DSP RX1 Source' 'ASPRX1'"
    adb shell "tinymix 'DSP RX2 Source' 'ASPRX1'"
    adb shell "tinymix 'RCV DSP RX1 Source' 'ASPRX1'"
    adb shell "tinymix 'RCV DSP RX2 Source' 'ASPRX2'"
    adb shell "tinymix 'RCV ASPRX1 Slot Position' '0'"
    adb shell "tinymix 'RCV ASPRX2 Slot Position' '2'"


    sleep 4

    tinyplay /vendor/etc/silent-3sec.wav

    sleep 4

    echo "----------------------------------"
    adb shell "tinymix 'DSP1 Diagnostic cd CAL_R'"
    adb shell "tinymix 'DSP1 Diagnostic cd CAL_STATUS'"
    adb shell "tinymix 'DSP1 Diagnostic cd CAL_CHECKSUM'"
    adb shell "tinymix 'DSP1 Diagnostic cd CAL_AMBIENT'"
    adb shell "tinymix 'DSP1 Diagnostic cd DIAG_F0_STATUS'"
    adb shell "tinymix 'DSP1 Diagnostic cd DIAG_F0'"
    adb shell "tinymix 'DSP1 Diagnostic cd DIAG_Z_LOW_DIFF'"
    adb shell "tinymix 'DSP1 Diagnostic cd CSPL_STATE'"
    echo "----------------------------------"
    adb shell "tinymix 'RCV DSP1 Diagnostic cd CAL_R'"
    adb shell "tinymix 'RCV DSP1 Diagnostic cd CAL_STATUS'"
    adb shell "tinymix 'RCV DSP1 Diagnostic cd CAL_CHECKSUM'"
    adb shell "tinymix 'RCV DSP1 Diagnostic cd CAL_AMBIENT'"
    adb shell "tinymix 'RCV DSP1 Diagnostic cd DIAG_F0_STATUS'"
    adb shell "tinymix 'RCV DSP1 Diagnostic cd DIAG_F0'"
    adb shell "tinymix 'RCV DSP1 Diagnostic cd DIAG_Z_LOW_DIFF'"
    adb shell "tinymix 'RCV DSP1 Diagnostic cd CSPL_STATE'"
    echo "----------------------------------"


    adb shell "tinymix" > diag-tinymix.txt
    adb shell logcat -d > diag-logcat.txt
    adb shell dmesg > diag-dmesg.txt
    adb shell "cat /d/regmap/1-0040/registers" > diag-regs-40.txt
    adb shell "cat /d/regmap/1-0041/registers" > diag-regs-41.txt


    adb shell "tinymix 'DSP Booted' '0'"
    adb shell "tinymix 'DSP1 Preload Switch' '0'"
    adb shell "tinymix 'RCV DSP Booted' '0'"
    adb shell "tinymix 'RCV DSP1 Preload Switch' '0'"

    adb shell "tinymix 'TERT_TDM_RX_0 Audio Mixer MultiMedia1' '0'"

    adb shell "tinymix 'DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'DSP1 Preload Switch' '1'"
    adb shell "tinymix 'RCV DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'RCV DSP1 Preload Switch' '1'"
}
