Function EventTest {
$job = Start-Job -ScriptBlock {
  while($true) {
    Register-EngineEvent -SourceIdentifier MyNewMessage -Forward
    Start-Sleep -Seconds 3
    $null = New-Event -SourceIdentifier MyNewMessage -MessageData "Pingback from job."
  }
}

$event = Register-EngineEvent -SourceIdentifier MyNewMessage -Action {
  Write-Host $event.MessageData;
}

for($i=0; $i -lt 10; $i++) {
  Start-Sleep -Seconds 1
  Write-Host "Pingback from main."
}

$job,$event| Stop-Job -PassThru| Remove-Job #stop the job and event listener

}

Function SuperTester {
    param(
        [Parameter()]
        [String]$Target, [String]$Patten, [Switch]$Dapm, [Switch]$Logs,
        [Switch]$View, [Switch]$Max, [Switch]$Min
    )
    $Callbacks = $TestCallbacks
    $CallBacks["OnStart"].Invoke();

    $job = Start-Job -ScriptBlock {
        #$CallBacks["OnTest"].Invoke();
        Out-Host "fuck..."
    }
    Start-Sleep -Seconds 3
<#
 $timer = New-Object System.Timers.Timer -Property @{
        Interval = 1000;
        Enabled = $true;
        AutoReset = $false
    }
    Register-ObjectEvent $timer Elapsed -Action {
        $Event | Out-Host
    }
    $timer.Start()
#>
    $timer = New-Object System.Timers.Timer -Property @{
        Interval = 500;
        AutoReset = $true
    }

    Register-ObjectEvent -InputObject $timer `
        -MessageData 5 `
        -SourceIdentifier Stateful -EventName Elapsed -Action {

        $script:counter += 1
        Write-Host "Event counter is $counter"
        if ($counter -ge $Event.MessageData) {
            Write-Host "Stopping timer"
            $timer.Stop()
        }
    } > $null


    $timer.Start()

<#
    return
    $file = Get-Content $Target
    $isWord = $file | %{$_ -match $Patten}
    if ($isWord -contains $true) {
        Write-Host "There is!"
        $CallBacks["OnLogs"].Invoke();
    } else {
        Write-Host "There ins't - $Patten"
    }
#>
}
$TestCallbacks = @{
    "OnStart"  = {
        write-host "Now started Test, Time: " $(get-date -format yyyy-MM-ddTHH-mm-ss-ff)
        return "OnStart..."
    }

    "OnTest"  = { write-host "Now started Test, Time:" $(get-date -format yyyy-MM-ddTHH-mm-ss-ff) }
    "OnCheck"  = { write-host "Now started Test, Time: $(get-date -format yyyy-MM-ddTHH-mm-ss-ff)" }
    "OnFinish" = { write-host "Finished, Time: $(get-date -format yyyy-MM-ddTHH-mm-ss-ff)"}
    "OnError"    = { write-host "error , Time: $(get-date -format yyyy-MM-ddTHH-mm-ss-ff)"}
    "OnLogs"    = {
            write-host "DDumpLogs"
            DLogs -Tag Failed -All -View
            sleep 100000
    }
}

Function Prdebug {
    $Sb = New-Object -TypeName System.Text.StringBuilder
    $AdbCmd = "adb shell `"@COMMANDS`""
    $DbgEna = "echo 'file @FILES +p' > /sys/kernel/debug/dynamic_debug/control;"
    $DbgFiles = "soc-utils.c",
                "soc-dapm.c",
                "soc-pcm.c",
                "soc-core.c",
                "kona.c",
                "laihana.c",
                "q6afe.c",
                "q6adm.c",
                "msm-pcm-routing-v2.c",
                "wm_adsp.c",
                "cs35l41.c",
                "cs35l45.c"
    #$[void]$Sb.Append("tinymix `'@PREFIX @CONTROL`' `'@VALUE`'").Replace("@CONTROL", $Control).Replace("@VALUE", $Value).Replace("@PREFIX", $Prefix)

    foreach ($element in $DbgFiles) {
        [void]$Sb.Append($DbgEna).Replace("@FILES", $element)
    }
    $DbgEna = $Sb.ToString()
    [void]$Sb.Clear().Append($AdbCmd).Replace("@COMMANDS", $DbgEna)
    #Write-Host $Sb.ToString()
    Invoke-Expression $Sb.ToString()
}

Function DLogs {
    param(
        [Parameter()]
        [String]$Tag, [Switch]$Regs, [Switch]$Dapm, [Switch]$Logs, [Switch]$All,
        [Switch]$View, [Switch]$Max, [Switch]$Min
    )

    Ainit

    $Product = DGetProduct
    $SoundCard = $Product.SoundCard
    $Amp = $Product.Amp
    #$Nodes = "spi1.0", "spi1.1"
    $Nodes = $Product.Nodes

    $Time=get-date -format yyyy-MM-ddTHH-mm-ss-ff
    $Dir = $Time

    if($Tag) {
        $Dir = "$Product-$Tag-$Time"
        Write-Host $Time
    }

    new-item -path . -name $Dir -type directory
    Set-Location -Path $Dir
    if($Regs) {
        foreach ($element in $Nodes) {
            Write-Host $element
            adb shell "echo Y > /d/regmap/$element/cache_bypass"
            adb shell "cat /d/regmap/$element/registers" > $element-registers.txt
            adb shell "echo N > /d/regmap/$element/cache_bypass"
        }
    }
    if($Dapm) {
        foreach ($element in $Nodes) {
            if ($Product.CIF -eq "SPI") {
                $Target = "/d/asoc/@SOUNDCARD/@NODE/dapm/*".Replace("@SOUNDCARD",$SoundCard).Replace("@NODE", $element)
            } else {
                $Target = "/d/asoc/@SOUNDCARD/@AMP.@NODE/dapm/*".Replace("@SOUNDCARD",$SoundCard).Replace("@AMP", $Amp).Replace("@NODE", $element)
            }
            adb shell "cat $Target" > $element-dapm.txt
        }
    }

    if($Logs) {
        if($Max) {
            Prdebug
        }
        adb shell dmesg > dmesg.txt
        adb shell "logcat -d" > logcat.txt
        adb shell "tinymix" > tinymix.txt
        foreach ($element in $Nodes) {
            Write-Host $element
            $Target = "/d/asoc/sm*/$element/dapm/*"
            adb shell "cat $Target" > $element-dapm.txt
        }
    }

    if($All) {
        adb shell dmesg > dmesg.txt
        adb shell "logcat -d" > logcat.txt
        adb shell "tinymix" > tinymix.txt
        foreach ($element in $Nodes) {
            Write-Host $element
            $Target = "/d/asoc/sm*/$element/dapm/*"
            adb shell "cat $Target" > $element-dapm.txt
        }
        foreach ($element1 in $Nodes) {
            Write-Host $element1
            adb shell "echo Y > /d/regmap/$element1/cache_bypass"
            adb shell "cat /d/regmap/$element1/registers" > $element1-registers.txt
            adb shell "echo N > /d/regmap/$element1/cache_bypass"
        }
    }

    if($View) {
        gvim *.txt
    }

    Set-Location -Path ..
    Get-ChildItem -Path $Dir
}

#Dbg-KernLoop -Patten "cs35|cirrus"
Function Dmesg {
    param(
        [Parameter()]
        [String]$Patten, [Switch]$Loop, [Switch]$Max
    )

    Ainit
    echo $Patten
    if($Max) {
        Prdebug
    }

    if ($Loop) {
        while(1) {
            if($Patten) {
                adb shell "dmesg -c" | rg -ie $Patten
            } else {
                adb shell "dmesg -c"
            }
            sleep 0.2
        }
    } else {
        if($Patten) {
            adb shell "dmesg -c" | rg -ie $Patten
        } else {
            adb shell "dmesg -c"
        }
    }
}

Function Logcat {
    param(
        [Parameter()]
        [String]$Patten, [Switch]$Loop, [Switch]$Max
    )

    Ainit
    echo $Patten
    if($Max) {
        Prdebug
    }

    if($Loop) {
        while(1) {
            # adb shell dmesg -c | rg -ie "cs35|cspl|cirrus|-0040|-0041|kona"
            if($Patten) {
                adb shell logcat -d | rg -ie $Patten
                adb shell logcat -c
            } else {
                adb shell logcat -d
                adb shell logcat -c
            }
            sleep 0.2
        }
    } else {
        if($Patten) {
            adb shell logcat -d | rg -ie $Patten
        } else {
            adb shell logcat -d
        }
    }
}

Function Dminidm {
    Ainit
    adb shell setprop sys.usb.config diag,adb
    adb wait-for-device
    sleep 2
    mode
}

Function DFwMd5 {
    Ainit
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

Function DBackup {
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

Function DMusic {
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

function Apull {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Src, $Dest
    )
    adb pull $Src $Dest
}
Register-ArgumentCompleter -CommandName Apull -ParameterName Src -ScriptBlock $pushBlock

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

