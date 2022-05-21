#!/bin/bash

. ./VARIABLES.sh

if [[ ! /proc/self/mounts -ef /etc/mtab ]]; then
	printf "/etc/mtab doesn't exist or is invalid\n"
	printf 'creating valid /etc/mtab\n'
	ln -sf /proc/self/mounts /etc/mtab
fi

echo "chk product.img"
e2fsck -f $ImagesRoot/product.img

echo "Resizing product.img"
resize2fs $ImagesRoot/product.img 1024M

echo "chk system.img"
e2fsck -f $ImagesRoot/system.img

echo "Resizing system.img"
resize2fs $ImagesRoot/system.img 1280M

echo "chk system_ext.img"
e2fsck -f $ImagesRoot/system_ext.img

echo "Resizing system_ext.img"
resize2fs $ImagesRoot/system_ext.img 150M

echo "chk vendor.img"
e2fsck -f $ImagesRoot/vendor.img

echo "Resizing vendor.img"
resize2fs $ImagesRoot/vendor.img 400M

echo "Creating mount point for product"
mkdir -p $MountPointProduct

echo "Creating mount point for system_ext" 
mkdir -p $MountPointSystemExt

echo "Creating mount point for system"
mkdir -p $MountPointSystem

echo "Creating mount point for vendor"
mkdir -p $MountPointVendor

echo "Mounting product"
mount $ImagesRoot/product.img $MountPointProduct

echo "Mounting system_ext"
mount $ImagesRoot/system_ext.img $MountPointSystemExt

echo "Mounting system"
mount $ImagesRoot/system.img $MountPointSystem

echo "Mounting vendor"
mount $ImagesRoot/vendor.img $MountPointVendor

echo "!! Images mounted !!"
