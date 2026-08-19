#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
每日新闻汇总脚本
生成带标题+来源+可点击链接的微信推送格式
"""
import os
import re
import sys
from datetime import datetime

REPO_DIR = "/root/.openclaw/workspace/shytone.com"
os.chdir(REPO_DIR)

today = datetime.now()
date_str = today.strftime('%Y%m%d')
date_display = today.strftime('%Y-%m-%d')

discover_file = f"_discover/{date_str}-今日发现.md"

lines = []
lines.append(f"📰 每日新闻汇总 · {date_display}\n")
lines.append("━" * 32)

if os.path.exists(discover_file):
    with open(discover_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 格式: ### 序号. 标题\n来源/来源行\n来源：[阅读原文](url)\n---
    # 先切分每个条目
    entries = re.split(r'\n---\n', content)
    news_entries = []
    for entry in entries:
        m = re.search(r'### \d+\. (.+?)\n(.*?)\n来源：\[阅读原文\]\((https?://[^)]+)\)', entry, re.DOTALL)
        if m:
            title = m.group(1).strip()
            meta = m.group(2).strip()  # Hacker News - xxx 或空
            url = m.group(3).strip()
            news_entries.append((title, meta, url))

    if news_entries:
        lines.append("\n🗞️ 今日发现 Top5")
        for i, (title, meta, url) in enumerate(news_entries[:5], 1):
            lines.append(f"\n{i}. {title}")
            if meta:
                lines.append(f"   📌 {meta}")
            lines.append(f"   🔗 <{url}>")
    else:
        lines.append("\n⚠️ 今日发现文章格式有变")
else:
    lines.append("\n⚠️ 今日发现文章未找到")

# 今日算法
algo_files = sorted([f for f in os.listdir('_algorithms')
                     if f.startswith(date_str) and not f.endswith('精选文章.md')])
if algo_files:
    lines.append("\n🧮 今日算法")
    for af in algo_files[:1]:
        title = af.replace(date_str + '-', '').replace('.md', '')
        lines.append(f"  • {title}")

# 软考高项
gaokao_files = sorted([f for f in os.listdir('_gaokao')
                         if f.startswith(date_str)])
if gaokao_files:
    lines.append("\n📚 软考高项")
    for gf in gaokao_files[:1]:
        title = gf.replace(date_str + '-', '').replace('.md', '')
        lines.append(f"  • {title}")

result = '\n'.join(lines)
print(result)

digest_file = f"/tmp/news-digest-{date_str}.txt"
with open(digest_file, 'w', encoding='utf-8') as f:
    f.write(result)
print(f"\n[DONE] saved to {digest_file}", file=sys.stderr)
