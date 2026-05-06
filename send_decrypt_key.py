#!/usr/bin/env python3
"""
send_decrypt_key.py — 每日加密密钥推送
每天定时运行，计算当日密钥并邮件发送

Usage: python3 send_decrypt_key.py
"""
import os
import sys
from datetime import date, datetime

# Add email module path
sys.path.insert(0, '/root/.openclaw/workspace/email')
from send_email import send_email

# ============== 配置 ==============
MASTER_KEY_FILE = '/root/.openclaw/encrypt_key.txt'  # master_key 存储位置（不在 GitHub）
EMAIL_FROM       = 'aiwuxt@qq.com'
EMAIL_TO         = 'shytone@qq.com'
GITHUB_PAT_FILE  = '/root/.openclaw/github_pat.txt'   # GitHub PAT（用于触发 workflow_dispatch）

# GitHub repo info
GITHUB_REPO = 'shytone/shytone.com'
WORKFLOW_ID = 'build.yml'
# ================================

def compute_daily_key(master_key: str, target_date: str = None) -> str:
    """
    计算当日密钥：HMAC-SHA256(master_key, date).hexdigest()[:32]
    与 GitHub Build 中的算法保持一致
    """
    import hmac
    import hashlib
    if target_date is None:
        target_date = date.today().strftime('%Y-%m-%d')
    return hmac.new(
        master_key.encode('utf-8'),
        target_date.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()[:32]

def get_master_key() -> str:
    """从本地文件读取 master_key"""
    path = os.path.expanduser(MASTER_KEY_FILE)
    if not os.path.exists(path):
        raise FileNotFoundError(f'Master key not found at {path}. Please create it.')
    with open(path, 'r', encoding='utf-8') as f:
        key = f.read().strip()
    if not key:
        raise ValueError('Master key is empty')
    return key

def trigger_github_rebuild(key: str) -> bool:
    """通过 GitHub API 触发 workflow_dispatch（传入当日密钥）"""
    pat_path = os.path.expanduser(GITHUB_PAT_FILE)
    if not os.path.exists(pat_path):
        print('[WARN] GitHub PAT not found, skipping rebuild trigger')
        return False
    with open(pat_path, 'r') as f:
        pat = f.read().strip()

    import urllib.request
    import json

    url = f'https://api.github.com/repos/{GITHUB_REPO}/actions/workflows/{WORKFLOW_ID}/dispatches'
    payload = {
        'ref': 'main',
        'inputs': {'encrypt_key': key}
    }
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode('utf-8'),
        headers={
            'Authorization': f'token {pat}',
            'Accept': 'application/vnd.github+json',
            'Content-Type': 'application/json'
        },
        method='POST'
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            if resp.status in (200, 204):
                print(f'[OK] GitHub rebuild triggered for {GITHUB_REPO}')
                return True
            else:
                print(f'[WARN] GitHub API returned {resp.status}')
                return False
    except Exception as e:
        print(f'[WARN] Failed to trigger GitHub rebuild: {e}')
        return False

def main():
    today = date.today()
    today_str = today.strftime('%Y-%m-%d')

    print(f'[{datetime.now():%H:%M:%S}] Computing daily key for {today_str}...')

    master_key = get_master_key()
    daily_key  = compute_daily_key(master_key, today_str)

    # 邮件内容（中英双语）
    subject = f'📧 每日文章密钥 / Daily Key — {today_str}'
    html_body = f"""
    <h2>🔑 今日密钥 / Today's Key</h2>
    <p style="font-size:1.4em; font-family:monospace; background:#f0f0f0; padding:12px 16px; border-radius:8px; display:inline-block;">
    <strong>{daily_key}</strong>
    </p>
    <h3 lang="zh">📖 使用说明</h3>
    <p lang="zh" style="color:#555;">访问加密文章时，在解锁框中输入上方密钥即可查看内容。密钥每日 00:00 更新。</p>
    <h3 lang="en" style="display:none">📖 How to Use</h3>
    <p lang="en" style="display:none;color:#555;">Enter the key above in the unlock box when visiting encrypted articles. Key renews daily at 00:00.</p>
    <hr style="margin:20px 0;">
    <p style="color:#888; font-size:0.85em;" lang="zh">
    此密钥由 master_key 派生：HMAC-SHA256(master_key, {today_str}).hexdigest()[:32]<br>
    如有疑问请联系你的 AI 助手。
    </p>
    <p style="color:#888; font-size:0.85em; display:none;" lang="en">
    Key derived from master_key: HMAC-SHA256(master_key, {today_str}).hexdigest()[:32]<br>
    Contact your AI assistant if you have questions.
    </p>
    """

    print(f'[SEND] Sending email to {EMAIL_TO}...')
    success = send_email(EMAIL_TO, subject, html_body)
    if success:
        print('[OK] Email sent successfully')
    else:
        print('[FAIL] Email send failed')
        sys.exit(1)

    # 触发 GitHub rebuild（传入当日密钥）
    trigger_github_rebuild(daily_key)

    print(f'[DONE] {today_str} key operations complete')

if __name__ == '__main__':
    main()