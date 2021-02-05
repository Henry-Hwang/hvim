Function WMd5sum {
    param([String]$File)
    Get-FileHash $File -Algorithm MD5
}

function BuildCrussp {
    param(
        [Parameter()]
        [Switch]$Push, [Switch]$Reboot
    )

    C:\work\tools\android-ndk-r21\ndk-build.cmd
    if ($Push) {
        Ainit
        adb push C:\Users\hhuang\work\src\audio-hal\libs\arm64-v8a\cstool           /vendor/bin/
        adb push C:\Users\hhuang\work\src\audio-hal\libs\arm64-v8a\libcrussp.so     /vendor/lib64/
        adb push C:\Users\hhuang\work\src\audio-hal\shared\libstdc++.so             /vendor/lib64/
    }
    if ($Reboot) {
        adb reboot
    }
}

function JsonConverter {
    param(
        [Parameter()]
        [string]$Json, $Out
    )

    $Tool = "C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_python\cspl_sp_link_android\json2hexagonbin.py"
    if($Out) {
        $Target = $Out
    } else {
        $Target = ($Json).Replace(".json", ".h")
    }

    python $Tool $Json -t $Target
}

Function CapiV2-LinesReplace {
    param(
         [String]$SrcLine, [String]$Name
    )
    $newline=$SrcLine.Replace("`/@TUNING`"", "")
    # Search the line in compat.c
    $line = @(Get-Content $file | Select-String "$newline" | Select-Object -ExpandProperty Line)
    $newline=$SrcLine.replace("@TUNING", $Name)

    $content = Get-Content $file
    $content | ForEach-Object {
        # Relace the line with a new one
        $_ -replace $line[0], $newline
    } | Set-Content $file
    $line = Get-Content $file | Select-String "$newline" | Select-Object -ExpandProperty Line
    write-host $line
}

Function CapiV2-PlaceTunings {
    param(
         [String[]]$Bit24, [String[]]$Bit16
    )

    $ofs = ','
    # set output field separator to a comma:
    "Names: $Tuning"
    $file = 'C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_QCOM_generic\capi_v2_cirrus_cspl\source\compat.c'
    $Capiv2Dir = "C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_QCOM_generic"
    $TuningDir = $Capiv2Dir+"\capi_v2_cirrus_cspl\include\tuningheaders"

    $def16bitTuning = @(
        "#define USE_CASE_0_TUNING `"tuningheaders/@TUNING`"",
        "#define USE_CASE_1_TUNING `"tuningheaders/@TUNING`"",
        "#define USE_CASE_2_TUNING `"tuningheaders/@TUNING`"",
        "#define USE_CASE_3_TUNING `"tuningheaders/@TUNING`""
    )

    $def24bitTuning = @(
        "#define USE_CASE_0_TUNING_24BIT `"tuningheaders/@TUNING`"",
        "#define USE_CASE_1_TUNING_24BIT `"tuningheaders/@TUNING`"",
        "#define USE_CASE_2_TUNING_24BIT `"tuningheaders/@TUNING`"",
        "#define USE_CASE_3_TUNING_24BIT `"tuningheaders/@TUNING`""
    )

    if ($Bit24) {
        For ($i=0; $i -lt $Bit24.Length; $i++) {
            if ($Bit24[$i]) {
                $t = Get-Item $Bit24[$i]
                if ($t.Extension -eq ".json") {
                    $Tuning_H = $t.BaseName+".h"
                    JsonConverter -Json $t.Name -Out $Tuning_H
                    $t = Get-Item $Tuning_H
                }
                cp $t.FullName $TuningDir
                CapiV2-LinesReplace -SrcLine $def24bitTuning[$i] -Name $t.Name
            }
        }
    }
    if ($Bit16) {
        For ($i=0; $i -lt $Bit16.Length; $i++) {
            if ($Bit16[$i]) {
                $t = Get-Item $Bit16[$i]
                if ($t.Extension -eq ".json") {
                    $Tuning_H = $t.BaseName+".h"
                    JsonConverter -Json $t.Name -Out $Tuning_H
                    $t = Get-Item $Tuning_H
                }
                cp $t.FullName $TuningDir
                CapiV2-LinesReplace -SrcLine $def16bitTuning[$i] -Name $t.Name
            }
        }
    }

<#
#>
}

Function Wisce {
    Ainit
    adb forward tcp:22349 tcp:22349
    adb shell
}

Function CapiV-2Make {
    $Capiv2Dir = "C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_QCOM_generic"
    $CsplLib = $Capiv2Dir + "\capi_v2_cirrus_cspl\LLVM_Debug\capi_v2_cirrus_cspl.so"
    Push-Location
    Set-Location -Path $Capiv2Dir
    try{
        . C:\Users\hhuang\hvim\cmdlet\Windows_Set.cmd
    } catch {
        throw "Build Failed"
    }
    Pop-Location

    Copy-Item $CsplLib capi_v2_cirrus_sp.so
    Copy-Item ~\hvim\cmdlet\PushCapiv2.ps1 .\Push.txt
    file2clip.exe capi_v2_cirrus_sp.so Push.txt
}



Function CapiV2 {
    #[CmdletBinding()]
    param(
        [Parameter()]
        [String[]]$Json24, [String[]]$Json16, [Switch]$Make=$true, [Switch]$Push, [Switch]$Reboot
    )
    $Capiv2Dir = "C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_QCOM_generic"
    $CsplLib = $Capiv2Dir + "\capi_v2_cirrus_cspl\LLVM_Debug\capi_v2_cirrus_cspl.so"

    CapiV2-PlaceTunings -Bit24 $Json24 -Bit16 $Json16

    if ($Make) {
        CapiV-2Make
    }

    if ($Push) {
        adb wait-for-device root
        adb wait-for-device remount
        adb push $CsplLib /system/vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so
    }

    if($Reboot) {
        adb wait-for-device root
        adb wait-for-device remount
        adb push $CsplLib /system/vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so
        adb reboot
    }
}
