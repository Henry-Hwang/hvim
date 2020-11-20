Function Ainit {
    adb wait-for-device root
    adb wait-for-device remount
    adb wait-for-device
    adb shell setenforce 0
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

