Function DRelease_Crussp {
    cp C:\work\src\audio-hal\libs\arm64-v8a\cstool          C:\work\customer\xiaomi\Heisha\calibration\lib
    cp C:\work\src\audio-hal\libs\arm64-v8a\libcrussp.so    C:\work\customer\xiaomi\Heisha\calibration\lib
    cp C:\work\src\audio-hal\shared\libstdc++.so               C:\work\customer\xiaomi\Heisha\calibration\lib
    cp C:\work\src\audio-hal\script\push.ps1                   C:\work\customer\xiaomi\Heisha\calibration\lib
}

Function DPort-Block-BS {
	Ainit
    while($Count -lt 100) {
        $Count++
        sleep 1
        adb shell "tinymix 'Speaker Port Blocked Status'"
        adb shell "tinymix 'RCV Speaker Port Blocked Status'"
    }
}

Function Dtplay-BS {
    $Wav="/sdcard/Music/lrp_loop.wav"
    adb shell "tinymix 'TERT_TDM_RX_0 Audio Mixer MultiMedia1' 1"
    #adb shell "tinymix 'TERT_TDM_RX_0 SampleRate' 'KHZ_96'"
    adb shell "tinymix 'TERT_TDM_RX_0 SampleRate' 'KHZ_48'"
    adb shell "tinymix 'TERT_TDM_RX_0 Channels' 'Two'"
    adb shell "tinymix 'TERT_TDM_RX_0 Format' 'S24_LE'"
    adb shell "tinymix 'PCM Source' 'DSP'"
    adb shell "tinymix 'RCV PCM Source' 'DSP'"
    adb shell "tinymix 'AMP PCM Gain' 16"
    adb shell "tinymix 'RCV AMP PCM Gain' 16"
    adb shell "tinymix 'DRE DRE Switch' 1"
    adb shell "tinymix 'RCV DRE DRE Switch' 1"
    adb shell "tinymix 'DSP RX1 Source' 'ASPRX1'"
    adb shell "tinymix 'DSP RX2 Source' 'ASPRX1'"
    adb shell "tinymix 'ASPRX1 Slot Position' '1'"
    adb shell "tinymix 'ASPRX2 Slot Position' '4'"
    adb shell "tinymix 'RCV DSP RX1 Source' 'ASPRX1'"
    adb shell "tinymix 'RCV DSP RX2 Source' 'ASPRX2'"
    adb shell "tinymix 'RCV ASPRX1 Slot Position' '0'"
    adb shell "tinymix 'RCV ASPRX2 Slot Position' '2'"
    adb shell "tinymix 'ASP TX1 Source' 'DSPTX1'"
    adb shell "tinymix 'ASP TX2 Source' 'Zero'"
    adb shell "tinymix 'RCV ASP TX1 Source' 'Zero'"
    adb shell "tinymix 'RCV ASP TX2 Source' 'DSPTX1'"
    adb shell "tinyplay $Wav"
}

Function Dunload-BS {
    Ainit
    adb shell "tinymix 'PCM Source' 'None'"
    adb shell "tinymix 'DSP Booted' '0'"
    adb shell "tinymix 'DSP1 Preload Switch' '0'"
}

Function FirstSilent {
	Ainit
	adb reboot
	$Count = 0
    while($Count -lt 5) {
        $Count++
		echo $Count
		sleep 30
		#adb shell input keyevent 27  #POWER
		adb shell input swipe 200 1700 200 300 # SWIPE UP

		adb shell input keyevent 3  #HOME
		sleep 1
		adb shell input tap 134 2039 # tap CALL PAD
		sleep 1
		adb shell input tap 994 1959 # tap PAD
		sleep 1
		adb shell input tap 210 1321 # tap 1
		sleep 1
		adb shell input tap 210 1321 # tap 1
		sleep 1
		adb shell input tap 539 1299 # tap 2
		sleep 1
		adb shell input tap 543 2138 # tap CALL
		sleep 3
		adb shell input tap 540 1086 # tap SPK-RCV
		sleep 2
		adb shell input tap 552 2057 # tap Hangup
		Ddump-BS $Count
		adb reboot
		Ainit
	}
}

Function Dreload-BS {
    Ainit
	adb shell "tinymix 'DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'DSP1 Preload Switch' '1'"
    adb shell "tinymix 'PCM Source' 'DSP'"
}

Function MassTest {
    Ainit
    $Count = 100
	adb shell input keyevent 27  #POWER
	sleep 2
	adb shell input swipe 200 1700 200 300 # SWIPE UP
    sleep 1
    while($Count-- -gt 0) {
        #Call 112
        adb shell service call phone 1 s16 112
        sleep 1
	    adb shell input tap 533 2156 # tap CALL
        Write-Host $Count "Calls"
	    $ModeCount = 15
        while($ModeCount-- -gt 0) {
            sleep 1
	        adb shell input tap 215 2060 # tap Handsfree/Handset
            Write-Host $ModeCount "Switch"
        }
	    adb shell input tap 541 2073 # tap Hang up
        sleep 6
    }
}

Function TxRecord-BS {
    adb wait-for-device root
    adb wait-for-device remount

    adb shell "tinymix 'RCV ASP_TX1 Source' 'DSP_TX1'"
    adb shell "tinymix 'ASP_TX2 Source' 'DSP_TX1'"

    adb shell "tinymix 'MultiMedia1 Mixer TERT_MI2S_TX' 1"
    adb shell "tinymix 'TERT_MI2S_TX SampleRate' KHZ_48"
    adb shell "tinymix 'TERT_MI2S_TX Format' S24_LE"
    adb shell "tinymix 'TERT_MI2S_TX Channels' 'Two'"

    adb shell "echo 4c20 18 > /d/regmap/3-0030/registers"
    adb shell "echo 4c24 18 > /d/regmap/3-0031/registers"

    adb shell "tinycap /data/rec.wav -D 0 -d 0 -r 48000 -c 2 -T 30"

    adb pull /data/rec.wav .
    start .
}
    #adb shell "cat /d/regmap/3-0030/registers" > regs-3-0030.txt
    #adb shell "cat /d/regmap/3-0031/registers" > regs-3-0031.txt
    #cat regs-3-0030.txt | findstr 4800:
    #cat regs-3-0031.txt | findstr 4800:
