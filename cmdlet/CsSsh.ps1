
$global:android_kernel = "/home/cirrus/src/opensource/android-kernel"
$global:USER_IP = "cirrus@198.90.140.120"
$global:IP = "198.90.140.120"
$global:audio_dir = "/private/msm-5.4/techpack/audio"

Function hssh-cmd{
    param([String]$cmd)
    ssh $global:USER_IP $cmd
}

Function hssh-sync {
    param([String[]]$Files)

    For ($i=0; $i -lt $Files.Length; $i++) {
        $t = Get-Item $Files[$i]
        #find ./ -name file.c
        $cmd = "find " + $global:android_kernel+$global:audio_dir + " -name " + $t.Name

        $remote = @(hssh-cmd $cmd)
        $cmd = "scp -r @SOURCE $USER_IP`:@DEST"
        if($remote.Length -gt 1) {
            $option = Create-Menu -MenuTitle "Files:" -MenuOption $remote
            $cmd = $cmd.Replace("@SOURCE", $t.FullName).Replace("@DEST", $remote[$option])
        } elseif($remote.Length -eq 1) {
            $cmd = $cmd.Replace("@SOURCE", $t.FullName).Replace("@DEST", $remote[0])
        } else {
            $cmd = "find " + $global:android_kernel+$global:audio_dir + " -name " + "cs35l*"
            $remote = @(hssh-cmd $cmd)
            $cmd = "scp -r @SOURCE $USER_IP`:@DEST"
            $option = Create-Menu -MenuTitle "Files:" -MenuOption $remote
            $cmd = $cmd.Replace("@SOURCE", $t.FullName).Replace("@DEST", $remote[$option])
        }

        Invoke-Expression $cmd
    }
}
Function Hssh {
    ssh $global:USER_IP
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
        Hscp -To -IP $global:IP -Src $Src -Dest $Dest
    } else {
        Hscp -To -IP $global:IP -Src $Src -Dest ~/temp
    }
}

Function HScpPull {
    param([String]$Src, [String]$Dest)
    Hscp -IP $global:IP -Src $Src -Dest $Dest
}

$pullBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (ssh $global:USER_IP:ls) | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
          "$_"
    }
}
Register-ArgumentCompleter -CommandName HScpPull -ParameterName Src -ScriptBlock $SourceBlock


