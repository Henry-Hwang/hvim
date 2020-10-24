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
		$NameFix=$Name+"-"
	}

	$TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss-ff
    $BackupDir = $NameFix + "Backup-" + $TimeStr

	new-item -path . -name $BackupDir -type directory
    new-item -path $BackupDir -name lib -type directory
    Set-Location -Path $BackupDir
	new-item -path . -name vendor -type directory
    if ($Name -ne 'Full') {
        new-item -path vendor -name lib -type directory
        new-item -path vendor -name lib64 -type directory
        new-item -path vendor -name bin -type directory
        new-item -path vendor -name etc -type directory
        new-item -path vendor -name firmware -type directory

        adb pull vendor/lib/hw vendor/lib/
        adb pull vendor/lib64/hw vendor/lib64/
        adb pull vendor/lib/libcrussp.so vendor/lib/
        adb pull vendor/lib64/libcrussp.so vendor/lib64/

        adb pull vendor/bin/cstool vendor/bin/
        adb pull vendor/etc  vendor/
        adb pull vendor/firmware vendor/
    } else {
        adb pull vendor/lib/ vendor/
        adb pull vendor/lib64/ vendor/

        adb pull vendor/bin/ vendor/
        adb pull vendor/etc  vendor/
        adb pull vendor/firmware vendor/

    }
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
    param([String]$Name, $Device1, $Device2, $SoundCard)

	if ($Name -ne '') {
		$Name=$Name+"-"
	}

    Ainit
	$TimeStr=get-date -format yyyy-MM-ddTHH-mm-ss
	$LogDir = $Name + "Log-" + $TimeStr
	$DmesgName = $Name + "Dmesg-" + $TimeStr+".txt"
	$LogcatName = $Name + "Logcat-" + $TimeStr+".txt"
	$TmixName = $Name + "Tinymix-" + $TimeStr+".txt"

	new-item -path . -name $LogDir -type directory
	Set-Location -Path $LogDir

	adb shell dmesg > $DmesgName
	adb shell logcat -d > $LogcatName
	adb shell tinymix > $TmixName

    if (($Device1 -ne '') -AND ($Device2 -ne '') -AND ($SoundCard -ne '')) {
        $DapmName1 = $Device1+"-dapm.txt"
        $DapmName2 = $Device2+"-dapm.txt"
        $Dapm1="/d/asoc/" + $SoundCard + "/" + $Device1 + "/" + "dapm/*"
        $Dapm2="/d/asoc/" + $SoundCard + "/" + $Device2 + "/" + "dapm/*"
        adb shell "cat $Dapm1" > $DapmName1
        adb shell "cat $Dapm2" > $DapmName2
    }
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

Function DTestAudio {
    Ainit
    adb push C:\Users\hhuang\OneDrive\TestAudio\test /sdcard/Music/
    adb push C:\Users\hhuang\OneDrive\TestAudio\test\lrp_loop.wav /sdcard/Music/
    adb push C:\Users\hhuang\OneDrive\TestAudio\test\silent-3sec.wav /vendor/etc/
}

Function DDownload {
    $url="https://raw.githubusercontent.com/Henry-Hwang/TestAudios/master/lrp_loop.wav"
    $output = "lrp_loop.wav"
    $start_time = Get-Date

    Invoke-WebRequest -Uri $url -OutFile $output
    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}
function Apush {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Src, $Dest
    )
    adb push $Src $Dest
}

$pushBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (adb shell "find /vendor/firmware/ -name '*cs35*';
                find /vendor/lib/rfsa/adsp -name '*cirrus*';
                find /vendor/etc -name 'mixer_paths_*.xml';
                find /vendor/lib64/hw/ -name 'audio.*primary*.so';
                find /vendor/lib/hw/ -name 'audio.*primary*.so';") + "/sdcard/Music/" + "/sdcard/Download/" + "/vendor/etc/" + "/sdcard/Music/" | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
          "$_"
    }
}
Register-ArgumentCompleter -CommandName Apush -ParameterName Dest -ScriptBlock $pushBlock

function Aecho {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Reg, $Val, $Node
    )
    $Cache = ($(Split-Path -Path "$Node") + "/cache_bypass").Replace('\','/')
    #$Cache = $Cache.Replace('\','/')
    adb shell "echo N > $Cache"
    adb shell "echo $Src $Dest > $Node"
    adb shell "echo Y > $Cache"
}

$nodeBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (adb shell "find /d/regmap/ -name '*registers*' | grep -iE 'spi|0031|0030|0032|0041|0040|0042'") | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
          "$_"
    }
}
Register-ArgumentCompleter -CommandName Aecho -ParameterName Node -ScriptBlock $nodeBlock

