#!/bin/bash
# 每日发现文章自动生成脚本

BLOG_DIR="/root/.openclaw/workspace/shytone.com"
PREVIEW_DIR="/var/www/shytone-com-preview/previews/2ftjl0s2"
DATE=$(date +%Y%m%d)
TODAY=$(date +%Y-%m-%d)

echo "🔍 正在获取今日科技资讯..."

python3 /root/.openclaw/workspace/shytone.com/scripts/fetch_news.py

echo "🔨 正在构建预览..."
cd $BLOG_DIR
JEKYLL_ENV=preview jekyll build --destination $PREVIEW_DIR 2>&1 | grep -v "WARNING\|DEPRECATION" | tail -3

echo "✅ 每日发现更新完成！"