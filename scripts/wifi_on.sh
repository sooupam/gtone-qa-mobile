#!/usr/bin/env bash
## wifi_on.sh — religa wifi + data do device/emulador via adb shell
set -e
adb shell svc wifi enable
adb shell svc data enable
sleep 3
echo "[wifi] network enabled"
