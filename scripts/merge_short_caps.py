#!/usr/bin/env python3
"""换成 Stephen 本人声音后语速快，fix_caps.py 断出的「同理」「比如说」这类短块不到 0.45 秒，一闪而过。
本脚本把同一句里不足 0.45 秒的字幕块并进相邻块（合并后不超过 12 个字，英文按半字算），重写 timeline.json 的 captions 和 subtitles.srt。
用法：fix_caps.py 之后跑，再跑 build_captions.py。
"""
import json
from pathlib import Path

MIN, MAXW = 0.45, 12.0
tl = json.loads(Path("audio/timeline.json").read_text(encoding="utf-8"))
caps = tl["captions"]


def width(s):
    return sum(0.5 if c.isascii() else 1.0 for c in s)


LINES = {l["id"]: l.get("text", "") for sc in tl.get("scenes", []) for l in sc.get("lines", [])}
PUNCT = "，。！？；：、,.!?;:…—"


def gap_has_punct(a, b):
    """原句里 a 和 b 之间有标点（如「为什么？因为」）就返回 True。"""
    t = LINES.get(a["line"], "")
    i = t.find(a["text"][-2:]) if len(a["text"]) >= 2 else t.find(a["text"])
    if i < 0:
        return False
    j = t.find(b["text"][:1], i + 1)
    return j > 0 and any(ch in PUNCT for ch in t[i:j])


def join(a, b):
    sep = " " if (a["text"][-1:].isascii() and b["text"][:1].isascii()) or gap_has_punct(a, b) else ""
    return {**a, "text": a["text"] + sep + b["text"], "end": b["end"], "duration": round(b["end"] - a["start"], 4)}


changed = True
while changed:
    changed = False
    for i, c in enumerate(caps):
        if c["duration"] >= MIN:
            continue
        nxt = caps[i + 1] if i + 1 < len(caps) and caps[i + 1]["line"] == c["line"] else None
        prv = caps[i - 1] if i > 0 and caps[i - 1]["line"] == c["line"] else None
        if nxt and width(c["text"] + nxt["text"]) <= MAXW:
            caps[i:i + 2] = [join(c, nxt)]; changed = True; break
        if prv and width(prv["text"] + c["text"]) <= MAXW:
            caps[i - 1:i + 1] = [join(prv, c)]; changed = True; break
for k, c in enumerate(caps, 1):
    c["id"] = f"c{k:03d}"
tl["captions"] = caps
Path("audio/timeline.json").write_text(json.dumps(tl, ensure_ascii=False, indent=1), encoding="utf-8")


def ts(x):
    ms = int(round(x * 1000)); h, ms = divmod(ms, 3600000); m, ms = divmod(ms, 60000); s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


Path("audio/subtitles.srt").write_text(
    "\n".join(f"{i}\n{ts(c['start'])} --> {ts(c['end'])}\n{c['text']}\n" for i, c in enumerate(caps, 1)), encoding="utf-8")
short = [c for c in caps if c["duration"] < MIN]
print(f"合并后 {len(caps)} 块，仍短于 {MIN}s：", " ".join(f"{c['text']}({c['duration']})" for c in short) or "无",
      "；最长", max(width(c["text"]) for c in caps), "字")
