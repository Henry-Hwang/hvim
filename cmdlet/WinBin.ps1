Function WMd5sum {
    param([String]$File)
    Get-FileHash $File -Algorithm MD5
}

function BuildCrussp {
    param(
        [Parameter()]
        [string]$Push, $Reboot
    )

    C:\work\tools\android-ndk-r21\ndk-build.cmd
    if ("$Push" -eq 'Push') {
        Ainit
        adb push C:\Users\hhuang\work\src\audio-hal\libs\arm64-v8a\cstool           /vendor/bin/
        adb push C:\Users\hhuang\work\src\audio-hal\libs\arm64-v8a\libcrussp.so     /vendor/lib64/
        adb push C:\Users\hhuang\work\src\audio-hal\shared\libstdc++.so             /vendor/lib64/
    }
    if ("$Reboot" -eq 'Reboot') {
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

function BuildCapiv2 {
    param(
        [Parameter()]
        [string]$Json, $Out, $Push
    )

    $Capiv2Dir = "C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_QCOM_generic"
    $SourceDir = $Capiv2Dir+"\capi_v2_cirrus_cspl"
    $TuningDir = $Capiv2Dir+"\capi_v2_cirrus_cspl\include\tuningheaders"
    $Target = ($Json).Replace(".json", ".h")

    if($Json) {
        JsonConverter -Json $Json -Out $Target
    }

    #Build
    cp $Target $TuningDir
    $Target.Replace(".\", "") | CLIP
    $CsplLib = $Capiv2Dir + "\capi_v2_cirrus_cspl\LLVM_Debug\capi_v2_cirrus_cspl.so"
    $Stamp = $SourceDir + "\include\build_stamp.h"
    $Compat = $SourceDir + "\source\compat.c"
    vim $Compat $Stamp
    echo "build..."

    Push-Location
    Set-Location -Path $Capiv2Dir
    .\Windows_Set.cmd
    Pop-Location

    Copy-Item $CsplLib capi_v2_cirrus_sp.so
    Copy-Item ~\hvim\cmdlet\PushCapiv2.ps1 .

    if($Push) {
        . ~\hvim\cmdlet\PushCapiv2.ps1
        if ("$Push" -eq 'Reboot') {
            adb reboot
        }
    }

    start .
}
