from functions import *
import subprocess
import os

if __name__ == '__main__':
    get_admin_permission()
    os.chdir(os.path.dirname(__file__))
    a = subprocess.run("powershell.exe Get-AppXPackage MicrosoftCorporationII.WindowsSubsystemForAndroid |"
                       " Remove-AppXPackage -AllUsers -Confirm")
    if not a.returncode:
        for _ in os.listdir("C:/Program Files/WSA_Advanced"):
            remove(os.path.join("C:/Program Files/WSA_Advanced", _))
        input("Windows Subsystem for Android uninstalled. Press ENTER to exit.")
    else:
        print("Windows Subsystem for Android failed to uninstall,"
              " or has already been uninstalled, or uninstallation canceled.")
        input("Press ENTER to exit.")
