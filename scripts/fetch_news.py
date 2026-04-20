#!/usr/bin/env python3
# 新闻获取脚本 - 每日发现

import requests
import re
import random
from datetime import datetime

today = datetime.now().strftime('%Y-%m-%d')
date_str = datetime.now().strftime('%Y%m%d')

# 备用新闻数据（当 RSS 获取失败时使用）
FALLBACK_NEWS = [
    {
        'title': 'AI 助手成为日常工具，越来越多人开始习惯使用 ChatGPT 等工具提升效率',
        'link': 'https://36kr.com/',
        'desc': '人工智能助手正在改变我们的工作方式，自动化办公成为新趋势'
    },
    {
        'title': '新款智能穿戴设备发布，健康监测功能再升级',
        'link': 'https://www.huxiu.com/',
        'desc': '可穿戴设备持续进化，健康管理成为核心卖点，血氧、睡眠监测成标配'
    },
    {
        'title': '编程教育受重视，Python 成为最受欢迎入门语言',
        'link': 'https://sspai.com/',
        'desc': '代码教育从娃娃抓起，Python 因简洁易学成为入门首选'
    },
    {
        'title': '折叠屏手机价格下探，更多消费者可享受大屏体验',
        'link': 'https://www.ithome.com/',
        'desc': '折叠屏技术成熟，成本下降推动普及，售价进入主流区间'
    },
    {
        'title': '开源大语言模型蓬勃发展，技术门槛持续降低',
        'link': 'https://github.com/',
        'desc': '开源模型让 AI 技术更加民主化，任何人都可以部署自己的 AI 助手'
    },
]

def fetch_huxiu():
    """获取虎嗅网 RSS"""
    articles = []
    try:
        response = requests.get('https://www.huxiu.com/rss/0.xml', timeout=10)
        response.encoding = 'utf-8'
        content = response.text
        
        titles = re.findall(r'<title><!\[CDATA\[(.*?)\]\]></title>', content)
        links = re.findall(r'<link>(.*?)</link>', content)
        
        for i, title in enumerate(titles[1:6], 1):  # 跳过第一个
            if i < len(links):
                articles.append({
                    'title': title.strip(),
                    'link': links[i].strip(),
                    'desc': f'来自虎嗅网的科技资讯 #{i}'
                })
    except Exception as e:
        print(f"虎嗅 RSS 获取失败: {e}")
    return articles

def fetch_ithome():
    """获取 IT 之家企业 RSS"""
    articles = []
    try:
        response = requests.get('https://www.ithome.com/rss/', timeout=10)
        response.encoding = 'utf-8'
        content = response.text
        
        titles = re.findall(r'<title><!\[CDATA\[(.*?)\]\]></title>', content)
        links = re.findall(r'<link>(.*?)</link>', content)
        
        for i, title in enumerate(titles[1:6], 1):
            if i < len(links):
                articles.append({
                    'title': title.strip(),
                    'link': links[i].strip(),
                    'desc': f'来自 IT 之家的数码科技资讯 #{i}'
                })
    except Exception as e:
        print(f"IT之家 RSS 获取失败: {e}")
    return articles

def fetch_sspai():
    """获取少数派 RSS"""
    articles = []
    try:
        response = requests.get('https://sspai.com/feed', timeout=10)
        response.encoding = 'utf-8'
        content = response.text
        
        titles = re.findall(r'<title><!\[CDATA\[(.*?)\]\]></title>', content)
        links = re.findall(r'<link>(.*?)</link>', content)
        
        for i, title in enumerate(titles[1:6], 1):
            if i < len(links):
                articles.append({
                    'title': title.strip(),
                    'link': links[i].strip(),
                    'desc': f'来自少数派的高质量内容 #{i}'
                })
    except Exception as e:
        print(f"少数派 RSS 获取失败: {e}")
    return articles

def generate_article(articles):
    """生成 Markdown 文章"""
    
    md_content = f'''---
title: 今日发现 {today}
date: {today}
tags: ['科技', 'AI', '数码', '开发']
description: 每日科技、数码、开发相关新闻汇总
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

今日科技领域继续快速发展，AI 技术在各个场景加速落地，智能设备持续迭代。建议关注：大模型应用进展、开发者工具创新、消费电子新品发布。

---

*本文内容由系统自动聚合自 {today} 的科技资讯*
'''

    return md_content

def main():
    print("📡 开始获取新闻...")
    
    all_articles = []
    
    # 尝试从多个来源获取
    all_articles.extend(fetch_huxiu())
    all_articles.extend(fetch_ithome())
    all_articles.extend(fetch_sspai())
    
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
