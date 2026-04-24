#!/bin/bash
# 博客每日审查脚本 v2.1
# 功能：可访问性 | SEO | 内容 | 性能 | 死链 | 异常告警

HOST="https://shytone.com"
ALERT_THRESHOLD_ARTICLES=1
MAX_RETRIES=2

log_ok()  { echo "[OK]    $*"; }
log_warn(){ echo "[WARN]  $*"; }
log_err() { echo "[ERROR] $*"; }
log_info(){ echo "  $*"; }

# ── HTTP 检查（带重试）──────────────────────────────────────────────
curl_status() {
  local url=$1
  for i in $(seq 1 $MAX_RETRIES); do
    local code=$(curl -o /dev/null -s -w "%{http_code}" --max-time 10 "$url" 2>/dev/null)
    [ "$code" != "000" ] && echo "$code" && return 0
    [ $i -lt $MAX_RETRIES ] && sleep 1
  done
  echo "000"
}

curl_time() {
  curl -o /dev/null -s -w "%{time_total}" --max-time 10 "$1" 2>/dev/null || echo "9.99"
}

# ── 主流程 ──────────────────────────────────────────────────────────
echo "开始博客每日审查..."
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

ACCESS_ISSUES=0
SLOW_PAGES=0

# 1. 页面可访问性 + 加载时间
echo "检查页面可访问性与加载时间..."
PAGES=(
  "/:首页"
  "/algorithms.html:算法专栏"
  "/ai-daily.html:AI日刊"
  "/discover.html:发现"
  "/relax.html:摸鱼专区"
  "/archive.html:归档"
  "/about.html:关于"
  "/robots.txt:robots.txt"
  "/sitemap.xml:sitemap.xml"
)

for entry in "${PAGES[@]}"; do
  url="${entry%%:*}"
  name="${entry##*:}"
  status=$(curl_status "${HOST}${url}")
  time_total=$(curl_time "${HOST}${url}")
  time_ms=$(echo "$time_total * 1000" | bc 2>/dev/null | cut -d. -f1)

  if [ "$status" = "200" ]; then
    if [ "${time_ms:-999}" -lt 1000 ]; then
      log_ok "${name}: 正常 - ${time_ms}ms"
    elif [ "${time_ms:-999}" -lt 3000 ]; then
      log_warn "${name}: 正常 - ${time_ms}ms (偏慢，GitHub Pages正常波动)"
      SLOW_PAGES=$((SLOW_PAGES + 1))
    else
      log_err "${name}: 正常 - ${time_ms}ms (过慢)"
      SLOW_PAGES=$((SLOW_PAGES + 1))
    fi
  else
    log_err "${name}: 异常 (${status})"
    ACCESS_ISSUES=$((ACCESS_ISSUES + 1))
  fi
done

# 2. SEO 检查
echo ""
echo "检查 SEO 状态..."
SEO_OK=0
check_seo() {
  local label=$1; local path=$2
  local code=$(curl_status "${HOST}${path}")
  if [ "$code" = "200" ]; then
    log_ok "${label}: 正常"
    SEO_OK=$((SEO_OK + 1))
  else
    log_err "${label}: 异常 (${code})"
  fi
}
check_seo "sitemap.xml" "/sitemap.xml"
check_seo "robots.txt"   "/robots.txt"
check_seo "ads.txt"      "/ads.txt"
check_seo "feed.xml"     "/feed.xml"

sitemap_urls=$(curl -s --max-time 10 "${HOST}/sitemap.xml" 2>/dev/null | grep -oP '(?<=<loc>)[^<]+' | wc -l)
log_info "sitemap.xml 包含 ${sitemap_urls} 个 URL"

# 3. 内容统计
echo ""
echo "检查内容更新..."

count_md() {
  ls "$1"/*.md 2>/dev/null | grep -v README | wc -l
}

algo_count=$(count_md "/root/.openclaw/workspace/shytone.com/_algorithms")
ai_count=$(count_md "/root/.openclaw/workspace/shytone.com/_ai-daily")
disc_count=$(count_md "/root/.openclaw/workspace/shytone.com/_discover")
post_count=$(count_md "/root/.openclaw/workspace/shytone.com/_posts")

log_info "算法专栏: ${algo_count} 篇"
log_info "AI日刊:  ${ai_count} 篇"
log_info "发现:     ${disc_count} 篇"
log_info "博客文章: ${post_count} 篇"

CONTENT_ALERTS=""
if [ "$algo_count" -le "$ALERT_THRESHOLD_ARTICLES" ]; then
  log_warn "算法专栏文章过少 (${algo_count}篇)，建议更新"
  CONTENT_ALERTS="${CONTENT_ALERTS}算法专栏文章过少；"
fi
if [ "$ai_count" -le 1 ]; then
  log_warn "AI日刊内容偏少 (${ai_count}篇)"
  CONTENT_ALERTS="${CONTENT_ALERTS}AI日刊内容偏少；"
fi

latest_post=$(ls -t /root/.openclaw/workspace/shytone.com/_algorithms/*.md /root/.openclaw/workspace/shytone.com/_ai-daily/*.md /root/.openclaw/workspace/shytone.com/_discover/*.md 2>/dev/null | head -1)
if [ -n "$latest_post" ]; then
  latest_epoch=$(stat -c %Y "$latest_post" 2>/dev/null || echo $(date +%s))
  days_since=$(( ($(date +%s) - latest_epoch) / 86400 ))
  log_info "最新内容: ${days_since}天前 ($(basename "$latest_post"))"
  if [ "$days_since" -ge 3 ]; then
    log_warn "内容超过 ${days_since} 天未更新"
    CONTENT_ALERTS="${CONTENT_ALERTS}内容${days_since}天未更新；"
  fi
fi

# 4. 死链检测（仅抽检首页15个链接）
echo ""
echo "检查内部死链（抽样首页）..."

BROKEN=0
html=$(curl -s --max-time 15 "${HOST}/" 2>/dev/null)
links=$(echo "$html" | grep -oP '(?<=href=")[^"#]*\.html(?:\\?[^\"]*)?' | grep '^/' | sort -u | head -15)
for link in $links; do
  status=$(curl_status "${HOST}${link}")
  if [ "$status" != "200" ]; then
    log_warn "死链: ${link} -> ${status}"
    BROKEN=$((BROKEN + 1))
  fi
done
[ "$BROKEN" = "0" ] && log_ok "未发现死链 (抽样检查15个链接)"

# 5. SEO 标签检查
echo ""
echo "检查关键词 SEO..."

index_html=$(curl -s --max-time 10 "${HOST}/" 2>/dev/null)
title=$(echo "$index_html" | grep -oP '(?<=<title>)[^<]+' | head -1)
desc=$(echo "$index_html" | grep -oP '(?<=name="description" content=")[^"]+' | head -1)
log_info "首页标题: ${title:-未找到}"
log_info "描述: ${desc:-未找到}"

if [ -n "$(echo "$index_html" | grep 'og:title')" ]; then
  log_ok "Open Graph 标签已配置"
else
  log_warn "建议添加 Open Graph 社交分享标签"
fi

# 6. GitHub 构建状态
echo ""
echo "检查构建状态..."
build_status=$(curl_status "https://api.github.com/repos/shytone/shytone.com/actions/runs?per_page=1")
if [ "$build_status" = "200" ]; then
  log_ok "GitHub Actions: 可访问"
else
  log_warn "GitHub Actions: 无法访问 (${build_status})"
fi

# 7. 优化建议
echo ""
echo "优化建议:"

if [ "$ACCESS_ISSUES" -gt 0 ]; then
  log_err "有 ${ACCESS_ISSUES} 个页面无法访问，请优先处理"
fi

if [ "$algo_count" -lt 7 ]; then
  log_info "算法专栏建议每周更新2-3篇，目标7篇以上"
fi
if [ "$ai_count" -lt 5 ]; then
  log_info "AI日刊建议每日更新1篇，保持5篇以上"
fi
if [ "${sitemap_urls:-0}" -lt 5 ]; then
  log_info "sitemap.xml URL数量偏少，请检查生成配置"
fi

log_info "继续坚持高质量内容输出 + 社交媒体引流"
log_info "可考虑添加百度搜索资源平台 / Google Search Console 统计"

# 8. 汇总报告
echo ""
echo "========================================"
echo "博客每日审查报告"
echo "========================================"
echo "可访问性: ${ACCESS_ISSUES} 个无法访问 | ${SLOW_PAGES} 个慢速页面"
echo "SEO: ${SEO_OK}/4 项通过"
echo "算法: ${algo_count}篇 | AI日刊: ${ai_count}篇 | 发现: ${disc_count}篇 | 文章: ${post_count}篇"
echo "死链: ${BROKEN} 个"
echo "最新内容: ${latest_post:+$(basename $latest_post)}"
echo "告警: ${CONTENT_ALERTS:-无}"
echo "========================================"

# 退出码：真正无法访问的页面才算问题
[ "$ACCESS_ISSUES" -gt 0 ] || [ -n "$CONTENT_ALERTS" ] && exit 1
exit 0
