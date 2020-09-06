Function Dprdbg {
    Ainit
    adb shell "echo 'file soc-utils.c +p' > /sys/kernel/debug/dynamic_debug/control"
    adb shell "echo 'file soc-dapm.c +p' > /sys/kernel/debug/dynamic_debug/control"
    adb shell "echo 'file soc-pcm.c +p' > /sys/kernel/debug/dynamic_debug/control"
    adb shell "echo 'file soc-core.c +p' > /sys/kernel/debug/dynamic_debug/control"
    adb shell "echo 'file kona.c +p' > /sys/kernel/debug/dynamic_debug/control"
}

#Dbg-KernLoop -Patten "cs35|cirrus"
Function DLdmesg {
    param([String]$Patten)
    Ainit
    echo $Patten
    while(1) {
       # adb shell dmesg -c | rg -ie "cs35|cspl|cirrus|-0040|-0041|kona"
       adb shell dmesg -c | rg -ie $Patten
    }
}

#Dbg-KernLoop -Patten "cs35|cirrus"
Function DLlogcat {
    param([String]$Patten)
    Ainit
    echo $Patten
    while(1) {
       adb shell logcat -d | rg -ie $Patten
       adb shell logcat -c
    }
}

Function Dminidm {
    Ainit
    adb shell setprop sys.usb.config diag,adb
    adb wait-for-device
    sleep 2
    mode
}

Function Dshowfw {
    Ainit
    adb shell "find /vendor/firmware/ -name '*cs35*' | xargs ls -l"
    adb shell "find /vendor/firmware/ -name '*cs35*' | xargs md5sum"
}

Function DTmix {
    param([String]$Name)
    $TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
	if ($Name -eq '') {
		$FileName="Tinymix-" + "$TimeStr" + ".txt"
	} else {
		$FileName="$Name" + "-" + "Tinymix-" + "$TimeStr" + ".txt"
	}
    adb shell tinymix > $FileName
    echo $FileName
	gvim $FileName
}

Function Dlogcat {
    param([String]$Name)
    $TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
	if ($Name -eq '') {
		$FileName="logcat-" + "$TimeStr" + ".txt"
	} else {
		$FileName="$Name" + "-" + "logcat-" + "$TimeStr" + ".txt"
	}
    adb shell logcat -d > $FileName
    echo $FileName
	gvim $FileName
}

Function Ddmesg {
    param([String]$Name)
    $TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
	if ($Name -eq '') {
		$FileName="dmesg-" + "$TimeStr" + ".txt"
	} else {
		$FileName="$Name" + "-" + "dmesg-" + "$TimeStr" + ".txt"
	}
    adb shell dmesg > $FileName
    echo $FileName
	gvim $FileName
}

Function Ddump {
    param([String]$Device1, $Device2, $Prefix, $SoundCard)

    $TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
    if ($Prefix -ne '') {
        $Prefix=$Prefix + "-"
    }
    $Dapm1="/d/asoc/" + $SoundCard + "/" + $Device1 + "/" + "dapm/*"
    $Dapm2="/d/asoc/" + $SoundCard + "/" + $Device2 + "/" + "dapm/*"

    $Regmap="/d/regmap"
    $NodeBypass1=$Regmap + "/" + $Device1 + "/" + "cache_bypass"
    $NodeBypass2=$Regmap + "/" + $Device2 + "/" + "cache_bypass"
    $NodeRegisters1=$Regmap + "/" + $Device1 + "/" + "registers"
    $NodeRegisters2=$Regmap + "/" + $Device2 + "/" + "registers"
    $DumpDir = $Prefix + "Dump-" + $TimeStr

    new-item -path . -name $DumpDir -type directory
    Set-Location -Path $DumpDir

    $DapmName1 = $Prefix + $Device1 + "-dapm-" + $TimeStr + ".txt"
    $DapmName2 = $Prefix + $Device2 + "-dapm-" + $TimeStr + ".txt"
    $RegName1 = $Prefix + $Device1 + "-registers-" + $TimeStr + ".txt"
    $RegName2 = $Prefix + $Device2 + "-registers-" + $TimeStr + ".txt"
    $TinymixName = $Prefix + "Tinymix-" + $TimeStr + ".txt"
    $DmesgName = $Prefix + "Dmesg-" + $TimeStr + ".txt"
    $LogcatName = $Prefix + "Logcat-" + $TimeStr + ".txt"

   # echo $NodeBypass1
   # echo $NodeBypass2
   # echo $NodeRegisters1
   # echo $NodeRegisters2
   # echo $RegName1
   # echo $RegName2
   # echo $TinymixName
   # echo $DmesgName
   # echo $LogcatName
    # Android
    adb shell dmesg > $DmesgName
    adb logcat -d > $LogcatName
    adb shell tinymix > $TinymixName
    adb shell "echo Y > $NodeBypass1"
    adb shell "echo Y > $NodeBypass2"
    #<
    adb shell "cat $NodeRegisters1" > $RegName1
    adb shell "cat $NodeRegisters2" > $RegName2
    adb shell "echo N > $NodeBypass1"
    adb shell "echo N > $NodeBypass2"
    adb shell "cat $Dapm1" > $DapmName1
    adb shell "cat $Dapm2" > $DapmName2
    #
    Set-Location -Path ..
    Get-ChildItem -Path $DumpDir
}


Function Dbackup {
    param([String]$Name)
    Ainit

	if ($Name -ne '') {
		$Name=$Name+"-"
	}

	$TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
    $BackupDir = $Name + "Backup-" + $TimeStr

	new-item -path . -name $BackupDir -type directory
    new-item -path $BackupDir -name lib -type directory
    Set-Location -Path $BackupDir

	adb pull /vendor/lib/modules lib/
    adb pull /vendor/lib/hw lib/
    adb pull /vendor/lib/rfsa lib/
    adb pull /vendor/etc .
    adb pull /vendor/firmware .

	Set-Location -Path ..
    Get-ChildItem -Path $BackupDir
}

Function Dwisce {
    Ainit
    adb forward tcp:22349 tcp:22349
    adb shell
}

Function Daudio-kill {
    adb shell "pgrep -f audioserver | xargs kill"
}

Function Dlogs {
	param([String]$Name)

	if ($Name -ne '') {
		$Name=$Name+"-"
	}

	$TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
	$LogDir = $Name + "Log-" + $TimeStr
	$DmesgName = $Name + "Dmesg-" + $TimeStr+".txt"
	$LogcatName = $Name + "Logcat-" + $TimeStr+".txt"
	$TmixName = $Name + "Tinymix-" + $TimeStr+".txt"

	new-item -path . -name $LogDir -type directory
	Set-Location -Path $LogDir

	adb shell dmesg > $DmesgName
	adb shell logcat -d > $LogcatName
	adb shell tinymix > $TmixName

	gvim $DmesgName $LogcatName $TmixName

	Set-Location -Path ..
	Get-ChildItem -Path $LogDir
}

Function Ddump-regs {
    param([String]$Device1, $Device2)

    $TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
    $Regmap="/d/regmap"
    $NodeBypass1=$Regmap + "/" + $Device1 + "/" + "cache_bypass"
    $NodeBypass2=$Regmap + "/" + $Device2 + "/" + "cache_bypass"
    $NodeRegisters1=$Regmap + "/" + $Device1 + "/" + "registers"
    $NodeRegisters2=$Regmap + "/" + $Device2 + "/" + "registers"
    $RegsDir = "RegsDir-" + $TimeStr
    new-item -path . -name $RegsDir -type directory
    Set-Location -Path $RegsDir
    $RegName1 = $Device1 + "-" + "registers" + $TimeStr + ".txt"
    $RegName2 = $Device2 + "-" + "registers" + $TimeStr + ".txt"

    # Android
    adb shell "echo Y > $NodeBypass1"
    adb shell "echo Y > $NodeBypass2"
    #<
    adb shell "cat $NodeRegisters1" > $RegName1
    adb shell "cat $NodeRegisters2" > $RegName2
    adb shell "echo N > $NodeBypass1"
    adb shell "echo N > $NodeBypass2"
    #
    gvim $RegName1 $RegName2
    Set-Location -Path ..
    Get-ChildItem -Path $RegsDir
}
