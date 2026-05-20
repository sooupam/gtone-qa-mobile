#!/usr/bin/env bash
## setup-env.sh — carrega .env.local e valida que as vars obrigatórias estão setadas.
## Uso: source scripts/setup-env.sh
##
## Pré-requisitos:
##   cp .env.example .env.local
##   editar .env.local com credenciais reais (gitignored)

set -e

ENV_FILE="${ENV_FILE:-.env.local}"

if [ ! -f "$ENV_FILE" ]; then
  echo "[setup-env] ERRO: $ENV_FILE não existe."
  echo "[setup-env] Rode: cp .env.example .env.local  →  edite com suas credenciais."
  return 1 2>/dev/null || exit 1
fi

## Carrega .env.local exportando todas as vars
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

## Valida vars obrigatórias
REQUIRED_VARS=(
  MAESTRO_TEST_EMAIL
  MAESTRO_TEST_PASSWORD
  MAESTRO_TEST_TENANT_SLUG
  MAESTRO_TEST_COMPANY_ID
)

MISSING=()
for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR}" ]; then
    MISSING+=("$VAR")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "[setup-env] ERRO: variáveis obrigatórias não setadas:"
  printf '  - %s\n' "${MISSING[@]}"
  echo "[setup-env] Edite $ENV_FILE."
  return 1 2>/dev/null || exit 1
fi

export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

echo "[setup-env] env carregado de $ENV_FILE (credenciais não exibidas)"
echo "[setup-env] ANDROID_HOME=$ANDROID_HOME"

## adb reverse para Metro + Supabase (idempotente)
if command -v adb >/dev/null 2>&1; then
  if adb devices | grep -q "device$"; then
    adb reverse tcp:8081 tcp:8081 >/dev/null 2>&1 || true
    adb reverse tcp:54321 tcp:54321 >/dev/null 2>&1 || true
    adb reverse tcp:54322 tcp:54322 >/dev/null 2>&1 || true
    echo "[setup-env] adb reverse configurado"
  else
    echo "[setup-env] Nenhum device adb conectado"
  fi
fi
