#!/usr/bin/env python3
import os, random, json
from datetime import datetime, timedelta

REPO_DIR = "/root/.openclaw/workspace/shytone.com"
os.chdir(REPO_DIR)

STATUS_FILE = REPO_DIR + "/_xiuxian/.status.json"

def load_status():
    if os.path.exists(STATUS_FILE):
        with open(STATUS_FILE) as f:
            return json.load(f)
    return {
        "day": 1, "date": "2026-07-10", "cultivation_level": "炼气一重",
        "cultivation_exp": 15, "max_cultivation_exp": 100, "life": 80, "max_life": 80,
        "spirit": 11, "max_spirit": 11, "sword_intent": 5, "merit": 0,
        "techniques": ["基础吐纳术", "清风剑法（残篇）"], "items": ["化神前辈玉佩"],
        "chapter_title": "第一章", "story_progress": 1
    }

def save_status(s):
    os.makedirs(os.path.dirname(STATUS_FILE), exist_ok=True)
    with open(STATUS_FILE, 'w') as f:
        json.dump(s, f, ensure_ascii=False, indent=2)

EVENTS = [
    ("按照吐纳术要诀修炼，感受丹田气流流转。", "exp+15"),
    ("清风剑法反复演练上百遍。", "exp+10|sword+3"),
    ("研读玉简，茅塞顿开。", "exp+12|merit+1"),
    ("盘膝打坐三时辰，神清气爽。", "exp+10|spirit+1"),
]

RANDOMS = [
    ("奇遇·灵药", "采到百年灵芝，灵力大增。", "spirit+5|max_spirit+3"),
    ("危机·妖兽", "遭遇青鳞蟒，激战逃脱。", "exp+15|life-10"),
    ("顿悟·剑意", "看落叶悟剑道真意。", "sword+10|exp+15"),
]

REALMS = [("炼气一重",0),("炼气二重",100),("炼气三重",200),("炼气四重",300),("炼气五重",400),("炼气六重",500),("炼气七重",600),("炼气八重",700),("炼气九重",800),("筑基一重",1000)]

def fx(s, s2):
    for p in s2.split("|"):
        if p.startswith("exp+"): s["cultivation_exp"] += int(p[4:])
        elif p.startswith("spirit+"): s["spirit"] = min(s["spirit"]+int(p[7:]), s["max_spirit"])
        elif p.startswith("max_spirit+"): s["max_spirit"] += int(p[11:])
        elif p.startswith("sword+"): s["sword_intent"] += int(p[6:])
        elif p.startswith("merit+"): s["merit"] += int(p[6:])
        elif p.startswith("life-"): s["life"] = max(1, s["life"]+int(p[6:]))

s = load_status()
s["day"] += 1
d = datetime.strptime(s["date"], "%Y-%m-%d")
d += timedelta(days=1)
s["date"] = d.strftime("%Y-%m-%d")
ds = d.strftime("%Y%m%d")

ev = random.choice(EVENTS)
fx(s, ev[1])
ev_desc = f"**【日常修炼】** {ev[0]}"

if random.random() < 0.3:
    re = random.choice(RANDOMS)
    fx(s, re[2])
    ev_desc += f"\n\n**【随机事件：{re[0]}】** {re[1]}"

old_lv, new_lv = None, None
for name, thr in REALMS:
    if s["cultivation_exp"] >= thr and s["cultivation_level"] != name:
        old_lv, new_lv = s["cultivation_level"], name
        s["cultivation_level"] = name
        s["max_life"] += 10
        s["life"] = s["max_life"]
        s["max_spirit"] += 5
        s["spirit"] = s["max_spirit"]
        break

bt_desc = ""
if old_lv:
    bt_desc = f"\n## 🌟 境界突破！\n\n{old_lv} → **{new_lv}**\n"

save_status(s)

ch_map = {2:"第二章",3:"第三章",4:"第四章",5:"第五章"}
if s["day"] % 7 == 0:
    s["story_progress"] += 1
    s["chapter_title"] = ch_map.get(s["story_progress"], s["chapter_title"])

prev = s["day"] - 1
content = f"""---
title: "{s["chapter_title"]} · 修行第{prev}日"
date: {s["date"]} 08:00:00 +0800
categories: [修仙养成]
tags: [修行日记, {s["cultivation_level"]}, 顾长清]
description: 顾长清修仙养成第{prev}日记录
---

# {s["chapter_title"]} · 修行第{prev}日

> *「道可道，非常道。修仙之路漫漫，吾将砥砺前行。」*

---

## 📊 当前状态

| 属性 | 数值 |
|------|------|
| 修为 | {s["cultivation_level"]}（{s["cultivation_exp"]}/{s["max_cultivation_exp"]}） |
| 寿命 | {s["life"]}/{s["max_life"]} |
| 灵力 | {s["spirit"]}/{s["max_spirit"]} |
| 剑意 | {s["sword_intent"]} |
| 功德 | {s["merit"]} |

---

## ⚔️ 今日修炼

{ev_desc}{bt_desc}

---

## 💬 修行感悟

*「修仙一途，如同逆水行舟。今日的每一次吐纳，都是明日突破的基石。」*

*—— 顾长清，修行第{prev}日*

---

距离太虚剑宗招生大典：**{365-prev}天**

*日有所进，道有所长。*
"""

fp = f"_xiuxian/{ds}-{s['chapter_title'].replace(' ', '-')}.md"
with open(fp, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"Generated: {fp}")
