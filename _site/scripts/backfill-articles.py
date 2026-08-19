#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量回填缺失文章
从 2026-04-25 到 2026-06-18，补齐数学、物理、算法、软考
"""

import os
import ast
from datetime import datetime, timedelta
from importlib import util

REPO_DIR = "/root/.openclaw/workspace/shytone.com"
os.chdir(REPO_DIR)

# ── 加载数据 ────────────────────────────────────────────────────────────────

# 软考
spec = util.spec_from_file_location("exam_prep", f"{REPO_DIR}/scripts/exam-prep-gen.py")
exam_mod = util.module_from_spec(spec)
spec.loader.exec_module(exam_mod)
CHAPTERS = exam_mod.CHAPTERS

# 数学
def load_topics(script_name, var_name):
    with open(f"{REPO_DIR}/scripts/{script_name}", 'r', encoding='utf-8') as f:
        content = f.read()
    start = content.find(f'{var_name} = [')
    start_bracket = content.find('[', start)
    depth = 0
    end_idx = start_bracket
    for i in range(start_bracket, len(content)):
        c = content[i]
        if c == '[': depth += 1
        elif c == ']':
            depth -= 1
            if depth == 0:
                end_idx = i
                break
    return ast.literal_eval(content[start_bracket:end_idx+1])

MATH_TOPICS = load_topics('math-daily.sh', 'MATH_TOPICS')
PHYSICS_TOPICS = load_topics('physics-daily.sh', 'PHYSICS_TOPICS')

# 算法
exec(open(f"{REPO_DIR}/scripts/algorithm-daily.sh").read())

# ── 内容生成函数 ────────────────────────────────────────────────────────────

def make_gaokao(date, day_of_year):
    ch = CHAPTERS[day_of_year % len(CHAPTERS)]
    ch_num = int(ch['id'].replace('ch', ''))
    date_str = date.strftime('%Y-%m-%d')
    date_short = date.strftime('%Y%m%d')
    weight_map = {'5星': '⭐⭐⭐ 高频必背', '4星': '⭐⭐ 中高频', '3星': '⭐ 中频', '2星': '低频', '1星': '冷门'}
    w = weight_map.get(ch.get('weight', '3星'), '⭐⭐')

    sections = []
    for section in ch['content'].split('\n\n'):
        if not section.strip(): continue
        if '】' in section:
            parts = section.split('】', 1)
            sections.append(f"## 📝 {parts[0].replace('【', '')}\n{parts[1]}")
        else:
            sections.append(f"## 📝 {section}")

    mnemonic = '持续学习，积少成多。每天进步一点点！'
    if '【记忆口诀】' in ch['content']:
        mnemonic = ch['content'].split('【记忆口诀】')[-1].split('\n')[0]

    prev_ch = CHAPTERS[(day_of_year - 1) % len(CHAPTERS)]
    prev_num = int(prev_ch['id'].replace('ch', ''))
    prev_date = (date - timedelta(days=1)).strftime('%Y%m%d')

    return f"""---
title: 软考高项每日一题{ch_num:03d}-{ch['name']}
date: {date_str} 08:00:00 +0800
categories: [软考高项]
tags: [软考, 每日一题, {ch['name']}, 项目管理]
description: 软考高项每日一题第{ch_num}期：{ch['name']}知识点详解与练习题。
---

> 备考时间紧迫，但努力绝对值得。每一道题目都是通往成功的阶梯 💪
>
> Exam prep time is tight, but your effort is absolutely worth it. Every question is a step toward success 💪

<!--more-->

## 📅 今日知识点：{ch['name']} ({ch['name_en']})

**难度**：{w}
**考查频率**：{ch.get('exam_freq', '中频')}

---

{chr(10).join(sections)}

---

## 💡 记忆口诀

{mnemonic}

---

*相关阅读：[软考高项每日一题{prev_num:03d}-{prev_ch['name']}](/_gaokao/{prev_date}-软考高项每日一题{prev_num:03d}-{prev_ch['name']}.md)*

""", f"_gaokao/{date_short}-软考高项每日一题{ch_num:03d}-{ch['name']}.md"


def make_math(date, day_of_year):
    idx = day_of_year % len(MATH_TOPICS)
    topic = MATH_TOPICS[idx]
    date_str = date.strftime('%Y-%m-%d')
    date_short = date.strftime('%Y%m%d')
    num = idx + 1

    points = ''
    for i, (p, pe) in enumerate(zip(topic['key_points'], topic['key_points_en']), 1):
        points += f"### {i}. {p}\n{pe}\n\n"

    return f"""---
title: "数学学习 {num:03d} - {topic['name']}"
date: {date_str} 08:00:00 +0800
categories: [数学, {topic['category']}]
tags: [{', '.join(topic['tags'])}]
description: "{topic['description']}"
math: true
---

# 数学学习 {num:03d} - {topic['name']} ({topic['name_en']})

## 概述

**难度**：{topic['difficulty']} ({topic['difficulty_en']})  
**分类**：{topic['category']} ({topic['category_en']})

{topic['description']}

{topic['description_en']}

---

## 核心要点

{points}---

## 公式

$$
{topic['formula']}
$$

---

## 今日练习

1. 理解上述核心要点，尝试用自己的话复述
2. 完成教材或习题册相关练习
3. 思考：这个知识点与其他知识的联系

---

## 📝 今日要点总结

| 概念 | 内容 |
|------|------|
| 名称 | {topic['name']} ({topic['name_en']}) |
| 分类 | {topic['category']} |
| 难度 | {topic['difficulty']} |
| 核心公式 | ${topic['formula']}$ |

---

**下一篇预告**：数学学习 {num+1:03d} - {'下一个知识点' if num < len(MATH_TOPICS) else '复习与总结'}

---

> 💡 学习建议：每天理解一个核心概念，不要贪多。理解 > 记忆。
> 💡 Learning tip: Focus on one concept per day. Understanding > memorization.
""", f"_math/{date_short}-数学{num:03d}-{topic['name']}.md"


def make_physics(date, day_of_year):
    idx = day_of_year % len(PHYSICS_TOPICS)
    topic = PHYSICS_TOPICS[idx]
    date_str = date.strftime('%Y-%m-%d')
    date_short = date.strftime('%Y%m%d')
    num = idx + 1

    points = ''
    for i, (p, pe) in enumerate(zip(topic['key_points'], topic['key_points_en']), 1):
        points += f"### {i}. {p}\n{pe}\n\n"

    formulas = '\n'.join([f"- ${f}$" for f in topic.get('formulas', [])])

    return f"""---
title: "物理学习 {num:03d} - {topic['name']}"
date: {date_str} 08:00:00 +0800
categories: [物理, {topic['category']}]
tags: [{', '.join(topic['tags'])}]
description: "{topic['description']}"
physics: true
---

# 物理学习 {num:03d} - {topic['name']} ({topic['name_en']})

## 概述

**难度**：{topic['difficulty']} ({topic['difficulty_en']})  
**分类**：{topic['category']} ({topic['category_en']})

{topic['description']}

{topic['description_en']}

---

## 核心要点

{points}---

## 重要公式

{formulas}

---

## 今日练习

1. 理解上述核心要点，尝试用自己的话复述
2. 完成教材或习题册相关练习
3. 思考：这个知识点在实际问题中的应用

---

## 📝 今日要点总结

| 概念 | 内容 |
|------|------|
| 名称 | {topic['name']} ({topic['name_en']}) |
| 分类 | {topic['category']} |
| 难度 | {topic['difficulty']} |

---

> 💡 学习建议：物理概念要理解本质，公式要掌握推导过程。
> 💡 Learning tip: Understand physics concepts deeply, master formula derivations.
""", f"_physics/{date_short}-物理{num:03d}-{topic['name']}.md"


def make_algorithm(date, day_of_year):
    algo = ALGORITHMS[day_of_year % len(ALGORITHMS)]
    date_str = date.strftime('%Y-%m-%d')
    date_short = date.strftime('%Y%m%d')

    code = algo.get('code', '# 代码待补充')
    if code.startswith('```'):
        lines = code.split('\n')
        code = '\n'.join(lines[1:-1])

    return f"""---
title: "{algo['name']} - 算法讲解"
date: {date_str}
tags: ['算法', '{algo['category']}', '{algo['name_en']}']
description: "{algo['description']}"
algorithm: true
---

<div class="ai-badge">🧑‍💻 算法学习 · {algo['name_en']}</div>

# {algo['name']} ({algo['name_en']})

## 概述

**难度**：{algo['difficulty']} ({algo['difficulty_en']})  
**分类**：{algo['category_en']} / {algo['category']}

{algo['description']}

{algo['description_en']}

---

## 算法原理

**中文**：{algo['principle']}

**English**: {algo['principle_en']}

---

## 复杂度分析

| 类型 | 复杂度 |
|------|--------|
| 时间复杂度 | {algo['time_complexity']} |
| 空间复杂度 | {algo['space_complexity']} |

---

## 代码实现

```{algo.get('language', 'python')}
{code}
```

---

## 每日练习

1. 完成算法实现
2. 分析算法复杂度
3. 思考：算法的适用场景和局限性

---

*相关阅读：[算法专栏](/algorithms)*

---

> 💡 学习建议：算法学习重在理解思想，多写多练是关键。
> 💡 Learning tip: Algorithm learning is about understanding the core idea. Practice makes perfect.
""", f"_algorithms/{date_short}-{algo['name']}.md"


def make_curated(date):
    date_str = date.strftime('%Y-%m-%d')
    date_short = date.strftime('%Y%m%d')
    return f"""---
title: 精选文章 {date_str}
date: {date_str}
tags: ['精选文章', '算法', '技术', '深度好文']
description: 每日精选算法相关文章推荐
ai_generated: true
---

<div class="ai-badge">📚 精选文章 · Curated Reading</div>

## 🌟 今日推荐

> 精选内容将在后续版本中根据您的学习偏好智能推荐

---

## 📝 学习笔记

坚持每日算法学习，积少成多，量变引起质变。

---

*相关阅读：[算法专栏](/algorithms)*

""", f"_algorithms/{date_short}-精选文章.md"


# ── 主回填逻辑 ──────────────────────────────────────────────────────────────

def backfill():
    start = datetime(2026, 4, 25)
    end   = datetime(2026, 6, 18)   # 6/19 已生成，跳过

    stats = {'gaokao': 0, 'math': 0, 'physics': 0, 'algorithm': 0, 'curated': 0, 'skipped': 0}

    d = start
    while d <= end:
        date_short = d.strftime('%Y%m%d')
        day_of_year = d.timetuple().tm_yday
        changed = False

        # 软考
        content, filepath = make_gaokao(d, day_of_year)
        if not os.path.exists(filepath):
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            stats['gaokao'] += 1
            changed = True

        # 数学
        content, filepath = make_math(d, day_of_year)
        if not os.path.exists(filepath):
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            stats['math'] += 1
            changed = True

        # 物理
        content, filepath = make_physics(d, day_of_year)
        if not os.path.exists(filepath):
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            stats['physics'] += 1
            changed = True

        # 算法
        content, filepath = make_algorithm(d, day_of_year)
        if not os.path.exists(filepath):
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            stats['algorithm'] += 1
            changed = True

        # 精选算法
        content, filepath = make_curated(d)
        if not os.path.exists(filepath):
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            stats['curated'] += 1
            changed = True

        if changed:
            print(f"  {d.strftime('%Y-%m-%d')}: 新增 5 篇")
        else:
            stats['skipped'] += 1

        d += timedelta(days=1)

    total = sum(v for k, v in stats.items() if k != 'skipped')
    print(f"\n========== 回填完成 ==========")
    print(f"软考高项:  +{stats['gaokao']} 篇")
    print(f"数学:      +{stats['math']} 篇")
    print(f"物理:      +{stats['physics']} 篇")
    print(f"算法讲解:  +{stats['algorithm']} 篇")
    print(f"精选算法:  +{stats['curated']} 篇")
    print(f"跳过:      {stats['skipped']} 天（已存在）")
    print(f"合计新增:  {total} 篇")
    return stats

if __name__ == '__main__':
    backfill()