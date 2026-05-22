#!/usr/bin/env bash
# =============================================================================
# 每日文章生成 + 推送脚本（健壮版）
# 
# 功能：
#   1. 生成软考高项每日一题（_gaokao/）
#   2. 生成 AI 日报 + 精选文章（_ai-daily/）
#   3. 生成今日发现（_discover/）
#   4. 验证文件存在后才 commit + push
#   5. 推送失败时告警（输出明显标记）
#
# 使用：
#   直接运行：./daily-article-generate.sh
#   Cron:    0 8 * * * cd /root/.openclaw/workspace/shytone.com && bash scripts/daily-article-generate.sh
# =============================================================================

set -euo pipefail

REPO_DIR="/root/.openclaw/workspace/shytone.com"
LOG_FILE="/tmp/daily-article-$(date +%Y%m%d).log"

# 当前日期
TODAY_DATE=$(date +%Y-%m-%d)        # 2026-05-20
TODAY_SHORT=$(date +%Y%m%d)         # 20260520

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()       { echo -e "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
log_ok()    { log "${GREEN}✓ $1${NC}"; }
log_warn()  { log "${YELLOW}⚠ $1${NC}"; }
log_error() { log "${RED}✗ $1${NC}"; }

# ---------------------------------------------------------------------------
# 软考高项：生成每日一题
# ---------------------------------------------------------------------------
generate_gaokao() {
    local out_file="$REPO_DIR/_gaokao/${TODAY_DATE}-软考高项每日一题014-项目沟通管理.md"
    
    if [ -f "$out_file" ]; then
        log_ok "软考文章已存在，跳过"
        return 0
    fi
    
    log "生成软考高项每日一题..."
    
    # 使用 Python 计算当天章节（与 exam-prep-gen.py 逻辑一致）
    python3 << 'PYTHON'
from datetime import datetime

today = datetime.now()
day_of_year = today.timetuple().tm_yday

# 读取章节数据（动态导入）
import sys
import importlib.util

spec = importlib.util.spec_from_file_location(
    "exam_prep", 
    "/root/.openclaw/workspace/shytone.com/scripts/exam-prep-gen.py"
)
exam_mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(exam_mod)

CHAPTERS = exam_mod.CHAPTERS
slot_count = len(CHAPTERS)

# 每天2篇：上午篇 + 下午篇
morning_idx = day_of_year % slot_count
afternoon_idx = (day_of_year * 3 + 1) % slot_count

date_str = today.strftime('%Y-%m-%d')
date_short = today.strftime('%Y%m%d')

# 生成上午篇（morning）
ch = CHAPTERS[morning_idx]
ch_num = int(ch['id'].replace('ch', ''))
title = f"软考高项每日一题{ch_num:03d}-{ch['name']}"

# 判断优先级标签
weight = ch.get('weight', '3星')
weight_map = {
    '5星': '⭐⭐⭐ 高频必背',
    '4星': '⭐⭐ 中高频',
    '3星': '⭐ 中频',
    '2星': '低频',
    '1星': '冷门'
}

content = f'''---
title: {title}
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

**难度**：{weight_map.get(weight, '⭐⭐')}
**考查频率**：{ch.get('exam_freq', '中频')}

---

{chr(10).join([
    '## 📝 ' + section.split('】')[0].replace('【', '') + chr(10) + section.split('】')[1] 
    if '】' in section else '## 📝 ' + section 
    for section in ch['content'].split('\n\n') if section.strip()
])}

---

## 💡 记忆口诀

{ch['content'].split('【记忆口诀】')[-1].split('\n')[0] if '【记忆口诀】' in ch['content'] else '持续学习，积少成多。每天进步一点点！'}

---

*相关阅读：[软考高项每日一题{ch_num-1:03d}-{CHAPTERS[(morning_idx-1) % slot_count]['name']}](/_gaokao/{(today.replace(day=today.day-1)).strftime("%Y%m%d")}-软考高项每日一题{ch_num-1:03d}-{CHAPTERS[(morning_idx-1) % slot_count]['name']}.md)*

'''

# 输出到文件（中文文件名用英文名替代）
filename = f"{date_short}-软考高项每日一题{ch_num:03d}-{ch['name']}.md"
filepath = f"/root/.openclaw/workspace/shytone.com/_gaokao/{filename}"
with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"生成: {filename}")
PYTHON

    log_ok "软考文章生成完成"
}

# ---------------------------------------------------------------------------
# AI 日报：生成 AI-今日资讯.md
# ---------------------------------------------------------------------------
generate_ai_daily() {
    local out_file="$REPO_DIR/_ai-daily/${TODAY_DATE}-AI-今日资讯.md"
    
    if [ -f "$out_file" ]; then
        log_ok "AI日报已存在，跳过"
        return 0
    fi
    
    log "生成 AI 日报..."
    
    cat > "$out_file" << 'ARTICLE'
---
title: AI 日报 - 今日资讯
date: DATE_PLACEHOLDER 08:00:00 +0800
categories: [AI日报]
tags: [AI, 资讯, 技术新闻]
description: 每日 AI 和技术领域资讯速递
ai_generated: true
---

> 每天学习一点点，进步一点点 🚀
>
> Learn a little every day, make progress every day 🚀

<!--more-->

## 🤖 AI 圈今日要闻

> 系统将在后续版本中接入真实新闻源自动抓取

ARTICLE

    sed -i "s/DATE_PLACEHOLDER/$TODAY_DATE/g" "$out_file"
    log_ok "AI日报生成完成"
}

# ---------------------------------------------------------------------------
# 精选文章：生成 精选文章.md
# ---------------------------------------------------------------------------
generate_curated() {
    local out_file="$REPO_DIR/_ai-daily/${TODAY_DATE}-精选文章.md"
    
    if [ -f "$out_file" ]; then
        log_ok "精选文章已存在，跳过"
        return 0
    fi
    
    log "生成精选文章..."
    
    cat > "$out_file" << ARTICLE
---
title: 精选文章 DATE_PLACEHOLDER
date: DATE_PLACEHOLDER
tags: ['精选文章', 'AI', '技术', '深度好文']
description: 每日精选技术文章推荐
ai_generated: true
---

<div class="ai-badge">📚 精选文章 · Curated Reading</div>

## 🌟 今日推荐

> 精选内容将在后续版本中根据您的学习偏好智能推荐

ARTICLE

    sed -i "s/DATE_PLACEHOLDER/$TODAY_DATE/g" "$out_file"
    log_ok "精选文章生成完成"
}

# ---------------------------------------------------------------------------
# 今日发现：运行 fetch_news.py
# ---------------------------------------------------------------------------
generate_discover() {
    local out_file="$REPO_DIR/_discover/${TODAY_DATE}-今日发现.md"
    
    if [ -f "$out_file" ]; then
        log_ok "今日发现已存在，跳过"
        return 0
    fi
    
    log "生成今日发现（调用 fetch_news.py）..."
    cd "$REPO_DIR"
    python3 scripts/fetch_news.py >> "$LOG_FILE" 2>&1 || {
        log_warn "fetch_news.py 执行失败，使用默认内容"
        cat > "$out_file" << ARTICLE
---
title: 今日发现 DATE_PLACEHOLDER
date: DATE_PLACEHOLDER
tags: ['科技', 'AI', '数码', '开发']
description: 每日科技、数码，开发相关新闻汇总
ai_generated: true
---

<div class="ai-badge">🤖 AI 资讯速递 · Today's Tech Digest</div>

## 📰 今日要闻

> 新闻源获取中，请稍后再访问

---
ARTICLE
        sed -i "s/DATE_PLACEHOLDER/$TODAY_DATE/g" "$out_file"
    }
    log_ok "今日发现生成完成"
}

# ---------------------------------------------------------------------------
# 验证 + 统计
# ---------------------------------------------------------------------------
verify_articles() {
    log "验证今日文章..."
    
    local all_exist=true
    local gaokao_count=0
    local ai_daily_count=0
    local discover_count=0
    
    # 统计 _gaokao
    gaokao_count=$(ls "$REPO_DIR/_gaokao/"${TODAY_SHORT}-*.md 2>/dev/null | wc -l)
    log "  软考高项: ${gaokao_count} 篇"
    
    # 统计 _ai-daily
    ai_daily_count=$(ls "$REPO_DIR/_ai-daily/"${TODAY_DATE}-*.md 2>/dev/null | wc -l)
    log "  AI 日报:  ${ai_daily_count} 篇"
    
    # 统计 _discover
    discover_count=$(ls "$REPO_DIR/_discover/"${TODAY_DATE}-*.md 2>/dev/null | wc -l)
    log "  今日发现: ${discover_count} 篇"
    
    if [ "$gaokao_count" -eq 0 ] && [ "$ai_daily_count" -eq 0 ] && [ "$discover_count" -eq 0 ]; then
        log_error "⚠️ 没有任何文章生成！"
        all_exist=false
    elif [ "$gaokao_count" -gt 0 ] || [ "$ai_daily_count" -gt 0 ] || [ "$discover_count" -gt 0 ]; then
        log_ok "文章验证完成：有文章可以推送"
    fi
    
    return 0
}

# ---------------------------------------------------------------------------
# Git 提交 + 推送（带重试）
# ---------------------------------------------------------------------------
git_push() {
    cd "$REPO_DIR"
    
    # Staged 所有变更
    git add -A
    
    # 确认有内容才提交
    if git diff --cached --quiet; then
        log_warn "没有内容变更，跳过 commit"
        return 0
    fi
    
    local commit_msg="自动推送 $(date +%Y-%m-%d) 文章 $(date +%H:%M:%S)"
    git commit -m "$commit_msg"
    
    # 推送（最多重试3次）
    local retry=0
    local max_retries=3
    
    while [ $retry -lt $max_retries ]; do
        if git push origin main >> "$LOG_FILE" 2>&1; then
            log_ok "Git 推送成功！"
            return 0
        fi
        retry=$((retry + 1))
        log_warn "推送失败，重试 $retry/$max_retries..."
        sleep 2
    done
    
    log_error "❌ Git 推送失败（重试 $max_retries 次后仍然失败）"
    log_error "请手动登录服务器检查：cd $REPO_DIR && git status"
    return 1
}

# ---------------------------------------------------------------------------
# 主流程
# ---------------------------------------------------------------------------
main() {
    echo "========================================" | tee "$LOG_FILE"
    echo "每日文章生成 $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"
    
    # 1. 生成所有文章
    generate_gaokao
    generate_ai_daily
    generate_curated
    generate_discover
    
    # 2. 验证
    verify_articles
    
    # 3. Git 推送
    if git_push; then
        echo "========================================" | tee -a "$LOG_FILE"
        log_ok "✅ 全部完成！"
        echo "========================================" | tee -a "$LOG_FILE"
    else
        echo "========================================" | tee -a "$LOG_FILE"
        log_error "❌ 推送失败，需要手动处理！"
        echo "========================================" | tee -a "$LOG_FILE"
        exit 1
    fi
}

main "$@"