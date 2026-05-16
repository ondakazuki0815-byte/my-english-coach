#!/usr/bin/env bash
#
# deploy.sh — My English Coach 自動デプロイスクリプト
#
# 使い方:
#   ./deploy.sh                       # 「Update site」というメッセージで commit & push
#   ./deploy.sh "Day 9 added"         # 任意のメッセージで commit & push
#   ./deploy.sh --dry-run             # 何が push されるかだけ表示（実際は push しない）
#
# 動作:
#   1. git status を確認（変更があるか）
#   2. .gitignore で除外されているファイル（CLAUDE.md / memory/ / Lessons/ など）は自動で push されない
#   3. 変更があれば add → commit → push origin main
#   4. push後、Vercel または Netlify が自動でデプロイを開始する
#
# 安全装置:
#   - 個人情報や非公開ファイルは .gitignore で除外済み（CLAUDE.md / memory/ / Lessons/ / 3_Month_English_Roadmap.docx）
#   - .gitignore に追加忘れがないか、push前に untracked files をチェックして警告する
#

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# カラー出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 引数処理
DRY_RUN=false
COMMIT_MSG="Update site"

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    --help|-h)
      head -20 "$0" | tail -18
      exit 0
      ;;
    *)
      COMMIT_MSG="$arg"
      ;;
  esac
done

echo -e "${BLUE}=== My English Coach Deploy ===${NC}"
echo -e "Repository: $REPO_DIR"
echo -e "Commit message: ${YELLOW}$COMMIT_MSG${NC}"
[ "$DRY_RUN" = true ] && echo -e "${YELLOW}DRY RUN MODE — no actual push${NC}"
echo

# 1. git status
echo -e "${BLUE}[1/4]${NC} 変更状況を確認中..."
if [ -z "$(git status --porcelain)" ]; then
  echo -e "${GREEN}✓${NC} 変更なし。デプロイ不要。"
  exit 0
fi

git status --short

# 2. 機密漏れチェック（untracked で危険なものがないか）
echo
echo -e "${BLUE}[2/4]${NC} 機密ファイルが入っていないか確認中..."
RISKY_PATTERNS="CLAUDE\.md|memory/|Lessons/|Roadmap\.docx|\.env|secret|password|api[_-]?key"
RISKY=$(git status --porcelain | grep -E "$RISKY_PATTERNS" || true)
if [ -n "$RISKY" ]; then
  echo -e "${RED}✗ 警告: 以下のファイルが追加される予定です。本当に公開してOK？${NC}"
  echo "$RISKY"
  echo
  read -p "続行しますか？ (y/N): " CONFIRM
  if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "${YELLOW}中断しました。${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}✓${NC} 機密ファイルなし"
fi

# 3. add & commit & push
echo
if [ "$DRY_RUN" = true ]; then
  echo -e "${BLUE}[3/4]${NC} [DRY RUN] 以下のファイルが add される予定:"
  git status --porcelain
  echo
  echo -e "${BLUE}[4/4]${NC} [DRY RUN] コミットメッセージ: \"$COMMIT_MSG\""
  echo -e "${YELLOW}DRY RUN 完了。実際の push はしていません。${NC}"
  exit 0
fi

echo -e "${BLUE}[3/4]${NC} ファイルを add してコミット中..."
git add .
git commit -m "$COMMIT_MSG"
echo -e "${GREEN}✓${NC} コミット完了"

# 4. push
echo
echo -e "${BLUE}[4/4]${NC} リモートに push 中..."
git push origin main
echo -e "${GREEN}✓ デプロイ要求送信完了${NC}"
echo
echo "Vercel が数十秒〜数分でビルドして公開します。"
echo "  公開URL: https://my-english-coach.vercel.app"
echo "  進捗確認: https://vercel.com/dashboard"
