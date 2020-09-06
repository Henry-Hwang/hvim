
#======================================================================
Function Ddump-K2 {
    param([String]$Tag)

    Ainit

	if ($Tag -ne '') {
		$Tag = $Tag + "-K2"
	}

    Ddump -Device1 1-0040 -Device2 1-0042 -SoundCard lahaina-mtp-snd-card -Prefix $Tag
}

Function Ddump-regs-K2 {
    Ainit
    Ddump-regs -Device1 1-0040 -Device2 1-0042
}

#======================================================================
Function Ddump-M2181 {
    param([String]$Tag)

    Ainit

	if ($Tag -ne '') {
		$Tag = $Tag + "-M2181"
	}

    Ddump -Device1 spi1.0 -Device2 spi1.1 -SoundCard sm8350-meizu-snd-card -Prefix $Tag
}

Function Ddump-regs-M2181 {
    Ainit
    Ddump-regs -Device1 spi1.0 -Device2 spi1.1
}

Function Dunload-J17 {
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
		Ddump-M2181 $Count
		adb reboot
		Ainit
	}
}

Function Dreload-M2181 {
    Ainit
	adb shell "tinymix 'DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'DSP1 Preload Switch' '1'"
    adb shell "tinymix 'PCM Source' 'DSP'"
}
#======================================================================
Function Ddump-J17 {
    param([String]$Tag)

    Ainit

	if ($Tag -ne '') {
		$Tag = $Tag + "-J17"
	}

    Ddump -Device1 0-0040 -Device2 0-0041 -Prefix $Tag
}

Function Ddump-regs-J17 {
    Ainit
    Ddump-regs -Device1 0-0040 -Device2 0-0041
}

Function Dunload-J17 {
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
		Ddump-J17 $Count
		adb reboot
		Ainit
	}
}

Function Dreload-J17 {
    Ainit
	adb shell "tinymix 'DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'DSP1 Preload Switch' '1'"
    adb shell "tinymix 'PCM Source' 'DSP'"
}
#======================================================================
Function Ddump-J10 {
    param([String]$Tag)
    Ainit
	if ($Tag -eq '') {
		$Tag = "J10"
	} else {
		$Tag = $Tag + "J10"
	}

    Ddump -Device1 7-0040 -Device2 7-0041 -Prefix J10
}
Function Ddump-regs-J10 {
    Ainit
    Ddump-regs -Device1 7-0040 -Device2 7-0041
}

#======================================================================
Function Ddump-J3S {
    Ainit
    Ddump -Device1 0-0040 -Device2 0-0042
}
Function Ddump-regs-J3S {
    Ainit
    Ddump-regs -Device1 0-0040 -Device2 0-0042
}

#======================================================================
Function Ddump-M2091 {
    Ainit
    Ddump -Device1 spi1.0 -Device2 spi1.1
}

