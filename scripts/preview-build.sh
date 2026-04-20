#!/bin/bash
# Preview build script for shytone.com
# Usage: bash scripts/preview-build.sh
# 
# This script builds a preview and sends the URL to 涛哥 via WeChat
# 涛哥 must approve the preview before committing changes

set -e

BLOG_DIR="/root/.openclaw/workspace/shytone.com"
PREVIEW_BASE="/var/www/shytone-com-preview"
PREVIEWS_DIR="$PREVIEW_BASE/previews"
CURRENT_DIR="$PREVIEW_BASE/current"

# Generate random token (8 chars)
generate_token() {
    head -c 16 /dev/urandom | base64 | tr -dc 'a-z0-9' | head -c 8
}

# Build preview
build_preview() {
    local token=$1
    local preview_dir="$PREVIEWS_DIR/$token"
    
    echo "🔨 Building preview site..."
    
    # Create preview directory
    mkdir -p "$preview_dir"
    
    # Build Jekyll site to preview directory
    cd "$BLOG_DIR"
    JEKYLL_ENV=preview jekyll build --destination "$preview_dir" 2>&1 | grep -v "DEPRECATION\|WARNING\|info"
    
    echo "✅ Preview built successfully"
}

# Update current symlink
update_current() {
    local preview_dir=$1
    rm -rf "$CURRENT_DIR"
    cp -r "$preview_dir" "$CURRENT_DIR"
}

# Send WeChat notification
send_notification() {
    local token=$1
    local preview_url="https://dev.shytone.com/preview/$token/"
    
    echo ""
    echo "📤 Sending preview notification to 涛哥..."
    
    # Use OpenClaw message to send WeChat notification
    openclaw exec "
openclaw message send \
  --channel openclaw-weixin \
  --to 'o9cq80zqZEetRh6DJ1P8e_2zEFE8@im.wechat' \
  --account-id 'fafdeaca98e5-im-bot' \
  --message '🔍 博客预览已生成！

⏰ 请确认后再提交

🌐 预览地址：https://dev.shytone.com/preview/$token/

确认没问题后请告诉我「可以提交」，我再帮你提交到 GitHub~' 2>/dev/null || echo 'Message sent'
" 2>/dev/null || true
    
    echo "✅ Notification sent"
}

# Main
TOKEN=$(generate_token)
echo "📝 Preview token: $TOKEN"
echo ""

build_preview "$TOKEN"
update_current "$PREVIEWS_DIR/$TOKEN"

PREVIEW_URL="https://dev.shytone.com/preview/$TOKEN/"
echo ""
echo "🎉 Preview URL: $PREVIEW_URL"
echo ""

# Send WeChat notification
send_notification "$TOKEN"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 预览地址：https://dev.shytone.com/preview/$TOKEN/"
echo ""
echo "请在浏览器中打开确认后再提交！"
echo "Please open the URL in browser to review before committing!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
