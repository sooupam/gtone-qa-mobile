#!/usr/bin/env bash
## wifi_off.sh — desliga wifi + data do device/emulador via adb shell
set -e
adb shell svc wifi disable
adb shell svc data disable
sleep 1
echo "[wifi] network disabled"
