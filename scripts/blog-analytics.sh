#!/bin/bash
# 博客访问量分析与优化脚本
# 每6小时执行一次，分析访问数据并优化博客内容

echo "📊 开始博客访问量分析..."
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 检查博客可访问性
check_site() {
    local url=$1
    local name=$2
    local status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [ "$status" = "200" ]; then
        echo "✅ $name: 正常 ($status)"
        return 0
    else
        echo "⚠️ $name: 异常 ($status)"
        return 1
    fi
}

# 检查各页面状态
echo ""
echo "🔍 检查页面可访问性..."
check_site "https://shytone.com/" "首页"
check_site "https://shytone.com/algorithms.html" "算法专栏"
check_site "https://shytone.com/ai-daily.html" "AI日刊"
check_site "https://shytone.com/discover.html" "发现"
check_site "https://shytone.com/relax.html" "摸鱼专区"
check_site "https://shytone.com/archive.html" "归档"
check_site "https://shytone.com/about.html" "关于"

# 检查 SEO 相关
echo ""
echo "🔍 检查 SEO 状态..."
robots_txt=$(curl -s -o /dev/null -w "%{http_code}" "https://shytone.com/robots.txt")
sitemap=$(curl -s -o /dev/null -w "%{http_code}" "https://shytone.com/sitemap.xml")
ads_txt=$(curl -s -o /dev/null -w "%{http_code}" "https://shytone.com/ads.txt")

[ "$robots_txt" = "200" ] && echo "✅ robots.txt: 正常" || echo "⚠️ robots.txt: 异常"
[ "$sitemap" = "200" ] && echo "✅ sitemap.xml: 正常" || echo "⚠️ sitemap.xml: 异常"
[ "$ads_txt" = "200" ] && echo "✅ ads.txt: 正常" || echo "⚠️ ads.txt: 异常"

# 检查新内容
echo ""
echo "📝 检查内容更新..."
algorithms_count=$(ls /root/.openclaw/workspace/shytone.com/_algorithms/*.md 2>/dev/null | wc -l)
ai_daily_count=$(ls /root/.openclaw/workspace/shytone.com/_ai-daily/*.md 2>/dev/null | wc -l)
discover_count=$(ls /root/.openclaw/workspace/shytone.com/_discover/*.md 2>/dev/null | wc -l)

echo "📚 算法专栏文章: $algorithms_count 篇"
echo "🤖 AI日刊文章: $ai_daily_count 篇"
echo "🔍 发现文章: $discover_count 篇"

# 内容优化建议
echo ""
echo "💡 优化建议:"

# 检查是否需要更新内容
if [ "$algorithms_count" -lt 7 ]; then
    echo "• 算法专栏文章较少，建议持续更新算法内容"
fi

if [ "$ai_daily_count" -lt 3 ]; then
    echo "• AI日刊建议每日更新，保持内容新鲜度"
fi

# 检查首页优化
index_content=$(curl -s "https://shytone.com/" 2>/dev/null)
if echo "$index_content" | grep -q "hero"; then
    echo "✅ 首页英雄区域已配置"
else
    echo "⚠️ 首页可能需要优化"
fi

echo ""
echo "📊 分析完成!"
echo "提示: 访问量提升需要持续输出优质内容 + SEO优化 + 社交流量"
