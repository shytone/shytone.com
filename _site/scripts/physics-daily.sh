#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
物理专栏自动生成脚本
每日生成一篇物理学习文章，从力学到电磁学，循序渐进。
"""

import os
from datetime import datetime, timedelta

# 物理内容列表 - 从基础到进阶
PHYSICS_TOPICS = [
    {
        "name": "运动的描述：位移与速度",
        "name_en": "Motion: Displacement and Velocity",
        "category": "力学基础",
        "category_en": "Mechanics Basics",
        "difficulty": "入门",
        "difficulty_en": "Beginner",
        "description": "从最基础的物理量开始，理解如何描述一个物体的运动状态。",
        "description_en": "Starting from the most basic physical quantities, understand how to describe an object's state of motion.",
        "key_points": [
            "质点：可忽略大小的简化模型",
            "参考系：描述运动需要参照物",
            "位移：矢量，位置的变化，方向从初到末",
            "速度：矢量，描述位置变化的快慢和方向",
            "速率：速度的大小，标量"
        ],
        "key_points_en": [
            "Mass point: simplified model ignoring size",
            "Reference frame: reference needed to describe motion",
            "Displacement: vector, change in position, direction from start to end",
            "Velocity: vector, describes speed and direction of position change",
            "Speed: magnitude of velocity, scalar"
        ],
        "formulas": [
            "位移: s = r - r₀",
            "平均速度: v̄ = Δr/Δt",
            "瞬时速度: v = lim(Δt→0) Δr/Δt"
        ],
        "tags": ["位移", "速度", "质点", "参考系"]
    },
    {
        "name": "加速度",
        "name_en": "Acceleration",
        "category": "力学基础",
        "category_en": "Mechanics Basics",
        "difficulty": "入门",
        "difficulty_en": "Beginner",
        "description": "理解加速度的概念，它是描述速度变化快慢的物理量。",
        "description_en": "Understand acceleration, the physical quantity describing the rate of velocity change.",
        "key_points": [
            "加速度：速度变化与所用时间的比值",
            "公式：a = Δv/Δt",
            "方向：与速度变化方向相同",
            "匀加速直线运动：a恒定",
            "自由落体：a = g ≈ 9.8 m/s²"
        ],
        "key_points_en": [
            "Acceleration: ratio of velocity change to time",
            "Formula: a = Δv/Δt",
            "Direction: same as velocity change direction",
            "Uniformly accelerated motion: a constant",
            "Free fall: a = g ≈ 9.8 m/s²"
        ],
        "formulas": [
            "a = (v - v₀)/t",
            "v = v₀ + at",
            "s = v₀t + ½at²",
            "v² = v₀² + 2as"
        ],
        "tags": ["加速度", "匀加速", "自由落体"]
    },
    {
        "name": "牛顿第一定律",
        "name_en": "Newton's First Law",
        "category": "牛顿运动定律",
        "category_en": "Newton's Laws",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解惯性定律，掌握物体保持运动状态不变的原理。",
        "description_en": "Understand the law of inertia, master the principle of objects maintaining their state of motion.",
        "key_points": [
            "内容：一切物体总保持匀速直线运动或静止状态，直到外力迫使它改变这种状态",
            "惯性：物体保持原有运动状态的性质",
            "质量是惯性大小的量度",
            "力是改变运动状态的原因",
            "不受力时，物体保持原有运动状态"
        ],
        "key_points_en": [
            "Content: All objects remain in uniform straight-line motion or at rest unless external forces change this state",
            "Inertia: property of objects to maintain their original motion state",
            "Mass is the measure of inertia",
            "Force is the cause of motion state change",
            "Without force, object maintains its original state"
        ],
        "formulas": ["F = 0 → a = 0 → v = constant"],
        "tags": ["惯性", "牛顿第一定律", "质量", "惯性定律"]
    },
    {
        "name": "牛顿第二定律",
        "name_en": "Newton's Second Law",
        "category": "牛顿运动定律",
        "category_en": "Newton's Laws",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "掌握力与运动的关系，F=ma是动力学核心公式。",
        "description_en": "Master the relationship between force and motion. F=ma is the core formula of dynamics.",
        "key_points": [
            "内容：物体的加速度与所受合外力成正比，与质量成反比",
            "公式：F = ma",
            "F是合外力，a是加速度，m是质量",
            "加速度方向与合外力方向相同",
            "单位：1N = 1kg·m/s²"
        ],
        "key_points_en": [
            "Content: Object acceleration is proportional to net force, inversely proportional to mass",
            "Formula: F = ma",
            "F is net force, a is acceleration, m is mass",
            "Acceleration direction same as net force direction",
            "Units: 1N = 1kg·m/s²"
        ],
        "formulas": [
            "F = ma",
            "a = F/m",
            "m = F/a"
        ],
        "tags": ["牛顿第二定律", "合外力", "加速度", "F=ma"]
    },
    {
        "name": "牛顿第三定律",
        "name_en": "Newton's Third Law",
        "category": "牛顿运动定律",
        "category_en": "Newton's Laws",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解作用力与反作用力的关系。",
        "description_en": "Understand the relationship between action and reaction forces.",
        "key_points": [
            "内容：两个物体之间的作用力和反作用力大小相等、方向相反、作用在同一直线上",
            "作用力与反作用力同时产生、同时消失",
            "作用力与反作用力是同种类型的力",
            "作用力与反作用力分别作用在不同物体上",
            "平衡力 vs 作用力反作用力"
        ],
        "key_points_en": [
            "Content: Action and reaction forces between two objects are equal in magnitude, opposite in direction, on same line",
            "Action and reaction occur simultaneously",
            "Action and reaction are same type of force",
            "Action and reaction act on different objects",
            "Balanced forces vs action-reaction pairs"
        ],
        "formulas": ["F = -F'"],
        "tags": ["牛顿第三定律", "作用力", "反作用力", "平衡力"]
    },
    {
        "name": "重力与弹力",
        "name_en": "Gravity and Elastic Force",
        "category": "力学",
        "category_en": "Mechanics",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解重力、弹力的产生条件和计算方法。",
        "description_en": "Understand the conditions and calculation methods for gravity and elastic force.",
        "key_points": [
            "重力：由于地球吸引而使物体受到的力",
            "重力的计算：G = mg，g ≈ 9.8 N/kg",
            "弹力：发生形变的物体对接触物的力",
            "弹力产生的条件：接触+形变",
            "胡克定律：F = kx（k为劲度系数）"
        ],
        "key_points_en": [
            "Gravity: force on object due to Earth's attraction",
            "Calculation: G = mg, g ≈ 9.8 N/kg",
            "Elastic force: force from deformed object on contact object",
            "Conditions: contact + deformation",
            "Hooke's law: F = kx (k is spring constant)"
        ],
        "formulas": [
            "G = mg",
            "F = kx"
        ],
        "tags": ["重力", "弹力", "胡克定律", "重力加速度"]
    },
    {
        "name": "摩擦力",
        "name_en": "Friction",
        "category": "力学",
        "category_en": "Mechanics",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解静摩擦和滑动摩擦的计算。",
        "description_en": "Understand static and kinetic friction calculations.",
        "key_points": [
            "滑动摩擦力：f = μN",
            "μ为动摩擦因数，N为正压力",
            "静摩擦力：0 ≤ f ≤ f_max",
            "最大静摩擦力：f_max = μ_s N",
            "滚动摩擦远小于滑动摩擦"
        ],
        "key_points_en": [
            "Kinetic friction: f = μN",
            "μ is coefficient of kinetic friction, N is normal force",
            "Static friction: 0 ≤ f ≤ f_max",
            "Maximum static friction: f_max = μ_s N",
            "Rolling friction much smaller than sliding"
        ],
        "formulas": [
            "f = μN (sliding)",
            "f_max = μ_s N (static max)"
        ],
        "tags": ["摩擦力", "动摩擦", "静摩擦", "动摩擦因数"]
    },
    {
        "name": "力的合成与分解",
        "name_en": "Composition and Resolution of Forces",
        "category": "力学",
        "category_en": "Mechanics",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "掌握向量合成与分解的平行四边形法则。",
        "description_en": "Master the parallelogram rule for vector composition and resolution.",
        "key_points": [
            "力的合成：求合力的过程",
            "平行四边形法则：两个力为邻边，合力为对角线",
            "力的分解：求分力的过程",
            "按效果分解或正交分解",
            "同一直线上力的合成：代数运算"
        ],
        "key_points_en": [
            "Composition: process of finding resultant force",
            "Parallelogram rule: two forces as adjacent sides, resultant is diagonal",
            "Resolution: process of finding component forces",
            "Resolution by effect or perpendicular components",
            "On same line: algebraic calculation"
        ],
        "formulas": [
            "F = √(F₁² + F₂² + 2F₁F₂cosθ)",
            "F_x = Fcosθ, F_y = Fsinθ"
        ],
        "tags": ["力的合成", "力的分解", "平行四边形法则", "正交分解"]
    },
    {
        "name": "功与能",
        "name_en": "Work and Energy",
        "category": "功与能",
        "category_en": "Work and Energy",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解功和能的概念，掌握动能定理。",
        "description_en": "Understand work and energy concepts, master the work-energy theorem.",
        "key_points": [
            "功：力与在力方向上位移的乘积",
            "公式：W = Fs cosθ",
            "正功：力推动运动；负功：力阻碍运动",
            "功率：做功的快慢，P = W/t",
            "动能：Ek = ½mv²",
            "动能定理：合外力做功 = 动能变化"
        ],
        "key_points_en": [
            "Work: product of force and displacement in force direction",
            "Formula: W = Fs cosθ",
            "Positive work: force promotes motion; negative work: force hinders motion",
            "Power: rate of doing work, P = W/t",
            "Kinetic energy: Ek = ½mv²",
            "Work-energy theorem: net work = change in kinetic energy"
        ],
        "formulas": [
            "W = Fs cosθ",
            "P = W/t = Fv",
            "Ek = ½mv²",
            "W_net = ΔEk"
        ],
        "tags": ["功", "功率", "动能", "动能定理"]
    },
    {
        "name": "势能",
        "name_en": "Potential Energy",
        "category": "功与能",
        "category_en": "Work and Energy",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解重力势能和弹性势能。",
        "description_en": "Understand gravitational and elastic potential energy.",
        "key_points": [
            "势能：物体由于位置或形状而具有的能量",
            "重力势能：Ep = mgh（h为高度）",
            "参考平面：人为规定的零势能面",
            "弹性势能：Ep = ½kx²",
            "重力做功与路径无关，只与高度差有关"
        ],
        "key_points_en": [
            "Potential energy: energy due to position or shape",
            "Gravitational: Ep = mgh (h is height)",
            "Reference plane: artificially set zero potential",
            "Elastic potential: Ep = ½kx²",
            "Gravity work independent of path, only height difference"
        ],
        "formulas": [
            "Ep_gravity = mgh",
            "Ep_elastic = ½kx²"
        ],
        "tags": ["势能", "重力势能", "弹性势能", "机械能"]
    },
    {
        "name": "机械能守恒定律",
        "name_en": "Law of Conservation of Mechanical Energy",
        "category": "功与能",
        "category_en": "Work and Energy",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "掌握机械能守恒的条件和应用。",
        "description_en": "Master conditions and applications of mechanical energy conservation.",
        "key_points": [
            "机械能：动能 + 势能",
            "机械能守恒条件：只有重力/弹力做功",
            "内容：在守恒条件下，E_k + E_p = 常数",
            "应用：求速度、高度、最远距离等",
            "能量守恒定律：能量不会凭空消失或产生"
        ],
        "key_points_en": [
            "Mechanical energy: kinetic + potential",
            "Conservation condition: only gravity/elastic force does work",
            "Content: under conservation, E_k + E_p = constant",
            "Applications: finding velocity, height, maximum distance",
            "Law of energy conservation: energy neither created nor destroyed"
        ],
        "formulas": [
            "E = Ek + Ep = constant",
            "½mv² + mgh = constant"
        ],
        "tags": ["机械能守恒", "能量守恒", "动能", "势能"]
    },
    {
        "name": "动量",
        "name_en": "Momentum",
        "category": "动量",
        "category_en": "Momentum",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解动量的概念和冲量定理。",
        "description_en": "Understand momentum and impulse theorem.",
        "key_points": [
            "动量：质量与速度的乘积，p = mv",
            "动量是矢量，方向与速度相同",
            "冲量：力与作用时间的乘积，I = Ft",
            "冲量定理：I = Δp",
            "动量定理：合外力的冲量 = 动量变化"
        ],
        "key_points_en": [
            "Momentum: product of mass and velocity, p = mv",
            "Momentum is vector, same direction as velocity",
            "Impulse: product of force and time, I = Ft",
            "Impulse theorem: I = Δp",
            "Momentum theorem: net force impulse = change in momentum"
        ],
        "formulas": [
            "p = mv",
            "I = Ft",
            "I = Δp"
        ],
        "tags": ["动量", "冲量", "动量定理", "冲量定理"]
    },
    {
        "name": "动量守恒定律",
        "name_en": "Law of Conservation of Momentum",
        "category": "动量",
        "category_en": "Momentum",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "掌握动量守恒的条件和应用。",
        "description_en": "Master conditions and applications of momentum conservation.",
        "key_points": [
            "动量守恒条件：系统不受外力或合外力为零",
            "内容：系统总动量保持不变",
            "表达式：p₁ + p₂ = p₁' + p₂'",
            "应用：碰撞、反冲、爆炸等",
            "动量守恒通常比能量守恒更容易判断"
        ],
        "key_points_en": [
            "Condition: system no external force or net external force is zero",
            "Content: total momentum of system remains constant",
            "Expression: p₁ + p₂ = p₁' + p₂'",
            "Applications: collisions, recoils, explosions",
            "Momentum conservation often easier to apply than energy"
        ],
        "formulas": ["Σp = constant"],
        "tags": ["动量守恒", "碰撞", "反冲", "爆炸"]
    },
    {
        "name": "匀速圆周运动",
        "name_en": "Uniform Circular Motion",
        "category": "曲线运动",
        "category_en": "Curved Motion",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解匀速圆周运动的特点和向心力。",
        "description_en": "Understand characteristics of uniform circular motion and centripetal force.",
        "key_points": [
            "匀速圆周运动：轨迹是圆，速度大小不变但方向变化",
            "线速度：v = s/t = 2πr/T",
            "角速度：ω = θ/t = 2π/T",
            "周期T：转一圈的时间",
            "向心力：F = mv²/r = mω²r",
            "向心加速度：a = v²/r = ω²r"
        ],
        "key_points_en": [
            "Uniform circular motion: circular path, constant speed but changing direction",
            "Linear velocity: v = s/t = 2πr/T",
            "Angular velocity: ω = θ/t = 2π/T",
            "Period T: time for one revolution",
            "Centripetal force: F = mv²/r = mω²r",
            "Centripetal acceleration: a = v²/r = ω²r"
        ],
        "formulas": [
            "v = 2πr/T",
            "ω = 2π/T",
            "F = mv²/r = mω²r",
            "a = v²/r = ω²r"
        ],
        "tags": ["匀速圆周运动", "向心力", "向心加速度", "周期"]
    },
    {
        "name": "万有引力",
        "name_en": "Universal Gravitation",
        "category": "曲线运动",
        "category_en": "Curved Motion",
        "difficulty": "基础",
        "difficulty_en": "Basic",
        "description": "理解万有引力定律和应用。",
        "description_en": "Understand Newton's law of universal gravitation and applications.",
        "key_points": [
            "万有引力定律：F = Gm₁m₂/r²",
            "G = 6.67×10⁻¹¹ N·m²/kg²",
            "引力提供向心力：GMm/r² = mv²/r",
            "天体质量：M = 4π²r³/GT²",
            "重力与万有引力的关系：mg = GMm/R²"
        ],
        "key_points_en": [
            "Law: F = Gm₁m₂/r²",
            "G = 6.67×10⁻¹¹ N·m²/kg²",
            "Gravity provides centripetal: GMm/r² = mv²/r",
            "Celestial mass: M = 4π²r³/GT²",
            "Relation: mg = GMm/R²"
        ],
        "formulas": [
            "F = Gm₁m₂/r²",
            "g = GM/R²",
            "v = √(GM/r)"
        ],
        "tags": ["万有引力", "引力常量", "天体运动", "重力加速度"]
    },
    {
        "name": "机械振动",
        "name_en": "Mechanical Vibration",
        "category": "振动与波",
        "category_en": "Vibration and Waves",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解简谐振动的特点和周期公式。",
        "description_en": "Understand characteristics of simple harmonic motion and period formula.",
        "key_points": [
            "简谐振动：回复力与位移成正比且方向相反",
            "表达式：F = -kx",
            "振幅A：最大位移",
            "周期T：完成一次全振动的时间",
            "弹簧振子周期：T = 2π√(m/k)",
            "单摆周期：T = 2π√(l/g)"
        ],
        "key_points_en": [
            "Simple harmonic: restoring force proportional to displacement, opposite direction",
            "Expression: F = -kx",
            "Amplitude A: maximum displacement",
            "Period T: time for one complete vibration",
            "Spring oscillator: T = 2π√(m/k)",
            "Simple pendulum: T = 2π√(l/g)"
        ],
        "formulas": [
            "F = -kx",
            "T = 2π√(m/k)",
            "T = 2π√(l/g)"
        ],
        "tags": ["简谐振动", "振幅", "周期", "弹簧振子", "单摆"]
    },
    {
        "name": "机械波",
        "name_en": "Mechanical Waves",
        "category": "振动与波",
        "category_en": "Vibration and Waves",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解机械波的形成和分类。",
        "description_en": "Understand formation and classification of mechanical waves.",
        "key_points": [
            "机械波：机械振动在介质中的传播",
            "横波：振动方向与传播方向垂直",
            "纵波：振动方向与传播方向平行",
            "波长λ：相邻同相位点间的距离",
            "波速v = λf = λ/T",
            "波不传递物质，传递能量和信息"
        ],
        "key_points_en": [
            "Mechanical wave: propagation of mechanical vibration in medium",
            "Transverse wave: vibration perpendicular to propagation direction",
            "Longitudinal wave: vibration parallel to propagation direction",
            "Wavelength λ: distance between adjacent in-phase points",
            "Wave speed v = λf = λ/T",
            "Wave transfers energy and information, not matter"
        ],
        "formulas": [
            "v = λf = λ/T",
            "f = 1/T"
        ],
        "tags": ["机械波", "横波", "纵波", "波长", "波速"]
    },
    {
        "name": "电场与电场强度",
        "name_en": "Electric Field and Field Intensity",
        "category": "电场",
        "category_en": "Electric Field",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解电场的概念和电场强度的计算。",
        "description_en": "Understand electric field concept and field intensity calculation.",
        "key_points": [
            "电场：存在于带电体周围的特殊物质",
            "电场强度E：描述电场的力的性质",
            "定义式：E = F/q",
            "点电荷电场：E = kQ/r²",
            "电场方向：正电荷受力方向",
            "电场线：描述电场分布的假想线"
        ],
        "key_points_en": [
            "Electric field: special substance around charged objects",
            "Field intensity E: describes force property of field",
            "Definition: E = F/q",
            "Point charge field: E = kQ/r²",
            "Direction: direction of force on positive charge",
            "Field lines: imaginary lines describing field distribution"
        ],
        "formulas": [
            "E = F/q",
            "E = kQ/r²",
            "k = 9×10⁹ N·m²/C²"
        ],
        "tags": ["电场", "电场强度", "点电荷", "电场线"]
    },
    {
        "name": "电势与电势能",
        "name_en": "Electric Potential and Potential Energy",
        "category": "电场",
        "category_en": "Electric Field",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解电势和电势能的概念。",
        "description_en": "Understand electric potential and potential energy concepts.",
        "key_points": [
            "电势φ：描述电场的能的性质",
            "定义式：φ = W/q",
            "电势能：Ep = qφ",
            "电场力做功：W = qEd",
            "等势面：电势相等的点组成的面",
            "电场线与等势面垂直"
        ],
        "key_points_en": [
            "Potential φ: describes energy property of field",
            "Definition: φ = W/q",
            "Potential energy: Ep = qφ",
            "Work by electric force: W = qEd",
            "Equipotential surface: surface of points with same potential",
            "Field lines perpendicular to equipotential surfaces"
        ],
        "formulas": [
            "φ = W/q",
            "Ep = qφ",
            "W = qEd"
        ],
        "tags": ["电势", "电势能", "等势面", "电场力做功"]
    },
    {
        "name": "电流与电路",
        "name_en": "Electric Current and Circuits",
        "category": "电路",
        "category_en": "Electric Circuits",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解电流、电压和电阻的基本概念。",
        "description_en": "Understand basic concepts of current, voltage and resistance.",
        "key_points": [
            "电流：电荷的定向移动",
            "电流强度：I = q/t",
            "电压：推动电荷移动的原因",
            "电阻：阻碍电流的作用",
            "欧姆定律：I = U/R",
            "电功率：P = UI = I²R"
        ],
        "key_points_en": [
            "Current: directional movement of charges",
            "Current: I = q/t",
            "Voltage: cause of charge movement",
            "Resistance: opposition to current",
            "Ohm's law: I = U/R",
            "Power: P = UI = I²R"
        ],
        "formulas": [
            "I = q/t",
            "I = U/R",
            "P = UI = I²R = U²/R"
        ],
        "tags": ["电流", "电压", "电阻", "欧姆定律", "电功率"]
    },
    {
        "name": "磁场与磁感应强度",
        "name_en": "Magnetic Field and Magnetic Induction",
        "category": "磁场",
        "category_en": "Magnetic Field",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解磁场和磁感应强度的概念。",
        "description_en": "Understand magnetic field and magnetic induction concepts.",
        "key_points": [
            "磁场：存在于磁体或电流周围的物质",
            "磁感应强度B：描述磁场的强弱和方向",
            "方向：小磁针N极受力方向",
            "磁感线：描述磁场分布的假想线",
            "安培定则：判断电流周围的磁场方向",
            "地磁场：地球周围的磁场"
        ],
        "key_points_en": [
            "Magnetic field: substance around magnets or currents",
            "Magnetic induction B: describes strength and direction",
            "Direction: direction of force on N pole of small compass",
            "Field lines: imaginary lines describing field distribution",
            "Ampere's rule: determine field direction around current",
            "Earth's magnetic field: field around Earth"
        ],
        "formulas": ["B = F/(IL)"],
        "tags": ["磁场", "磁感应强度", "磁感线", "安培定则"]
    },
    {
        "name": "电磁感应",
        "name_en": "Electromagnetic Induction",
        "category": "电磁感应",
        "category_en": "Electromagnetic Induction",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解电磁感应现象和法拉第定律。",
        "description_en": "Understand electromagnetic induction and Faraday's law.",
        "key_points": [
            "电磁感应：穿过闭合回路的磁通量变化时，回路中产生感应电流",
            "磁通量：Φ = BScosθ",
            "法拉第电磁感应定律：E = nΔΦ/Δt",
            "楞次定律：感应电流的磁场阻碍原磁场变化",
            "右手定则：判断导体切割磁感线时的电流方向"
        ],
        "key_points_en": [
            "Induction: current induced when magnetic flux through closed loop changes",
            "Magnetic flux: Φ = BScosθ",
            "Faraday's law: E = nΔΦ/Δt",
            "Lenz's law: induced current's magnetic field opposes original change",
            "Right-hand rule: determine current direction when conductor moves in field"
        ],
        "formulas": [
            "Φ = BScosθ",
            "E = nΔΦ/Δt",
            "E = BLv"
        ],
        "tags": ["电磁感应", "磁通量", "法拉第定律", "楞次定律"]
    },
    {
        "name": "电磁波",
        "name_en": "Electromagnetic Waves",
        "category": "电磁波",
        "category_en": "Electromagnetic Waves",
        "difficulty": "进阶",
        "difficulty_en": "Intermediate",
        "description": "理解电磁波的产生和特点。",
        "description_en": "Understand generation and characteristics of electromagnetic waves.",
        "key_points": [
            "电磁波：电磁振荡在空间的传播",
            "电磁波是横波",
            "速度：c = 3×10⁸ m/s",
            "波速与波长、频率的关系：c = λf",
            "电磁波谱：无线电波→微波→红外→可见光→紫外→X射线→γ射线"
        ],
        "key_points_en": [
            "EM wave: propagation of electromagnetic oscillation in space",
            "EM wave is transverse wave",
            "Speed: c = 3×10⁸ m/s",
            "Relation: c = λf",
            "Spectrum: radio→microwave→infrared→visible→ultraviolet→X-ray→γ-ray"
        ],
        "formulas": [
            "c = λf",
            "c = 3×10⁸ m/s"
        ],
        "tags": ["电磁波", "横波", "波速", "电磁波谱"]
    }
]


def get_topic_for_day():
    """根据日期选择主题，确保不重复"""
    day_of_year = datetime.now().timetuple().tm_yday
    index = day_of_year % len(PHYSICS_TOPICS)
    return PHYSICS_TOPICS[index], index + 1


def generate_physics_article():
    """生成物理学习文章"""
    topic, num = get_topic_for_day()
    today = datetime.now()
    date_str = today.strftime('%Y-%m-%d')
    date_short = today.strftime('%Y%m%d')
    
    # 构建内容
    content = f'''---
title: "物理学习 {num:03d} - {topic['name']}"
date: {date_str} 08:00:00 +0800
categories: [物理, {topic['category']}]
tags: [{', '.join(topic['tags'])}]
description: "{topic['description']}"
math: true
---

# 物理学习 {num:03d} - {topic['name']} ({topic['name_en']})

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

    content += '''---

## 重要公式

'''
    for formula in topic['formulas']:
        content += f"$${formula}$\n\n"

    content += f'''---

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

---

**下一篇预告**：物理学习 {num+1:03d} - {'下一个知识点' if num < len(PHYSICS_TOPICS) else '复习与总结'}

---

> 💡 学习建议：物理要联系实际，多思考生活中的物理现象。
> 💡 Learning tip: Connect physics to real life, think about physical phenomena around you.
'''

    filename = f'{date_short}-物理{num:03d}-{topic["name"]}.md'
    filepath = f'/root/.openclaw/workspace/shytone.com/_physics/{filename}'
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return filepath


def main():
    print("⚛️ 开始生成物理学习内容...")
    filepath = generate_physics_article()
    topic, num = get_topic_for_day()
    print(f"✅ 已生成物理学习 {num:03d}: {topic['name']}")
    print(f"📁 文件: {filepath}")


if __name__ == '__main__':
    main()