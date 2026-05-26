#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
数学专栏自动生成脚本
每日生成一篇数学学习文章，从基础数学到高等数学，循序渐进。
"""

import os
from datetime import datetime, timedelta

# 数学内容列表 - 从基础到高等
MATH_TOPICS = [
    {
        "name": "有理数与无理数",
        "name_en": "Rational and Irrational Numbers",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "入门",
        "difficulty_en": "Beginner",
        "description": "理解有理数和无理数的本质区别，建立实数体系的认知框架。",
        "description_en": "Understand the essential difference between rational and irrational numbers, build the framework of real number system.",
        "key_points": [
            "有理数：可表示为p/q（q≠0）的数，包括整数和分数",
            "无理数：无限不循环小数，如√2、π、e",
            "实数 = 有理数 ∪ 无理数",
            "有理数的稠密性：任意两数之间必有有理数"
        ],
        "key_points_en": [
            "Rational: numbers that can be expressed as p/q (q≠0), including integers and fractions",
            "Irrational: infinite non-repeating decimals like √2, π, e",
            "Real = Rational ∪ Irrational",
            "Density of rationals: between any two numbers exists a rational"
        ],
        "formula": "R = Q ∪ (R\\Q)",
        "tags": ["有理数", "无理数", "实数", "数系"]
    },
    {
        "name": "数的分类与数轴",
        "name_en": "Number Classification and Number Line",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "入门",
        "difficulty_en": "Beginner",
        "description": "从自然数到复数的完整数系扩展过程，理解每种数系的特点。",
        "description_en": "The complete number system expansion from natural numbers to complex numbers.",
        "key_points": [
            "自然数N：0, 1, 2, 3...",
            "整数Z：...-2, -1, 0, 1, 2...",
            "有理数Q：整数之比",
            "实数R：有理数+无理数",
            "复数C：a + bi (i² = -1)"
        ],
        "key_points_en": [
            "Natural N: 0, 1, 2, 3...",
            "Integer Z: ...-2, -1, 0, 1, 2...",
            "Rational Q: ratio of integers",
            "Real R: rational + irrational",
            "Complex C: a + bi (i² = -1)"
        ],
        "formula": "N ⊂ Z ⊂ Q ⊂ R ⊂ C",
        "tags": ["自然数", "整数", "数系", "复数"]
    },
    {
        "name": "绝对值与相反数",
        "name_en": "Absolute Value and Opposite Number",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "入门",
        "difficulty_en": "Beginner",
        "description": "理解绝对值的几何意义和代数性质，掌握相反数的概念。",
        "description_en": "Understand the geometric meaning of absolute value and algebraic properties.",
        "key_points": [
            "|a| 表示数轴上a到原点的距离",
            "|a| ≥ 0 永远成立",
            "|-a| = |a|",
            "|a| = a (a≥0), |a| = -a (a<0)",
            "相反数：a和-a在数轴上关于原点对称"
        ],
        "key_points_en": [
            "|a| represents distance from a to origin on number line",
            "|a| ≥ 0 always holds",
            "|-a| = |a|",
            "|a| = a (a≥0), |a| = -a (a<0)",
            "Opposite: a and -a are symmetric about origin"
        ],
        "formula": "|a| = √(a²)",
        "tags": ["绝对值", "相反数", "数轴"]
    },
    {
        "name": "整式与分式",
        "name_en": "Integral and Fractional Expressions",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "入门",
        "difficulty_en": "Beginner",
        "description": "掌握整式（单项式、多项式）和分式的基本概念与运算。",
        "description_en": "Master basic concepts and operations of integral and fractional expressions.",
        "key_points": [
            "单项式：数与字母的积，如3x²y",
            "多项式：几个单项式的和",
            "同底数幂：a^m · a^n = a^(m+n)",
            "分式：分母含有字母的式子",
            "分式有意义条件：分母 ≠ 0"
        ],
        "key_points_en": [
            "Monomial: product of numbers and letters, e.g., 3x²y",
            "Polynomial: sum of several monomials",
            "Same base powers: a^m · a^n = a^(m+n)",
            "Fractional expression: denominator contains letters",
            "Valid condition: denominator ≠ 0"
        ],
        "formula": "(a^m)^n = a^(m·n)",
        "tags": ["整式", "分式", "幂", "代数"]
    },
    {
        "name": "一元一次方程",
        "name_en": "Linear Equation in One Variable",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "入门",
        "difficulty_en": "Beginner",
        "description": "理解方程的解的概念，掌握一元一次方程的解法。",
        "description_en": "Understand the concept of solution and master solving linear equations in one variable.",
        "key_points": [
            "方程：含有未知数的等式",
            "解：使方程成立的未知数的值",
            "同解变形：两边同时加减乘除（不为0）",
            "移项法则：左边的项移到右边要变号",
            "解题步骤：去分母→去括号→移项→合并→系数化为1"
        ],
        "key_points_en": [
            "Equation: equality containing unknown",
            "Solution: value that makes equation true",
            "Equivalent transformation: add/subtract/multiply/divide both sides (non-zero)",
            "Transposition: change sign when moving terms",
            "Steps: remove fractions→remove brackets→transpose→combine→divide by coefficient"
        ],
        "formula": "ax + b = 0 → x = -b/a",
        "tags": ["方程", "一元一次", "同解变形"]
    },
    {
        "name": "二元一次方程组",
        "name_en": "System of Linear Equations",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "掌握代入法和加减法解二元一次方程组。",
        "description_en": "Master substitution and elimination methods for systems of linear equations.",
        "key_points": [
            "代入法：从一个方程解出x=...或y=...，代入另一个",
            "加减法：使某个未知数系数相同后相减",
            "解的情况：唯一解/无解/无穷多解",
            "图像法：两直线交点即解"
        ],
        "key_points_en": [
            "Substitution: solve for x=... or y=... from one equation, substitute into the other",
            "Elimination: make coefficients of one variable equal, then subtract",
            "Solution cases: unique/no/infinite solutions",
            "Graphical: intersection of two lines is the solution"
        ],
        "formula": "a1x + b1y = c1; a2x + b2y = c2",
        "tags": ["二元一次", "方程组", "代入法", "加减法"]
    },
    {
        "name": "不等式",
        "name_en": "Inequalities",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解不等式的基本性质和解法。",
        "description_en": "Understand basic properties and solving methods of inequalities.",
        "key_points": [
            "基本性质：两边同时加减不变方向",
            "两边同时乘除正数：方向不变",
            "两边同时乘除负数：方向改变",
            "一元一次不等式解法与方程类似",
            "数轴表示解集"
        ],
        "key_points_en": [
            "Basic: adding/subtracting same number preserves direction",
            "Multiplying/dividing by positive: direction unchanged",
            "Multiplying/dividing by negative: direction reversed",
            "Solving similar to equations",
            "Represent solution on number line"
        ],
        "formula": "a < b → a + c < b + c",
        "tags": ["不等式", "基本性质", "解集"]
    },
    {
        "name": "平面直角坐标系",
        "name_en": "Cartesian Coordinate System",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解平面直角坐标系的建立和点的坐标表示。",
        "description_en": "Understand the Cartesian coordinate system and representation of points.",
        "key_points": [
            "原点O：x轴和y轴交点",
            "象限：第一象限(+,+), 第二(-,+), 第三(-,-), 第四(+,-)",
            "坐标：(x, y)，x为横坐标，y为纵坐标",
            "特殊点：原点(0,0)，坐标轴上的点",
            "两点间距离公式：d = √[(x₁-x₂)² + (y₁-y₂)²]"
        ],
        "key_points_en": [
            "Origin O: intersection of x-axis and y-axis",
            "Quadrants: I(+,+), II(-,+), III(-,-), IV(+,-)",
            "Coordinates: (x, y), x is abscissa, y is ordinate",
            "Special: origin(0,0), points on axes",
            "Distance: d = √[(x₁-x₂)² + (y₁-y₂)²]"
        ],
        "formula": "d = √[(x₁-x₂)² + (y₁-y₂)²]",
        "tags": ["坐标系", "坐标", "象限", "距离"]
    },
    {
        "name": "一次函数",
        "name_en": "Linear Function",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解一次函数的图像和性质，掌握k和b的几何意义。",
        "description_en": "Understand the graph and properties of linear functions, master geometric meaning of k and b.",
        "key_points": [
            "一般式：y = kx + b (k≠0)",
            "k：斜率，决定倾斜方向和程度",
            "b：截距，决定与y轴交点",
            "k>0：上升直线；k<0：下降直线",
            "图像是直线，与y轴交于(0,b)"
        ],
        "key_points_en": [
            "General form: y = kx + b (k≠0)",
            "k: slope, determines direction and steepness",
            "b: y-intercept, determines intersection with y-axis",
            "k>0: ascending; k<0: descending",
            "Graph is a straight line, intersects y-axis at (0,b)"
        ],
        "formula": "y = kx + b, k = tan θ",
        "tags": ["一次函数", "斜率", "截距", "图像"]
    },
    {
        "name": "三角形",
        "name_en": "Triangles",
        "category": "基础几何",
        "category_en": "Basic Geometry",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解三角形的分类、内角和及基本性质。",
        "description_en": "Understand classification, interior angles, and basic properties of triangles.",
        "key_points": [
            "分类：按边（等边、等腰、不等边）；按角（锐角、直角、钝角）",
            "内角和：180°",
            "三边关系：任意两边之和 > 第三边",
            "重要线段：中线、高线、角平分线、中位线"
        ],
        "key_points_en": [
            "Classification: by sides (equilateral, isosceles, scalene); by angles (acute, right, obtuse)",
            "Interior angles sum: 180°",
            "Side relations: sum of any two sides > third side",
            "Important lines: median, altitude, angle bisector, midsegment"
        ],
        "formula": "a + b > c, a + c > b, b + c > a",
        "tags": ["三角形", "内角和", "分类", "重要线段"]
    },
    {
        "name": "全等三角形",
        "name_en": "Congruent Triangles",
        "category": "基础几何",
        "category_en": "Basic Geometry",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "掌握三角形全等的判定条件和性质。",
        "description_en": "Master criteria and properties for triangle congruence.",
        "key_points": [
            "全等：形状、大小完全相同",
            "SSS：三边对应相等",
            "SAS：两边及其夹角对应相等",
            "ASA：两角及其夹边对应相等",
            "AAS：两角及其中一边对应相等",
            "HL：直角三角形斜边直角边对应相等"
        ],
        "key_points_en": [
            "Congruent: same shape and size",
            "SSS: three sides equal",
            "SAS: two sides and included angle equal",
            "ASA: two angles and included side equal",
            "AAS: two angles and one side equal",
            "HL: right triangle hypotenuse and leg equal"
        ],
        "formula": "ΔABC ≅ ΔDEF",
        "tags": ["全等", "SSS", "SAS", "ASA", "HL"]
    },
    {
        "name": "相似三角形",
        "name_en": "Similar Triangles",
        "category": "基础几何",
        "category_en": "Basic Geometry",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "掌握三角形相似的判定条件和性质。",
        "description_en": "Master criteria and properties for triangle similarity.",
        "key_points": [
            "相似：对应角相等，对应边成比例",
            "AA：两角对应相等",
            "SAS：两边对应成比例且夹角相等",
            "SSS：三边对应成比例",
            "相似比k：对应边之比",
            "面积比 = (相似比)²"
        ],
        "key_points_en": [
            "Similar: corresponding angles equal, corresponding sides proportional",
            "AA: two angles equal",
            "SAS: two sides proportional and included angle equal",
            "SSS: three sides proportional",
            "Similarity ratio k: ratio of corresponding sides",
            "Area ratio = (similarity ratio)²"
        ],
        "formula": "ΔABC ~ ΔDEF, k = AB/DE = BC/EF",
        "tags": ["相似", "相似比", "AA", "SAS", "SSS"]
    },
    {
        "name": "勾股定理",
        "name_en": "Pythagorean Theorem",
        "category": "基础几何",
        "category_en": "Basic Geometry",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解勾股定理的内容、证明和应用。",
        "description_en": "Understand the Pythagorean theorem, its proof and applications.",
        "key_points": [
            "内容：直角三角形两直角边平方和 = 斜边平方",
            "表达式：a² + b² = c²",
            "常见勾股数：(3,4,5), (5,12,13), (8,15,17)",
            "逆定理：若a²+b²=c²，则为直角三角形",
            "应用：求距离、证明垂直"
        ],
        "key_points_en": [
            "Content: sum of squares of legs = square of hypotenuse",
            "Formula: a² + b² = c²",
            "Common triples: (3,4,5), (5,12,13), (8,15,17)",
            "Converse: if a²+b²=c², then right triangle",
            "Applications: distance, proving perpendicularity"
        ],
        "formula": "a² + b² = c²",
        "tags": ["勾股定理", "直角三角形", "毕达哥拉斯"]
    },
    {
        "name": "圆的性质",
        "name_en": "Properties of Circles",
        "category": "基础几何",
        "category_en": "Basic Geometry",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解圆的基本概念和重要性质。",
        "description_en": "Understand basic concepts and important properties of circles.",
        "key_points": [
            "圆心：圆心到圆上任意点距离相等",
            "半径：圆心到圆上任意点的线段",
            "直径：过圆心的弦 = 2r",
            "弦：圆上任意两点的连线",
            "弧：圆上任意两点间的部分",
            "圆周角定理：圆周角 = 圆心角的一半"
        ],
        "key_points_en": [
            "Center: equal distance from center to any point on circle",
            "Radius: segment from center to any point on circle",
            "Diameter: chord through center = 2r",
            "Chord: segment connecting two points on circle",
            "Arc: portion between two points on circle",
            "Inscribed angle theorem: inscribed angle = half central angle"
        ],
        "formula": "C = 2πr, S = πr²",
        "tags": ["圆", "半径", "直径", "弦", "弧"]
    },
    {
        "name": "概率初步",
        "name_en": "Introduction to Probability",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解概率的基本概念和计算方法。",
        "description_en": "Understand basic concepts and calculation methods of probability.",
        "key_points": [
            "概率：事件发生的可能性大小，0≤P≤1",
            "古典概型：等可能性，P(A)=满足条件的个数/总个数",
            "频率与概率：大量试验中频率稳定于概率",
            "互斥事件：不能同时发生，P(A∪B)=P(A)+P(B)",
            "对立事件：A不发生，P(Ā)=1-P(A)"
        ],
        "key_points_en": [
            "Probability: likelihood of event, 0≤P≤1",
            "Classical: equally likely outcomes, P(A)=favorable/total",
            "Frequency vs probability: frequency stabilizes to probability in large trials",
            "Mutually exclusive: cannot happen together, P(A∪B)=P(A)+P(B)",
            "Complementary: A doesn't occur, P(Ā)=1-P(A)"
        ],
        "formula": "P(A) = n(A)/n(S)",
        "tags": ["概率", "古典概型", "互斥事件", "对立事件"]
    },
    {
        "name": "数据的统计描述",
        "name_en": "Statistical Description of Data",
        "category": "基础数学",
        "category_en": "Basic Mathematics",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解平均数、中位数、众数等统计量。",
        "description_en": "Understand statistical measures like mean, median, mode.",
        "key_points": [
            "平均数：所有数据之和÷个数",
            "中位数：数据排序后中间位置的值",
            "众数：出现次数最多的数据",
            "方差：数据偏离平均数的程度，σ² = Σ(x-平均)²/n",
            "标准差：方差的平方根"
        ],
        "key_points_en": [
            "Mean: sum of all data divided by count",
            "Median: middle value after sorting",
            "Mode: most frequently occurring value",
            "Variance: deviation from mean, σ² = Σ(x-avg)²/n",
            "Standard deviation: square root of variance"
        ],
        "formula": "σ² = [Σ(xᵢ - x̄)²]/n",
        "tags": ["平均数", "中位数", "众数", "方差", "标准差"]
    },
    {
        "name": "指数函数",
        "name_en": "Exponential Function",
        "category": "函数",
        "category_en": "Functions",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解指数函数的概念、图像和性质。",
        "description_en": "Understand exponential function concept, graphs and properties.",
        "key_points": [
            "一般式：y = a^x (a>0, a≠1)",
            "定义域：R",
            "值域：(0, +∞)",
            "恒过点：(0,1)",
            "a>1：递增；0<a<1：递减",
            "图像位于x轴上方"
        ],
        "key_points_en": [
            "General: y = a^x (a>0, a≠1)",
            "Domain: R",
            "Range: (0, +∞)",
            "Always passes: (0,1)",
            "a>1: increasing; 0<a<1: decreasing",
            "Graph above x-axis"
        ],
        "formula": "y = a^x, a > 0, a ≠ 1",
        "tags": ["指数函数", "对数", "函数", "图像"]
    },
    {
        "name": "对数",
        "name_en": "Logarithms",
        "category": "函数",
        "category_en": "Functions",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解对数的概念和运算法则。",
        "description_en": "Understand the concept of logarithms and calculation rules.",
        "key_points": [
            "定义：若a^b=N，则log_a(N)=b",
            "常用对数：lg(N)=log_10(N)",
            "自然对数：ln(N)=log_e(N)",
            "运算法则：log(MN)=logM+logN",
            "换底公式：log_a(b)=lg(b)/lg(a)"
        ],
        "key_points_en": [
            "Definition: if a^b=N, then log_a(N)=b",
            "Common log: lg(N)=log_10(N)",
            "Natural log: ln(N)=log_e(N)",
            "Rules: log(MN)=logM+logN",
            "Change of base: log_a(b)=lg(b)/lg(a)"
        ],
        "formula": "log_a(MN) = log_aM + log_aN",
        "tags": ["对数", "常用对数", "自然对数", "换底公式"]
    },
    {
        "name": "数列",
        "name_en": "Sequences",
        "category": "数列",
        "category_en": "Sequences",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解数列的概念和等差、等比数列。",
        "description_en": "Understand sequences and arithmetic/geometric sequences.",
        "key_points": [
            "数列：按一定顺序排列的数",
            "通项公式：a_n",
            "等差数列：后项减前项为常数d",
            "等差通项：a_n = a₁ + (n-1)d",
            "等比数列：后项与前项比为常数q",
            "等比通项：a_n = a₁ · q^(n-1)"
        ],
        "key_points_en": [
            "Sequence: numbers arranged in order",
            "General term: a_n",
            "Arithmetic: difference of consecutive terms is constant d",
            "Arithmetic formula: a_n = a₁ + (n-1)d",
            "Geometric: ratio of consecutive terms is constant q",
            "Geometric formula: a_n = a₁ · q^(n-1)"
        ],
        "formula": "等差: S_n = n(a₁+an)/2; 等比: S_n = a₁(1-q^n)/(1-q)",
        "tags": ["数列", "等差数列", "等比数列", "通项"]
    },
    {
        "name": "极限",
        "name_en": "Limits",
        "category": "高等数学",
        "category_en": "Calculus",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解极限的概念和基本性质。",
        "description_en": "Understand the concept and basic properties of limits.",
        "key_points": [
            "数列极限：n→∞时，a_n→A",
            "函数极限：x→x₀或x→∞时，f(x)→L",
            "极限唯一性",
            "夹逼定理：若b_n≤a_n≤c_n，且bn,c_n→A，则an→A",
            "重要极限：lim(sin x/x)=1 (x→0)"
        ],
        "key_points_en": [
            "Sequence limit: as n→∞, a_n→A",
            "Function limit: as x→x₀ or x→∞, f(x)→L",
            "Uniqueness of limit",
            "Squeeze theorem: if b_n≤a_n≤c_n and b_n,c_n→A, then a_n→A",
            "Important limit: lim(sin x/x)=1 (x→0)"
        ],
        "formula": "lim(x→x₀) f(x) = L",
        "tags": ["极限", "数列极限", "函数极限", "夹逼定理"]
    },
    {
        "name": "导数",
        "name_en": "Derivatives",
        "category": "高等数学",
        "category_en": "Calculus",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解导数的概念和几何意义。",
        "description_en": "Understand the concept and geometric meaning of derivatives.",
        "key_points": [
            "导数定义：f'(x) = lim[Δx→0] [f(x+Δx)-f(x)]/Δx",
            "几何意义：切线斜率",
            "基本求导公式：(x^n)' = nx^(n-1)",
            "导数四则运算",
            "复合函数求导：链式法则"
        ],
        "key_points_en": [
            "Definition: f'(x) = lim[Δx→0] [f(x+Δx)-f(x)]/Δx",
            "Geometric meaning: slope of tangent",
            "Basic formulas: (x^n)' = nx^(n-1)",
            "Operations: sum, product, quotient",
            "Chain rule for composite functions"
        ],
        "formula": "f'(x) = dy/dx",
        "tags": ["导数", "微分", "切线", "链式法则"]
    },
    {
        "name": "微分",
        "name_en": "Differentials",
        "category": "高等数学",
        "category_en": "Calculus",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解微分的概念和近似计算。",
        "description_en": "Understand differentials and approximation calculations.",
        "key_points": [
            "微分：dy = f'(x)dx",
            "微分与导数的关系：dy/dx = f'(x)",
            "微分近似：f(x+Δx) ≈ f(x) + f'(x)Δx",
            "微分在误差估计中的应用"
        ],
        "key_points_en": [
            "Differential: dy = f'(x)dx",
            "Relation: dy/dx = f'(x)",
            "Approximation: f(x+Δx) ≈ f(x) + f'(x)Δx",
            "Applications in error estimation"
        ],
        "formula": "dy = f'(x)dx",
        "tags": ["微分", "导数", "近似计算", "误差"]
    },
    {
        "name": "积分",
        "name_en": "Integrals",
        "category": "高等数学",
        "category_en": "Calculus",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解不定积分和定积分的概念。",
        "description_en": "Understand indefinite and definite integrals.",
        "key_points": [
            "不定积分：求原函数，F'(x)=f(x)",
            "基本积分公式",
            "定积分：求曲边梯形面积，∫[a,b]f(x)dx",
            "牛顿-莱布尼茨公式：∫[a,b]f(x)dx = F(b)-F(a)",
            "积分与微分互为逆运算"
        ],
        "key_points_en": [
            "Indefinite integral: find antiderivative, F'(x)=f(x)",
            "Basic integration formulas",
            "Definite integral: area under curve, ∫[a,b]f(x)dx",
            "Newton-Leibniz formula: ∫[a,b]f(x)dx = F(b)-F(a)",
            "Integration and differentiation are inverse operations"
        ],
        "formula": "∫f(x)dx = F(x) + C",
        "tags": ["积分", "不定积分", "定积分", "牛顿-莱布尼茨"]
    },
    {
        "name": "常微分方程",
        "name_en": "Ordinary Differential Equations",
        "category": "高等数学",
        "category_en": "Calculus",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解常微分方程的基本概念和解法。",
        "description_en": "Understand ODE concepts and solving methods.",
        "key_points": [
            "常微分方程：含有未知函数及其导数的方程",
            "阶：最高阶导数的阶数",
            "可分离变量方程：dy/dx = f(x)g(y)",
            "一阶线性方程：dy/dx + P(x)y = Q(x)",
            "通解与特解"
        ],
        "key_points_en": [
            "ODE: equation containing unknown function and its derivatives",
            "Order: highest derivative order",
            "Separable: dy/dx = f(x)g(y)",
            "First-order linear: dy/dx + P(x)y = Q(x)",
            "General and particular solutions"
        ],
        "formula": "dy/dx = f(x,y)",
        "tags": ["微分方程", "阶", "可分离变量", "一阶线性"]
    }
]


def get_topic_for_day():
    """根据日期选择主题，确保不重复"""
    day_of_year = datetime.now().timetuple().tm_yday
    index = day_of_year % len(MATH_TOPICS)
    return MATH_TOPICS[index], index + 1


def generate_math_article():
    """生成数学学习文章"""
    topic, num = get_topic_for_day()
    today = datetime.now()
    date_str = today.strftime('%Y-%m-%d')
    date_short = today.strftime('%Y%m%d')
    
    # 构建内容
    content = f'''---
title: "数学学习 {num:03d} - {topic['name']}"
date: {date_str} 08:00:00 +0800
categories: [数学, {topic['category']}]
tags: [{', '.join(topic['tags'])}]
description: "{topic['description']}"
math: true
---

# 数学学习 {num:03d} - {topic['name']} ({topic['name_en']})

## 概述

**难度**：{topic['difficulty']} ({topic['difficulty_en']})  
**分类**：{topic['category']} ({topic['category_en']})

{topic['description']}

{topic['description_en']}

---

## 核心要点

'''

    for i, (point, point_en) in enumerate(zip(topic['key_points'], topic['key_points_en']), 1):
        content += f"### {i}. {point}\n{point_en}\n\n"

    content += f'''---

## 公式

$$
{topic['formula']}
$$

---

## 今日练习

1. 理解上述核心要点，尝试用自己的话复述
2. 完成教材或习题册相关练习
3. 思考：这个知识点与其他知识的联系

---

## 📝 今日要点总结

| 概念 | 内容 |
|------|------|
| 名称 | {topic['name']} ({topic['name_en']}) |
| 分类 | {topic['category']} |
| 难度 | {topic['difficulty']} |
| 核心公式 | ${topic['formula']}$ |

---

**下一篇预告**：数学学习 {num+1:03d} - {'下一个知识点' if num < len(MATH_TOPICS) else '复习与总结'}

---

> 💡 学习建议：每天理解一个核心概念，不要贪多。理解 > 记忆。
> 💡 Learning tip: Focus on one concept per day. Understanding > memorization.
'''

    filename = f'{date_short}-数学{num:03d}-{topic["name"]}.md'
    filepath = f'/root/.openclaw/workspace/shytone.com/_math/{filename}'
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return filepath


def main():
    print("📐 开始生成数学学习内容...")
    filepath = generate_math_article()
    topic, num = get_topic_for_day()
    print(f"✅ 已生成数学学习 {num:03d}: {topic['name']}")
    print(f"📁 文件: {filepath}")


if __name__ == '__main__':
    main()