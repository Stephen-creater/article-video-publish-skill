#!/bin/zsh
# 导出两张标准 JPG 封面（sips 导出，抖音能识别尺寸）。源图比例偏差超过 1% 就报错，不硬拉伸。
# 用法：export_covers.sh <16比9源图> <3比4源图> <输出目录>
set -e
ratio(){ sips -g pixelWidth -g pixelHeight "$1" | awk '/pixelWidth/{w=$2}/pixelHeight/{h=$2}END{print w/h}'; }
check(){ awk -v r="$(ratio "$1")" -v t="$2" -v f="$1" 'BEGIN{d=(r-t)/t; if(d<0)d=-d; if(d>0.01){print "比例不对：" f " 是 " r "，应为 " t; exit 1}}'; }
check "$1" 1.7778; check "$2" 0.75
mkdir -p "$3"
sips -s format jpeg -s formatOptions 92 -z 1080 1920 "$1" --out "$3/B站_16比9_1920x1080.jpg" >/dev/null
sips -s format jpeg -s formatOptions 92 -z 1656 1242 "$2" --out "$3/竖版3比4_1242x1656_小红书视频号抖音通用.jpg" >/dev/null
ls "$3"
