#!/usr/bin/env bash
## setup-emulator.sh — boota Pixel_6 (API 31) e espera o boot completar.
## Evita Medium_Phone_API_36.1 (bug DEADLINE_EXCEEDED no Gboard).

set -e

AVD_NAME="${AVD_NAME:-Pixel_6}"
EMULATOR_BIN="${ANDROID_HOME:-$HOME/Library/Android/sdk}/emulator/emulator"
ADB_BIN="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"

echo "[emulator] Listando AVDs disponíveis:"
"$EMULATOR_BIN" -list-avds

if ! "$EMULATOR_BIN" -list-avds | grep -q "^$AVD_NAME$"; then
  echo "[emulator] ERRO: AVD '$AVD_NAME' não existe."
  echo "[emulator] Criar via Android Studio > Device Manager (Pixel 6, API 31)."
  exit 1
fi

## Se já tem device rodando, pula boot
if "$ADB_BIN" devices | grep -q "emulator-.*device$"; then
  echo "[emulator] Emulador já está rodando, pulando boot."
else
  echo "[emulator] Bootando $AVD_NAME (headless)..."
  "$EMULATOR_BIN" -avd "$AVD_NAME" \
    -no-snapshot-save -no-boot-anim -gpu auto \
    -no-window &
  disown
fi

echo "[emulator] Aguardando boot completar..."
"$ADB_BIN" wait-for-device
until [ "$("$ADB_BIN" shell getprop sys.boot_completed | tr -d '\r')" = "1" ]; do
  sleep 2
done

## Wake screen
"$ADB_BIN" shell input keyevent 82 || true

echo "[emulator] Boot completo."

## Port forwarding
"$ADB_BIN" reverse tcp:8081 tcp:8081 || true
"$ADB_BIN" reverse tcp:54321 tcp:54321 || true
"$ADB_BIN" reverse tcp:54322 tcp:54322 || true

echo "[emulator] adb reverse configurado."
