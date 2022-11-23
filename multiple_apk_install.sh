#!/bin/sh
 
RELATIVE_APK_PATH="$1"
PACKAGE_NAME="$2"
for device in `adb devices -l | awk '{print $1}'`; do
 if [ ! "$device" = "" ] && [ ! "$device" = "List" ]
  then
    adb -s $device uninstall $PACKAGE_NAME
    adb -s $device install $RELATIVE_APK_PATH
  fi
done