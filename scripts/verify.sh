#!/usr/bin/env bash
# Verificação final de tarefa — roda UMA vez, só no que mudou, com saída curta.
#   pnpm verify                 # pacotes afetados desde $VERIFY_BASE (padrão origin/main)
#   pnpm verify --only=backend  # só um pacote (após corrigir uma falha)
#   pnpm verify --full          # tudo + e2e do roteiro da demo (antes de merge/sprint)
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"

BASE="${VERIFY_BASE:-origin/main}"
git rev-parse --verify -q "$BASE" >/dev/null || BASE="HEAD~1"
MAX_LINES="${VERIFY_MAX_LINES:-80}"
MODE="affected"; ONLY=""
for arg in "$@"; do
  case "$arg" in
    --full) MODE="full" ;;
    --only=*) MODE="only"; ONLY="${arg#--only=}" ;;
    --verbose) MAX_LINES=100000 ;;
  esac
done

case "$MODE" in
  full)     FILTER=() ;;
  only)     FILTER=(--filter="${ONLY}") ;;
  affected) FILTER=(--filter="...[${BASE}]") ;;
esac

LOG="$(mktemp)"
pnpm turbo run lint typecheck test "${FILTER[@]}" --output-logs=errors-only --continue >"$LOG" 2>&1
STATUS=$?

if [[ "$MODE" == "full" && $STATUS -eq 0 ]]; then
  pnpm --filter web exec playwright test --reporter=line >>"$LOG" 2>&1 || STATUS=$?
fi

if [[ $STATUS -eq 0 ]]; then
  SUMMARY="$(grep -E 'Tasks:|Cached:' "$LOG" | tail -n 2 | tr '\n' ' ')"
  echo "VERIFY: ok ($MODE) ${SUMMARY}"
else
  echo "VERIFY: falhou ($MODE, base $BASE) — mostrando só erros:"
  grep -vE '^\s*$|cache (hit|miss)|^\s*•|Packages in scope|Running .* in [0-9]+ packages' "$LOG" | tail -n "$MAX_LINES"
fi
rm -f "$LOG"
exit $STATUS
