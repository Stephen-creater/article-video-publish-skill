#!/bin/zsh
# 把选定的 16:9 和 3:4 封面导出成四个平台的标准 JPG（用 sips，抖音才认）。
# 用法：export_covers.sh <16比9源图> <3比4源图> <输出目录>
set -e
W="$1"; T="$2"; O="$3"; mkdir -p "$O"
mk(){ sips -s format jpeg -s formatOptions 92 -z "$3" "$2" "$1" --out "$4" >/dev/null; }
mk "$W" 1920 1080 "$O/B站_16比9_1920x1080.jpg"
mk "$T" 1080 1440 "$O/小红书_3比4_1080x1440.jpg"
mk "$T" 1080 1440 "$O/视频号_3比4_1080x1440.jpg"
mk "$T" 1242 1656 "$O/抖音_3比4_1242x1656.jpg"
for f in "$O"/*.jpg; do echo "$(sips -g pixelWidth -g pixelHeight "$f" | awk '/pixel/{printf $2" "}') $(basename "$f")"; done
