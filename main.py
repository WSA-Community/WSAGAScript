from functions import *
import os
import shutil
import traceback
from sys import exit
from wsa_online_link_generator import *
import fnmatch
from speed_downloader import speed_download
from xml.dom import minidom

# URL to download WSA Script from GitHub
wsagascript_url = "https://github.com/ADeltaX/WSAGAScript/archive/refs/heads/main.zip"

# URL to download GApps from SourceForge. Hardcoded :(
gapps_url = "https://nchc.dl.sourceforge.net/project/opengapps/x86_64/20211021/open_gapps-x86_64-11.0-pico-20211021.zip"

gapps_dir = "./TEMP/WSAGAScript-main/#GAPPS"
images_dir = "./TEMP/WSAGAScript-main/#IMAGES"

if __name__ == "__main__":
    try:
        # gets admin and modifies registry for developer mode, tries to enable WSL,
        # and switches to the executable directory (just don't want to be execute in the wrong one,
        # which may delete important stuff

        get_admin_permission()
        executable_dir = os.path.dirname(__file__)

        print(f"EXECUTABLE DIRECTORY: {executable_dir}")
        os.chdir(executable_dir)
        print(f'WSL install status: {is_linux_enabled("debian")}')

        os.popen('reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock"'
                 ' /t REG_DWORD'
                 ' /f /v "AllowDevelopmentWithoutDevLicense" /d "1"').read()


        def cleanup():
            remove("./TEMP/wsa")
            remove("./TEMP/wsa_main")
            remove("./TEMP/WSAGAScript-main")
            remove("./TEMP/wsa.zip")
            remove("./TEMP/WSAGAScript.zip")
            for f in os.listdir("./TEMP"):
                if fnmatch.fnmatch(f, "*.part*"):
                    remove(os.path.join("./TEMP", f))


        cleanup()

        # creates WSA directories
        # downloads the newest version of WSA. Otherwise asks for a MSIX archive if the link happens to not be found
        os.makedirs("./TEMP/wsa", exist_ok=True)
        os.makedirs("./TEMP/wsa_main", exist_ok=True)
        wsa_archive_url = get_wsa_linkstore_id()
        if not wsa_archive_url:
            wsa_archive_dir = request_file_name(title="Select Windows Subsystem for Android MSIXBUNDLE archive",
                                                initialdir=".",
                                                filetypes=(('MSIX bundle files', '*.msixbundle'),))
            if not wsa_archive_dir:
                exit()
            print(f"ARCHIVE LOCATION: {wsa_archive_dir}")
            shutil.unpack_archive(wsa_archive_dir, "./TEMP/wsa", "zip")
        else:
            speed_download(wsa_archive_url, "./TEMP", "wsa.zip")
            shutil.unpack_archive("./TEMP/wsa.zip", "./TEMP/wsa", "zip")

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
        shutil.copy(f'./TEMP/WSAGAScript-main/misc/kernel', "./TEMP/wsa_main/Tools")

        # installs and bypasses Windows 11 requirement
        manifest_data = minidom.parse("./TEMP/wsa_main/AppxManifest.xml")
        selected_element = manifest_data.getElementsByTagName("TargetDeviceFamily")[0]
        selected_element.attributes["MinVersion"].value = "10.0.19043.1237"

        with open("./TEMP/wsa_main/AppxManifest.xml", "w", encoding="utf-8") as file:
            file.write(manifest_data.toxml())

        print(os.popen("powershell.exe Add-AppxPackage -Register .\\TEMP\\wsa_main\\AppXManifest.xml").read())

        # cleans up
        print()
        print("Cleaning up temporary files.")
        cleanup()
        input("WSA with GApps and root access installed. Press Enter to exit.")

    except Exception as e:
        with open("error.log", "w") as file:
            print(e, file=file)
            print(traceback.format_exc(), file=file)
