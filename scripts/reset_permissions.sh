#!/usr/bin/env bash
## reset_permissions.sh — limpa app data + permissoes via adb
set -e
APP_ID="${APP_ID:-net.globalthings.gtone}"
adb shell pm clear "$APP_ID"
echo "[reset_permissions] $APP_ID data + permissions cleared"
