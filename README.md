# [WSA GApps Script](https://github.com/WSA-Community/WSAGAScript)


<p align="center">
  <a href="#required-warnings">Required Warnings</a> •
  <a href="#youtube-tutorial">YouTube Tutorial</a> •
  <a href="#installation-procedure">Installation procedure</a> •
  <a href="#uninstallation-procedure">Uninstallation procedure</a> •
  <a href="#gaining-root-access">Gaining Root Access</a> •
  <a href="https://t.me/WSA_Community">Telegram Group</a>
</p>

# Required Warnings
## This project is Work-In-Progress

This project is being updated without schedule (though frequently). This README might not be completely clear right now, it will be fixed ASAP.

As for potential questions - please open Discussions instead of Issues.  
Issues are needed in cases if you have an **actual** issue that **prevents** you from **using** this project.

## Legal Warnings

By using the tools (scripts, but not limited to) provided by this project, you agree with the terms of [Unlicense License](https://github.com/WSA-Community/WSAGAScript/blob/main/LICENSE), which states that "THE SOFTWARE IS PROVIDED "AS IS"".

To end user this serves as a warning, though we currently don't have any explicit confirmations - such way of installing Google Services and Google Play Store may potentially be in a legal gray area.

## Copyright notices

Any product or trademark referenced in this document (or project as whole) belongs to their respective owners. No copyright infringement is intended.

# YouTube Tutorial

As a temporary measure and additional information (especially if README remains unclear, [@ADeltaX](https://github.com/ADeltaX) provides a video-tutorial hosted on YouTube 

<p align="center">

[![How to install Google Apps (Play Store) on WSA (Windows Subsystem Android)](http://img.youtube.com/vi/rIt00xDp0tM/0.jpg)](http://www.youtube.com/watch?v=rIt00xDp0tM 'How to install Google Apps (Play Store) on WSA (Windows Subsystem Android)')

</p>

*Click on the image to see the video*

# Installation procedure

## Install Windows Subsystem for Linux (Version 2)

### Q & A for WSL Installation
If you have never used WSL, please do check the following:

- You must be running Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11

Fastest way to check your build version is to run `winver` command in Windows Search or via "Run..." (Right-click the Start button to access "Run...")

- Why do I need that "WSL"?

Because of the way Android as an operating system is built - specific tools to do the modifications that we are doing are only available on Linux-based OSes. The fastest way to get access to these tools is via WSL.

### How to install WSL

- Open Windows PowerShell as an Administrator
- Run `wsl --install`: this will install Ubuntu 20.04 LTS in WSL (Version 2) and all necessary components required to run as it is default (this is recommended)

Your PC may restart several times when downloading and installing required components.
After that - follow installation wizard instructions to proceed. If you have any questions, official documentation from Microsoft for WSL will help you.

- Check with `wsl --list --verbose` to be sure that you have a Linux Distro installed with WSL2 version. If for some reason you have receieved WSL1 kernel (or you have trouble running this command in general) - follow instructions in the section below to perform conversion.

[Microsoft Docs: Installing WSL](https://docs.microsoft.com/en-us/windows/wsl/install) 

[Microsoft Docs: Set up and best practices](https://docs.microsoft.com/en-us/windows/wsl/setup/environment)

### How to convert WSL1 to WSL2 (and manual installation)

If you have trouble installing WSL2 with `wsl --install` in general - follow this instruction from Microsoft.

[Microsoft Docs: Manual installation steps for older versions of WSL](https://docs.microsoft.com/en-us/windows/wsl/install-manual)

If you have already used WSL, have trouble installing with `wsl --install` or for some reason have received a WSL1 version installation, this section is for you.

Follow these steps:

- Download WSL2 kernel for manual installation. Use the Microsoft Docs link above (Manual Installation) and check Step 4 to receive the kernel package.
- Open Windows PowerShell as Administrator and run:
  - `wsl --shutdown` to stop all WSL related processes (if any are running).
- Install the kernel package from the step above.
- Return to Windows PowerShell and run:
  - `wsl --list --verbose` to get your installed distribution name. In case of Ubuntu, it most likely will look like `Ubuntu-20.04`.
  - `wsl --set-version <distribution name> 2`, replace <distribution name> with the one that you have.
  - Optional: if you would like to automatically install only WSL2 version builds in future. `wsl --set-default-version 2`. To be sure about the difference, check [Microsoft Docs: WSL - Compare versions](https://docs.microsoft.com/en-us/windows/wsl/compare-versions)

## Install unzip, lzip

For now, we are assuming that you have went with default installation (Ubuntu), terminal commands will be provided for Ubuntu. Commands provided for the most part will work for other Linux Distributions but there may be some that use other package managers. Check how to correctly install applications for your chosen distribution on the internet.

Run following in the **WSL Terminal** (If you are unsure what is WSL Terminal, refer to the video, Microsoft Docs, or search Ubuntu in your start menu to be sure):

**Attention!** For new users who have never used Linux Terminals - when you are being asked for your password (which you've set up when installed WSL) - it will **NOT** be displayed in the terminal as part of security measures. You should enter it blindly and then press enter. If password was entered incorrectly system will give you two more attempts, after which you will need to run the command again and try entering password again.

```
sudo apt update
sudo apt install unzip lzip
```
We have checked availability of updates and requested installation of two packages which are required for execution of scripts provided by this project. They may be already present at your installation, but it is better to check anyway.

## Prepare folder structure

For the sake of simplicity, create a folder in the root of C Drive, so you will have `C:\WSA\`. You may use other location if you would like, be sure to adjust commands below for new location.

**Attention!** The folder where you will place the files which we will be downloading is going to become an installation folder. **DO NOT** delete that folder!  
**Attention!** At the time of last update for this README, attempt to run scripts if they are located in path that contains spaces (like "Zulu Storage" in `D:\Zulu Storage\WSA`) will result in an error. Be sure to use paths with no spaces as long as fix have not been implemented.

Hint: You can also open any folder (even those that are located within Linux WSL Filesystem, by typing `explorer.exe .` (Yes, with the dot) in the WSL Terminal, to move files around.

## Download Windows Subsystem for Android™️ Installation Package

### Download
As we need to modify installation files,  we cannot download WSA from the Microsoft Store. To download it directly we will use this [service](https://store.rg-adguard.net/)

Use settings:
- ProductID: 9P3395VX91NR
- Ring: Fast

Click the checkmark, and locate file which has size of approx. ~1.3GB (usually at the bottom of the page) and has `.msixbundle` extension.

Click the filename to begin downloading (or copy the download link). You may be warned by your web-browser that "The file cannot be downloaded securely". Disregard the warning and force the download (use buttons like "Keep anyway" or similar, depending on your web-browser)

Save the file at our prepared directory `C:\WSA\`

### Extract
- Download 7zip or a similar archival program and use it to extract downloaded file. Do not mind that this file does not bear any archival extensions (like .zip).
- After extraction open `C:\WSA\MicrosoftCorporationII.WindowsSubsystemForAndroid_versionnumber_neutral___identifier\`. This folder will contain a lot of `.msix` files, use "Sort by size" to locate two biggest files. 
- Extract the one that is valid for your architecture, like this one `WsaPackage_1.8.32822.0_x64_Release-Nightly.msix`
- Open the extracted folder
- Locate and delete files `AppxBlockMap.xml`, `AppxSignature.p7x` and `[Content_Types].xml`
- Locate and delete `AppxMetadata` folder

Do not close this folder - we will return here to collect \*.img files. 

## Download "GApps" via OpenGApps Project

To install Play Store, we need to get it from somewhere. Use [OpenGApps](https://opengapps.org/).

Use settings:
- Platform: x86_64 if you are running Windows on a traditional laptop/PC, otherwise choose ARM64
- Android: 11.0
- Variant: Pico (at the time of writing this README, only minimal functionality with Pico variant have been confirmed working).

For the time being save the .zip file at `C:\WSA\gapps-zip-file-name.zip`. Do **not** extract it.

## Clone this repository and populate the directories

As we have used `C:\WSA`, you will be able to use Windows Explorer to move files around.

*Reminder: commands provided are for Ubuntu*

**Attention!** To be sure that you can access your Windows filesystem from inside of WSL, you can run `cd FolderName` to change to another directory and `ls` to list what files and folders you have there. Typically, Windows Filesystem is available by "/mnt/$DriveLetter/", so `/mnt/c/Users` will be your Windows `C:\Users`

```bash
cd /mnt/c/WSA
git clone https://github.com/WSA-Community/WSAGAScript
```
Wait for the command to finish running.

At the **Extract** step (in Download Windows Subsystem for Android™️ Installation Package) of this Guide we have got a folder that contains four \*.img files which are *product*, *system*, *system_ext* and *vendor*. Move those files into `C:\WSA\WSAGAScript\#IMAGES`

Then issuing `ls /mnt/c/WSA/WSAGAScript/\#IMAGES` via WSL terminal should give the list of the following files:

```
product.img  system_ext.img  system.img  vendor.img
```

We also have `C:\WSA\gapps-zip-file-name.zip`. Copy this .zip file into `C:\WSA\WSAGAScript\#GAPPS`. Do not **extract** it, just move the file.

Issuing `ls /mnt/c/WSA/WSAGAScript/\#GAPPS` via WSL terminal, you should get something similar to the following:

```
open_gapps-x86_64-11.0-pico-20220503.zip  output  product_output
```

## Final preparations

### Change architecture

If you are using this project on a device with ARM architecture (e.g., Qualcomm Snapdragon), please edit `VARIABLES.sh` and set the correct architecture. Hint is in the file.

### Set executable permissions for the scripts

You should still be in the same directory within the WSL Terminal, if not use `cd /mnt/c/WSA/WSAGAScript` to get back.
Set executable permissions for the scripts:

```bash
chmod +x *.sh
```

Verify that your scripts are executable by running `ls -l` and checking that you have `-rwxrwxrwx` at the start of lines that contain files: `VARIABLES.sh`, `apply.sh`, `extend_and_mount_images.sh`, `extract_gapps_pico.sh`, `unmount_images.sh`.

## Running the scripts

Make sure you're in the same directory as in the step before, the run:

```bash
./extract_gapps_pico.sh
sudo ./extend_and_mount_images.sh
sudo ./apply.sh
sudo ./unmount_images.sh
```

## Copy the edited images

After successful execution, you can now copy edited images from `C:\WSA\WSAGAScript\#IMAGES` back to `C:\WSA\MicrosoftCorporationII.WindowsSubsystemForAndroid_1.8.32822.0_neutral___8wekyb3d8bbwe\WsaPackage_1.8.32822.0_x64_Release-Nightly` (example, the folder from where you have taken the images).

## Registering the edited Windows Subsystem for Android™️ Installation Package

- Use Windows Search to find "Developer Settings", when PC Settings app opens, enable "Developer Mode" on that page.
- Uninstall any other installed versions of WSA (if you had any, uninstall exactly the main WSA app, all Android apps that have been added to Start Menu will be removed automatically)
- Open Windows PowerShell as Administrator and run `Add-AppxPackage -Register path-to-extracted-msix\AppxManifest.xml`

Where `path-to-extracted-msix`, use path from "Copy the edited images" section (right above) as example.

WSA will install with GApps, **make sure to sign in to Play Store and install "Android System WebView"** or most apps will crash without that component.

# Uninstallation procedure

- Locate Windows Subsystem for Android™️ in your Start Menu, right-click, uninstall. This will uninstall Android and all Android Apps will vanish from Start as they are just shortcuts wired in from the WSA. You don't need to uninstall all Android Apps one-by-one beforehand.
- Locate the directory where you have placed the files (in the example of this README it would be `C:\WSA`) - remove it.

Done.

# Gaining Root Access

You can get root access by replacing the kernel. (This step is no longer required to sign in GApps.)

## (ADB SHELL ROOT WITH su)

Copy the kernel file from this repo (in `misc` folder) and replace the kernel file inside the `Tools` folder of your extracted msix (make sure WSA is not running, use Stop button inside WSA Settings, and close settings).

Kernel files inside `misc` are named for their respective architectures, do not forget to rename the file you took to `kernel` before placing it back into `Tools`.

This will allow you to use `su` inside the `adb shell`.
Enter into the `adb shell` and run the following commands:

```bash
su
```

You are now root.

# Procedure to add files to WSA

It is possible to add files to WSA (Windows Sybsystem for Android) through WSL. As an example, we will install [busybox](https://busybox.net/) and *bash*.

First, turn off WSA:
- Open *Windows Sybsystem for Android Settings*
- Turn off Windows Sybsystem for Android (press *Turn off*)

Then open a WSL terminal:

```bash
cd /mnt/d/WSA/...MicrosoftCorporationII.WindowsSubsystemForAndroid_versionnumber_neutral___identifier...

# Temporarily extend the "system" filesystem to allow adding things
e2fsck -f system.img
sudo resize2fs system.img 1280M

# Mount "system" in read-write
sudo mount system.img /mnt/system
```

## Example to add busybox and bash

Check the most recent [binaries for x86_64-linux](https://busybox.net/downloads/binaries/); at the time of writing: https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/

```bash
cd /mnt/system/system
sudo mkdir xbin
cd xbin
sudo wget https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
sudo chmod 755 busybox
for i in `./busybox --list`; do sudo ln busybox "$i"; done

# We will use the debian bash executable
sudo mkdir temp
cd temp
sudo wget http://http.us.debian.org/debian/pool/main/b/bash/bash-static_5.1-2+b3_i386.deb
sudo dpkg-deb -R bash-static_5.1-2+b3_i386.deb tmp
sudo chmod 755 tmp/bin/bash-static
sudo cp tmp/bin/bash-static ..
cd ..
sudo rm -r temp

# Yet another bash executable...
sudo wget https://github.com/robxu9/bash-static/releases/download/5.1.016-1.2.3/bash-linux-x86_64
sudo chmod 755 bash-linux-x86_64

# Unmount system filesystem
cd
sudo umount /mnt/system

# Shrink the system filesystem to minimize its size as much as possible
e2fsck -f system.img
sudo resize2fs -M system.img
```

## Testing the installation

Start *Windows Sybsystem for Android* (e.g., open *Windows Sybsystem for Android Settings* and press the button close to *Files*).

Open a *CMD* with path to *adb*.

```cmd
adb connect 127.0.0.1:58526
adb shell
su
export PATH=$PATH:/system/xbin
type vi
```

# Kernel source

- [WSA-Community/WSA-Linux-Kernel](https://github.com/WSA-Community/WSA-Linux-Kernel)

# Currently known issues

- [Issues](https://github.com/WSA-Community/WSAGAScript/issues)
