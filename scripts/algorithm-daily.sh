#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
算法专栏自动生成脚本
每日生成两篇文章：
1. 算法讲解文章（从基础到复杂）
2. 精选算法文章
"""

import os
import json
import random
from datetime import datetime, timedelta

# 算法列表 - 从简单到复杂
ALGORITHMS = [
    {
        "name": "二分查找",
        "name_en": "Binary Search",
        "difficulty": "简单",
        "difficulty_en": "Easy",
        "category": "查找",
        "category_en": "Search",
        "description": "二分查找是一种在有序数组中查找目标元素的搜索算法。",
        "description_en": "Binary search is a search algorithm that finds the position of a target value within a sorted array.",
        "principle": "通过比较数组中间元素与目标值，每次将搜索范围缩小一半。",
        "principle_en": "By comparing the middle element with the target, the search range is halved each time.",
        "time_complexity": "O(log n)",
        "space_complexity": "O(1)",
        "code": '''def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    while left <= right:
        mid = (left + right) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1''',
        "code_language": "python",
        "example": "在有序数组 [1,3,5,7,9,11,13] 中查找 7，返回索引 3。",
        "example_en": "Searching for 7 in sorted array [1,3,5,7,9,11,13], returns index 3.",
        "scenarios": ["排序数组搜索", "确定性问题", "近似查找"],
        "scenarios_en": ["Sorted array search", "Deterministic problems", "Approximate search"]
    },
    {
        "name": "冒泡排序",
        "name_en": "Bubble Sort",
        "difficulty": "简单",
        "difficulty_en": "Easy",
        "category": "排序",
        "category_en": "Sorting",
        "description": "冒泡排序是一种简单的排序算法，通过相邻元素的比较和交换将最大（或最小）的元素逐步冒泡到序列的一端。",
        "description_en": "Bubble sort is a simple sorting algorithm that repeatedly steps through the list, compares adjacent elements and swaps them if they are in the wrong order.",
        "principle": "重复遍历数组，比较相邻元素，大的往后冒泡。优化版本可在提前排好序时停止。",
        "principle_en": "Repeatedly traverse the array, comparing adjacent elements and bubbling the larger one to the end. The optimized version stops early when no swaps are needed.",
        "time_complexity": "O(n²)",
        "space_complexity": "O(1)",
        "code": '''def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        swapped = False
        for j in range(0, n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
                swapped = True
        if not swapped:
            break
    return arr''',
        "code_language": "python",
        "example": "数组 [64, 34, 25, 12, 22, 11] 排序后为 [11, 12, 22, 25, 34, 64]。",
        "example_en": "Array [64, 34, 25, 12, 22, 11] becomes [11, 12, 22, 25, 34, 64] after sorting.",
        "scenarios": ["教学理解", "小规模数据排序", "检查是否已排序"],
        "scenarios_en": ["Educational purposes", "Small datasets", "Checking if already sorted"]
    },
    {
        "name": "快速排序",
        "name_en": "Quick Sort",
        "difficulty": "中等",
        "difficulty_en": "Medium",
        "category": "排序",
        "category_en": "Sorting",
        "description": "快速排序是一种高效的分治排序算法，采用递归和分区策略。",
        "description_en": "Quick sort is an efficient divide-and-conquer sorting algorithm using recursion and partitioning.",
        "principle": "选择一个基准元素，将数组分为两部分，小于基准的在左，大于基准的在右，递归排序两部分。",
        "principle_en": "Select a pivot element, partition the array into two parts - elements less than pivot on left, greater on right, then recursively sort both parts.",
        "time_complexity": "O(n log n)",
        "space_complexity": "O(log n)",
        "code": '''def quick_sort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quick_sort(left) + middle + quick_sort(right)''',
        "code_language": "python",
        "example": "数组 [3, 6, 8, 10, 1, 2, 1] 排序后为 [1, 1, 2, 3, 6, 8, 10]。",
        "example_en": "Array [3, 6, 8, 10, 1, 2, 1] becomes [1, 1, 2, 3, 6, 8, 10] after sorting.",
        "scenarios": ["大规模数据排序", "需要稳定性能", "原地排序需求"],
        "scenarios_en": ["Large datasets", "Requiring stable performance", "In-place sorting requirements"]
    },
    {
        "name": "归并排序",
        "name_en": "Merge Sort",
        "difficulty": "中等",
        "difficulty_en": "Medium",
        "category": "排序",
        "category_en": "Sorting",
        "description": "归并排序是采用分治策略的稳定排序算法，将数组递归分成小数组，排序后合并。",
        "description_en": "Merge sort is a stable sorting algorithm using divide-and-conquer, splitting arrays recursively, sorting, then merging.",
        "principle": "递归地将数组分成两半，分别排序后合并成一个有序数组。",
        "principle_en": "Recursively split the array into two halves, sort each half, then merge them into a single sorted array.",
        "time_complexity": "O(n log n)",
        "space_complexity": "O(n)",
        "code": '''def merge_sort(arr):
    if len(arr) <= 1:
        return arr
    mid = len(arr) // 2
    left = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])
    return merge(left, right)

def merge(left, right):
    result = []
    i = j = 0
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    result.extend(left[i:])
    result.extend(right[j:])
    return result''',
        "code_language": "python",
        "example": "数组 [38, 27, 43, 3, 9, 82, 10] 排序后为 [3, 9, 10, 27, 38, 43, 82]。",
        "example_en": "Array [38, 27, 43, 3, 9, 82, 10] becomes [3, 9, 10, 27, 38, 43, 82] after sorting.",
        "scenarios": ["外部排序", "链表排序", "需要稳定排序"],
        "scenarios_en": ["External sorting", "Linked list sorting", "Requiring stable sorting"]
    },
    {
        "name": "深度优先搜索",
        "name_en": "Depth-First Search (DFS)",
        "difficulty": "中等",
        "difficulty_en": "Medium",
        "category": "图遍历",
        "category_en": "Graph Traversal",
        "description": "深度优先搜索是一种Graph/树遍历算法，沿着一条路径走到底，然后回溯探索其他路径。",
        "description_en": "DFS is a graph/tree traversal algorithm that explores as far as possible along each branch before backtracking.",
        "principle": "从起点开始，尽可能深地访问节点，直到没有未访问的邻居，然后回溯。",
        "principle_en": "Start from the source, visit nodes as deep as possible, until no unvisited neighbors, then backtrack.",
        "time_complexity": "O(V + E)",
        "space_complexity": "O(V)",
        "code": '''def dfs(graph, start, visited=None):
    if visited is None:
        visited = set()
    visited.add(start)
    print(start, end=' ')
    for neighbor in graph[start]:
        if neighbor not in visited:
            dfs(graph, neighbor, visited)
    return visited''',
        "code_language": "python",
        "example": "在Graph {'A': ['B', 'C'], 'B': ['D', 'E'], 'C': ['F'], 'D': [], 'E': ['F'], 'F': []} 中从A开始遍历。",
        "example_en": "Traversing graph from node A in {'A': ['B', 'C'], 'B': ['D', 'E'], 'C': ['F'], 'D': [], 'E': ['F'], 'F': []}.",
        "scenarios": ["迷宫求解", "拓扑排序", "连通分量检测"],
        "scenarios_en": ["Maze solving", "Topological sorting", "Connected components"]
    },
    {
        "name": "广度优先搜索",
        "name_en": "Breadth-First Search (BFS)",
        "difficulty": "中等",
        "difficulty_en": "Medium",
        "category": "图遍历",
        "category_en": "Graph Traversal",
        "description": "广度优先搜索是一种层次遍历算法，先访问所有邻居节点，再向外扩展。",
        "description_en": "BFS is a level-order traversal algorithm that visits all neighbor nodes first before expanding outward.",
        "principle": "使用队列，从起点开始，先访问所有邻居入队，再依次处理队列中的节点。",
        "principle_en": "Using a queue, start from source, enqueue all neighbors, then process nodes in queue order.",
        "time_complexity": "O(V + E)",
        "space_complexity": "O(V)",
        "code": '''from collections import deque

def bfs(graph, start):
    visited = set()
    queue = deque([start])
    visited.add(start)
    
    while queue:
        node = queue.popleft()
        print(node, end=' ')
        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    return visited''',
        "code_language": "python",
        "example": "在Graph {'A': ['B', 'C'], 'B': ['D', 'E'], 'C': ['F'], 'D': [], 'E': ['F'], 'F': []} 中从A开始层次遍历。",
        "example_en": "Level-order traversing graph from node A in {'A': ['B', 'C'], 'B': ['D', 'E'], 'C': ['F'], 'D': [], 'E': ['F'], 'F': []}.",
        "scenarios": ["最短路径", "层次遍历", "社交网络好友推荐"],
        "scenarios_en": ["Shortest path", "Level-order traversal", "Social network friend recommendations"]
    },
    {
        "name": "动态规划",
        "name_en": "Dynamic Programming",
        "difficulty": "困难",
        "difficulty_en": "Hard",
        "category": "算法思想",
        "category_en": "Algorithm Paradigm",
        "description": "动态规划是一种将复杂问题分解为更小子问题的算法思想，通过存储子问题避免重复计算。",
        "description_en": "DP is an algorithm paradigm that decomposes complex problems into subproblems, storing results to avoid redundant computation.",
        "principle": "最优子结构 + 重叠子问题 = 动态规划。通过记忆化或自底向上避免重复计算。",
        "principle_en": "Optimal substructure + overlapping subproblems = DP. Use memoization or bottom-up to avoid redundant computation.",
        "time_complexity": "O(n)",
        "space_complexity": "O(n) 或 O(1)",
        "code": '''# 以斐波那契为例
def fib_dp(n):
    if n <= 1:
        return n
    dp = [0] * (n + 1)
    dp[1] = 1
    for i in range(2, n + 1):
        dp[i] = dp[i-1] + dp[i-2]
    return dp[n]

# 空间优化版本
def fib_optimized(n):
    if n <= 1:
        return n
    prev, curr = 0, 1
    for _ in range(2, n + 1):
        prev, curr = curr, prev + curr
    return curr''',
        "code_language": "python",
        "example": "计算斐波那契数列第10项：F(10) = 55。",
        "example_en": "Computing the 10th Fibonacci number: F(10) = 55.",
        "scenarios": ["最优路径问题", "资源分配", "字符串编辑距离"],
        "scenarios_en": ["Optimal path problems", "Resource allocation", "String edit distance"]
    },
    {
        "name": "Dijkstra算法",
        "name_en": "Dijkstra Algorithm",
        "difficulty": "困难",
        "difficulty_en": "Hard",
        "category": "最短路径",
        "category_en": "Shortest Path",
        "description": "Dijkstra 算法是用于计算单源最短路径的贪心算法，适用于非负权边。",
        "description_en": "Dijkstra is a greedy algorithm for single-source shortest path in graphs with non-negative edge weights.",
        "principle": "从起点开始，每次选择未处理节点中距离最小的，加入已处理集合，更新邻居距离。",
        "principle_en": "Starting from source, each time select the closest unprocessed node, add to processed set, update neighbor distances.",
        "time_complexity": "O((V + E) log V)",
        "space_complexity": "O(V)",
        "code": '''import heapq

def dijkstra(graph, start):
    dist = {node: float('inf') for node in graph}
    dist[start] = 0
    pq = [(0, start)]
    
    while pq:
        d, node = heapq.heappop(pq)
        if d > dist[node]:
            continue
        for neighbor, weight in graph[node]:
            new_dist = dist[node] + weight
            if new_dist < dist[neighbor]:
                dist[neighbor] = new_dist
                heapq.heappush(pq, (new_dist, neighbor))
    return dist''',
        "code_language": "python",
        "example": "在带权Graph中计算从A到所有节点的最短距离。",
        "example_en": "Computing shortest distances from node A to all nodes in a weighted graph.",
        "scenarios": ["导航路线规划", "网络路由", "航班价格优化"],
        "scenarios_en": ["Navigation routing", "Network routing", "Flight price optimization"]
    }
]

# 精选算法文章资源
ALGORITHM_ARTICLES = [
    {
        "title": "算法复杂度分析：时间与空间的权衡",
        "title_en": "Algorithm Complexity Analysis: Time-Space Tradeoff",
        "url": "https://www.geeksforgeeks.org/complexity-analysis-of-algorithms/",
        "source": "GeeksforGeeks"
    },
    {
        "title": "图论基础：从入门到实战",
        "title_en": "Graph Theory: From Basics to Practice",
        "url": "https://visualgo.net/en/graphds",
        "source": "VisuAlgo"
    },
    {
        "title": "排序算法全面对比分析",
        "title_en": "Comprehensive Comparison of Sorting Algorithms",
        "url": "https://www.toptal.com/developers/sorting-algorithms",
        "source": "Toptal"
    },
    {
        "title": "LeetCode 刷题指南：高效准备技术面试",
        "title_en": "LeetCode Guide: Preparing for Technical Interviews",
        "url": "https://leetcode.com/explore/",
        "source": "LeetCode"
    },
    {
        "title": "动态规划思维训练",
        "title_en": "Dynamic Programming Mindset Training",
        "url": "https://medium.com/dynamic-programming/",
        "source": "Medium"
    },
    {
        "title": "回溯算法详解：解决组合优化问题",
        "title_en": "Backtracking Algorithm: Solving Combinatorial Problems",
        "url": "https://www.geeksforgeeks.org/backtracking-algorithms/",
        "source": "GeeksforGeeks"
    }
]


def get_algorithm_for_day():
    """根据日期选择算法，确保不重复"""
    day_of_year = datetime.now().timetuple().tm_yday
    index = day_of_year % len(ALGORITHMS)
    return ALGORITHMS[index]


def get_picked_article():
    """获取精选文章"""
    day_of_year = datetime.now().timetuple().tm_yday
    index = day_of_year % len(ALGORITHM_ARTICLES)
    return ALGORITHM_ARTICLES[index]


def generate_algorithm_article(algo):
    """生成算法讲解文章"""
    today = datetime.now()
    date_str = today.strftime('%Y%m%d')
    
    content = f'''---
layout: article
title: "{algo["name"]} ({algo["name_en"]})"
date: {today.strftime('%Y-%m-%d')}
tags: ['算法', '{algo["category"]}', '{algo["difficulty"]}', '数据结构', '算法讲解']
description: "{algo["description"][:100]}..."
ai_generated: true
---

# 🧮 {algo["name"]} ({algo["name_en"]})

> **难度 / Difficulty**: {algo["difficulty"]} ({algo["difficulty_en"]})  
> **分类 / Category**: {algo["category"]} ({algo["category_en"]})  
> **时间复杂度 / Time Complexity**: {algo["time_complexity"]}  
> **空间复杂度 / Space Complexity**: {algo["space_complexity"]}

---

## 📖 算法简介 / Introduction

{algo["description"]}

{algo["description_en"]}

---

## 💡 算法原理 / Principle

{algo["principle"]}

{algo["principle_en"]}

---

## 📝 代码实现 / Implementation

```{algo["code_language"]}
{algo["code"]}
```

---

## ✨ 示例 / Example

{algo["example"]}

{algo["example_en"]}

---

## 🎯 适用场景 / Scenarios

{', '.join(algo["scenarios"])}

{', '.join(algo["scenarios_en"])}

---

## 🔄 扩展阅读 / Further Reading

- 建议在 LeetCode 或 HackerRank 上刷相关题目
- 尝试自己实现非递归版本
- 对比其他同类型算法的性能差异

---

*本文由 AI 自动生成 | Generated by AI*
'''

    filename = f'/root/.openclaw/workspace/shytone.com/_algorithms/{date_str}-{algo["name"]}.md'
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return filename


def generate_picked_article():
    """生成精选算法文章"""
    today = datetime.now()
    date_str = today.strftime('%Y%m%d')
    article = get_picked_article()
    
    content = f'''---
layout: article
title: "📚 {article["title"]}"
date: {today.strftime('%Y-%m-%d')}
tags: ['算法', '精选文章', '学习资源']
description: "{article["title"]} - 精选算法学习资料"
ai_generated: true
---

# 📚 {article["title"]}

**英文标题 / English Title**: {article["title_en"]}

**来源 / Source**: {article["source"]}

---

## 📌 文章简介 / Introduction

这是一篇精选的算法相关文章，建议认真学习：

👉 **阅读原文**: [点击访问]({article["url"]})

---

## 🔍 内容要点 / Key Points

1. 深入理解核心概念
2. 结合实例理解原理
3. 多动手实践练习

---

*每日精选，持续更新 | Curated daily*
'''

    filename = f'/root/.openclaw/workspace/shytone.com/_algorithms/{date_str}-精选文章.md'
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return filename


def main():
    print("📡 开始生成算法专栏内容...")
    
    algo = get_algorithm_for_day()
    f1 = generate_algorithm_article(algo)
    f2 = generate_picked_article()
    
    print(f"✅ 已生成算法讲解: {f1}")
    print(f"✅ 已生成精选文章: {f2}")
    print(f"📚 今日算法: {algo['name']} ({algo['name_en']})")


if __name__ == '__main__':
    main()
