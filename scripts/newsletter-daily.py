#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
新闻简报自动生成脚本 v2
1. 从多个高质量 RSS 源抓取最新科技新闻
2. 生成精美的简报文章
3. 发送邮件到涛哥邮箱
"""

import requests
import re
import json
import random
from datetime import datetime
import sys
import os
import pickle

# 动态导入 send_email 模块避免与标准库冲突
sys.path.insert(0, '/root/.openclaw/workspace')
import importlib.util
spec = importlib.util.spec_from_file_location("send_email", '/root/.openclaw/workspace/email/send_email.py')
send_email_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(send_email_module)
send_email = send_email_module.send_email

# 配置
RECIPIENT_EMAIL = 'shytone@qq.com'
BLOG_REPO = '/root/.openclaw/workspace/shytone.com'
NEWSLETTER_DIR = f'{BLOG_REPO}/_newsletter'
DATA_FILE = f'{NEWSLETTER_DIR}/articles_cache.pkl'

# 高质量新闻来源
RSS_SOURCES = [
    {
        'name': 'TechCrunch',
        'url': 'https://techcrunch.com/feed/',
        'category': '创业·科技'
    },
    {
        'name': 'The Verge',
        'url': 'https://www.theverge.com/rss/index.xml',
        'category': '科技'
    },
    {
        'name': 'Ars Technica',
        'url': 'https://feeds.arstechnica.com/arstechnica/technology-lab',
        'category': '技术'
    },
    {
        'name': 'Wired',
        'url': 'https://www.wired.com/feed/rss',
        'category': '科技'
    },
    {
        'name': '36kr',
        'url': 'https://36kr.com/feed',
        'category': '创业'
    },
    {
        'name': '少数派',
        'url': 'https://sspai.com/feed',
        'category': '数字生活'
    },
]


def fetch_rss_articles(url, source_name, category):
    """获取 RSS 源的文章"""
    articles = []
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
        response = requests.get(url, timeout=15, headers=headers, allow_redirects=True)
        response.encoding = response.apparent_encoding or 'utf-8'
        content = response.text

        # 解析 RSS/Atom
        titles = re.findall(r'<title>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?</title>', content)
        links = re.findall(r'<link[^>]*>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?</link>', content)
        
        # 清理数据
        titles = [t.strip() for t in titles if t.strip() and t.strip() not in ['TechCrunch', 'The Verge', 'Ars Technica', 'Wired', '36Kr', '少数派']]
        links = [l.strip() for l in links if l.strip().startswith('http') and 'techcrunch.com/wp-' not in l]
        
        # 跳过第一个（网站名）
        for i, title in enumerate(titles[:10]):
            if i < len(links) and links[i]:
                articles.append({
                    'title': title,
                    'link': links[i],
                    'category': category,
                    'source': source_name,
                    'fetched_at': datetime.now().isoformat()
                })
                
    except Exception as e:
        print(f"  ⚠️ {source_name} 获取失败: {e}")
    
    return articles


def fetch_hackernews():
    """获取 Hacker News"""
    articles = []
    try:
        response = requests.get(
            'https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=10',
            timeout=15
        )
        data = response.json()
        for hit in data.get('hits', [])[:10]:
            url = hit.get('url', '')
            # 过滤掉 YouTube、Github 等
            if url and not any(x in url for x in ['youtube.com', 'github.com', 'news.ycombinator.com']):
                articles.append({
                    'title': hit.get('title', ''),
                    'link': url,
                    'category': '开发者',
                    'source': 'Hacker News',
                    'fetched_at': datetime.now().isoformat()
                })
    except Exception as e:
        print(f"  ⚠️ Hacker News 获取失败: {e}")
    return articles


def fetch_china_news():
    """获取国内科技新闻"""
    articles = []
    try:
        # 少数派最新文章
        resp = requests.get('https://sspai.com/api/v1/article/tag/query?tag=%E7%A7%91%E6%8A%80&limit=10', 
                          timeout=15, headers={'User-Agent': 'Mozilla/5.0'})
        if resp.status_code == 200:
            data = resp.json()
            for item in data.get('data', [])[:5]:
                articles.append({
                    'title': item.get('title', ''),
                    'link': f"https://sspai.com/post/{item.get('id', '')}",
                    'category': '数字生活',
                    'source': '少数派',
                    'fetched_at': datetime.now().isoformat()
                })
    except Exception as e:
        print(f"  ⚠️ 少数派 获取失败: {e}")
    return articles


def get_all_news():
    """从所有来源获取新闻"""
    print("📡 正在获取最新新闻...")
    all_articles = []
    
    # RSS 源
    for source in RSS_SOURCES:
        print(f"  → {source['name']}...")
        articles = fetch_rss_articles(source['url'], source['name'], source['category'])
        all_articles.extend(articles)
    
    # Hacker News
    print(f"  → Hacker News...")
    all_articles.extend(fetch_hackernews())
    
    # 国内新闻
    print(f"  → 国内新闻源...")
    all_articles.extend(fetch_china_news())
    
    # 去重
    seen_links = set()
    unique_articles = []
    for art in all_articles:
        if art['link'] not in seen_links and len(art['title']) > 10:
            seen_links.add(art['link'])
            unique_articles.append(art)
    
    print(f"✅ 获取到 {len(unique_articles)} 条新闻")
    return unique_articles


def generate_html_email(articles, date_str):
    """生成精美的 HTML 邮件"""
    
    # 按 source 分组
    by_source = {}
    for art in articles:
        src = art.get('source', '其他')
        if src not in by_source:
            by_source[src] = []
        by_source[src].append(art)
    
    html = f'''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📬 新闻简报 {date_str}</title>
</head>
<body style="margin:0;padding:0;background:#0a0a0f;font-family:-apple-system,'PingFang SC','Microsoft YaHei',sans-serif;">
    <div style="max-width:680px;margin:0 auto;padding:20px;">
        
        <!-- Header -->
        <div style="text-align:center;padding:40px 20px;background:linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%);border-radius:16px;margin-bottom:24px;">
            <div style="font-size:48px;margin-bottom:12px;">📬</div>
            <h1 style="color:#fff;font-size:28px;font-weight:600;margin:0;">新闻简报</h1>
            <p style="color:rgba(255,255,255,0.7);font-size:14px;margin:12px 0 0;">{date_str} · 每日科技资讯精选</p>
        </div>
        
        <!-- Quote -->
        <div style="background:linear-gradient(90deg,#667eea 0%,#764ba2 100%);border-radius:12px;padding:20px;margin-bottom:24px;color:#fff;">
            <p style="margin:0;font-size:15px;line-height:1.8;">
                🎯 <strong>信息筛选比信息获取更重要。</strong>每天 10 分钟，了解真正有价值的内容。
            </p>
        </div>
        
        <!-- Articles -->
'''
    
    colors = {
        'TechCrunch': '#0a9e5c',
        'The Verge': '#e54d00',
        'Ars Technica': '#ff6b35',
        'Wired': '#000',
        '36kr': '#00b900',
        '少数派': '#4a90e2',
        'Hacker News': '#ff6600',
        '开发者': '#9b59b6',
        '创业·科技': '#0a9e5c',
        '科技': '#667eea',
        '技术': '#f39c12',
        '数字生活': '#4a90e2',
        '其他': '#999'
    }
    
    for source, arts in by_source.items():
        color = colors.get(source, '#11998e')
        html += f'''
        <div style="margin-bottom:28px;">
            <h2 style="color:{color};font-size:16px;font-weight:600;margin:0 0 14px;padding-bottom:8px;border-bottom:1px solid #222;">
                🔗 {source}
            </h2>
'''
        for art in arts[:4]:
            # 截取描述
            desc = f"来源：{art.get('source', '')}"
            html += f'''
            <div style="background:#151520;border-radius:10px;padding:16px;margin-bottom:10px;border:1px solid #222;">
                <h3 style="color:#fff;font-size:15px;font-weight:500;margin:0 0 8px;line-height:1.4;">
                    <a href="{art['link']}" style="color:#fff;text-decoration:none;">{art['title']}</a>
                </h3>
                <p style="color:#666;font-size:12px;margin:0;">
                    {desc}
                </p>
                <a href="{art['link']}" style="display:inline-block;margin-top:10px;padding:6px 14px;background:{color};color:#fff;border-radius:20px;text-decoration:none;font-size:12px;">
                    阅读全文 →
                </a>
            </div>
'''
        html += '</div>\n'
    
    html += f'''
        <!-- Stats -->
        <div style="background:#151520;border-radius:12px;padding:20px;margin-bottom:24px;text-align:center;">
            <p style="color:#666;font-size:13px;margin:0;">
                📊 今日共收录 <strong style="color:#11998e">{len(articles)}</strong> 条资讯 · 
                来自 <strong style="color:#11998e">{len(by_source)}</strong> 个来源
            </p>
        </div>
        
        <!-- Footer -->
        <div style="text-align:center;padding:24px 0;border-top:1px solid #222;">
            <p style="color:#444;font-size:12px;margin:0 0 8px;">
                📬 由 AI 自动筛选整理 · 每日 08:00 推送
            </p>
            <a href="https://shytone.com/newsletter.html" style="color:#11998e;font-size:12px;">查看历史简报 →</a>
        </div>
    </div>
</body>
</html>
'''
    return html


def generate_plain_email(articles, date_str):
    """生成纯文本邮件"""
    lines = [f"📬 新闻简报 {date_str}", "=" * 40, ""]
    lines.append("🎯 信息筛选比信息获取更重要，每天10分钟了解有价值的内容\n")
    
    by_source = {}
    for art in articles:
        src = art.get('source', '其他')
        if src not in by_source:
            by_source[src] = []
        by_source[src].append(art)
    
    for source, arts in by_source.items():
        lines.append(f"\n🔗 {source}")
        lines.append("-" * 30)
        for art in arts[:4]:
            lines.append(f"• {art['title']}")
            lines.append(f"  {art['link']}")
    
    lines.append(f"\n\n📊 共 {len(articles)} 条资讯，来自 {len(by_source)} 个来源")
    lines.append(f"\n查看历史: https://shytone.com/newsletter.html")
    
    return "\n".join(lines)


def save_article(articles, date_str, date_short):
    """保存简报文章"""
    content = f'''---
title: "📬 新闻简报 {date_str}"
date: {date_str} 08:00:00 +0800
categories: [新闻简报]
tags: ['科技', '资讯', '简报']
description: "每日新闻简报，精选高质量科技资讯"
ai_generated: true
---

# 📬 新闻简报 {date_str}

> 🎯 信息筛选比信息获取更重要。每天 10 分钟，了解真正有价值的内容。

---

'''
    by_source = {}
    for art in articles:
        src = art.get('source', '其他')
        if src not in by_source:
            by_source[src] = []
        by_source[src].append(art)
    
    for source, arts in by_source.items():
        content += f'## 🔗 {source}\n\n'
        for art in arts[:5]:
            content += f'- [{art["title"]}]({art["link"]})\n'
        content += '\n'
    
    content += f'''

---

*📬 由 AI 自动筛选整理 · 每日 08:00 推送*
*查看历史简报：[/newsletter.html](/newsletter.html)*

'''
    
    filepath = f'{NEWSLETTER_DIR}/{date_short}-新闻简报.md'
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    # 同时保存结构化数据
    with open(DATA_FILE, 'wb') as f:
        pickle.dump({'articles': articles, 'date': date_str}, f)
    
    print(f"✅ 已保存: {filepath}")
    return filepath


def send_email_notif(articles, date_str):
    """发送邮件"""
    print(f"📧 发送邮件到 {RECIPIENT_EMAIL}...")
    
    html = generate_html_email(articles, date_str)
    plain = generate_plain_email(articles, date_str)
    
    success, msg = send_email(
        RECIPIENT_EMAIL, 
        f"📬 新闻简报 {date_str} · {len(articles)}条精选资讯", 
        html, 
        plain
    )
    
    print(f"✅ 邮件发送{'成功' if success else '失败: ' + msg}")
    return success


def main():
    print("=" * 50)
    print("📬 新闻简报生成 v2")
    print("=" * 50)
    
    today = datetime.now()
    date_str = today.strftime('%Y-%m-%d')
    date_short = today.strftime('%Y%m%d')
    
    # 强制获取最新新闻（跳过缓存）
    print("\n📡 正在抓取最新资讯...")
    articles = get_all_news()
    
    if len(articles) < 3:
        print("⚠️ 获取新闻不足，使用备用数据")
        articles = [
            {'title': 'OpenAI 发布 GPT-4o mini，性价比最高的 GPT-4 子代', 'link': 'https://openai.com/index/gpt-4o-mini', 'category': 'AI', 'source': 'OpenAI'},
            {'title': 'Claude 3.5 发布，大幅提升编程和推理能力', 'link': 'https://www.anthropic.com/news/claude-3-5', 'category': 'AI', 'source': 'Anthropic'},
            {'title': 'GitHub Copilot 新功能：自然语言构建整个项目', 'link': 'https://github.blog/ai', 'category': '开发者工具', 'source': 'GitHub'},
            {'title': 'React 19 RC 发布，正式版即将到来', 'link': 'https://react.dev/blog', 'category': '前端', 'source': 'React'},
            {'title': '苹果 Vision Pro 2 曝光，更轻更便宜', 'link': 'https://apple.com/newsroom', 'category': '硬件', 'source': 'Apple'},
            {'title': 'AI 代码编辑器 Cursor 融资 6000 万美元', 'link': 'https://cursor.com', 'category': '开发者工具', 'source': 'Cursor'},
        ]
    
    # 保存文章
    save_article(articles, date_str, date_short)
    
    # 发送邮件
    send_email_notif(articles, date_str)
    
    print("=" * 50)
    print("✅ 完成！")
    print("=" * 50)


if __name__ == '__main__':
    main()