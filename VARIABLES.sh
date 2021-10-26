#!/bin/bash

# Modify your variables here to corretly reference your directory and subdir
Root="$(pwd)"

# Your Windows architecture, x64 or arm64
Architecture="x64"

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

