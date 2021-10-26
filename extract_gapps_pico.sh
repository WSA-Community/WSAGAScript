#!/bin/bash

. ./VARIABLES.sh

rm -rf $GAppsOutputFolder
rm -rf $GAppsTmpFolder
rm -rf $GAppsExtractFolder

mkdir -p $GAppsOutputFolder
mkdir -p $GAppsTmpFolder
mkdir -p $GAppsExtractFolder

echo "Unzipping OpenGApps"
for file in "$GAppsRoot/"*.zip; do unzip -q "$file" -d $GAppsExtractFolder; done

echo "Extracting Core Google Apps"
for f in "$GAppsExtractFolder/Core/"*.lz; do tar --lzip -xvf "$f" -C $GAppsTmpFolder &>/dev/null; done

echo "Extracting Google Apps"
for f in "$GAppsExtractFolder/GApps/"*.lz; do tar --lzip -xvf "$f" -C $GAppsTmpFolder &>/dev/null; done

echo "Deleting duplicates & conflicting apps"
rm -rf "$GAppsTmpFolder/setupwizardtablet-x86_64" # We already have setupwizard "default"

echo "Merging folders"
for D in $GAppsTmpFolder/*; do [ -d "${D}" ] && cp -r ${D}/* $GAppsOutputFolder; done

echo "Merging subfolders"
for D in $GAppsOutputFolder/*; do [ -d "${D}" ] && cp -r ${D}/* $GAppsOutputFolder && rm -rf ${D}; done

echo "Post merge operation"
mv -i $GAppsOutputFolder/product/ $GAppsRoot/product_output/

echo "Deleting temporary files"
rm -rf $GAppsTmpFolder
rm -rf $GAppsExtractFolder

echo "!! GApps folder ready !!"
