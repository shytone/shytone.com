#!/bin/bash
# 每日自动创建并推送文章
# 使用方法: ./daily-article.sh

cd /root/.openclaw/workspace/shytone.com

TODAY=$(date +%m-%d)
TOMORROW_DATE=$(date -d "+1 day" +%Y-%m-%d)
TOMORROW_SHORT=$(date -d "+1 day" +%m-%d)

echo "=== $(date) ==="
echo "检查 $TOMORROW_SHORT 的文章..."

# 检查文章是否已存在
AI_FILE="_ai-daily/${TOMORROW_DATE}-AI-今日资讯.md"
ALGO_FILE="_algorithms/${TOMORROW_DATE}-*.md"

if ls $AI_FILE 1> /dev/null 2>&1; then
    echo "AI日报已存在，跳过创建"
else
    echo "需要创建 $TOMORROW_SHORT 的文章..."
    # TODO: 调用AI生成文章
    echo "请手动创建 $TOMORROW_SHORT 的文章"
fi

# 自动 commit + push
git add _ai-daily/ _algorithms/ 2>/dev/null
if git diff --cached --quiet; then
    echo "没有新内容需要推送"
else
    git commit -m "添加 $(date +%Y-%m-%d) 文章"
    git push origin main
    echo "已推送 $(date +%Y-%m-%d) 的文章"
fi
