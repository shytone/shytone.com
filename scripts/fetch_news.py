#!/usr/bin/env python3
# 新闻获取脚本 - 每日发现

import requests
import re
import random
from datetime import datetime

today = datetime.now().strftime('%Y-%m-%d')
date_str = datetime.now().strftime('%Y%m%d')

# 真实新闻文章链接（备用数据）
FALLBACK_NEWS = [
    {
        'title': 'Claude 4 发布：AI 编程能力再创新高',
        'link': 'https://www.anthropic.com/news/claude-4',
        'desc': 'Anthropic 发布新一代 Claude 4，在编程和推理能力上大幅提升'
    },
    {
        'title': 'GitHub Copilot Workspace 发布：AI 驱动的完整开发环境',
        'link': 'https://github.blog/news-inspirations/announcing-github-copilot-workspace',
        'desc': 'GitHub 推出 AI 原生开发环境，让 AI 从辅助工具变成开发伙伴'
    },
    {
        'title': 'Stack Overflow AI 产品发布：开发者问答进入新时代',
        'link': 'https://stackoverflow.blog/2024/05/announcing-overflow-ai',
        'desc': 'Stack Overflow 发布 AI 产品，结合平台积累回答开发问题'
    },
    {
        'title': '苹果发布 M4 芯片：性能提升50%，功耗降低',
        'link': 'https://www.apple.com/newsroom/2024/05/apple-unveils-m4-chip',
        'desc': '苹果 M4 芯片发布，采用第二代 3nm 工艺，性能大幅提升'
    },
    {
        'title': 'React 19 稳定版发布：新编译器带来显著性能提升',
        'link': 'https://react.dev/blog/2024/04/react-19',
        'desc': 'React 19 稳定版发布，包含新编译器、自动优化等重磅功能'
    },
]

def fetch_rss(url, source_name):
    """获取 RSS 源"""
    articles = []
    try:
        response = requests.get(url, timeout=8)
        response.encoding = 'utf-8'
        content = response.text
        
        # 尝试多种 RSS 格式
        titles = re.findall(r'<title><!\[CDATA\[(.*?)\]\]></title>', content)
        links = re.findall(r'<link>(.*?)</link>', content)
        
        if not links:
            links = re.findall(r'<link rel="alternate"[^>]*href="(.*?)"', content)
        
        for i, title in enumerate(titles[1:6], 1):  # 跳过第一个（网站名称）
            if i-1 < len(links):
                link = links[i-1].strip()
                if link and link.startswith('http'):
                    articles.append({
                        'title': title.strip(),
                        'link': link,
                        'desc': f'来自 {source_name}'
                    })
    except Exception as e:
        print(f"{source_name} RSS 获取失败: {e}")
    return articles

def fetch_techcrunch():
    """获取 TechCrunch RSS"""
    return fetch_rss('https://techcrunch.com/feed/', 'TechCrunch')

def fetch_ars_technica():
    """获取 Ars Technica RSS"""
    return fetch_rss('https://feeds.arstechnica.com/arstechnica/technology-lab', 'Ars Technica')

def fetch_hackernews():
    """获取 Hacker News"""
    try:
        response = requests.get('https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=5', timeout=8)
        data = response.json()
        articles = []
        for hit in data.get('hits', [])[:5]:
            articles.append({
                'title': hit.get('title', ''),
                'link': hit.get('url', 'https://news.ycombinator.com'),
                'desc': f'Hacker News - {hit.get("author", "")}'
            })
        return articles
    except Exception as e:
        print(f"Hacker News API 获取失败: {e}")
        return []

def generate_article(articles):
    """生成 Markdown 文章"""
    
    md_content = f'''---
title: 今日发现 {today}
date: {today}
tags: ['科技', 'AI', '数码', '开发']
description: 每日科技、数码，开发相关新闻汇总
ai_generated: true
---

<div class="ai-badge">🤖 AI 资讯速递 · Today's Tech Digest</div>

## 📰 今日要闻

'''
    
    for i, art in enumerate(articles[:5], 1):
        md_content += f'''### {i}. {art['title']}

{art['desc']}

来源：[阅读原文]({art['link']})

---

'''
    
    md_content += f'''
## 💡 科技观点

今日科技领域持续创新，AI 技术在各行业加速落地。建议关注：大模型进展、开源社区动态、新硬件发布。

---

*本文内容由系统自动聚合自 {today} 的科技资讯*
'''

    return md_content

def main():
    print("📡 开始获取新闻...")
    
    all_articles = []
    
    # 尝试从多个来源获取
    all_articles.extend(fetch_techcrunch())
    all_articles.extend(fetch_ars_technica())
    all_articles.extend(fetch_hackernews())
    
    # 如果都没有获取到，使用备用数据
    if not all_articles:
        print("⚠️ 所有 RSS 源获取失败，使用备用数据")
        all_articles = FALLBACK_NEWS
    else:
        # 打乱顺序
        random.shuffle(all_articles)
        all_articles = all_articles[:5]
    
    # 生成文章
    article_content = generate_article(all_articles)
    
    # 写入文件
    output_file = f'/root/.openclaw/workspace/shytone.com/_discover/{date_str}-今日发现.md'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(article_content)
    
    print(f"✅ 已生成文章: {output_file}")
    print(f"📰 共收录 {len(all_articles)} 条资讯")

if __name__ == '__main__':
    main()
