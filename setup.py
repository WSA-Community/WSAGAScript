from functions import *
import os
import shutil
import traceback
from sys import exit
from wsa_online_link_generator import *
import fnmatch
from speed_downloader import speed_download
from xml.dom import minidom
from packaging import version
import subprocess

# URL to download WSA Script from GitHub
wsagascript_url = "https://github.com/ADeltaX/WSAGAScript/archive/refs/heads/main.zip"

# URL to download GApps from SourceForge. Hardcoded :(
gapps_url = "https://nchc.dl.sourceforge.net/project/opengapps/x86_64/20211021/open_gapps-x86_64-11.0-pico-20211021.zip"

# directories for system images
gapps_dir = "./TEMP/WSAGAScript-main/#GAPPS"
images_dir = "./TEMP/WSAGAScript-main/#IMAGES"

# instead of installing in a temporary folder, move everything to install_loc before installing
install_loc = "C:/Program Files/WSA_Advanced/"

# preinstalled version initialization
existing_install_version = None


def cleanup():
    cur_dir = os.path.dirname(__file__)
    os.chdir(cur_dir)
    remove("./TEMP")


if __name__ == "__main__":
    try:
        # gets admin and modifies registry for developer mode, tries to enable WSL,
        # and switches to the executable directory (just don't want to be execute in the wrong one,
        # which may delete important stuff
        get_admin_permission()
        executable_dir = os.path.dirname(__file__)
        # if the script executes in the shell with the location C:\,
        # it will affect the folder C:\TEMP (which is NOT good)
        print(f"EXECUTABLE DIRECTORY: {executable_dir}")
        os.chdir(executable_dir)
        print(f'WSL install status: {is_linux_enabled("debian")}')

        os.popen('reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock"'
                 ' /t REG_DWORD'
                 ' /f /v "AllowDevelopmentWithoutDevLicense" /d "1"').read()

        cleanup()

        # creates WSA directories
        # Checks for updates and downloads the newest version of WSA.
        os.makedirs("./TEMP/wsa", exist_ok=True)
        os.makedirs("./TEMP/wsa_main", exist_ok=True)
        os.makedirs(install_loc, exist_ok=True)

        # obtains WSA package link and version
        wsa_entry_result = get_wsa_entry()
        if not wsa_entry_result:
            wsa_archive_version = None
            input("No matching Windows Subsystem for Android package was found. Press ENTER to exit.")
            exit()
        else:
            wsa_archive_url, wsa_archive_name = wsa_entry_result
            wsa_archive_version = version.parse(wsa_archive_name.split("_")[1])
            if not wsa_archive_version:
                raise Exception("Sanity check failed. WSA archive version not found.")
            try:
                existing_install_version = max(map(version.parse, os.listdir(install_loc)))
                # exception will be raised so that the new installation mode is used if there is nothing
                if not existing_install_version:
                    # makes sure the version is not empty. Empty directories may cause unintentional deletions.
                    raise Exception("Sanity check failed. WSA existing version not found.")
                print(f"Existing installation version: {existing_install_version}")
                print(f'Latest version:                {wsa_archive_version}')
                if wsa_archive_version <= existing_install_version:
                    input("Windows Subsystem for Android is up-to-date. Press ENTER to exit.")
                    exit()
                else:
                    print("Updating WSA...")
            except ValueError:
                print("New installation detected.")
            speed_download(wsa_archive_url, "./TEMP", "wsa.zip")
            shutil.unpack_archive("./TEMP/wsa.zip", "./TEMP/wsa", "zip")

        # unpacks the x64 archive
        for _ in os.listdir("./TEMP/wsa"):
            if fnmatch.fnmatch(_, "*x64_Release*.msix"):
                shutil.unpack_archive(f"./TEMP/wsa/{_}", "./TEMP/wsa_main", "zip")
                break
        else:
            _ = WindowError("Your selected archive does not have the 64-bit MSIX bundle.", no_text="Exit")
            _.wait_window()
            cleanup()
            exit()

        # removes signature from package
        remove("./TEMP/wsa_main/AppxMetadata")
        remove("./TEMP/wsa_main/[Content_Types].xml")
        remove("./TEMP/wsa_main/AppxBlockMap.xml")
        remove("./TEMP/wsa_main/AppxSignature.p7x")

        # downloads WSAGAScript and extract, creates WSAGAScript-main
        os.makedirs("./TEMP/WSAGAScript-main", exist_ok=True)
        speed_download(wsagascript_url, "./TEMP", "WSAGAScript.zip")
        shutil.unpack_archive("./TEMP/WSAGAScript.zip", "./TEMP", "zip")

        # creates GAPPS and IMAGES directory in case it's missing
        os.makedirs(gapps_dir, exist_ok=True)
        os.makedirs(images_dir, exist_ok=True)

        # downloads GApps
        speed_download(gapps_url, gapps_dir)

        # moves files to working directory.
        for _ in os.listdir("./TEMP/wsa_main"):
            if fnmatch.fnmatch(_, "*.img"):
                shutil.move(f'./TEMP/wsa_main/{_}', "./TEMP/WSAGAScript-main/#IMAGES")

        # executes main script
        install_script = """#!/bin/bash
        sudo apt update
        sudo apt install unzip lzip
        sudo bash ./extract_gapps_pico.sh
        sudo bash ./extend_and_mount_images.sh
        sudo bash ./apply.sh
        sudo bash ./unmount_images.sh"""
        with open("./TEMP/WSAGAScript-main/autorun.sh", "w", newline="\n") as file:
            file.write(install_script)
        print("ALTERING SYSTEM IMAGE. DO NOT EXIT!")
        print(os.popen("bash -c 'cd ./TEMP/WSAGAScript-main; sudo bash ./autorun.sh'").read())

        # copies back
        for _ in os.listdir("./TEMP/WSAGAScript-main/#IMAGES"):
            if fnmatch.fnmatch(_, "*.img"):
                shutil.move(f'./TEMP/WSAGAScript-main/#IMAGES/{_}', "./TEMP/wsa_main")

        # rooted kernel
        shutil.copy(f'./TEMP/WSAGAScript-main/misc/kernel-x86_64', "./TEMP/wsa_main/Tools")

        # bypasses Windows 11 requirement
        manifest_data = minidom.parse("./TEMP/wsa_main/AppxManifest.xml")
        selected_element = manifest_data.getElementsByTagName("TargetDeviceFamily")[0]
        selected_element.attributes["MinVersion"].value = "10.0.19043.1237"

        with open("./TEMP/wsa_main/AppxManifest.xml", "w", encoding="utf-8") as file:
            file.write(manifest_data.toxml())

        # installs
        new_install_location = os.path.realpath(os.path.join(install_loc, str(wsa_archive_version)))
        print(f'Installing to {new_install_location}')
        os.makedirs(new_install_location, exist_ok=True)

        for file in os.listdir("./TEMP/wsa_main"):
            shutil.move(os.path.join("./TEMP/wsa_main", file), new_install_location)
        install_process = subprocess.run(f"powershell.exe Add-AppxPackage "
                                         f"-Register '{new_install_location}\\AppXManifest.xml' "
                                         f"-ForceTargetApplicationShutdown")

        # cleans up temporary folder
        print("Cleaning up temporary files.")
        cleanup()

        # deletes either the old or new version depending on return code
        if not install_process.returncode:
            if existing_install_version:
                print(f"Deleting version {existing_install_version}.")
                remove(os.path.join(install_loc, str(existing_install_version)))
            input("WSA with GApps and root access installed. Press ENTER to exit.")
        else:
            remove(new_install_location)
            input("Package install failure. Installation has been rolled back. Press ENTER to exit.")
    except Exception as e:
        cleanup()
        print(traceback.format_exc())
        input("Install failure. An exception occured. Installation has been rolled back. Press ENTER to exit.")
        with open("error.log", "w") as file:
            print(e, file=file)
            print(traceback.format_exc(), file=file)
