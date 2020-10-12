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
Function Dlogs-M2181 {
    Dlogs -Name M2181 -Device1 spi1.0 -Device2 spi1.1 -SoundCard sm8350-meizu-snd-card
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

Function TxRecord-M2181 {
    param([Int32]$Second = 10)
    Ainit
    $Wav = "/sdcard/Download/rec.wav"
    adb shell "tinymix 'RCV ASP_TX1 Source' 'DSP_TX1'"
    adb shell "tinymix 'SPK ASP_TX2 Source' 'DSP_TX1'"
    adb shell "tinymix 'MultiMedia1 Mixer PRI_MI2S_TX' 1"
    adb shell "tinymix 'PRIM_MI2S_TX SampleRate' KHZ_48"
    adb shell "tinymix 'PRIM_MI2S_TX Format' S16_LE"
    adb shell "tinymix 'PRIM_MI2S_TX Channels' 'Two'"
    adb shell "tinycap $Wav -D 0 -d 0 -r 48000 -c 2 -T $Second"
    adb pull $Wav .
    start .
}

Function TxEcho-M2181 {
    param([String]$Switch)
    Ainit
    if ($Switch -eq 'Off') {
        adb shell "tinymix 'RCV TxEcho' 'Zero'"
        #adb shell "tinymix 'RCV ASP_TX1 Source' 'Zero'"
        adb shell "tinymix 'SPK TxEcho' 'Zero'"
        #adb shell "tinymix 'SPK ASP_TX1 Source' 'Zero'"
    } else {
        adb shell "tinymix 'RCV TxEcho' 'ASP_TX1'"
        adb shell "tinymix 'SPK TxEcho' 'ASP_TX1'"
        adb shell "tinymix 'RCV ASP_TX1 Source' 'DSP_TX1'"
        adb shell "tinymix 'SPK ASP_TX1 Source' 'DSP_TX1'"
    }
}

#adb shell input keyevent 24 # Volume Up
#adb shell input keyevent 25 # Volume Download
Function VolumeTest {
    Ainit
	$Count = 0
    while($Count++ -lt 100) {
        $Key = 24, 25 | Get-Random
        echo $Key
        sleep 0.5
        adb shell input keyevent $Key # Volume Up/Down
        adb shell input keyevent $Key # Volume Up/Down
    }
}
#adb shell "tinymix 'RCV Fast Use Case Delta File' 's35l45-delta-rcv-music.txt'"
#adb shell "tinymix 'RCV Fast Use Case Switch Enable' '1'"
Function DeltaTest {

    Ainit
	$Count = 0
    while($Count++ -lt 100) {
        sleep 0.5
        $Index = 0, 1 | Get-Random
        echo $Index
        adb shell "tinymix 'RCV Fast Use Case Switch Enable' 0"
        adb shell "tinymix 'SPK Fast Use Case Switch Enable' 0"
        adb shell "tinymix 'RCV Fast Use Case Delta File' '$Index'"
        adb shell "tinymix 'SPK Fast Use Case Delta File' '$Index'"
        adb shell "tinymix 'RCV Fast Use Case Switch Enable' 1"
        adb shell "tinymix 'SPK Fast Use Case Switch Enable' 1"
    }
}
