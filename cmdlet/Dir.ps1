
Function GXiaomi {Set-Location -Path C:\work\customer\xiaomi}
Function GMeizu {Set-Location -Path C:\work\customer\meizu}
Function GCspl {Set-Location -Path C:\work\src\aus\amps\cspl}
Function GHvim {Set-Location -Path C:\cygwin64\home\hhuang\hvim}
Function GCapiv2 {Set-Location -Path C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_QCOM_generic}
Function GMusic {Set-Location -Path C:\work\music\Music}
Function GScspb {Set-Location -Path C:\work\src\aus\scs\scs_playback}
Function GWork {Set-Location -Path C:\work}
Function GTechnote {Set-Location -Path C:\work\docs\technote}
Function GExpense {Set-Location -Path C:\work\docs\expense}
Function GDatasheet {Set-Location -Path C:\work\docs\datasheet}
Function GCirrus-Linux {Set-Location -Path C:\work\src\aus\cirrus-linux}
Function GOrmis {Set-Location -Path C:\work\src\aus\amps\ormis}
Function GAmps {Set-Location -Path C:\work\src\aus\amps}
Function GHal {Set-Location -Path C:\work\src\audio-hal}
Function GScs {Set-Location -Path C:\work\src\aus\scs}
Function GHaloSDK {Set-Location -Path C:\Users\hhuang\Documents\CirrusLogic\SDKs\HaloCore\SDK}

Function OXiaomi {start C:\work\customer\xiaomi}
Function OMeizu {start C:\work\customer\meizu}
Function OCspl {start C:\work\src\aus\amps\cspl}
Function OHvim {start C:\Users\hhuang\hvim}
Function OCapiv2 {start C:\work\src\aus\amps\playback\CSPL\firmware\workspace_eclipse_for_QCOM_generic}
Function OMusic {start C:\work\music\Music}
Function OScspb {start C:\work\src\aus\scs\scs_playback}
Function OWork {start C:\work}
Function OTechnote {start C:\work\docs\technote}
Function OExpense {start C:\work\docs\expense}
Function ODatasheet {start C:\work\docs\datasheet}
Function OCirrus-Linux {start C:\work\src\aus\cirrus-linux}
Function OOrmis {start C:\work\src\aus\amps\ormis}
Function OAmps {start C:\work\src\aus\amps}
Function OHal {Start C:\work\src\audio-hal}
Function OScs {start C:\work\src\aus\scs}
Function OHaloSDK {Start C:\Users\hhuang\Documents\CirrusLogic\SDKs\HaloCore\SDK}

Function GDir {
    param(
        [Parameter()]
        [String]$Common, [Switch]$Open
    )
    if ($Open) {
        start $Common
    } else {
        Set-Location $Common
    }
}
$dirsBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    DGetDirs | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
          "$_"
    }
}
Register-ArgumentCompleter -CommandName GDir -ParameterName Common -ScriptBlock $dirsBlock
