Function GD {
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
Register-ArgumentCompleter -CommandName GD -ParameterName Common -ScriptBlock $dirsBlock
