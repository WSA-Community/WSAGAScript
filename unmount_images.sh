#!/bin/bash

. ./VARIABLES.sh

echo "Unmounting product.img"
umount $MountPointProduct

echo "Unmounting system_ext.img"
umount $MountPointSystemExt

echo "Unmounting system.img"
umount $MountPointSystem

echo "Unmounting vendor.img"
umount $MountPointVendor

echo "!! Unmounting completed !!"