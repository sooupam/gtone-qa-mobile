#!/usr/bin/env bash
## seed-supabase.sh — reseta DB local + aplica seeds + força senha do user de teste.
## Pré-requisitos:
##   - .env.local configurado (cp .env.example .env.local, edite)
##   - Repo principal em $EFFORTONE_REPO (default: ../effortone)
##   - supabase CLI instalado
##   - Docker rodando
##
## Uso: source scripts/setup-env.sh && bash scripts/seed-supabase.sh

set -e

## Valida vars
: "${MAESTRO_TEST_EMAIL:?MAESTRO_TEST_EMAIL não setado — rode 'source scripts/setup-env.sh'}"
: "${MAESTRO_TEST_PASSWORD:?MAESTRO_TEST_PASSWORD não setado — rode 'source scripts/setup-env.sh'}"

EFFORTONE_REPO="${EFFORTONE_REPO:-../effortone}"
RESET_DB="${RESET_DB:-true}"

if [ ! -d "$EFFORTONE_REPO/supabase" ]; then
  echo "[seed] ERRO: repo principal não encontrado em $EFFORTONE_REPO"
  echo "[seed] Set EFFORTONE_REPO=/path/to/effortone no .env.local"
  exit 1
fi

cd "$EFFORTONE_REPO"

if [ "$RESET_DB" = "true" ]; then
  echo "[seed] Resetando DB local (supabase db reset)..."
  supabase db reset --no-seed
fi

echo "[seed] Aplicando seeds..."
supabase db seed --linked || supabase db reset

## Container do Postgres
DB_CONTAINER=$(docker ps --format '{{.Names}}' | grep "supabase_db" | head -1)
if [ -z "$DB_CONTAINER" ]; then
  echo "[seed] ERRO: container supabase_db não encontrado. Rode 'supabase start'."
  exit 1
fi

echo "[seed] Forçando senha do user de teste (lida do env, não exibida)..."
## Senha vem do .env.local — nunca hardcoded
docker exec -e SEED_PASSWORD="$MAESTRO_TEST_PASSWORD" -e SEED_EMAIL="$MAESTRO_TEST_EMAIL" \
  "$DB_CONTAINER" psql -U postgres -d postgres -c \
  "UPDATE auth.users SET encrypted_password = extensions.crypt(current_setting('SEED_PASSWORD', true), extensions.gen_salt('bf')) WHERE email = current_setting('SEED_EMAIL', true);" \
  2>&1 | grep -v "SEED_PASSWORD\|SEED_EMAIL" || true

## Fallback se current_setting não funcionar (depende da config do PG)
docker exec "$DB_CONTAINER" psql -U postgres -d postgres -v "email=$MAESTRO_TEST_EMAIL" -v "pwd=$MAESTRO_TEST_PASSWORD" -c \
  "UPDATE auth.users SET encrypted_password = extensions.crypt(:'pwd', extensions.gen_salt('bf')) WHERE email = :'email';" \
  > /dev/null 2>&1 || true

echo "[seed] Pronto."
