Function M2181-HSSH-GET-KO {
    $cs35l45_dlkm="~/src/opensource/android-kernel/out/msm-5.4/private/msm-5.4/techpack/audio/asoc/codecs/cs35l45/cs35l45_dlkm.ko"
    hscp -from -src $cs35l45_dlkm -dest .
}

Function M2181-SwapCH {
    param([Switch]$LR, [Switch]$RL)
    adb wait-for-device root
    adb wait-for-device remount

    adb shell "tinymix 'SPK DSP_RX1 Source' 'ASP_RX2'"
    adb shell "tinymix 'SPK DSP_RX1 Source' 'ASP_RX1'"
    adb shell "tinymix 'RCV DSP_RX1 Source' 'ASP_RX1'"
    adb shell "tinymix 'RCV DSP_RX2 Source' 'ASP_RX2'"
    if($LR) {
        adb shell "tinymix 'SPK DSP1 Protection cd CH_BAL' 00 40 00 00"
        adb shell "tinymix 'RCV DSP1 Protection cd CH_BAL' 00 00 00 00"
    } else {
        adb shell "tinymix 'SPK DSP1 Protection cd CH_BAL' 00 00 00 00"
        adb shell "tinymix 'RCV DSP1 Protection cd CH_BAL' 00 40 00 00"
    }
}
Function M2181-Tinyplay {
    param([String]$Wav)
    adb wait-for-device root
    adb wait-for-device remount

    if($Wav) {
        adb push $Wav /sdcard/Music/cs_test.wav
    }

    adb shell "tinymix 'SPK Amplifier Mode' 'SPK'"
    adb shell "tinymix 'RCV Amplifier Mode' 'SPK'"

    adb shell "tinymix 'SPK DSP_RX1 Source' 'ASP_RX2'"
    adb shell "tinymix 'SPK DSP_RX2 Source' 'ASP_RX2'"
    adb shell "tinymix 'SPK AMP Enable Switch' '1'"
    adb shell "tinymix 'SPK DACPCM Source' 'DSP_TX1'"
    adb shell "tinymix 'SPK Digital PCM Volume' '817'"
    adb shell "tinymix 'SPK ASP_TX2 Source' 'DSP_TX1'"
    adb shell "tinymix 'SPK Fast Use Case Delta File' 'cs35l45-delta-spk-music.txt'"
    adb shell "tinymix 'SPK Fast Use Case Switch Enable' '0'"
    adb shell "tinymix 'RCV DSP_RX1 Source' 'ASP_RX1'"
    adb shell "tinymix 'RCV DSP_RX2 Source' 'ASP_RX1'"
    adb shell "tinymix 'RCV AMP Enable Switch' '1'"
    adb shell "tinymix 'RCV DACPCM Source' 'DSP_TX1'"
    adb shell "tinymix 'RCV Digital PCM Volume' '817'"
    adb shell "tinymix 'SPK ASP_TX2 Source' 'DSP_TX1'"
    adb shell "tinymix 'RCV Fast Use Case Delta File' 'cs35l45-delta-rcv-music.txt'"
    adb shell "tinymix 'RCV Fast Use Case Switch Enable' '0'"
    adb shell "tinymix 'PRI_MI2S_RX Audio Mixer MultiMedia1' 1"
    adb shell "tinyplay '/sdcard/Music/cs_test.wav'"
}

#Accepts a Job as a parameter and writes the latest progress of it
function WriteJobProgress
{
    param($Job)

    #Make sure the first child job exists
    if($Job.ChildJobs[0].Progress -ne $null)
    {
        #Extracts the latest progress of the job and writes the progress
        $jobProgressHistory = $Job.ChildJobs[0].Progress;
        $latestProgress = $jobProgressHistory[$jobProgressHistory.Count - 1];
        $latestPercentComplete = $latestProgress | Select -expand PercentComplete;
        $latestActivity = $latestProgress | Select -expand Activity;
        $latestStatus = $latestProgress | Select -expand StatusDescription;

        #When adding multiple progress bars, a unique ID must be provided. Here I am providing the JobID as this
        Write-Progress -Id $Job.Id -Activity $latestActivity -Status $latestStatus -PercentComplete $latestPercentComplete;
    }
}

Function DeltaTest-Jobs {
    Ainit

    # Create synced hashtable
    $job = Start-Job -WorkingDirectory $PWD -Name Delta {
        $Status = "Processing"

        # Process. update activity
        $Activity = "Id processing"

        adb shell input keyevent 27  #POWER
        sleep 2
        adb shell input swipe 200 1700 200 300 # SWIPE UP
        sleep 1
        foreach ($percent in 1..100) {
            # Update process on status
            $Status = "Handling $percent/100"

            $PercentComplete = (($percent / 100) * 100)

            adb shell service call phone 1 s16 112
            sleep 1
	        adb shell input tap 533 2156 # tap CALL
                    $Activity = "Id processing"
            foreach ($Tabs in 1..15) {
                sleep 1
                $Activity = "Id processing"
	            adb shell input tap 538 1100 # tap Handsfree/Handset
                adb shell dmesg > dmesg.txt
                $file = Get-Content dmesg.txt
                $isWord = $file | %{$_ -match "CSPL_STATE"}
                if ($isWord -contains $true) {
                    $Activity = "Id processing"
                    $Status = "Handling: $percent Calls, $Tabs Switching, Failed!"
                    $Completed = $true
                    return
                } else {
                    $Status = "Handling-0: $percent Calls, $Tabs Switching"
                }

                Write-Progress -Activity $Activity -Status $status -PercentComplete $percentComplete;
                Start-Sleep -Seconds 0.1
            }

	        adb shell input tap 531 2073 # tap Hang up
            sleep 2
            # Fake workload that takes x amount of time to complete
        }

        # Mark process as completed
        $Completed = $true
    }

    while($job.State -eq 'Running') {
        # Create parameter hashtable to splat
        #$param = $origin
        # Execute Write-Progress
        #Write-Progress @param
        WriteJobProgress($job)
        # Wait to refresh to not overload gui
        Start-Sleep -Seconds 0.1
    }

    Dlogs -Tag Failed -All -View
    $param
}

Function DPowerDown {
    adb shell "tinymix 'RCV DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'SPK DSP1 Firmware' 'Protection'"
    adb shell "tinymix 'RCV SYNC Enable Switch' '1'"
    adb shell "tinymix 'SPK SYNC Enable Switch' '1'"
    adb shell "tinymix 'SPK DACPCM Source' 'Zero'"
    adb shell "tinymix 'SPK DSP_RX1 Source' 'Zero'"
    adb shell "tinymix 'SPK DSP_RX2 Source' 'Zero'"
    adb shell "tinymix 'SPK ASP_TX1 Source' 'Zero'"
    adb shell "tinymix 'SPK ASP_TX2 Source' 'Zero'"
    adb shell "tinymix 'SPK ASP_TX3 Source' 'Zero'"
    adb shell "tinymix 'SPK ASP_TX4 Source' 'Zero'"
    adb shell "tinymix 'SPK AMP Mute' '0'"
    adb shell "tinymix 'SPK AMP Enable Switch' '0'"
    adb shell "tinymix 'RCV DACPCM Source' 'Zero'"
    adb shell "tinymix 'RCV DSP_RX1 Source' 'Zero'"
    adb shell "tinymix 'RCV DSP_RX2 Source' 'Zero'"
    adb shell "tinymix 'RCV ASP_TX1 Source' 'Zero'"
    adb shell "tinymix 'RCV ASP_TX2 Source' 'Zero'"
    adb shell "tinymix 'RCV ASP_TX3 Source' 'Zero'"
    adb shell "tinymix 'RCV ASP_TX4 Source' 'Zero'"
    adb shell "tinymix 'RCV AMP Mute' '0'"
    adb shell "tinymix 'RCV AMP Enable Switch' '0'"

    sleep 2
    adb shell "tinymix 'RCV DSP1 Preload Switch' '1'"
    adb shell "tinymix 'SPK DSP1 Preload Switch' '1'"
    adb shell "tinymix 'RCV DSP1 Boot Switch' '1'"
    adb shell "tinymix 'SPK DSP1 Boot Switch' '1'"
}

Function CallTest {
    Ainit
    $Count = 30
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
	    $ModeCount = 30
        while($ModeCount-- -gt 0) {
            sleep 0.5
	        adb shell input tap 538 1100 # tap Handsfree/Handset
            adb shell dmesg > dmesg.txt

            $ELINE = Get-Content dmesg.txt | Where-Object { $_.Contains("HALO_STATE") }
            if($ELINE) {
                Write-Host $ELINE
            }
            #@( Get-Content mylogfile.txt | Where-Object { $_.Contains("ERROR") } ).Count
            Write-Host $ModeCount "Switch"
        }
	    adb shell input tap 531 2073 # tap Hang up
        sleep 2
    }
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
		adb reboot
		Ainit
	}
}

Function Call {
    adb shell service call phone 1 s16 "112"
}

Function TxRecord-Loopback-M2181 {
    $Wav = "/sdcard/Download/rec1.wav"
    adb shell "tinymix 'RCV ASP_TX1 Source' 'ASP_RX1'"
    adb shell "tinymix 'SPK ASP_TX2 Source' 'ASP_RX1'"
    adb shell "tinymix 'MultiMedia1 Mixer PRI_MI2S_TX' 1"
    adb shell "tinymix 'PRIM_MI2S_TX SampleRate' KHZ_48"
    adb shell "tinymix 'PRIM_MI2S_TX Format' S16_LE"
    adb shell "tinymix 'PRIM_MI2S_TX Channels' 'Two'"
    adb shell "tinycap $Wav -D 0 -d 0 -r 48000 -c 2 -T 15"
    adb pull $Wav .
    start .
}


Function TxRecord-M2181 {
    param([Int32]$Second = 10)
    Ainit
    $Wav = "/sdcard/Download/rec1.wav"
    adb shell "tinymix 'RCV ASP_TX1 Source' 'DSP_TX1'"
    adb shell "tinymix 'SPK ASP_TX2 Source' 'DSP_TX1'"
    adb shell "tinymix 'MultiMedia1 Mixer PRI_MI2S_TX' 1"
    adb shell "tinymix 'PRIM_MI2S_TX SampleRate' KHZ_48"
    adb shell "tinymix 'PRIM_MI2S_TX Format' S16_LE"
    adb shell "tinymix 'PRIM_MI2S_TX Channels' 'Two'"

    adb shell "echo 4808 20200200 > /d/regmap/spi1.0/registers"
    adb shell "echo 4808 20200200 > /d/regmap/spi1.1/registers"


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
Function TxEchoTest {
    param([String]$Off)
    adb wait-for-device root
    adb wait-for-device remount
    $Path = Get-Location
    $Sbuilder = New-Object -TypeName System.Text.StringBuilder
    $Spi1_0 = $Sbuilder.Append($Path).Append("\spi1.0-regs.txt").ToString()
    $Spi1_1 = $Sbuilder.Clear().Append($Path).Append("\spi1.1-regs.txt").ToString()
    Write-Host $Spi1_0
    Write-Host $Spi1_1
    if($Off) {
        adb shell "tinymix 'RCV ASP_TX1 Source' 'Zero'"
        adb shell "tinymix 'SPK ASP_TX2 Source' 'Zero'"
    } else {
        adb shell "tinymix 'RCV ASP_TX1 Source' 'DSP_TX1'"
        adb shell "tinymix 'SPK ASP_TX2 Source' 'DSP_TX1'"
    }
    sleep 1
    adb shell "cat /d/regmap/spi1.0/registers" > $Spi1_0
    adb shell "cat /d/regmap/spi1.1/registers" > $Spi1_1
    adb shell "cat /d/asoc/sm8350-meizu-snd-card/spi1.0/dapm/*"
    adb shell "cat /d/asoc/sm8350-meizu-snd-card/spi1.1/dapm/*"
    cat $Spi1_0 | findstr 0004800:
    cat $Spi1_1 | findstr 0004800:
    start .
}

Function TxEcho-M2181 {
    param([String]$Switch)
    Ainit
    if ($Switch -eq 'Off') {
        adb shell "tinymix 'RCV ASP_TX1 Source' 'Zero'"
        adb shell "tinymix 'SPK ASP_TX1 Source' 'Zero'"
    } else {
        adb shell "tinymix 'RCV ASP_TX1 Source' 'DSP_TX1'"
        adb shell "tinymix 'SPK ASP_TX1 Source' 'DSP_TX1'"
    }
    adb shell "cat /d/asoc/sm*/spi1.0/dapm/*"
    adb shell "cat /d/asoc/sm*/spi1.1/dapm/*"
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

Function Usecase-Pops-M2181 {
    param([String]$RCV, $SPK)

    For ($k=0; $k -lt 100; $k++) {
        For ($i=0; $i -lt 3; $i++) {
            adb shell "tinymix 'RCV PCM Soft Ramp'  32ms"
            adb shell "tinymix 'SPK PCM Soft Ramp'  32ms"
            adb shell "tinymix 'RCV Digital PCM Volume'  0"
            adb shell "tinymix 'SPK Digital PCM Volume'  0"

            adb shell "tinymix 'Cirrus SP Usecase'  $i"

            adb shell "tinymix 'RCV Digital PCM Volume'  817"
            adb shell "tinymix 'SPK Digital PCM Volume'  817"
            adb shell "tinymix 'SPK PCM Soft Ramp'  4ms"
            adb shell "tinymix 'RCV PCM Soft Ramp'  4ms"
            sleep 2
        }
    }
}
