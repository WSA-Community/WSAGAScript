#!/bin/bash

. ./VARIABLES.sh

TARGET_PRODUCT="redfin"
TARGET_DEVICE="redfin"
PRODUCT_BRAND="google"
PRODUCT_MODEL="Pixel 5"
PRODUCT_MANUFACTURER="Google"

# Remove a property from a file, 
# then append the property with provided value
# if the property is present before
remove_append() {
    if grep -q -e "^$1=" $3; then
        sed -i "/^$1=/ d" $3
        echo "$1=$2" >> $3
    fi
}

# Get the value of a property from a file
get_prop() {
    grep "^$1=" $2 | cut -d'=' -f2
}

# Fix properties
fix_prop() {
    COMMENT="# extra prop added by WSAGASCRIPT"

    echo "-> fixing $1"
    echo "$COMMENT" >> $2

    remove_append "ro.product.$1.brand" "$PRODUCT_BRAND" $2
    remove_append "ro.product.$1.device" "$TARGET_DEVICE" $2
    remove_append "ro.product.$1.manufacturer" "$PRODUCT_MANUFACTURER" $2
    remove_append "ro.product.$1.model" "$PRODUCT_MODEL" $2
    remove_append "ro.product.$1.name" "$TARGET_PRODUCT" $2
    remove_append "ro.build.product" "$TARGET_DEVICE" $2

    BUILD_NUMBER=$(get_prop "ro.$1.build.version.incremental" $2)
    BUILD_ID=$(get_prop "ro.$1.build.id" $2)
    BUILD_TYPE=$(get_prop "ro.$1.build.type" $2)
    BUILD_TAGS=$(get_prop "ro.$1.build.tags" $2)
    PLATFORM_VERSION=$(get_prop "ro.$1.build.version.release" $2)
    TARGET_BUILD_VARIANT=$(get_prop "ro.$1.build.type" $2)
    BUILD_VERSION_TAGS=$(get_prop "ro.$1.build.tags" $2)

    BUILD_FLAVOR="$TARGET_PRODUCT-$TARGET_BUILD_VARIANT"
    BUILD_DESC="$BUILD_FLAVOR $PLATFORM_VERSION $BUILD_ID $BUILD_NUMBER $BUILD_VERSION_TAGS"
    BUILD_FINGERPRINT="$PRODUCT_BRAND/$TARGET_PRODUCT/$TARGET_DEVICE:$PLATFORM_VERSION/$BUILD_ID/$BUILD_NUMBER:$TARGET_BUILD_VARIANT/$BUILD_VERSION_TAGS"

    remove_append "ro.build.flavor" "$BUILD_FLAVOR" $2
    remove_append "ro.build.description" "$BUILD_DESC" $2
    remove_append "ro.$1.build.fingerprint" "$BUILD_FINGERPRINT" $2
}

echo "Modifing build.prop for each image"
fix_prop system $MountPointSystem/system/build.prop
fix_prop vendor $MountPointVendor/build.prop
fix_prop product $MountPointProduct/build.prop
fix_prop system_ext $MountPointSystemExt/build.prop

printf 'removing duplicate apps from system\n'
rm -Rf $InstallDir/apex/com.android.extservices/
rm -Rf $InstallDir/app/DocumentsUI/
rm -Rf $InstallDir/app/ExtShared/
rm -Rf $InstallDir/priv-app/PackageInstaller/
rm -Rf $InstallDir/priv-app/SoundPicker/
rm -Rf $MountPointProduct/app/Camera2/
rm -Rf $MountPointProduct/app/Gallery2/
rm -Rf $MountPointProduct/app/Music/
rm -Rf $MountPointProduct/priv-app/Contacts/

echo "Copying GApps files to system..."
cp -f -a $GAppsOutputFolder/app/* $InstallDir/app
cp -f -a $GAppsOutputFolder/etc/* $InstallDir/etc
cp -f -a $GAppsOutputFolder/priv-app/* $InstallDir/priv-app
cp -f -a $GAppsOutputFolder/framework/* $InstallDir/framework
cp -fra  $GAppsRoot/product_output/* $MountPointProduct/

echo "Applying root file ownership"
find $InstallDir/app -exec chown root:root {} &>/dev/null \;
find $InstallDir/etc -exec chown root:root {} &>/dev/null \;
find $InstallDir/priv-app -exec chown root:root {} &>/dev/null \;
find $InstallDir/framework -exec chown root:root {} &>/dev/null \;
find $InstallDir/lib -exec chown root:root {} &>/dev/null \;
find $InstallDir/lib64 -exec chown root:root {} &>/dev/null \;
find $MountPointProduct/app -exec chown root:root {} &>/dev/null \;
find $MountPointProduct/etc -exec chown root:root {} &>/dev/null \;
find $MountPointProduct/overlay -exec chown root:root {} &>/dev/null \;
find $MountPointProduct/priv-app -exec chown root:root {} &>/dev/null \;

echo "Setting directory permissions"
find $InstallDir/app -type d -exec chmod 755 {} \;
find $InstallDir/etc -type d -exec chmod 755 {} \;
find $InstallDir/priv-app -type d -exec chmod 755 {} \;
find $InstallDir/framework -type d -exec chmod 755 {} \;
find $InstallDir/lib -type d -exec chmod 755 {} \;
find $InstallDir/lib64 -type d -exec chmod 755 {} \;
find $MountPointProduct/app  -type d -exec chmod 755 {} \;
find $MountPointProduct/etc  -type d -exec chmod 755 {} \;
find $MountPointProduct/overlay -type d -exec chmod 755 {} \;
find $MountPointProduct/priv-app -type d -exec chmod 755 {} \;

echo "Setting file permissions"
find $InstallDir/app -type f -exec chmod 644 {} \;
find $InstallDir/priv-app -type f -exec chmod 644 {} \;
find $InstallDir/framework -type f -exec chmod 644 {} \;
find $InstallDir/lib -type f -exec chmod 644 {} \;
find $InstallDir/lib64 -type f -exec chmod 644 {} \;
find $InstallDir/etc/permissions -type f -exec chmod 644 {} \;
find $InstallDir/etc/default-permissions -type f -exec chmod 644 {} \;
find $InstallDir/etc/preferred-apps -type f -exec chmod 644 {} \;
find $InstallDir/etc/sysconfig -type f -exec chmod 644 {} \;
find $MountPointProduct/app -type f -exec chmod 644 {} \;
find $MountPointProduct/etc -type f -exec chmod 644 {} \;
find $MountPointProduct/overlay -type f -exec chmod 644 {} \;
find $MountPointProduct/priv-app -type f -exec chmod 644 {} \;

echo "Applying SELinux security contexts to directories"
find $InstallDir/app -type d -exec chcon --reference=$InstallDir/app {} \;
find $InstallDir/priv-app -type d -exec chcon --reference=$InstallDir/priv-app {} \;
find $InstallDir/framework -type d -exec chcon --reference=$InstallDir/framework {} \;
find $InstallDir/lib -type d -exec chcon --reference=$InstallDir/lib {} \;
find $InstallDir/lib64 -type d -exec chcon --reference=$InstallDir/lib64 {} \;
find $InstallDir/etc/permissions -type d -exec chcon --reference=$InstallDir/etc/permissions {} \;
find $InstallDir/etc/default-permissions -type d -exec chcon --reference=$InstallDir/etc/permissions {} \;
find $InstallDir/etc/preferred-apps -type d -exec chcon --reference=$InstallDir/etc/permissions {} \;
find $InstallDir/etc/sysconfig -type d -exec chcon --reference=$InstallDir/etc/sysconfig {} \;
find $MountPointProduct/app -type d -exec chcon --reference=$MountPointProduct/app {} \;
find $MountPointProduct/etc/permissions  -type d -exec chcon --reference=$MountPointProduct/etc/permissions {} \;
find $MountPointProduct/overlay -type d -exec chcon --reference=$MountPointVendor/overlay {} \;
find $MountPointProduct/priv-app  -type d -exec chcon --reference=$MountPointProduct/priv-app {} \;

echo "Applying SELinux security contexts to files"
find $InstallDir/framework -type f -exec chcon --reference=$InstallDir/framework/ext.jar {} \;
find $InstallDir/app -type f -exec chcon --reference=$InstallDir/app/CertInstaller/CertInstaller.apk {} \;
find $InstallDir/priv-app -type f -exec chcon --reference=$InstallDir/priv-app/Shell/Shell.apk {} \;
find $InstallDir/lib -type f -exec chcon --reference=$InstallDir/lib/libcap.so {} \;
find $InstallDir/lib64 -type f -exec chcon --reference=$InstallDir/lib64/libcap.so {} \;
find $InstallDir/etc/permissions -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $InstallDir/etc/default-permissions -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $InstallDir/etc/preferred-apps -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $InstallDir/etc/sysconfig -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $MountPointProduct/app  -type f -exec chcon --reference=$MountPointProduct/app/ModuleMetadata/ModuleMetadata.apk {} \;
find $MountPointProduct/etc/permissions -type f -exec chcon --reference=$MountPointProduct/etc/permissions/privapp-permissions-venezia.xml {} \;
find $MountPointProduct/overlay -type f -exec chcon --reference=$MountPointVendor/overlay/framework-res__auto_generated_rro_vendor.apk {} \;
find $MountPointProduct/priv-app -type f -exec chcon --reference=$MountPointProduct/priv-app/amazon-adm-release/amazon-adm-release.apk {} \;

echo "Applying SELinux security contexts to props"
chcon --reference=$MountPointSystem/system/etc $MountPointSystem/system/build.prop
chcon --reference=$MountPointSystemExt/etc $MountPointSystemExt/build.prop
chcon --reference=$MountPointProduct/etc $MountPointProduct/build.prop
chcon --reference=$MountPointVendor/etc $MountPointVendor/build.prop

echo "Applying SELinux policy"
SELinuxPolicy="(allow gmscore_app self (vsock_socket (read write create connect)))"
SELinuxPolicy="${SELinuxPolicy}\n(allow gmscore_app device_config_runtime_native_boot_prop (file (read)))"
SELinuxPolicy="${SELinuxPolicy}\n(allow gmscore_app system_server_tmpfs (dir (search)))"
SELinuxPolicy="${SELinuxPolicy}\n(allow gmscore_app system_server_tmpfs (file (open)))"
# Sed will remove the SELinux policy for plat_sepolicy.cil, preserve policy using cp
cp $InstallDir/etc/selinux/plat_sepolicy.cil $InstallDir/etc/selinux/plat_sepolicy_new.cil
sed -i "s/(allow gmscore_app self (process (ptrace)))/(allow gmscore_app self (process (ptrace)))\n${SELinuxPolicy}/g" $InstallDir/etc/selinux/plat_sepolicy_new.cil
cp $InstallDir/etc/selinux/plat_sepolicy_new.cil $InstallDir/etc/selinux/plat_sepolicy.cil
rm $InstallDir/etc/selinux/plat_sepolicy_new.cil

# Prevent android from using cached SELinux policy
echo '0000000000000000000000000000000000000000000000000000000000000000' > $InstallDir/etc/selinux/plat_sepolicy_and_mapping.sha256

echo "!! Apply completed !!"
