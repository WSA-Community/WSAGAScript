#!/bin/bash

# added quote mark ('"') for every variable so it wont conflict when path has space/whitespace
. ./VARIABLES.sh

echo "Unmounting product.img"
umount "$MountPointProduct"

echo "Unmounting system_ext.img"
umount "$MountPointSystemExt"

echo "Unmounting system.img"
umount "$MountPointSystem"

echo "Unmounting vendor.img"
umount "$MountPointVendor"

echo "!! Unmounting completed !!"