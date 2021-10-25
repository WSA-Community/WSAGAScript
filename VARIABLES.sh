#!/bin/bash

# Modify your variables here to corretly reference your directory and subdir
# get current dir of this script
Root="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Your Windows architecture, x64 or arm64
# get architecture based on wsl architecture 
# its always same as windows afaik
Architecture=$(uname -m)
if [ $Architecture == 'x86_64' ]; then
    Architecture="x64"
elif [ $Architecture == 'arm64' || 
$Architecture == 'aarch64' ]; then
    Architecture="ARM64"
else 
    echo "is your cpu 64 or arm64 ??"
    exit
fi

MiscRoot="$Root/misc"
PropRoot="$MiscRoot/prop/$Architecture"

GAppsRoot="$Root/#GAPPS"
GAppsOutputFolder="$GAppsRoot/output"
GAppsExtractFolder="$GAppsRoot/extract"
GAppsTmpFolder="$GAppsRoot/tmp"

ImagesRoot="$Root/#IMAGES"
MountPointProduct="/mnt/product"
MountPointSystemExt="/mnt/system_ext"
MountPointSystem="/mnt/system"
MountPointVendor="/mnt/vendor"

InstallPartition="/mnt/system"
InstallDir="$InstallPartition/system"