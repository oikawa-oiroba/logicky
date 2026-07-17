#!/bin/bash
# 受信した問題フィードバックを一覧表示する管理用スクリプト
# Usage: ./scripts/list-feedback.sh
set -e
cd "$(dirname "$0")/.."

TOKEN=$(grep BLOB_READ_WRITE_TOKEN .env.local | cut -d'"' -f2)
if [ -z "$TOKEN" ]; then
  echo "BLOB_READ_WRITE_TOKEN が .env.local にありません。'npx vercel env pull' を実行してください。"
  exit 1
fi

# Vercel CLIは表をstderrに出力する
PATHS=$(npx -y vercel blob list --rw-token "$TOKEN" --limit 1000 2>&1 \
  | grep -o 'feedback/[^ ]*\.json' | sort -u)

if [ -z "$PATHS" ]; then
  echo "フィードバックはまだありません。"
  exit 0
fi

for p in $PATHS; do
  echo "── $p"
  npx -y vercel blob get "$p" --access private --rw-token "$TOKEN" 2>/dev/null || echo "(取得失敗)"
  echo ""
done
