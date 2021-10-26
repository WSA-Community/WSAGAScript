#!/bin/bash
function loading_spinner() {
    local pid=$!
    local spin='-\|/'
    local i=0
    while kill -0 $pid 2>/dev/null
    do
    i=$(( (i+1) %4 ))
    printf "\r${spin:$i:1}"
    sleep .1
    done
}
function convertPath() {
    #convert path to WSL(linux) Format and add (/mnt)
    #remove ("); lowercase disk letter; remove (:); change (\) to (/); add ("/mnt) to first line; add (") to last line
    #input example ("C:/Windows") output ("/mnt/c/Windows")
    echo $(sed 's/"//g; s/^\(.\{1\}\)/\L&\E/; s/://; s/\\/\//g;  s/^/\/mnt\//; s/$//' <<<"$1")
}
function check_unzip_lzip() {
    if [ ! command -v unzip &> /dev/null || 
    ! command -v lzip &> /dev/null || 
    ! command -v pv &> /dev/null ]; then
        echo "unzip and/or lzip could not be found"
        echo "Installing"
        sudo apt install unzip lzip -y
    fi
}
function createUnpackDir() {
    if [ ! -d "$UNPACK_DIR" ]; then
        echo "Creating $UNPACK_DIR"
        mkdir "$UNPACK_DIR"
    fi
}

check_unzip_lzip
#get all variable from VARIABLES.sh
. ./VARIABLES.sh

#ask user to input the path to the MsixBundle and OpenGapps.zip
clear
read -rp "Enter MsixBundle PATH (drag here or copy as path): " MsixBundlePath
read -rp "Enter OpenGapps.zip PATH (drag here or copy as path): " OpenGappsPath
clear

echo "!! You got $Architecture CPU !!"
echo "----------------"

# start
UNPACK_DIR=$Root/msix_unpack
createUnpackDir

# set msixbundle var and opengapps var
MsixBundlePath=$(convertPath "$MsixBundlePath")
MsixBundleName=`basename "$MsixBundlePath"`
OpenGappsPath=$(convertPath "$OpenGappsPath")
OpenGappsName=`basename "$OpenGappsPath"`

echo "Extracting ${Architecture} WsaPackage from $MsixBundleName"
unzip -joq "$MsixBundlePath" "WsaPackage_*_${Architecture}_*" -d "$UNPACK_DIR" & loading_spinner

# set extracted WsaPackage var
WsaPackagePath=$(find "$UNPACK_DIR"/WsaPackage_*_${Architecture}_*)
WsaPackageName=`basename "$WsaPackagePath"`
WsaPackageUnpackDir=$UNPACK_DIR/${WsaPackageName%.*}
WsaPackageExclude=".AppxMetadata .[Content_Types].xml .AppxBlockMap.xml .AppxSignature.p7x"

echo "Extracting $WsaPackageName"
unzip -oq "$WsaPackagePath" -d "$WsaPackageUnpackDir" & loading_spinner

echo "Remove $MsixBundleName"
rm -rf "$UNPACK_DIR/$WsaPackageName"

echo "Remove Metadata and other in $WsaPackageName"
rm -rf "$WsaPackageUnpackDir/AppxMetadata"
rm -rf "$WsaPackageUnpackDir/[Content_Types].xml"
rm -rf "$WsaPackageUnpackDir/AppxBlockMap.xml"
rm -rf "$WsaPackageUnpackDir/AppxSignature.p7x"

echo "Copy $OpenGappsName"
cp "$OpenGappsPath" "$GAppsRoot"

echo "Moving .img file to $ImagesRoot"
mv "$WsaPackageUnpackDir"/*.img "$ImagesRoot"

# run script
echo "----------------"
. ./extract_gapps_pico.sh
echo "----------------"
. ./extend_and_mount_images.sh
echo "----------------"
. ./apply.sh
echo "----------------"
. ./unmount_images.sh
echo "----------------"

echo "Moving .img file Back to $WsaPackageUnpackDir"
mv "$ImagesRoot"/*img "$WsaPackageUnpackDir"
# if all done, the terminal should back to cmd
