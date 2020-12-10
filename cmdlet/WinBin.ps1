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

Function CapiV2Make {
    $Capiv2Dir = "C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_QCOM_generic"
    $CsplLib = $Capiv2Dir + "\capi_v2_cirrus_cspl\LLVM_Debug\capi_v2_cirrus_cspl.so"
    Push-Location
    Set-Location -Path $Capiv2Dir
    . C:\Users\hhuang\hvim\cmdlet\Windows_Set.cmd
    Pop-Location

    Copy-Item $CsplLib capi_v2_cirrus_sp.so
    Copy-Item ~\hvim\cmdlet\PushCapiv2.ps1 .\Push.txt
}

Function CapiV2 {
    param(
        [Parameter()]
        [String]$Json, [Switch]$Make, [Switch]$Push, [Switch]$Reboot
    )
    $Capiv2Dir = "C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_QCOM_generic"
    $TuningDir = $Capiv2Dir+"\capi_v2_cirrus_cspl\include\tuningheaders"
    $SourceDir = $Capiv2Dir+"\capi_v2_cirrus_cspl"
    $CsplLib = $Capiv2Dir + "\capi_v2_cirrus_cspl\LLVM_Debug\capi_v2_cirrus_cspl.so"
    $Stamp = $SourceDir + "\include\build_stamp.h"
    $Compat = $SourceDir + "\source\compat.c"


    if ($Json) {
        $Target = ($Json).Replace(".json", ".h")
        JsonConverter -Json $Json -Out $Target
        $Target | CLIP
        cp $Target $TuningDir
        vim $Compat $Stamp
        CapiV2Make
        start .
    }

    if ($Make) {
        CapiV2Make
    }

    if ($Push) {
        adb wait-for-device root
        adb wait-for-device remount
        adb push $CsplLib /system/vendor/lib/rfsa/adsp/capi_v2_cirrus_sp.so
    }

    if($Reboot) {
        adb reboot
    }
}


