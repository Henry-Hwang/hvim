Function Hssh {
    ssh cirrus@198.90.140.120
}

Function HScp {
    param([Switch]$To, [String]$IP, [String]$Src, [String]$Dest)
    if($To) {
        scp -r $Src cirrus@$IP`:$Dest
    } else {
        scp -r cirrus@$IP`:$Src $Dest
    }
}
Function HScpPush {
    param([String]$Src, [String]$Dest)

    if($Dest) {
        Hscp -To -IP 198.90.140.120 -Src $Src -Dest $Dest
    } else {
        Hscp -To -IP 198.90.140.120 -Src $Src -Dest ~/temp
    }
}

Function HScpPull {
    param([String]$Src, [String]$Dest)
    Hscp -IP 198.90.140.120 -Src $Src -Dest $Dest
}

$pullBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (ssh cirrus@198.90.140.120:ls) | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
          "$_"
    }
}
Register-ArgumentCompleter -CommandName HScpPull -ParameterName Src -ScriptBlock $SourceBlock


