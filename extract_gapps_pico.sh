#!/bin/bash

# added quote mark ('"') for every variable so it wont be a problem if the path has space/whitespace
. ./VARIABLES.sh

rm -rf "$GAppsOutputFolder"
rm -rf "$GAppsTmpFolder"
rm -rf "$GAppsExtractFolder"

mkdir -p "$GAppsOutputFolder"
mkdir -p "$GAppsTmpFolder"
mkdir -p "$GAppsExtractFolder"

echo "Unzipping OpenGApps"
for file in "$GAppsRoot"/*.zip; do unzip -q "$file" -d "$GAppsExtractFolder"; done

echo "Extracting Core Google Apps"
for f in "$GAppsExtractFolder"/Core/*.lz; do tar --lzip -xvf "$f" -C "$GAppsTmpFolder" &>/dev/null; done

echo "Extracting Google Apps"
for f in "$GAppsExtractFolder"/GApps/*.lz; do tar --lzip -xvf "$f" -C "$GAppsTmpFolder" &>/dev/null; done

echo "Deleting duplicates & conflicting apps"
rm -rf "$GAppsTmpFolder"/setupwizardtablet-x86_64 # We already have setupwizard "default"
rm -rf "$GAppsTmpFolder"/packageinstallergoogle-all # The image already has a package installer, and we are not allowed to have two.

echo "Merging folders"
for D in "$GAppsTmpFolder"/*; do [ -d "${D}" ] && cp -r "${D}"/* "$GAppsOutputFolder"; done

echo "Merging subfolders"
for D in "$GAppsOutputFolder"/*; do [ -d "${D}" ] && cp -r "${D}"/* "$GAppsOutputFolder" && rm -rf ${D}; done

echo "Post merge operation"
cp -r "$GAppsOutputFolder"/product/* "$GAppsOutputFolder" && rm -rf "$GAppsOutputFolder"/product;

echo "Deleting temporary files"
rm -rf "$GAppsTmpFolder"
rm -rf "$GAppsExtractFolder"

echo "!! GApps folder ready !!"
