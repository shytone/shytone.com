#!/usr/bin/env python3
"""Fix xiuxian state: normalize exp overflow with looping realm upgrade."""
import json, os
from datetime import datetime, timedelta

REPO_DIR = "/root/.openclaw/workspace/shytone.com"
STATUS_FILE = REPO_DIR + "/_xiuxian/.status.json"

REALMS = [
    ("炼气一重", 0), ("炼气二重", 100), ("炼气三重", 200),
    ("炼气四重", 300), ("炼气五重", 400), ("炼气六重", 500),
    ("炼气七重", 600), ("炼气八重", 700), ("炼气九重", 800),
    ("筑基一重", 1000)
]

with open(STATUS_FILE) as f:
    s = json.load(f)

print(f"Before fix: day={s['day']} level={s['cultivation_level']} exp={s['cultivation_exp']}/{s['max_cultivation_exp']}")

# Normalize exp: subtract max_exp until exp < max_exp
overflow_count = s["cultivation_exp"] // s["max_cultivation_exp"]
s["cultivation_exp"] = s["cultivation_exp"] % s["max_cultivation_exp"]
print(f"  Overflowed by {overflow_count} realm(s), residual exp={s['cultivation_exp']}")

# Find current realm index
current_idx = next((i for i, (n, _) in enumerate(REALMS) if n == s["cultivation_level"]), 0)
print(f"  Current realm index: {current_idx} ({s['cultivation_level']})")

# Apply realm upgrades for each overflow
for _ in range(overflow_count):
    if current_idx < len(REALMS) - 1:
        current_idx += 1
        old_lv, new_lv = REALMS[current_idx - 1][0], REALMS[current_idx][0]
        s["cultivation_level"] = REALMS[current_idx][0]
        s["max_life"] += 10
        s["life"] = s["max_life"]
        s["max_spirit"] += 5
        s["spirit"] = s["max_spirit"]
        print(f"  🌟 Realm突破: {old_lv} → {new_lv}")

# Additional check: if exp is now >= max_exp (shouldn't happen, but safety check)
# Loop until exp < max_exp
loop_count = 0
while s["cultivation_exp"] >= s["max_cultivation_exp"] and current_idx < len(REALMS) - 1:
    s["cultivation_exp"] -= s["max_cultivation_exp"]
    current_idx += 1
    old_lv, new_lv = REALMS[current_idx - 1][0], REALMS[current_idx][0]
    s["cultivation_level"] = REALMS[current_idx][0]
    s["max_life"] += 10
    s["life"] = s["max_life"]
    s["max_spirit"] += 5
    s["spirit"] = s["max_spirit"]
    print(f"  🌟 Extra突破: {old_lv} → {new_lv}")
    loop_count += 1
    if loop_count > 10:
        print("  Safety stop - too many loops!")
        break

print(f"After fix: day={s['day']} level={s['cultivation_level']} exp={s['cultivation_exp']}/{s['max_cultivation_exp']}")

with open(STATUS_FILE, 'w') as f:
    json.dump(s, f, ensure_ascii=False, indent=2)
print("Status saved.")
