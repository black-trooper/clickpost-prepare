#!/bin/bash

set -e

# デフォルトで回転しない
ROTATE=false

# オプション解析
while getopts "r" opt; do
  case "$opt" in
    r) ROTATE=true ;;
    *) echo "使い方: $0 [-r] input.pdf"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ $# -ne 1 ]; then
  echo "使い方: $0 [-r] input.pdf"
  exit 1
fi

INPUT="$1"
BASENAME=$(basename "$INPUT" .pdf)
FINAL="${BASENAME}_processed.pdf"
INPUT_ABS=$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")
OUTPUT_PATH="$(pwd)/$FINAL"

TMPDIR=$(mktemp -d -t clickpost_tmp.XXXXXX)
trap "rm -rf \"$TMPDIR\"" EXIT
cd "$TMPDIR" || exit

# Step 1: 4分割
mutool poster -x 2 -y 2 "$INPUT_ABS" output.pdf

# Step 2: 総ページ数を取得して1ページずつに分割
PAGE_COUNT=$(qpdf --show-npages output.pdf)
for i in $(seq 1 "$PAGE_COUNT"); do
  PAGE_NAME=$(printf "page_%02d.pdf" "$i")
  qpdf output.pdf --pages . "$i" -- "$PAGE_NAME"
done

# Step 3: 回転（必要な場合）
if $ROTATE; then
  for f in page_*.pdf; do
    qpdf "$f" --rotate=180 --replace-input
  done
fi

# Step 4: 空白ページ除外
mkdir filtered

is_effectively_blank() {
  local text cleaned
  text=$(pdftotext "$1" -)
  cleaned=$(echo "$text" | tr -d '\n\r[:space:]')
  [[ -z "$cleaned" || ${#cleaned} -le 10 ]]
}

included_pages=0
for f in page_*.pdf; do
  if ! is_effectively_blank "$f"; then
    cp "$f" filtered/
    included_pages=$((included_pages + 1))
  fi
done

if [ "$included_pages" -eq 0 ]; then
  echo "⚠ 空白でないページが見つかりませんでした"
fi

cd filtered || exit
PAGE_LIST=$(ls -1v page_*.pdf)
qpdf --empty --pages $PAGE_LIST -- "$OUTPUT_PATH"

echo "✅ 出力完了: $OUTPUT_PATH"
