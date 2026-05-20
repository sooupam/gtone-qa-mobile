#!/usr/bin/env bash
## run-all.sh — roda toda a suite de flows e gera relatório.
## Uso: ./scripts/run-all.sh [tag]
## Exemplos:
##   ./scripts/run-all.sh                # roda tudo
##   ./scripts/run-all.sh smoke          # só os smoke
##   ./scripts/run-all.sh critical       # só os críticos
##   ./scripts/run-all.sh regression     # regressão completa

set -e

cd "$(dirname "$0")/.."

source scripts/setup-env.sh

TAG="${1:-}"
REPORT_DIR="reports/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"

if [ -n "$TAG" ]; then
  echo "[run-all] Rodando flows com tag: $TAG"
  maestro test --include-tags="$TAG" \
    --format=junit \
    --output="$REPORT_DIR/junit.xml" \
    flows/
else
  echo "[run-all] Rodando toda a suite"
  maestro test \
    --format=junit \
    --output="$REPORT_DIR/junit.xml" \
    flows/
fi

echo "[run-all] Relatório em: $REPORT_DIR"
