#!/usr/bin/env bash
## send_test_push.sh — dispara notif local via adb (modo dev/test)
## Em CI real, usar Expo push API ou FCM dry-run.
set -e
APP_ID="${APP_ID:-net.globalthings.gtone}"
TITLE="${TITLE:-Notificacao teste}"
BODY="${BODY:-E2E test notification}"
adb shell am broadcast -a "$APP_ID.TEST_PUSH" --es title "$TITLE" --es body "$BODY" || true
sleep 2
echo "[push] '$TITLE' broadcast sent"
