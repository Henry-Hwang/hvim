Function Dbg-Prdebug {
    Adb-init
    adb shell "echo 'file soc-utils.c +p' > /sys/kernel/debug/dynamic_debug/control"
    adb shell "echo 'file soc-dapm.c +p' > /sys/kernel/debug/dynamic_debug/control"
    adb shell "echo 'file soc-pcm.c +p' > /sys/kernel/debug/dynamic_debug/control"
    adb shell "echo 'file soc-core.c +p' > /sys/kernel/debug/dynamic_debug/control"
    adb shell "echo 'file kona.c +p' > /sys/kernel/debug/dynamic_debug/control"
}

#Dbg-KernLoop -Patten "cs35|cirrus"
Function Dbg-LoopKern {
    param([String]$Patten)
    Adb-init
    echo $Patten
    while(1) {
       # adb shell dmesg -c | rg -ie "cs35|cspl|cirrus|-0040|-0041|kona"
       adb shell dmesg -T -c | rg -ie $Patten
    }
}

#Dbg-KernLoop -Patten "cs35|cirrus"
Function Dbg-LoopLogcat {
    param([String]$Patten)
    Adb-init
    echo $Patten
    while(1) {
       adb shell logcat -d | rg -ie $Patten
       adb shell logcat -c
    }
}

Function Dbg-minidm {
    Adb-init
    adb shell setprop sys.usb.config diag,adb
    adb wait-for-device
    sleep 2
    mode
}

Function Dbg-ShowFirmware {
    Adb-init
    adb shell "find /vendor/firmware/ -name '*cs35*' | xargs ls -l"
    adb shell "find /vendor/firmware/ -name '*cs35*' | xargs md5sum"
}

Function Dbg-Dmesg {
    param([String]$Name)
    $TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
    $FileName="$Name" + "-" + "dmesg-" + "$TimeStr" + ".txt"
    adb shell dmesg > $FileName
    echo $FileName
}

Function Dbg-Dump {
    param([String]$Device1, $Device2)
    Adb-Init

    $TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
    $Regmap="/d/regmap"
    $NodeBypass1=$Regmap + "/" + $Device1 + "/" + "cache_bypass"
    $NodeBypass2=$Regmap + "/" + $Device2 + "/" + "cache_bypass"
    $NodeRegisters1=$Regmap + "/" + $Device1 + "/" + "registers"
    $NodeRegisters2=$Regmap + "/" + $Device2 + "/" + "registers"
    $DumpDir = "Dump-" + $TimeStr
    new-item -path . -name $DumpDir -type directory
    Set-Location -Path $DumpDir
    $RegName1 = $Device1 + "-" + "registers" + $TimeStr + ".txt"
    $RegName2 = $Device2 + "-" + "registers" + $TimeStr + ".txt"
    $TinymixName = "Tinymix-" + $TimeStr + ".txt"
    $DmesgName = "Dmesg-" + $TimeStr + ".txt"
    $LogcatName = "Logcat-" + $TimeStr + ".txt"

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
    #
    Set-Location -Path ..
    Get-ChildItem -Path $DumpDir
}


Function Dbg-Backup {
    param([String]$Name)
    $TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
    $BackupDir = $Name + "Backup-" + $TimeStr
    new-item -path . -name $BackupDir -type directory
    Set-Location -Path $BackupDir
    adb pull /vendor/lib .
    adb pull /vendor/etc .
    adb pull /vendor/firmware .
    Set-Location -Path ..
    Get-ChildItem -Path $BackupDir
}

Function Dbg-ShowFirmware {
    Adb-Init
    adb shell "find /vendor/firmware/ -name '*cs35*' | xargs ls -l"
    adb shell "find /vendor/firmware/ -name '*cs35*' | xargs md5sum"
}

Function Dbg-Wisce {
    Adb-Init
    adb forward tcp:22349 tcp:22349
    adb shell
}

Function Dbg-AudioKill {
    adb shell "pgrep -f audioserver | xargs kill"
}

Function Dbg-Log {
    param([String]$Name)
    $TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
    $LogDir = $Name + "Log-" + $TimeStr
    $DmesgName = $Name + "Dmesg-" + $TimeStr+".txt"
    $LogcatName = $Name + "Logcat-" + $TimeStr+".txt"
    new-item -path . -name $LogDir -type directory
    Set-Location -Path $LogDir
    adb shell dmesg > $DmesgName
    adb shell logcat -d > $LogcatName
    gvim $DmesgName $LogcatName
    Set-Location -Path ..
    Get-ChildItem -Path $LogDir

}

Function Dbg-Registers {
    param([String]$Device1, $Device2)
    Adb-Init

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
