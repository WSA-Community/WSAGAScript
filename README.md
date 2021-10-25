# IT'S **WIP**

## This readme is being updated frequently. As I am aware that it might not be completely clear right now, I am going to resolve it ASAP

## As a temporary measure, I have also made a tutorial and hosted that video on YouTube

<p align="center">

[![How to install Google Apps (Play Store) on WSA (Windows Subsystem Android)](http://img.youtube.com/vi/rIt00xDp0tM/0.jpg)](http://www.youtube.com/watch?v=rIt00xDp0tM 'How to install Google Apps (Play Store) on WSA (Windows Subsystem Android)')

</p>

### THIS IS FOR TESTING

### Download msixbundle (~1.2GB)

Use this [link](https://store.rg-adguard.net/) to download the msixbundle with the settings ProductId: 9P3395VX91NR, Ring: SLOW

### Install WSL2

Ubuntu is used in this guide, but any other distro will work for this just fine.

(We are assuming that you are using the exact terminal, and you are also continuing this from where the last command has been left off)

### Install unzip lzip

For Ubuntu

```bash
sudo apt-get update
sudo apt-get install unzip lzip
```

### Download gapps

Select Platform: x86_64 if Windows architecture is x64, otherwise choose ARM64, Android: 11 and Variant: Pico on [OpenGApps](https://opengapps.org/)

### Extract msixbundle

Download 7zip or a similar archival program and open the recently downloaded msixbundle. Find the msix file inside the msixbundle relating to your architecture and extract that to a folder.
Delete the files appxblockmap, appxsignature and \[content_types\] along with the folder appxmetadata.

### Clone this repo and populate the directories

For Ubuntu

```bash
git clone https://github.com/ADeltaX/WSAGAScript
cd WSAGAScript/\#IMAGES
mv /mnt/path-to-extracted-msix/*.img .
cd ../\#GAPPS
cp /mnt/path-to-downloaded-gapps/*.zip .
```

paths in wsl follow the same as windows after /mnt/ its just the drive letter then folder structure as normal. For example /mnt/c/users would be the c:\users folder

### Edit scripts

Set executable permission for the scripts

```bash
cd ..
sudo chmod +x extract_gapps_pico.sh
sudo chmod +x extend_and_mount_images.sh
sudo chmod +x apply.sh
sudo chmod +x unmount_images.sh
```

Change the root directory in VARIABLES.sh

```bash
pwd
```

(take note of the output)

```bash
nano VARIABLES.sh
```

replace the root variable with the output of pwd up until and including the WSAGAScript folder

### Run the scripts

```bash
sudo ./extract_gapps_pico.sh
sudo ./extend_and_mount_images.sh
sudo ./apply.sh
sudo ./unmount_images.sh
```

### Copy the edited images

```bash
cd \#IMAGES
cp *.img /mnt/path-to-extracted-msix/
```

### Register the edited WSA

- Enable developer mode in windows settings.
- Uninstall any other installed versions of WSA
- Open powershell as admin and run `Add-AppxPackage -Register path-to-extracted-msix\AppxManifest.xml`

WSA will install with gapps

## Root access

You can get root access by replacing the kernel. (This step is no longer required to sign in gapps)

### (ADB SHELL ROOT WITH su)

Copy the kernel file from this repo and replace the kernel file inside the `Tools` folder of your extracted msix (make sure WSA is not running)

This will allow you to use use `su` inside the `adb shell`.

Enter into the `adb shell` and run the following commands

```bash
su
setenforce 0
```

You can sign in successfully from now on.
