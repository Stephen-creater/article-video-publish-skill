#!/bin/zsh
# 把发布版的音量提到 -14 LUFS（短视频平台习惯值，-16 上传会提示「音量偏低」），真峰值限在 -1.5 dBTP。
# 两遍：先测量，再按测量值标准化；画面直接复制不重压。最后打印新响度和峰值。
# 用法：loudnorm14.sh <输入mp4> <输出mp4>
set -e
IN="$1"; OUT="$2"
J=$(ffmpeg -nostdin -hide_banner -i "$IN" -vn -af loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json -f null - 2>&1 | sed -n '/^{/,/^}/p')
M=$(print -r -- "$J" | python3 -c "import json,sys;d=json.load(sys.stdin);print(f\"measured_I={d['input_i']}:measured_TP={d['input_tp']}:measured_LRA={d['input_lra']}:measured_thresh={d['input_thresh']}:offset={d['target_offset']}\")")
ffmpeg -nostdin -y -loglevel error -i "$IN" -c:v copy \
  -af "loudnorm=I=-14:TP=-1.5:LRA=11:${M}:linear=true,aresample=48000" \
  -c:a aac -b:a 192k -movflags +faststart "$OUT"
ffmpeg -nostdin -i "$OUT" -vn -af ebur128=peak=true -f null - 2>&1 | grep -E "^\s+(I|Peak):"
