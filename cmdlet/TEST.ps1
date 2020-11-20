Function MultiJobs-Foreach-Parallel {
    # Example workload
    $dataset = @(
        @{
            Id   = 1
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
        }
        @{
            Id   = 2
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
        }
        @{
            Id   = 3
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
        }
        @{
            Id   = 4
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
        }
        @{
            Id   = 5
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
        }
    )

    # Create a hashtable for process.
    # Keys should be ID's of the processes
    $origin = @{}
    $dataset | Foreach-Object {$origin.($_.id) = @{}}
    # Create synced hashtable
    $sync = [System.Collections.Hashtable]::Synchronized($origin)
    $job = $dataset | Foreach-Object -ThrottleLimit 3 -AsJob -Parallel {
        $syncCopy = $using:sync
        $process = $syncCopy.$($PSItem.Id)

        $process.Id = $PSItem.Id
        $process.Activity = "Id $($PSItem.Id) starting"
        $process.Status = "Processing"

        # Fake workload start up that takes x amount of time to complete
        start-sleep -Milliseconds ($PSItem.wait*5)

        # Process. update activity
        $process.Activity = "Id $($PSItem.id) processing"
        foreach ($percent in 1..100)
        {
            # Update process on status
            $process.Status = "Handling $percent/100"
            $process.PercentComplete = (($percent / 100) * 100)

            # Fake workload that takes x amount of time to complete
            Start-Sleep -Milliseconds $PSItem.Wait
        }

        # Mark process as completed
        $process.Completed = $true
    }

    while($job.State -eq 'Running')
    {
        $sync.Keys | Foreach-Object {
            # If key is not defined, ignore
            if(![string]::IsNullOrEmpty($sync.$_.keys))
            {
                # Create parameter hashtable to splat
                $param = $sync.$_
                # Execute Write-Progress
                Write-Progress @param
            }
        }

        # Wait to refresh to not overload gui
        Start-Sleep -Seconds 0.1
    }
}


#MultiJobs-Foreach-Parallel

Function MultiJobs-Foreach-Parallel-Callback {
    # Example workload
    $dataset = @(
        @{
            Id   = 1
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
            Callback = {
                Param (
                    [Int32] $num
                )
                 "Time: $num"
            }
        }
        @{
            Id   = 2
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
            Callback = {
                Param (
                    [Int32] $num
                )
                 "Time: $num"
            }
        }
        @{
            Id   = 3
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
            Callback = {
                Param (
                    [Int32] $num
                )
                 "Time: $num"
            }
        }
        @{
            Id   = 4
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
            Callback = {
                Param (
                    [Int32] $num
                )
                 "Time: $num"
            }
        }
        @{
            Id   = 5
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
            Callback = {
                Param (
                    [Int32] $num
                )
                 "Time: $num"
            }
        }
    )

    # Create a hashtable for process.
    # Keys should be ID's of the processes
    $origin = @{}
    $dataset | Foreach-Object {$origin.($_.id) = @{}}
    # Create synced hashtable
    $sync = [System.Collections.Hashtable]::Synchronized($origin)
    $job = $dataset | Foreach-Object -ThrottleLimit 3 -AsJob -Parallel {
        $syncCopy = $using:sync
        $process = $syncCopy.$($PSItem.Id)

        $process.Id = $PSItem.Id
        $process.Activity = "Id $($PSItem.Id) starting"
        $process.Status = "Processing"

        # Fake workload start up that takes x amount of time to complete
        start-sleep -Milliseconds ($PSItem.wait*5)

        # Process. update activity
        $process.Activity = "Id $($PSItem.id) processing"
        foreach ($percent in 1..100)
        {
            # Update process on status
            #$process.Status = "Handling $percent/100"

            $process.Status = "Handling:" + [String]$PSItem.Callback.Invoke($percent)
            $process.PercentComplete = (($percent / 100) * 100)

            # Fake workload that takes x amount of time to complete
            Start-Sleep -Milliseconds $PSItem.Wait
        }

        # Mark process as completed
        $process.Completed = $true
    }

    while($job.State -eq 'Running')
    {
        $sync.Keys | Foreach-Object {
            # If key is not defined, ignore
            if(![string]::IsNullOrEmpty($sync.$_.keys))
            {
                # Create parameter hashtable to splat
                $param = $sync.$_
                # Execute Write-Progress
                Write-Progress @param
            }
        }

        # Wait to refresh to not overload gui
        Start-Sleep -Seconds 0.1
    }
}


#MultiJobs-Foreach-Parallel-Callback
$deltaBlock ={
    param(
        [Parameter()]
        [ref]$Status, [Int32]$Cnt
    )
    $Count = $Cnt
	adb shell input keyevent 27  #POWER
	sleep 2
	adb shell input swipe 200 1700 200 300 # SWIPE UP
    sleep 1
    while($Count-- -gt 0) {
        #Call 112
        adb shell service call phone 1 s16 112
        sleep 1
	    adb shell input tap 533 2156 # tap CALL
        Write-Host $Count "Calls"
	    $ModeCount = 20
        while($ModeCount-- -gt 0) {
            sleep 1
	        adb shell input tap 538 1100 # tap Handsfree/Handset
            adb shell dmesg > dmesg.txt
            CheckInLogs -Target dmesg.txt -Patten "CSPL_STATE"
        }
	    adb shell input tap 531 2073 # tap Hang up
        sleep 2
    }
}


Function MultiJobs-Foreach-Parallel-Callback-DeltaTest {
    # Example workload
    $dataset = @(
        @{
            Id   = 1
            Wait = 3..10 | get-random | Foreach-Object {$_*10}
            Callback = $deltaBlock
        }
    )

    Ainit
    # Create a hashtable for process.
    # Keys should be ID's of the processes
    $origin = @{}
    $dataset | Foreach-Object {$origin.($_.id) = @{}}
    # Create synced hashtable
    $sync = [System.Collections.Hashtable]::Synchronized($origin)
    $job = $dataset | Foreach-Object -ThrottleLimit 3 -AsJob -Parallel {
        $syncCopy = $using:sync
        $process = $syncCopy.$($PSItem.Id)

        $process.Id = $PSItem.Id
        $process.Activity = "Id $($PSItem.Id) starting"
        $process.Status = "Processing"

        # Fake workload start up that takes x amount of time to complete
        start-sleep -Milliseconds ($PSItem.wait*5)

        # Process. update activity
        $process.Activity = "Id $($PSItem.id) processing"

        foreach ($percent in 1..100) {
            # Update process on status
            #$process.Status = "Handling $percent/100"

            $process.PercentComplete = (($percent / 100) * 100)

            adb shell service call phone 1 s16 112
            sleep 1
	        adb shell input tap 533 2156 # tap CALL
            foreach ($Tabs in 1..15) {
                sleep 1
	            adb shell input tap 538 1100 # tap Handsfree/Handset
                adb shell dmesg > dmesg.txt
                $file = Get-Content dmesg.txt
                $isWord = $file | %{$_ -match "CSPL_STATE"}
                if ($isWord -contains $true) {
                    $process.Status = "Handling: $percent Calls, $Tabs Switching, Failed!"
                    $process.Completed = $true
                    return
                } else {
                    $process.Status = "Handling: $percent Calls, $Tabs Switching"
                }
            }

	        adb shell input tap 531 2073 # tap Hang up
            sleep 2
            # Fake workload that takes x amount of time to complete
        }

        # Mark process as completed
        $process.Completed = $true
    }

    while($job.State -eq 'Running')
    {
        $sync.Keys | Foreach-Object {
            # If key is not defined, ignore
            if(![string]::IsNullOrEmpty($sync.$_.keys))
            {
                # Create parameter hashtable to splat
                $param = $sync.$_
                # Execute Write-Progress
                Write-Progress @param
            }
        }

        # Wait to refresh to not overload gui
        Start-Sleep -Seconds 0.1
    }
    $param
}


#MultiJobs-Foreach-Parallel-Callback-DeltaTest
Function MultiJobs-Foreach-Start-Job-DeltaTest {
    Ainit
    $origin = @{}
    # Create synced hashtable
    $job = Start-Job -WorkingDirectory $PWD -Name Delta {
        #$syncCopy = $using:sync
        $process = $using:origin
        $process.Id = 66
        $process.Activity = "Id $($PSItem.Id) starting"
        $process.Status = "Processing"

        # Process. update activity
        $process.Activity = "Id $($PSItem.id) processing"

        adb shell input keyevent 27  #POWER
        sleep 2
        adb shell input swipe 200 1700 200 300 # SWIPE UP
        sleep 1
        foreach ($percent in 1..100) {
            # Update process on status
            #$process.Status = "Handling $percent/100"

            $process.PercentComplete = (($percent / 100) * 100)

            adb shell service call phone 1 s16 112
            sleep 1
	        adb shell input tap 533 2156 # tap CALL
            foreach ($Tabs in 1..15) {
                sleep 1
	            adb shell input tap 538 1100 # tap Handsfree/Handset
                adb shell dmesg > dmesg.txt
                $file = Get-Content dmesg.txt
                $isWord = $file | %{$_ -match "CSPL_STATE"}
                if ($isWord -contains $true) {
                    $process.Status = "Handling: $percent Calls, $Tabs Switching, Failed!"
                    $process.Completed = $true
                    return
                } else {
                    $process.Status = "Handling-0: $percent Calls, $Tabs Switching"
                }
                Start-Sleep -Seconds 0.1
            }

	        adb shell input tap 531 2073 # tap Hang up
            sleep 2
            # Fake workload that takes x amount of time to complete
        }

        # Mark process as completed
        $process.Completed = $true
    }

    while($job.State -eq 'Running') {
        # Create parameter hashtable to splat
        $param = $origin
        # Execute Write-Progress
        Write-Progress @param

        # Wait to refresh to not overload gui
        Start-Sleep -Seconds 0.1
    }

    Dlogs -Tag Failed -All -View
    $param
}


#MultiJobs-Foreach-Parallel-Callback-DeltaTest
