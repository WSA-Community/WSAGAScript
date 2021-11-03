from functions import *
import subprocess
import os
import traceback
from sys import exit

if __name__ == '__main__':
    try:
        get_admin_permission()
        if not subprocess.run("powershell.exe Get-AppXPackage MicrosoftCorporationII.WindowsSubsystemForAndroid").stdout:
            input("Windows Subsystem for Android is not installed. Press ENTER to exit.")
            exit()
        os.chdir(os.path.dirname(__file__))
        choice = input("Uninstall Windows Subsystem for Android? [Y]es [N]o (default: no)")
        if choice.casefold() in ["y", "yes"]:
            a = subprocess.run("powershell.exe Get-AppXPackage MicrosoftCorporationII.WindowsSubsystemForAndroid |"
                               " Remove-AppXPackage -AllUsers")
            if not a.returncode:
                for _ in os.listdir("C:/Program Files/WSA_Advanced"):
                    remove(os.path.join("C:/Program Files/WSA_Advanced", _))
                input("Windows Subsystem for Android uninstalled. Press ENTER to exit.")
            else:
                print("Windows Subsystem for Android failed to uninstall,"
                      " or has already been uninstalled, or uninstallation canceled.")
                input("Press ENTER to exit.")
    except Exception as e:
        print(traceback.format_exc())
        input("Press ENTER to exit.")