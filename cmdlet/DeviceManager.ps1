Function ReadRegs {
    $reg1 = $(adb shell "cat /d/regmap/spi1.0/registers | grep 0004800:")
    $reg2 = $(adb shell "cat /d/regmap/spi1.1/registers | grep 0004800:")
    Write-Host $reg1 $reg2
}

Function Cmd2AShell {
    Param(
        [Parameter(Mandatory=$True)]
        [String]$Cmds
    )
    $Sb = New-Object -TypeName System.Text.StringBuilder
    [void]$Sb.Append("adb shell `"@COMMANDS`"").Replace("@COMMANDS", $Cmds)
    return $Sb.ToString()
}

Function DCmd2Set{
    $Cmds = @()
    $Json = DGetJson
    #Write-Host $Json.AmpName $Json.AmpSet
    foreach ($element in $Json.Mixers) {
        $Cmds+=MixersRead2Cmd -InputObject $Json -Control $element -Prefix "RCV"
        #$element
    }
    $Cmd = $Cmds -join ";"
    return $Cmd
}

Function DMainDebug {
    <#
    $CSet = DCmd2Set
    $Cmd = Cmd2AShell -Cmds $Cset
    Invoke-Expression $Cmd
    #>

    DGetProducts
}

Function DGetDirs {
    param(
        [Parameter()]
        [Switch]$Project, [Switch]$Common
    )
    $Json = DGetJson
    $Dirs = @()
    foreach ($element in $Json.VENDORS) {
            foreach ($product in $element.Products) {
                    $Dirs += $product.Dir
            }
    }

    if ($Project) {
        return $Dirs
    }

    foreach ($element in $Json.DIRS) {
        $Dirs += $element
    }
    #$Dirs = $Dirs | Sort-Object
    $Dirs
}
Function DGetProduct {
    $Json = DGetJson
    foreach ($element in $Json.VENDORS) {
            foreach ($product in $element.Products) {
                if ($product.Name -eq $Json.WORKON) {
                    return $product
                }
            }
    }
}

Function DGetNodes {
    $Json = DGetJson
    foreach ($element in $Json.VENDORS) {
            foreach ($product in $element.Products) {
                if ($product.Name -eq $Json.WORKON) {
                    return $product.Nodes
                }
            }
    }
}
Function DGetSoundCard {
    $Json = DGetJson
    foreach ($element in $Json.VENDORS) {
            foreach ($product in $element.Products) {
                if ($product.Name -eq $Json.WORKON) {
                    return $product.SoundCard
                }
            }
    }
}
Function DDevices {
    param(
        [Parameter()]
        [String]$Workon, [Switch]$Get, [Switch]$Nodes, [Switch]$Show
    )

    $Json = DGetJson
    if ($Show) {
        foreach ($element in $Json.VENDORS) {
                foreach ($product in $element.Products) {
                    $product.Name
                }
        }
    }

    if ($Workon) {
        $Json.WORKON = $Workon
        $Json | ConvertTo-Json -depth 32| set-content '~\hvim\cmdlet\DevInfo.json'
    }
}

$devBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $Json = DGetJson
    DDevices -Show | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
        "$_"
    }
}

Register-ArgumentCompleter -CommandName DDevices -ParameterName Workon -ScriptBlock $devBlock

Function DGetJson{
    $Json = Get-Content ~\hvim\cmdlet\DevInfo.json | ConvertFrom-Json

    return $Json
}
function ATmix {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Control, $Value
    )
    $Sb = New-Object -TypeName System.Text.StringBuilder
    if($Value) {
        [void]$Sb.Append("tinymix `'@CONTROL`' `'@VALUE`'").Replace("@CONTROL", $Control).Replace("@VALUE", $Value)
    } else {
        [void]$Sb.Append("tinymix `'@CONTROL`'").Replace("@CONTROL", $Control)
    }

    $Cmd = Cmd2AShell -Cmds $Sb.ToString()
    $global:TmixCtls = $Cmd
    #$global:TmixCtls
    Invoke-Expression $Cmd
}

$ctlsBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $Json = DGetJson
    $Json.Mixers | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
        foreach ($element in $Json.AmpPrefix) {
            if ($element) {
                "`'$element $_`'"
            } else {
                "`'$_`'"
            }
        }
    }
}

$valueBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $(DgetJson).Mixers | where-Object {
        $_ -like "*$wordToComplete*"
    } | ForEach-Object {
          "`'RCV $_`'"
    }
}
Register-ArgumentCompleter -CommandName ATmix -ParameterName Control -ScriptBlock $ctlsBlock
<#
Function QuickAccessList {
#$QuickAccess = New-Object -ComObject shell.application
#$QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | where {Write-Host $_.Path}
    [CmdletBinding()] 
    Param ( 
         [Parameter(Mandatory=$true,Position=1,HelpMessage="Pin or Unpin folder to/from Quick Access in File Explorer.")] 
         [ValidateSet("Pin", "Unpin")] 
         [string]$Action, 
         [Parameter(Mandatory=$true,Position=2,HelpMessage="Path to the folder to Pin or Unpin to/from Quick Access in File Explorer.")] 
         [string]$Path 
        )

    Write-Host "$Action to/from Quick Access: $Path.. " -NoNewline 

    #Check if specified path is valid 
    If ((Test-Path -Path $Path) -ne $true) { 
           Write-Warning "Path does not exist." 
               return
    }
    #Check if specified path is a folder 
    If ((Test-Path -Path $Path -PathType Container) -ne $true){
        Write-Warning "Path is not a folder." 
            return
    }

    #Pin or Unpin
    $QuickAccess = New-Object -ComObject shell.application 
    $TargetObject = $QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | where {$_.Path -eq "$Path"} 
    If ($Action -eq "Pin") {
        If ($TargetObject -ne $null) {
            Write-Warning "Path is already pinned to Quick Access."
                return
        } Else {
            $QuickAccess.Namespace("$Path").Self.InvokeVerb(“pintohome”)
        }
    } ElseIf ($Action -eq "Unpin") {
        If ($TargetObject -eq $null) {
            Write-Warning "Path is not pinned to Quick Access."
                return
        } Else {
            $TargetObject.InvokeVerb("unpinfromhome")
        }
    }

    Write-Host "Done"
}
#>
