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
Function Dunmask-MboxIrq-J10 {
}


Function DPortBlock-j10 {
	Ainit
    # Unlock IRQ
    adb shell "echo 10114 FFDFFFFF > /d/regmap/7-0040/registers"
    adb shell "echo 10114 FFDFFFFF > /d/regmap/7-0041/registers"

    while($Count -lt 1000) {
        $Count++
        sleep 1.5
        adb shell "tinymix 'Speaker Port Blocked Status'"
        adb shell "tinymix 'RCV Speaker Port Blocked Status'"
    }
}
