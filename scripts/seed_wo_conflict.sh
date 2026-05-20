#!/usr/bin/env bash
## seed_wo_conflict.sh — simula edicao remota concorrente de uma OS
## Requer: env MAESTRO_TEST_WO_ID com UUID da OS de teste; Supabase local UP
##
## Edita a description direto no Postgres pra forcar divergencia com edicao offline do app.
set -e
: "${MAESTRO_TEST_WO_ID:?MAESTRO_TEST_WO_ID nao setado — exporte no .env.local}"

DB_CONTAINER=$(docker ps --format '{{.Names}}' | grep "supabase_db" | head -1)
if [ -z "$DB_CONTAINER" ]; then
  echo "[conflict] ERRO: container supabase_db nao encontrado."
  exit 1
fi

docker exec "$DB_CONTAINER" psql -U postgres -d postgres -v "id=$MAESTRO_TEST_WO_ID" -c \
  "UPDATE public.work_orders SET description = 'Edicao remota concorrente (seed conflict)' WHERE id = :'id';"

echo "[conflict] OS $MAESTRO_TEST_WO_ID editada remotamente"
