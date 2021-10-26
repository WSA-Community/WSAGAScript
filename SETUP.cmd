@echo off

rem get registry key for windows developer mode
set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
set VALUE_NAME=AllowDevelopmentWithoutDevLicense
FOR /F "tokens=2* skip=2" %%a in ('reg query "%KEY_NAME%" /v "%VALUE_NAME%"') do set ValueValue=%%b
if %ValueValue% neq 1 (
    echo Please Enable Windows Developer Mode in Settings
    timeout 2 >nul
    echo After that, press enter to continue
    timeout 1 >nul
    echo Opening Settings
    timeout 4 >nul
    start ms-settings:developers
    pause
)
rem start install.sh
set current_dir=%~dp0
pushd %current_dir%
if exist %current_dir%install.sh (
    wsl sudo ./install.sh
) else (
    rem for some reason this else is showing even the install.sh is exist
    echo install.sh.sh not found
    timeout 3 >nul
)
rem get uac confirm from sudo.vbs and then install appx-package
for /d %%a in ("%current_dir%msix_unpack\*") do set manifest=%%~fa%\AppxManifest.xml
"%current_dir%sudo.vbs" powershell Add-AppxPackage -Register '%manifest%'
pause