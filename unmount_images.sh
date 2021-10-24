#!/bin/bash

. ./VARIABLES

echo "Unmounting product.img"
umount $MountPointSystem/product

echo "Unmounting system_ext.img"
umount $MountPointSystem/system_ext

echo "Unmounting vendor.img"
umount $MountPointSystem/vendor

echo "Unmounting system.img"
umount $MountPointSystem

echo "!! Unmounting completed !!"