# 选题与严格语义查重记录

日期：2026-10-14；最终反向查询同日。结论仅限本记录可访问范围：**未发现成熟维护、直接提供有限焦元质量传播与显式冲突重分配的 MoonBit 替代项目**。不声称首个、唯一或穷尽全部未公开项目。

## 方法和范围

执行已安装 osc2026-guide 的 Project Research Guide：先定义问题/用户/数据/接口/验收，再进行 MoonCakes 大上限检索、GitHub 仓库与代码检索、官方 [awesome-moonbit](https://github.com/moonbitlang/awesome-moonbit) 清单、永久项目注册表的全量能力筛选及匹配指纹复核。没有把包名不同或关键词零命中当作通过条件。

MoonCakes 通过 `moon search <term> --limit 100`，覆盖 bayes/probabilistic/factor/inference/graphical、ddmin/delta/shrink、reliability/fault tree、homology/persistent homology/persistence/bottleneck/Vietoris/simplicial/topology、belief/Dempster/Shafer/pignistic/mass function/commonality/evidence/fusion/uncertainty/sensor fusion 及中文任务同义词。接着读取候选的公开精确版本元数据、下载源码及生成接口、测试，而非只看摘要。模糊 Shafer 搜索有 shader 假阳性；一般的 evidence/fusion 不必然属于信念函数。

GitHub 使用带 `language:MoonBit` 的代码查询以及 MoonBit 仓库/任务词查询；代码 API 每页 100，保存 total_count 和 incomplete_results。最终反向词 `pignistic`、`shafer`、`combine_conjunctive`、`commonality` 均返回 total_count=0、incomplete_results=false（不是无限期保证）。较宽 `belief function` 返回四条，逐个源文件检查见下文。API/搜索有索引延迟、语言识别和分页范围限制；不覆盖私有代码。搜索未失败，也未把网络失败算成空结果。

研究原始响应与参考下载保留在仓库外，不把冗长搜索流水或他人源码装进本项目。下表提供可公开复查的对象、版本和源路径。维护状态用实际多版本发布和现有测试/接口判断，不用 stars 代替能力审查。

## 五个不同候选的能力指纹

| 候选 | 用户与三类工作流 | 输入→核心行为→输出 | 接口/验收/明确不做 |
|---|---|---|---|
| 离散贝叶斯网络 | 数据分析、模型教学、规则推断：构建依赖图、证据条件化、边缘查询 | CPT/离散证据→因子乘积与消元→后验 | 可复用推断库；枚举对照；不做连续 MCMC |
| 保失败 delta debugging | 编译器、测试基础设施、格式开发：重现错误、约减语句、输出最小反例 | 失败输入+判定器→ddmin/分块约减→缩小重现 | 库/CLI；保持失败；不做通用优化器 |
| 系统可靠性 | 设备工程、维护分析、风险建模：寿命拟合、系统组合、失效树计算 | 失效数据/树→分布与组合→可靠度报告 | 数值/结构分析；解析案例；不做证据质量融合 |
| 持久同调 | 形状分析、拓扑教学、批量数据分析：建 Rips、算条码、比图距离 | 点云/距离→滤过/边界约减→H0/H1/H2/条码 | 可复用拓扑库；已知复形验证；不做通用图画图器 |
| **MoonBelief** | 分类传感器、设备诊断、分类器集成：融合冲突、条件化粗化、效用拒绝及留一敏感性 | 有序有限框架+稀疏集合质量+可靠度→集合传播/冲突规则→belief/plausibility、步骤与决策报告 | 库/版本化 JSON/CLI；独立集合与有理数 oracle；不做贝叶斯学习、连续状态、密码学证据或可信度学习 |

评分为选题时的工程判断，不是实测性能。1–5，越高越有利；“重合风险”列表示低重合程度。**直接重合硬失败不能用总分抵消**。

| 候选 | 生态广度 | 用户多样性 | 复用 | 低重合 | 深度 | 可验证 | 工期 | 可维护 | 总分 | 门禁 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 贝叶斯网络 | 5 | 4 | 5 | 1 | 5 | 5 | 3 | 4 | 32 | 直接替代，淘汰 |
| delta debugging | 5 | 5 | 5 | 1 | 4 | 5 | 4 | 4 | 33 | 直接替代，淘汰 |
| 可靠性 | 4 | 4 | 5 | 1 | 5 | 5 | 3 | 4 | 31 | 直接替代，淘汰 |
| 持久同调 | 4 | 4 | 5 | 1 | 5 | 5 | 2 | 3 | 29 | 直接替代，淘汰 |
| MoonBelief | 4 | 5 | 5 | 4 | 5 | 5 | 4 | 4 | 36 | 通过并预留 |

## 实际源码能力对照

“接口”包括源码中的公开 API 与生成 .mbti；测试证明对方有实际实现，不把发布次数当作正确性证明。

| 对象/版本和证据 | 任务、数据、算法、接口与输出 | 归类及决策 |
|---|---|---|
| [tyytyy68/moon-bayes-kit@0.1.9](https://mooncakes.io/docs/tyytyy68/moon-bayes-kit)；README、`.mbti`、`bayesian_network_production.mbt`、`advanced_wbtest.mbt` 等 | 生产级因子/边缘化/查询；CPT 与证据→后验；Apache-2.0；已有多版本和测试 | 贝叶斯候选直接重合，淘汰；与 MoonBelief 是相邻不同行为，后者不训练或查询概率图 |
| [Ag108/MoonReduce@0.2.0](https://mooncakes.io/docs/Ag108/MoonReduce)；`.mbti`、约减/判定器源码、`library_test.mbt`、CLI 与 checkpoint 测试 | 失败保持约减、运行判定器、检查点与应用入口；输入→反例 | delta 候选直接重合，淘汰；与证据质量无实质重合 |
| [wcx789ll/moon-reliability@0.3.3](https://mooncakes.io/docs/wcx789ll/moon-reliability)；寿命/组合源码与接口、`fitting_test.mbt`、`engineering_test.mbt`、边界测试；相邻 oyjh0381/moonbdd | 寿命分布拟合、可靠性组合与工程报告，不是焦元集合 | 可靠性候选直接重合，淘汰；不再通过改名 fault-tree 绕过 |
| [wdgodghl/moontopolens@0.20.4](https://mooncakes.io/docs/wdgodghl/moontopolens)；README、Rips 构造/约减源码、API、`analysis_features_test.mbt` 等 | 实际 Rips H0/H1/H2、bottleneck 稳定性与分析工作流；MIT；多版本 | 持久同调候选直接重合，淘汰；不是只因“topology”名字就判断重复 |
| [starlittle/MoonEvidence@0.5.1](https://mooncakes.io/docs/starlittle/MoonEvidence)，仓库 [wenlittle/MoonEvidence](https://github.com/wenlittle/MoonEvidence)；manifest 验证源码、`.mbti`、`audit_log_wbtest.mbt` | 文件清单、密码学哈希/Merkle/审计证明→验证结果；Apache-2.0 | evidence 同词而核心不同。MoonBelief 不收集证物或提供不可篡改证明；独立数学库比扩展该安全产品更合理 |
| [Lyllyl789/moon-kalman@0.2.1](https://mooncakes.io/docs/Lyllyl789/moon-kalman)；标量滤波实现、状态/协方差 API、`advanced_models_test.mbt` 与融合测试 | 数值状态/协方差→预测更新→连续状态估计；Apache-2.0 | 高度相邻的传感器用户，但模型/输入/算法/输出均不同；MoonBelief 不提供动态运动估计，不应塞入滤波 API |
| [FrozenLemonTee/LunarUncertainty@0.1.1](https://mooncakes.io/docs/FrozenLemonTee/LunarUncertainty)；measured quantity 源码、`.mbti`、`measured_quantity_test.mbt` | 数值测量、单位与误差传播；Apache-2.0 | 同方向不同功能；焦元支持不等于测量标准差，无法直接复用其运算接口 |
| [clbbbb/bayes-shift@0.1.0](https://mooncakes.io/docs/clbbbb/bayes-shift)；Detector 更新实现/接口 | 在线运行长度后验与变点检测；Apache-2.0 | 不同模型/任务，不是集合质量与六规则融合 |
| [qjgqjg/moon-causal@0.2.5](https://mooncakes.io/docs/qjgqjg/moon-causal)；估计器源代码/测试 | 因果估计与数据估计器 | 相邻统计方向，不是信念质量模型 |
| [Juwan-Hwang/moon-certified](https://github.com/Juwan-Hwang/moon-certified)；`ml/gmm/gmm.mbt`、`stats/bayesian/bayesian.mbt` | Dempster 命中是 Dempster/Laird/Rubin 的 EM 引用；bayesian 是 MCMC/共轭推断 | 逐源排除文字误报，不能称 Dempster–Shafer 实现 |

宽查询另外三个源码命中也已读取：[moonbitlang/website](https://github.com/moonbitlang/website) 的 `src/pages/rabbita-home/main/data.mbt` 为用户名 beliefone；[moonbit-community/diago](https://github.com/moonbit-community/diago) 的 `text_metrics/text_metrics_test.mbt` 为自然语言 beliefs 排版样本；[marianoguerra/slack-mb](https://github.com/marianoguerra/slack-mb) 的 `ext/test/highlevel/highlevel_test.mbt` 为测试替身注释中的 belief。均不包含本项目核心算法。

## 注册表和最终判断

实现前通过固定排他锁重新读取永久注册表并原子预留 MoonBelief；登记以上已检查外部项目与四个淘汰领域。交付前再次按 Dempster/Shafer、pignistic、focal-subset、belief mass、evidence fusion 等核心能力复核新增条目。已有密码学证据项目、Kalman、概率图、形式逻辑/格、可靠性、图/拓扑等均按完整能力而非名字比较；未将本项目自己预留的记录误判成他人冲突。

保留的是跨三类系统可复用的“有限分类框架上的集合质量传播—冲突可见性—不确定决策”完整闭环，而不是六个函数薄封装。其原生预算、可变别名隔离、映射/变换、JSON 协议与审计敏感性形成统一模型。参考 pyds 用于规则行为对照，不复制其实现，也不宣传所有科学场景适用。

最后的无命中反向查询只能补充证据；决策依赖以上源码对比、用户任务边界和原子预留。若未来出现成熟直接替代，应重新评估合作/合并，而不是维持“唯一”声明。
