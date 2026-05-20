#!/usr/bin/env bash
## touch_js_file.sh — toca um arquivo JS no repo principal pra forcar hot reload
## Requer: env EFFORTONE_REPO (default ../effortone)
set -e
EFFORTONE_REPO="${EFFORTONE_REPO:-../effortone}"
TARGET="$EFFORTONE_REPO/apps/mobile/app/_layout.tsx"

if [ ! -f "$TARGET" ]; then
  echo "[touch] alvo nao existe: $TARGET"
  exit 0
fi

touch "$TARGET"
echo "[touch] $TARGET tocado"
