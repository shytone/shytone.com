#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
软考高项每日备考推送内容生成 - 完整详细版
每章：核心摘要 + 详细解读 + 考试重点 + 历年真题 + 记忆方法
"""
from datetime import datetime

CHAPTERS = [
    {"id": "ch01", "name": "项目整体管理", "name_en": "Project Integration Management", "weight": "5星 高频必背", "content": "【核心摘要】项目整体管理是PMBOK的核心，协调所有知识领域：通过制定项目章程正式启动，通过项目管理计划建立基准，通过指导与管理项目工作执行，通过监控项目工作跟踪偏差，通过实施整体变更控制处理变化，通过结束项目或阶段收尾交付。\n\n【详细解读：制定项目章程】章程是项目的出生证，由项目发起人/赞助人批准，而非项目经理。主要内容：①项目目的（为什么要做）；②成功标准（必须量化）；③总预算；④主要干系人；⑤主要风险；⑥退出标准。\n\n【详细解读：制定项目管理计划】计划是项目的宪法，包含所有子计划和基准。基准=范围基准+进度基准+成本基准=绩效测量基准PMB。\n\n【详细解读：变更控制流程】提出变更→评估影响→CCB审批→批准/拒绝→实施→验证→记录。任何干系人都可提出，必须经过正式审批！\n\n【考试重点】★章程批准人=发起人（非项目经理）；★计划是宪法；★变更流程七步骤\n\n【历年真题】Q：项目章程应该由谁批准？A.项目经理 B.项目发起人 C.PMO D.客户→答案：B\n\n【记忆口诀】章程由发起人来批，计划综合三十篇；执行交付出成果，监控偏差找根源；变更须经CCB批，收尾总结经验存。"},
    {"id": "ch02", "name": "项目范围管理", "name_en": "Project Scope Management", "weight": "5星 高频必背", "content": "【核心摘要】范围管理回答项目做什么，核心目标是确保项目做且只做所需的工作。范围蔓延=未经控制的对范围的增加，是最大敌人。\n\n【详细解读：WBS分解】100%原则（不能漏不能多）；工作包=最底层，通常80小时内完成；控制账户CA=范围基准的监控点；WBS词典=每个工作包的详细说明。\n\n【详细解读：确认范围 vs 控制范围】确认范围由客户/发起人执行（正式验收签字）；控制范围由项目管理团队执行。注意：确认范围≠质量控制QC，前者由客户做，后者由项目团队做。\n\n【考试重点】★范围基准=范围说明书+WBS+WBS词典；★WBS分解100%原则\n\n【历年真题】Q：WBS分解原则不包括？A.功能分解 B.100%原则 C.滚动波 D.远离供应商→答案：D\n\n【记忆口诀】范围管理六步走，做多浪费做少愁；收集需求问客户，定义范围写清楚；WBS分解遵原则，100%不漏不多够。"},
    {"id": "ch03", "name": "项目进度管理", "name_en": "Project Schedule Management", "weight": "5星 高频必背", "content": "【核心摘要】进度管理是软考高项的计算题大户。关键路径法CPM、进度压缩、PERT分析是三大核心武器。\n\n【详细解读：关键路径法CPM】前向传播：ES=max(紧前EF)，EF=ES+工期；后向传播：LF=min(紧后LS)，LS=LF-工期；总浮动=LS-ES=LF-EF。关键路径：工期最长、总浮动=0、可能多条、动态变化。\n\n【详细解读：进度压缩】赶工Crashing：加钱省时间，优先压缩关键路径上成本斜率最低的活动；快速跟进Fast Tracking：并行执行，返工风险增加。压缩只对关键路径有效！\n\n【详细解读：三点估算PERT】期望=(O+4M+P)/6；标准差=(P-O)/6\n\n【考试重点】★ES=max(紧前EF)；★总浮为零是关键路径；★赶工=加钱，快速跟进=并行\n\n【历年真题】Q：最乐观6天，最可能10天，最悲观18天，期望工期？A.10天 B.10.67天 C.11天→答案：B。PERT=(6+4×10+18)/6=10.67天\n\n【高频公式】ES=max(紧前EF)，LF=min(紧后LS)，总浮动=LS-ES，PERT=(O+4M+P)/6\n\n【记忆口诀】前向传播算最早，后向传播算最晚；总浮为零是关键；赶工加钱，快速并行；压缩只对关键路。"},
    {"id": "ch04", "name": "项目成本管理", "name_en": "Project Cost Management", "weight": "5星 高频必背", "content": "【核心摘要】挣值管理EVM是软考高项的绝对重点！必须熟练掌握PV/EV/AC三大指标和所有公式。\n\n【三大基本指标】PV=计划值；EV=挣值；AC=实际成本。\n\n【偏差分析】SV=EV-PV（SV>0=超前）；CV=EV-AC（CV>0=节约）。【绩效分析】SPI=EV/PV；CPI=EV/AC。CPI>1=节约，CI<1=超支！\n\n【完工预测EAC】典型=BAC/CPI（当前效率不变）；非典型=AC+(BAC-EV)。\n\n【考试重点】★CPI大于1=节约；★典型EAC=BAC/CPI；★非典型EAC=AC+BAC-EV\n\n【历年真题】Q：非典型EAC公式？A.BAC/CPI B.AC+BAC-EV C.AC+(BAC-EV)/CPI→答案：B\n\n【记忆口诀】挣值分析三指标，PV计划EV完成AC花；CV正数是节约，SV正数是超前；CPI大于1好，小于1是超支；完工估算典型BACP，非典型A加BAC减E。"},
    {"id": "ch05", "name": "项目质量管理", "name_en": "Project Quality Management", "weight": "4星 中高频", "content": "【核心摘要】质量不是最好，而是满足需求（朱兰）。七大手法和控制图判异原则是高频考点。QA=过程导向预防，QC=结果导向检查。\n\n【质量大师理论】戴明Deming：PDCA循环+零缺陷；朱兰Juran：质量适用性；克劳斯比Crosby：一次把事情做对+零缺陷；石川馨：因果图/鱼骨图发明者。\n\n【质量成本COQ】一致性成本=预防成本+评估成本；非一致性成本=内部失败+外部失败。预防成本越高，失败成本越低。\n\n【控制图判异7原则】①超出UCL/LCL；②连续7点升/降；③连续7点在中心线同一侧\n\n【历年真题】Q：非一致性成本不包括？A.返工 B.报废 C.质量培训 D.客户投诉→答案：C。质量培训是预防成本。\n\n【记忆口诀】戴明PDCA，克劳斯比零缺陷；七大数据工具：流因核直帕散控；控制图七判异：越界连七偏交替。"},
    {"id": "ch06", "name": "项目资源管理", "name_en": "Project Resource Management", "weight": "4星 中高频", "content": "【核心摘要】塔克曼团队建设五阶段是经典理论。Storming震荡期冲突最大，是正常现象。冲突解决：合作双赢最好，强迫最差（仅紧急用）。\n\n【塔克曼五阶段】Forming形成期→Storming震荡期冲突最大→Norming规范期→Performing成熟期→Adjourning解散期。阶段不可跳过！\n\n【冲突解决策略排序】合作>妥协>缓和>撤退>强迫。合作/问题解决=双赢；强迫/命令=强方赢（仅紧急用）。\n\n【RACI矩阵】R=执行；A=问责（每个工作包只有一个A）；C=咨询（双向）；I=知情（单向）。\n\n【历年真题】Q：团队处于震荡期，项目经理应该？A.放任不管 B.直接命令 C.直面冲突指出方向→答案：C\n\n【记忆口诀】塔克曼五阶段：形Storm形Norm完Per熟；冲突处理合作赢，强迫只是暂时用；RACI：A问责R执行C咨询I知情。"},
    {"id": "ch07", "name": "项目沟通管理", "name_en": "Project Communications Management", "weight": "4星 中高频", "content": "【核心摘要】沟通渠道数量=n(n-1)/2是高频计算题。交互式最好（双向），推式次之（单向），拉式适合大数据量。沟通失败是项目失败的主要原因（70%+）。\n\n【沟通方式】交互式会议/电话=最佳双向；推式邮件/报告=确保送达；拉式知识库=大数据量。核心原则：能开会就不发邮件。\n\n【沟通渠道计算】公式：n(n-1)/2。10个干系人=45条；12个干系人=66条。\n\n【权力/利益方格】权力高+利益高→重点管理；权力高+利益低→令其满意；权力低+利益高→随时告知；权力低+利益低→监督\n\n【历年真题】Q：12个干系人，沟通渠道？A.12 B.66 C.72→答案：B。12×11/2=66条\n\n【记忆口诀】沟通渠道 n×(n-1)÷2；能开会就不发邮件；四象限：高高重点，高低满意。"},
    {"id": "ch08", "name": "项目风险管理", "name_en": "Project Risk Management", "weight": "5星 高频必背", "content": "【核心摘要】风险管理6过程：规划→识别→定性分析→定量分析→规划应对→实施应对→监督风险。威胁=负面风险，机会=正面风险，两者应对策略对称。\n\n【威胁应对策略】规避（改变策略）；转移（外包/保险/分包）；减轻（降低概率/影响）；接受（建立储备）；上报。\n\n【机会应对策略】开拓（确保机会发生）；分享（分配给第三方）；提高（增强概率或收益）；接受；上报。\n\n【储备分析】应急储备（已知-未知风险）=项目经理可直接动用；管理储备（未知-未知风险）=需额外批准。\n\n【历年真题】Q：风险转移是？A.消除风险 B.转移给第三方 C.降低概率→答案：B\n\n【记忆口诀】风险管理六步走：规划识别定高低，定量规划实施监；威胁策略避转减受上，机会策略开分提受上。"},
    {"id": "ch09", "name": "项目采购管理", "name_en": "Project Procurement Management", "weight": "3星 中频", "content": "【核心摘要】合同分三大类型：总价合同（需求明确时用）、成本补偿合同（需求不明时用）、工料合同（快速招人/小项目时用）。\n\n【合同类型】总价合同FFP=价格固定，需求明确时用；成本补偿合同CPFF/CPIF/CPAF=实报实销+费用，需求不明时用；工料合同T&M=按人工费率+材料成本结算。\n\n【采购管理4过程】规划采购管理→实施采购→控制采购→结束采购\n\n【考试重点】需求明确+风险低→总价合同；需求不明+风险高→成本补偿合同\n\n【记忆口诀】采购合同三类型：总价锁定最安全；成本补偿风险高，卖方激励最大化；工料合同最灵活，小快灵首选。"},
    {"id": "ch10", "name": "项目相关方管理", "name_en": "Project Stakeholder Management", "weight": "3星 中频", "content": "【核心摘要】权力/利益方格是核心工具。高高重点管，高低满意管，低高随时告，低低监督管。\n\n【四象限】权力高+利益高→重点管理；权力高+利益低→令其满意；权力低+利益高→随时告知；权力低+利益低→监督。\n\n【记忆口诀】干系人管理四象限，高高重点低满意。"},
    {"id": "ch11", "name": "IT治理与信息化规划", "name_en": "IT Governance", "weight": "2星 低频", "content": "IT治理关注做什么（投资优先级）、做到什么程度（绩效标准）、谁做决策（权责分配）。COBIT是主流IT治理框架，5个域：EDMS、PO、AIS、DSS、MEA。等保2.0：自主保护→指导保护→监督保护→强制保护→专控保护。"},
    {"id": "ch12", "name": "组织级项目管理OPM", "name_en": "OPM", "weight": "3星 中频", "content": "OPM将项目、项目集和项目组合与组织战略协调一致。OPM三个层次：项目组合Portfolio（选择正确项目）；项目集Program（协同相关项目）；项目Project（正确做事）。OPM三要素：过程标准化+人员能力培养+组织文化治理。CMM五级：初始级→已管理级→已定义级→量化管理级→优化级。"},
    {"id": "ch13", "name": "管理科学（计算专题）", "name_en": "Management Science", "weight": "3星 中频", "content": "管理科学计算包括线性规划、决策论、图论与网络计划、盈亏平衡分析。线性规划在可行域顶点找最优解。决策论：确定型、风险型EMV法、不确定型（乐观法maximax、悲观法maximin、后悔值法）。图论：最小生成树、最短路径Dijkstra、最大流。"},
    {"id": "ch14", "name": "项目绩效评估", "name_en": "Project Performance", "weight": "2星 低频", "content": "项目绩效评估从时间、成本、质量三个维度进行综合评价。绩效评估三维度：时间维度SV/SPI；成本维度CV/CPI；质量维度缺陷率/测试通过率。TCPI完工尚需绩效指数=(BAC-EV)/(BAC-AC)。综合评估要结合SPI、CPI、质量指标。"},
    {"id": "ch15", "name": "业务流程重构BPR", "name_en": "BPR", "weight": "2星 低频", "content": "BPR是彻底重新设计业务流程，实现绩效大幅飞跃（跳跃式）。与持续改进Kaizen（渐进式）不同。BPR核心理念：彻底重新设计、根本性思考、戏剧性改善。原则：以流程为中心、顾客导向、打破部门壁垒。"},
    {"id": "ch16", "name": "知识管理", "name_en": "Knowledge Management", "weight": "2星 低频", "content": "知识管理是对组织知识的获取、存储、分享、应用和创新的系统化管理。SECI模型：社会化（隐性→隐性）；外化（隐性→显性）；组合（显性→显性）；内化（显性→隐性）。知识管理工具：经验教训库、最佳实践库、知识地图、专家网络。"},
    {"id": "ch17", "name": "项目管理成熟度模型", "name_en": "OPM3", "weight": "2星 低频", "content": "项目管理成熟度模型用于评估组织项目管理能力的等级。CMM五级：Level 1初始级过程随意；Level 2已管理级项目层面管理；Level 3已定义级组织层面标准化；Level 4量化管理级数据驱动决策；Level 5优化级持续改进。"},
    {"id": "ch18", "name": "信息系统工程与安全", "name_en": "IS Security", "weight": "4星 中高频", "content": "信息系统安全涉及保密性、完整性、可用性三属性。等保2.0五级保护：第一级自主保护→第二级指导保护→第三级监督保护→第四级强制保护→第五级专控保护。安全技术：加密技术DES/AES/RSA；身份认证；防火墙；IDS/IPS。"},
    {"id": "ch19", "name": "法律法规与知识产权", "name_en": "Laws & IP", "weight": "3星 中频", "content": "软件著作权：自然人终生+死后50年，法人首次发表后50年，自动产生。专利权：发明专利20年，实用新型10年，需申请。商标权：注册后10年有效，可无限续展。商业秘密：保密是关键，无期限。合同法：委托开发无约定归受托方，合作开发共有。"},
    {"id": "ch20", "name": "电子商务与电子政务", "name_en": "E-Commerce", "weight": "2星 低频", "content": "电商模式：B2B、B2C、C2C、O2O、C2B。电商三流：信息流、资金流、物流。电子政务：G2G、G2B、G2C、G2E。数字经济：以数据为核心生产要素，以数字技术为驱动，以互联网为载体的新经济形态。"},
    {"id": "ch21", "name": "企业信息化战略规划", "name_en": "Enterprise IS Planning", "weight": "3星 中频", "content": "企业信息化战略规划是将组织战略转化为信息系统战略的过程。规划方法：BSP自上而下识别目标→流程→数据→系统；CSF关键成功因素法；SDP战略数据规划法；IE信息工程法。企业架构EA四层：业务架构、应用架构、数据架构、技术架构。"},
    {"id": "ch22", "name": "商业智能与决策支持", "name_en": "BI & Decision Support", "weight": "3星 中频", "content": "商业智能BI将数据转化为决策信息。BI技术体系：ETL抽取-转换-加载→数据仓库→OLAP联机分析→数据挖掘→辅助决策。数据仓库四特征：面向主题、集成、非易失、时变。OLAP操作：上卷、下钻、切片、切块、旋转。数据挖掘：分类、聚类、关联分析、预测。大数据4V：Volume体量大、Velocity速度快、Variety种类多、Value价值密度低。"},
    {"id": "ch23", "name": "云计算、大数据、物联网、AI", "name_en": "Cloud, Big Data, IoT, AI", "weight": "5星 高频必背", "content": "云计算三层SPI：IaaS基础设施即服务（虚拟机存储）；PaaS平台即服务（开发平台数据库）；SaaS软件即服务（在线应用）。大数据技术栈：采集层Flume/Sqoop→存储层HDFS/HBase→计算层MapReduce/Spark→分析层Hive/SparkSQL。物联网四层：感知层、网络层、平台层、应用层。5G三场景：eMBB增强移动宽带20Gbps、uRLLC超可靠低时延1ms、mMTC海量机器类通信100万/km2。AI技术：机器学习、深度学习CNN/RNN/Transformer、大语言模型LLM、AIGC。历年真题：大数据4V不包括？Virtual。"},
    {"id": "ch24", "name": "综合计算题专题", "name_en": "Calculation Problems", "weight": "5星 高频必须拿分", "content": "综合计算题是软考高项的拿分重点：挣值管理、关键路径、沟通渠道、三点PERT、线性规划。挣值管理：SV=EV-PV，CV=EV-AC，SPI=EV/PV，CPI=EV/AC。典型EAC=BAC/CPI；非典型EAC=AC+BAC-EV。CPI大于1=节约，CI小于1=超支！关键路径：工期最长路径=关键路径，总浮动=LS-ES，总浮为零是关键活动。沟通渠道：n(n-1)/2。三点估算：PERT=(O+4M+P)/6。"},
    {"id": "ch25", "name": "论文写作指南", "name_en": "Essay Writing Guide", "weight": "5星 必考", "content": "论文写作是软考高项的重要科目，要求根据题目结合自身项目经验撰写3000字左右的论文。论文结构：摘要300字（项目概述+主要成果+个人贡献）；正文2000-2500字；总结300字。十大知识领域论文要点：整体管理、范围管理、进度管理、成本管理、质量管理、沟通管理、风险管理、采购管理。写作注意事项：①真实项目经验优先，量化指标要具体；②体现项目经理视角，理论与实践结合；③不能只写做了什么，要写为什么这么做；④结尾要有总结和反思。常见失分点：偏题、缺乏项目管理方法论、缺乏量化数据、字数不足、流水账。"}

]

def get_today_content():
    day_of_year = datetime.now().timetuple().tm_yday
    slot_count = len(CHAPTERS)
    morning_idx = (day_of_year * 3) % slot_count
    afternoon_idx = (day_of_year * 3 + 1) % slot_count
    evening_idx = (day_of_year * 3 + 2) % slot_count
    return {
        'morning': CHAPTERS[morning_idx],
        'afternoon': CHAPTERS[afternoon_idx],
        'evening': CHAPTERS[evening_idx],
    }

def build_content(chapter):
    """Build full push content with English translation"""
    lines = []
    lines.append(f"📖 第四版教材｜第{chapter['id'].replace('ch','')}章")
    lines.append(f"【{chapter['name']}】")
    lines.append("")
    lines.append(chapter['content'])
    return '\n'.join(lines)

def main():
    slot = sys.argv[1] if len(sys.argv) > 1 else 'morning'
    data = get_today_content()
    ch = data.get(slot, data['morning'])
    print(build_content(ch))

if __name__ == '__main__':
    import sys
    main()
