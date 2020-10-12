function VerbCompletion {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Get-Verb "$wordToComplete*" |
    ForEach-Object {
        New-CompletionResult -CompletionText $_.Verb -ToolTip ("Group: " + $_.Group)
    }
}
$scriptBlock = { 'foo','bar' }
function Do-Thing {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Name
    )
    $Name
}

Register-ArgumentCompleter -CommandName Do-Thing -ParameterName Name -ScriptBlock $scriptBlock


#$scriptBlock = { Get-ChildItem -Path 'C:\Program Files' | Select-Object -ExpandProperty Name }

function Get-ProgramFilesFolder {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$FolderName
    )
}
#Register-ArgumentCompleter -CommandName Get-ProgramFilesFolder -ParameterName FolderName -ScriptBlock $scriptBlock

$scriptblock = {
    param($commandName,$parameterName)
    $commandName,$parameterName
}
#Register-ArgumentCompleter -CommandName Get-ProgramFilesFolder -ParameterName FolderName -ScriptBlock $scriptBlock

$scriptblock = {
    param($commandName,$parameterName,$stringMatch)
    Get-ChildItem -Path "C:\Program Files\$stringMatch*" | Select-Object -ExpandProperty Name
}

Register-ArgumentCompleter -CommandName Get-ProgramFilesFolder -ParameterName FolderName -ScriptBlock $scriptBlock

$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (Get-TimeZone -ListAvailable).Id | Where-Object {
        $_ -like "$wordToComplete*"
    } | ForEach-Object {
          "'$_'"
    }
}
Register-ArgumentCompleter -CommandName Set-TimeZone -ParameterName Id -ScriptBlock $scriptBlock

