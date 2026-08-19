#!/usr/bin/env bash
# =============================================================================
# 博客每日文章生成 - 统一调度脚本
# 
# 生成以下内容：
#   - 软考高项每日一题（_gaokao/）
#   - AI 日报（_ai-daily/）
#   - 精选文章（_ai-daily/）
#   - 今日发现（_discover/）
#   - 数学学习（_math/）
#   - 物理学习（_physics/）
#   - 算法讲解（_algorithms/）
#
# 完成后自动 git push
# =============================================================================

set -uo pipefail

REPO_DIR="/root/.openclaw/workspace/shytone.com"
LOG_FILE="/tmp/master-daily-$(date +%Y%m%d).log"

TODAY_DATE=$(date +%Y-%m-%d)
TODAY_SHORT=$(date +%Y%m%d)
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log()       { echo -e "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
log_ok()    { log "${GREEN}✓ $1${NC}"; }
log_warn()  { log "${YELLOW}⚠ $1${NC}"; }
log_error() { log "${RED}✗ $1${NC}"; }

# ---------------------------------------------------------------------------
# 1. 软考高项
# ---------------------------------------------------------------------------
run_gaokao() {
    log "生成软考高项每日一题..."
    cd "$REPO_DIR"
    if python3 scripts/exam-prep-gen.py >> "$LOG_FILE" 2>&1; then
        log_ok "软考高项完成"
    else
        log_warn "软考高项执行异常"
    fi
}

# ---------------------------------------------------------------------------
# 2. AI 日报 + 精选文章
# ---------------------------------------------------------------------------
run_ai_daily() {
    log "生成 AI 日报 + 精选文章..."
    local ai_file="$REPO_DIR/_ai-daily/${TODAY_DATE}-AI-今日资讯.md"
    local curated_file="$REPO_DIR/_ai-daily/${TODAY_DATE}-精选文章.md"

    if [ -f "$ai_file" ]; then
        log_ok "AI日报已存在，跳过"
    else
        cat > "$ai_file" << 'TPL'
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

TPL
        sed -i "s/DATE_PLACEHOLDER/$TODAY_DATE/g" "$ai_file"
        log_ok "AI日报生成完成"
    fi

    if [ -f "$curated_file" ]; then
        log_ok "精选文章已存在，跳过"
    else
        cat > "$curated_file" << 'TPL'
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

TPL
        sed -i "s/DATE_PLACEHOLDER/$TODAY_DATE/g" "$curated_file"
        log_ok "精选文章生成完成"
    fi
}

# ---------------------------------------------------------------------------
# 3. 今日发现
# ---------------------------------------------------------------------------
run_discover() {
    log "生成今日发现..."
    cd "$REPO_DIR"
    if python3 scripts/fetch_news.py >> "$LOG_FILE" 2>&1; then
        log_ok "今日发现完成"
    else
        log_warn "fetch_news.py 失败，使用默认内容"
        local discover_file="$REPO_DIR/_discover/${TODAY_SHORT}-今日发现.md"
        if [ ! -f "$discover_file" ]; then
            cat > "$discover_file" << TPL
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
TPL
            sed -i "s/DATE_PLACEHOLDER/$TODAY_DATE/g" "$discover_file"
        fi
    fi
}

# ---------------------------------------------------------------------------
# 4. 数学
# ---------------------------------------------------------------------------
run_math() {
    log "生成数学学习文章..."
    cd "$REPO_DIR"
    if python3 scripts/math-daily.sh >> "$LOG_FILE" 2>&1; then
        log_ok "数学完成"
    else
        log_warn "数学脚本执行异常"
    fi
}

# ---------------------------------------------------------------------------
# 5. 物理
# ---------------------------------------------------------------------------
run_physics() {
    log "生成物理学习文章..."
    cd "$REPO_DIR"
    if python3 scripts/physics-daily.sh >> "$LOG_FILE" 2>&1; then
        log_ok "物理完成"
    else
        log_warn "物理脚本执行异常"
    fi
}

# ---------------------------------------------------------------------------
# 6. 算法
# ---------------------------------------------------------------------------
run_algorithm() {
    log "生成算法专栏..."
    cd "$REPO_DIR"
    if python3 scripts/algorithm-daily.sh >> "$LOG_FILE" 2>&1; then
        log_ok "算法完成"
    else
        log_warn "算法脚本执行异常"
    fi
}

# ---------------------------------------------------------------------------
# Git push
# ---------------------------------------------------------------------------
git_push() {
    cd "$REPO_DIR"
    git add -A
    if git diff --cached --quiet; then
        log_warn "没有变更，跳过提交"
        return 0
    fi
    local msg="自动推送 $(date +%Y-%m-%d) 文章 $(date +%H:%M:%S)"
    git commit -m "$msg"
    for i in 1 2 3; do
        if git push origin main >> "$LOG_FILE" 2>&1; then
            log_ok "Git 推送成功"
            return 0
        fi
        log_warn "推送失败，重试 $i/3..."
        sleep 2
    done
    log_error "Git 推送失败（已重试3次）"
    return 1
}

# ---------------------------------------------------------------------------
# 主流程
# ---------------------------------------------------------------------------
main() {
    echo "========================================" | tee "$LOG_FILE"
    log "每日文章生成开始: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================" | tee -a "$LOG_FILE"

    run_gaokao
    run_ai_daily
    run_discover
    run_math
    run_physics
    run_algorithm

    echo "========================================" | tee -a "$LOG_FILE"
    log "开始 Git 推送..."
    if git_push; then
        log_ok "✅ 全部完成！"
    else
        log_error "❌ 推送失败，请检查"
    fi
    echo "========================================" | tee -a "$LOG_FILE"
}

main "$@"