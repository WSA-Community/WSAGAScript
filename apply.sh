#!/bin/bash

./VARIABLES.sh

echo "Copying build.prop for each image"
cp "$MiscRoot/prop/build_system_ext.prop" /mnt/system_ext/build.prop
cp "$MiscRoot/prop/build_system.prop" /mnt/system/build.prop
cp "$MiscRoot/prop/build_system.prop" /mnt/system/system/build.prop
cp "$MiscRoot/prop/build_product.prop" /mnt/product/build.prop
cp "$MiscRoot/prop/build_vendor.prop" /mnt/vendor/build.prop
cp "$MiscRoot/prop/build_vendor_odm.prop" /mnt/vendor/odm/etc/vendor.prop

echo "Copying GApps files to system..."
cp -f -a $GAppsOutputFolder/app/* $InstallDir/app
cp -f -a $GAppsOutputFolder/etc/* $InstallDir/etc
cp -f -a $GAppsOutputFolder/overlay/* $InstallDir/overlay
cp -f -a $GAppsOutputFolder/priv-app/* $InstallDir/priv-app
cp -f -a $GAppsOutputFolder/framework/* $InstallDir/framework

echo "Applying root file ownership"
find $InstallDir/app -exec chown root:root {} \;
find $InstallDir/etc -exec chown root:root {} \;
find $InstallDir/overlay -exec chown root:root {} \;
find $InstallDir/priv-app -exec chown root:root {} \;
find $InstallDir/framework -exec chown root:root {} \;
find $InstallDir/lib -exec chown root:root {} \;
find $InstallDir/lib64 -exec chown root:root {} \;

echo "Setting directory permissions"
find $InstallDir/app -type d -exec chmod 755 {} \;
find $InstallDir/etc -type d -exec chmod 755 {} \;
find $InstallDir/overlay -type d -exec chmod 755 {} \;
find $InstallDir/priv-app -type d -exec chmod 755 {} \;
find $InstallDir/framework -type d -exec chmod 755 {} \;
find $InstallDir/lib -type d -exec chmod 755 {} \;
find $InstallDir/lib64 -type d -exec chmod 755 {} \;

echo "Setting file permissions"
find $InstallDir/app -type f -exec chmod 644 {} \;
find $InstallDir/overlay -type f -exec chmod 644 {} \;
find $InstallDir/priv-app -type f -exec chmod 644 {} \;
find $InstallDir/framework -type f -exec chmod 644 {} \;
find $InstallDir/lib -type f -exec chmod 644 {} \;
find $InstallDir/lib64 -type f -exec chmod 644 {} \;
find $InstallDir/etc/permissions -type f -exec chmod 644 {} \;
find $InstallDir/etc/default-permissions -type f -exec chmod 644 {} \;
find $InstallDir/etc/preferred-apps -type f -exec chmod 644 {} \;
find $InstallDir/etc/sysconfig -type f -exec chmod 644 {} \;

echo "Applying SELinux security contexts to directories"
find $InstallDir/app -type d -exec chcon --reference=$InstallDir/app {} \;
find $InstallDir/overlay -type d -exec chcon --reference=$InstallDir/overlay {} \;
find $InstallDir/priv-app -type d -exec chcon --reference=$InstallDir/priv-app {} \;
find $InstallDir/framework -type d -exec chcon --reference=$InstallDir/framework {} \;
find $InstallDir/lib -type d -exec chcon --reference=$InstallDir/lib {} \;
find $InstallDir/lib64 -type d -exec chcon --reference=$InstallDir/lib64 {} \;
find $InstallDir/etc/permissions -type d -exec chcon --reference=$InstallDir/etc/permissions {} \;
find $InstallDir/etc/default-permissions -type d -exec chcon --reference=$InstallDir/etc/permissions {} \;
find $InstallDir/etc/preferred-apps -type d -exec chcon --reference=$InstallDir/etc/permissions {} \;
find $InstallDir/etc/sysconfig -type d -exec chcon --reference=$InstallDir/etc/sysconfig {} \;

echo "Applying SELinux security contexts to files"
find $InstallDir/framework -type f -exec chcon --reference=$InstallDir/framework/ext.jar {} \;
find $InstallDir/overlay -type f -exec chcon --reference=$InstallDir/app/CertInstaller/CertInstaller.apk {} \;
find $InstallDir/app -type f -exec chcon --reference=$InstallDir/app/CertInstaller/CertInstaller.apk {} \;
find $InstallDir/priv-app -type f -exec chcon --reference=$InstallDir/priv-app/Shell/Shell.apk {} \;
find $InstallDir/lib -type f -exec chcon --reference=$InstallDir/lib/libcap.so {} \;
find $InstallDir/lib64 -type f -exec chcon --reference=$InstallDir/lib64/libcap.so {} \;
find $InstallDir/etc/permissions -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $InstallDir/etc/default-permissions -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $InstallDir/etc/preferred-apps -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $InstallDir/etc/sysconfig -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;

echo "!! Apply completed !!"