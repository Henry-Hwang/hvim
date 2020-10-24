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
Function CatRegs {
    echo "background cap ..."
    sleep 1
    adb shell "cat /d/regmap/spi1.0/registers" > C:\work\customer\meizu\M2191\txecho\spi1.0-regs.txt
    adb shell "cat /d/regmap/spi1.1/registers" > C:\work\customer\meizu\M2191\txecho\spi1.1-regs.txt
}
Function TxRecord-M2181 {
    param([Int32]$Second = 60)
    Ainit
    $Wav = "/sdcard/Download/rec1.wav"
    adb shell "tinymix 'RCV ASP_TX1 Source' 'DSP_TX1'"
    adb shell "tinymix 'SPK ASP_TX2 Source' 'DSP_TX1'"
    adb shell "tinymix 'MultiMedia1 Mixer PRI_MI2S_TX' 1"
    adb shell "tinymix 'PRIM_MI2S_TX SampleRate' KHZ_48"
    adb shell "tinymix 'PRIM_MI2S_TX Format' S16_LE"
    adb shell "tinymix 'PRIM_MI2S_TX Channels' 'Two'"
    echo "start record ......"
    adb shell "tinycap $Wav -D 0 -d 0 -r 48000 -c 2 -T $Second"
    #Start-Job -ScriptBlock { Get-Process -Name Tinycap }
    echo "dump registers ......"
    adb shell "cat /d/regmap/spi1.0/registers" > spi1.0-regs.txt
    adb shell "cat /d/regmap/spi1.1/registers" > spi1.0-regs.txt
    adb pull $Wav .
    start .
}

Function TxRec-BGround {
    $Path = Get-Location
    $Sbuilder = New-Object -TypeName System.Text.StringBuilder
    $Spi1_0 = $Sbuilder.Append($Path).Append("\spi1.0-regs.txt").ToString()
    $Spi1_1 = $Sbuilder.Clear().Append($Path).Append("\spi1.1-regs.txt").ToString()
    Write-Host $Spi1_0
    Write-Host $Spi1_1

    $Wav = "/sdcard/Download/rec.wav"
    $Time = 360
    #Start-Process -NoNewWindow Tinycap
    $BgRegs = {
        param($Node1, $Node2)
        echo "background cap ..."
        sleep 1
        adb shell "cat /d/regmap/spi1.0/registers" > $Node1
        adb shell "cat /d/regmap/spi1.1/registers" > $Node2
    }

    $BgRec = {
        param($Path, $Time)

        adb shell "rm /sdcard/Download/rec.wav"
        if($Time) {
            adb shell "tinycap $Path -D 0 -d 0 -r 48000 -c 2 -T $Time"
        } else {
            adb shell "tinycap $Path -D 0 -d 0 -r 48000 -c 2"
        }
    }

    #Start-Job -Name "Bg-Regs" $BgRec -ArgumentList $Wav, $Time
    $RegJob = Start-Job -Name "Bg-Rec" $BgRegs -ArgumentList $Spi1_0, $Spi1_1
    echo "background cap ..."
    $CapJob = Start-Job -Name "Bg-Regs" $BgRec -ArgumentList $Wav, $Time
    echo "background regs ..."

    Wait-Job $RegJob
    Stop-Job $CapJob
    adb pull $Wav $Path
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

Function Reload-M2181 {
    param([String]$RCV, $SPK)

    adb wait-for-device root
    adb wait-for-device remount
    adb shell "input keyevent 85"
    sleep 4

    if ($SPK) {
        echo "reload SPK tuning"
        adb push $SPK /vendor/firmware/SPK-cs35l45-dsp1-spk-prot.bin
        adb shell "tinymix 'SPK DSP1 Preload Switch' '0'"
        adb shell "tinymix 'SPK DSP1 Boot Switch' '0'"
        sleep 0.5
        adb shell "tinymix 'SPK DSP1 Preload Switch' '1'"
        adb shell "tinymix 'SPK DSP1 Boot Switch' '1'"
    }


    if ($RCV) {
        echo "reload RCV tuning"
        adb push $RCV /vendor/firmware/RCV-cs35l45-dsp1-spk-prot.bin
        adb shell "tinymix 'RCV DSP1 Preload Switch' '0'"
        adb shell "tinymix 'RCV DSP1 Boot Switch' '0'"
        sleep 0.5
        adb shell "tinymix 'RCV DSP1 Preload Switch' '1'"
        adb shell "tinymix 'RCV DSP1 Boot Switch' '1'"
    }

    sleep 2
    adb shell "input keyevent 85"
}

Function MixersWrite2Cmd {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [Object[]]$InputObject,
        [String]$Control, $Value, $Prefix
    )
    $Sb = New-Object -TypeName System.Text.StringBuilder
    [void]$Sb.Append("tinymix `'@PREFIX @CONTROL`' `'@VALUE`'").Replace("@CONTROL", $Control).Replace("@VALUE", $Value).Replace("@PREFIX", $Prefix)
    #Invoke-Expression $Sb.ToString()
    return $Sb.ToString()
}
Function MixersRead2Cmd {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [Object[]]$InputObject,
        [String]$Control, $Prefix
    )
    $Sb = New-Object -TypeName System.Text.StringBuilder
    [void]$Sb.Append("tinymix `'@PREFIX @CONTROL`'").Replace("@CONTROL", $Control).Replace("@PREFIX", $Prefix)
    #Invoke-Expression $Sb.ToString()
    return $Sb.ToString()
}

Function Cmd2AShell {
    Param(
        [Parameter(Mandatory=$True)]
        [String]$Cmds
    )
    $Sb = New-Object -TypeName System.Text.StringBuilder
    [void]$Sb.Append("adb shell `"@COMMANDS`"").Replace("@COMMANDS", $Cmds)
    return $Sb.ToString()
}

Function DCmd2Set{
    $Cmds = @()
    $Json = DGetJson
    #Write-Host $Json.AmpName $Json.AmpSet
    foreach ($element in $Json.Mixers) {
        $Cmds+=MixersRead2Cmd -InputObject $Json -Control $element -Prefix "RCV"
        #$element
    }
    $Cmd = $Cmds -join ";"
    return $Cmd
}

Function DMainDebug {
    <#
    $CSet = DCmd2Set
    $Cmd = Cmd2AShell -Cmds $Cset
    Invoke-Expression $Cmd
    #>
    $Json = DGetJson
    $Json
    foreach ($element in $Json.AmpPrefix) {
        if ($element) {
            $element
        }
    }
}

Function DGetJson{
    $Json = Get-Content ~\hvim\cmdlet\M2181.json | ConvertFrom-Json

    return $Json
}
$global:TmixCtls = ""
$global:TmixOpt = ""
function ATmix {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Control, $Value
    )
    $Sb = New-Object -TypeName System.Text.StringBuilder
    if($Value) {
        [void]$Sb.Append("tinymix `'@CONTROL`' `'@VALUE`'").Replace("@CONTROL", $Control).Replace("@VALUE", $Value)
    } else {
        [void]$Sb.Append("tinymix `'@CONTROL`'").Replace("@CONTROL", $Control)
    }

    $Cmd = Cmd2AShell -Cmds $Sb.ToString()
    $global:TmixCtls = $Cmd
    $global:TmixCtls
    #Invoke-Expression $Cmd
}

$ctlsBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $Json = DGetJson
    $Json.Mixers | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
        foreach ($element in $Json.AmpPrefix) {
            if ($element) {
                "`'$element $_`'"
            } else {
                "`'$_`'"
            }
        }
    }
}

$valueBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $(DgetJson).Mixers | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
          "`'RCV $_`'"
    }
}
Register-ArgumentCompleter -CommandName ATmix -ParameterName Control -ScriptBlock $ctlsBlock

