
Function Ormis-Server {
    ormis server --cspl-block-path C:\work\src\aus\amps\algorithms\blocks\primitives --block-path C:\work\src\aus\amps\algorithms\blocks --platform-path C:\work\src\aus\amps\csplc\platforms
}

Function Ormis-package {
    ormis register package --cspl-block-path C:\work\src\aus\amps\algorithms\blocks\primitives --block-path C:\work\src\aus\amps\algorithms\blocks -o playback.csplpkg
}

Function Ormis-Tuning-Create-Cmd {
    param(
        [Parameter()]
        [String]$Top, [String]$Platform, [String]$Name
    )
    try{
        . C:\Users\hhuang\hvim\cmdlet\Ormis-Cmd-Create-Tuning.cmd $Top $Platform $Name
    } catch {
        throw "Build Failed"
    }
}

Function Ormis-Tuning-Create-No-Evn {
    param(
        [Parameter()]
        [String]$Top, [String]$Name
    )
    $CORMIS_TUNING_UUID = $(cormis tuning create $Top)
    write-host $CORMIS_TUNING_UUID
    cormis tuning compile --tuning-uuid $CORMIS_TUNING_UUID  > $Name
    $t = Get-Item $Name
    $PNG = $t.BaseName+".png"
    #This command have to be executed in cmd
    cmd /c "cormis block graphviz  --tuning-uuid $CORMIS_TUNING_UUID main | dot -Tpng > $PNG"
    $save_name = $t.BaseName+".save.json"
    cormis tuning save --tuning-uuid $CORMIS_TUNING_UUID $save_name
    write-host "Supported Platform:"
    cormis tuning platform --tuning-uuid $CORMIS_TUNING_UUID
    cormis tuning delete $CORMIS_TUNING_UUID
}

Function Ormis-Tuning-Create {
    param(
        [Parameter()]
        [String]$Top, [String]$Name,[Switch]$Compile=$False, [Switch]$Pic=$False
    )

    $Env:CORMIS_TUNING_UUID = $(cormis tuning create $Top)
    write-host $Env:CORMIS_TUNING_UUID

    if($Compile) {
        cormis tuning compile  > $Name
    }

    if($Pic) {
        $t = Get-Item $Name
        $PNG = $t.BaseName+".png"
        cormis block graphviz main | dot -Tpng > $PNG
    }
    write-host "Supported Platform:"
    cormis tuning platform
    #cormis tuning save $save_name
}

Function Ormis-Tuning-Clean {
    param(
        [Parameter()]
        [Switch]$All=$True
    )

    $Tunings = @(cormis tuning list)
    $UUIDS = @()
    foreach ($element in $Tunings) {
        if($element.contains($Env:CORMIS_TUNING_UUID) -and ($All -eq $False)) {
            write-host Keep $element -Foreground "Green"
            continue
        }
        $UUIDS += $element.split()[0]
        write-host delete $element -Foreground "Red"
    }

    foreach ($element in $UUIDS) {
        cormis tuning delete $element
    }
}

Function Ormis-Tuning-Delete {
    param(
        [Parameter()]
        [String]$Top, [String]$Name
    )

    cormis tuning list
    cormis tuning delete $Env:CORMIS_TUNING_UUID
}

Function Ormis-Tuning-List {
    param(
        [Parameter()]
        [Switch]$On=$False, [String]$Name
    )

    $Tunings = @(cormis tuning list)
    if($Tunings.Count -eq 0) {
        write-host No Tuning
    }

    foreach ($element in $Tunings) {
        if($element.contains($Env:CORMIS_TUNING_UUID)) {
            write-host Keep $element -Foreground "Green"
            continue
        }
        write-host $element
    }
}

Function Ormis-Tuning-Load{
    param(
        [Parameter()]
        [String[]]$Tunings
    )
    $UUIDS = @()
    foreach ($element in $Tunings) {
        $UUIDS += $(CORMIS tuning load $element)
    }

    foreach ($element in $UUIDS) {
        write-host Loaded $element
    }
}

Function Ormis-Tuning-Save{
    param(
        [Parameter()]
        [String]$UUID, [Switch]$All
    )

    $Tunings = @(cormis tuning list)
    if(!$All) {
        if(!$UUID) {
            $UUID = $Tunings[0].split()[0]
            $Name = $Tunings[0].split()[1] + "." + $((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds)+".tuning"
        }
        cormis tuning save --tuning-uuid $UUID $Name
        write-host Saved $Name
    } else {
        foreach($element in $Tunings) {
            $UUID = $element.split()[0]
            $Name = $element.split()[1] + "." + $((New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds)+".tuning"
            cormis tuning save --tuning-uuid $UUID $Name
            write-host Saved $Name
        }
    }
}

Function Ormis-Tuning-Subblock{
    param(
        [Parameter()]
        [String]$UUID, [Switch]$All
    )

    $Tunings = @(cormis tuning list)
    if(!$All) {
        if(!$UUID) {
            $UUID = $Tunings[0].split()[0]
        }
        write-host $UUID
        cormis tuning subblock --tuning-uuid $UUID "C:\work\src\aus\amps\algorithms\blocks"
    } else {
        foreach($element in $Tunings) {
            $UUID = $element.split()[0]
            cormis tuning subblock --tuning-uuid $UUID
        }
    }
}

Function Ormis-Tuning-Delta {
    param(
        [Parameter()]
        [String]$UUID1, [String]$UUID2
    )

    write-host $UUID1
    write-host $UUID2
    cormis tuning compile_delta --tuning-uuid $CORMIS_TUNING_UUID  --tuning-uuid-from $CORMIS_TUNING_UUID_B > mydelta.json
}

Function Ormis-Param-List {
    $Tunings = @(cormis tuning list)
    $UUID = $Tunings[0].split()[0]
    cormis param list --tuning-uuid $UUID "C:\work\src\aus\amps\algorithms\blocks\composites\mix"
}
