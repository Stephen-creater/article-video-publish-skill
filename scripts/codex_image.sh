#!/bin/zsh
# 用 Stephen 的 Codex 生成一张图。
# 用法：codex_image.sh <输出目录> <文件名.png> <提示词txt> [参考图]
set -e
OUT=${1:A}; NAME="$2"; PROMPT=$(cat "${3:A}"); REF=${4:+${4:A}}
mkdir -p "$OUT"
ARGS=(-m gpt-5.6-sol --skip-git-repo-check -s workspace-write -C "$OUT" -o "$OUT/codex_回复_${NAME%.*}.txt")
[ -n "$REF" ] && ARGS=(-i "$REF" "${ARGS[@]}")   # -i 后面能接多个文件，必须放在其他选项前面，否则提示词会被当成图片
codex exec "${ARGS[@]}" "请用你的图片生成功能生成一张图片，并把图片保存到当前目录，文件名 ${NAME}。${REF:+附件是参考图。}图片要求如下：${PROMPT}" \
  < /dev/null > "$OUT/codex_${NAME%.*}.log" 2>&1
ls -la "$OUT/$NAME"
