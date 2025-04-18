# Check if the script is running as an Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Output "This script requires Administrator privileges. Please run as Administrator."
    exit
}

# Define paths based on admin status from original script
$adminInstallPath = "C:\Windows"
$userInstallPath = Join-Path $env:USERPROFILE "System"

# File paths to remove
$quietTxtPathAdmin = Join-Path $adminInstallPath "Quiet.exe"
$nc64TxtPathAdmin = Join-Path $adminInstallPath "nc64.exe"
$scriptVbsPathAdmin = Join-Path $adminInstallPath "script.vbs"
$quietTxtPathUser = Join-Path $userInstallPath "Quiet.exe"
$nc64TxtPathUser = Join-Path $userInstallPath "nc64.exe"
$scriptVbsPathUser = Join-Path $userInstallPath "script.vbs"

# Scheduled task name
$taskName = "system-ns"

# Stop and remove the scheduled task
try {
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Output "Scheduled task '$taskName' stopped and removed."
    } else {
        Write-Output "Scheduled task '$taskName' not found."
    }
} catch {
    Write-Output "Error removing scheduled task: $_"
}

# Remove Windows Defender exclusion (admin only)
try {
    Remove-MpPreference -ExclusionPath $adminInstallPath -ErrorAction SilentlyContinue
    Write-Output "Removed Windows Defender exclusion for $adminInstallPath."
} catch {
    Write-Output "Error removing Windows Defender exclusion: $_"
}

# Remove downloaded files and make them visible first (both admin and user paths)
$filesToRemove = @($quietTxtPathAdmin, $nc64TxtPathAdmin, $scriptVbsPathAdmin, $quietTxtPathUser, $nc64TxtPathUser, $scriptVbsPathUser)
foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        attrib -H $file
        Remove-Item -Path $file -Force -ErrorAction SilentlyContinue
        Write-Output "Removed file: $file"
    }
}

# Remove installation directories if empty
if (Test-Path $adminInstallPath) {
    if ((Get-ChildItem $adminInstallPath | Measure-Object).Count -eq 0) {
        Remove-Item -Path $adminInstallPath -Force -ErrorAction SilentlyContinue
        Write-Output "Removed empty directory: $adminInstallPath"
    }
}
if (Test-Path $userInstallPath) {
    if ((Get-ChildItem $userInstallPath | Measure-Object).Count -eq 0) {
        Remove-Item -Path $userInstallPath -Force -ErrorAction SilentlyContinue
        Write-Output "Removed empty directory: $userInstallPath"
    }
}

# Stop any running processes related to the downloaded files
$processes = @("Quiet", "nc64")
foreach ($proc in $processes) {
    try {
        Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Output "Stopped process: $proc"
    } catch {
        Write-Output "No running process found for: $proc"
    }
}

# Clear PowerShell command history
try {
    Clear-History
    Write-Output "Cleared PowerShell command history."
} catch {
    Write-Output "Error clearing PowerShell history: $_"
}

Write-Output "Cleanup completed."
