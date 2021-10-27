#!/bin/bash

. ./VARIABLES.sh

rm -rf $GAppsOutputFolder
rm -rf $GAppsTmpFolder
rm -rf $GAppsExtractFolder

mkdir -p $GAppsOutputFolder

echo "Unzipping OpenGApps"
find "$GAppsRoot/"*.zip -exec unzip -p {} {Core,GApps}/'*.lz' \; | tar --lzip -C $GAppsOutputFolder -xvf - -i --strip-components=2 --exclude='setupwizardtablet-x86_64'

echo "Post merge operation"
cp -ra $GAppsOutputFolder/product/* $GAppsRoot/product_output/

echo "!! GApps folder ready !!"
