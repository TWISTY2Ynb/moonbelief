# MoonBelief

有限分类框架上的证据质量函数、显式冲突融合与可拒绝决策。纯 MoonBit 实现，无运行时网络、训练或第三方算法依赖；模块 `TWISTY2Ynb/moonbelief@0.1.0`，MIT。

它解决的是“若干来源只支持一组候选，但不足以选定一个候选”时的计算问题。集合质量不是普通分类概率：`{a,b}` 上的质量表示没有继续分配的支持；空集质量表示冲突。使用者必须先保证类别互斥、穷尽，并说明来源依赖性与可靠度。融合规则不是从观测自动推导的真理。

## 安装与最小集成

```sh
moon add TWISTY2Ynb/moonbelief@0.1.0
```

在消费者的 `moon.pkg` 中加入：

```moonbit
import {
  "TWISTY2Ynb/moonbelief" @belief,
}
```

在可抛出 `@belief.BeliefError` 的函数中使用：

```moonbit
let f = @belief.frame(["clear", "blocked"])
let optical = @belief.simple_support(f, 1, 0.8)
let sonar = @belief.simple_support(f, 2, 0.6)
let result = @belief.yager(optical, sonar)
let (lower, upper) = result.interval(1)
assert_true(lower <= upper)
```

位掩码中第 i 位对应第 i 个标签；`0` 是空集，`f.universe()` 是全集。框架标签顺序属于语义：即使标签相同，顺序不同也不可直接融合；显式使用 `align`。完整接口见 [pkg.generated.mbti](pkg.generated.mbti)。

## 六种融合规则

| API / 协议值 | 交集为空时的处理 | 重要边界 |
|---|---|---|
| `conjunctive` | 留在空集 | 支持开放世界质量；不隐去冲突 |
| `dempster` | 以非空存活质量归一化 | 存活量默认不得小于等于 1e-12 |
| `disjunctive` | 所有质量按并集累计 | 表示至少一个来源有效的不同假设 |
| `yager` | 冲突移到全集 | 不等价于概率归一化；多源顺序可能影响结果 |
| `dubois_prade` / `dubois-prade` | 不相容对移到该对的并集 | 确定的二元规则 |
| `pcr5` / `pairwise-pcr5` | 按每对质量比例重新分配 | 仅闭世界输入；不是广义多源 PCR5 |

`pipeline` 对 1–32 个命名来源先用调用者提供的可靠度折扣，再按调用顺序左折叠。它保留每步冲突、无知与焦元数；诊断计算和融合计算均计入总 pair budget。单来源只折扣，不额外归一化。不要将顺序敏感规则的左折叠称为多源闭式规则。

## 可复用能力

- 有界框架与质量构造：重复焦元合并、有限数校验、补偿求和、向外复制数组，不暴露可变内部状态。
- `belief`、`plausibility`、`commonality`、区间、全集无知、非单点质量、直接计算的存活质量。
- 稠密 zeta/Möbius 变换与 commonality 反演；不一致的逆向输入报错。
- 开放/归一化条件化、可靠度折扣、细化/粗化、显式同标签重排与位置重命名。
- Pignistic 投影、稳定排序、效用/损失、冲突/非特异性/效用间隔拒绝策略。
- Jousselme 距离、焦元总变差、最大 belief 差、留一来源敏感性；不据此自动学习来源可信度。
- 无 I/O 的 `execute_request` / `execute_json`，以及同一协议的单次 CLI。

## 三个实际工作流

```sh
moon run examples/sensors --target wasm-gc
moon run examples/diagnostics --target wasm-gc
moon run examples/ensemble --target wasm-gc
python scripts/check_examples.py --target wasm-gc
```

1. **分类传感器**：光学与声纳分别提供“通行/受阻”的集合支持，指定可靠度后 Yager 融合。原始交集冲突为 0.3456，输出无知为 0.4912，通行 plausibility 为 0.8656，避免把冲突悄悄变成置信结论。
2. **设备诊断**：对电源/机械/软件的集合质量折扣、按硬件事件条件化并粗化，得到电源区间 [0.16, 0.76]，硬件 belief 为 1；这是设备演示，不是临床诊断。
3. **分类器集成**：三个分类器输出集合支持，通过 Yager 与业务效用矩阵产生 `accept`，期望效用 0.31；示例策略接受该建议，逐个去除来源时三个获胜标签均不变。这个玩具结果不证明真实模型校准或安全性。

## JSON 与 CLI

```sh
moon run cmd/moonbelief --target wasm-gc -- '{"schema":"moonbelief.request.v1","frame":["a","b"],"rule":"yager","sources":[{"name":"sensor","masses":[{"subset":["a"],"mass":0.7},{"subset":["a","b"],"mass":0.3}]}],"queries":[["a"]]}'
```

Windows PowerShell 推荐先把 JSON 放入字符串变量，再作为一个参数传入。完整请求示例在 [examples/request.json](examples/request.json)；也可直接调用纯函数 `execute_json`。

- `moonbelief.mass.v1`：`schema`、有序 `frame`、`masses`（`subset` 标签数组和 `mass` 数值）。
- `moonbelief.request.v1`：`schema`、`frame`、`rule`、1–32 个 `sources`；来源字段为 `name`、可选 `reliability`、`masses`。可选 `queries` 与 `decision`。
- `decision`：`actions`、逐行动作×逐列类别的 `utilities`，以及可选 `policy`（`max_conflict`、`max_nonspecific`、`min_margin`）。默认 0.5、0.8、0.05。效用间隔的单位由调用者定义，单动作间隔定义为 0。
- `moonbelief.report.v1`：规范质量、冲突、非单点质量、排序、融合步骤、pair_work，以及请求的查询/决策。
- `moonbelief.error.v1`：结构化错误。**CLI 的领域错误仍以进程状态 0 返回，消费者必须检查 schema/kind，不能只看退出码。** 全冲突无法生成排序，因此报告服务报错；底层 conjunctive API 可保留全冲突质量。

输入拒绝未知字段；JSON 重复对象键遵循 core 解析器的**最后一个值覆盖**行为，不保证检测重复键。需防止重复键歧义的接入方必须在上游单独拒绝它们。

## 资源与数值契约

- 1–16 个唯一非空标签，每个最多 256 字符；输入质量须有限且在 [0,1]，总和允许误差 1e-10；内部计算结果重新归一化。正的极小质量不人为截断。
- 默认/硬上限：4096 焦元、1,000,000 次 pair 工作、65536 稠密单元；`limits` 只能收紧。稠密变换是 O(n·2^n)，不是大规模连续状态算法。
- JSON 文本最多 262144 UTF-16 代码单元、容器嵌套最多 12；查询最多 256。决策最多 64 动作×16 类别，效用/损失绝对值不超过 1e12。
- 错误为 `Invalid`、`Budget`、`FrameMismatch`、`TotalConflict`。归一化与 pignistic 直接求和非空质量，避免用 `1-conflict` 丢失微小存活量；默认阈值仍主动拒绝数值不稳定区域。
- 反演只对不超过 1e-12 的负舍入残差截零；不是任意修复不合法质量。

## 验证

```sh
moon info && moon fmt
moon fmt --check
moon check --deny-warn --target wasm-gc
moon test --deny-warn --target wasm-gc
moon build --deny-warn --target wasm-gc
python scripts/differential.py
python scripts/audit.py
```

验证工具链为 Moon 0.1.20261012 / moonc v0.10.15+943464bfa（2026-10-12）；源码与 CI 使用同一版本的规范格式。CI 在 Linux 上分别检查/测试/构建 wasm-gc、wasm、js、native，并对三个例子断言输出。工具链下载带 ETag 与 SHA-256 校验，见 [CI 安装脚本](scripts/install-ci-toolchain.sh)。本地 Windows 已运行 wasm-gc/wasm/js；native 本地只有严格 check，缺少 C 编译器，不声称本地 native 执行成功。

测试不是覆盖率数字：35 个 test 声明中包含 13,475 个双源规则枚举结果，以及边界、可变别名、变换与顺序测试；另有 72 个经实际 CLI 的有理数差分案例。具体口径见 [验证说明](docs/competition/verification.md)。

## 范围与参考

不做贝叶斯网络训练、连续状态 Kalman 滤波、密码学取证、自动可靠度学习或安全认证。来源相关性、框架是否穷尽及规则是否适用须由调用者论证；存在冲突并不说明哪一个来源错了。

原创实现，仅依赖 MoonBit core。参考 Dempster–Shafer / transferable-belief 通用定义；对照 [reineking/pyds](https://github.com/reineking/pyds) 的确切二元 conjunctive/disjunctive 行为，未复制其源码或测试数据。上游 BSD-3-Clause，且 README 明示停止维护并建议考虑概率方法；本项目不以该库作为推荐决策准则或维护保证。见 [来源说明](docs/provenance.md)、[架构](docs/architecture.md)、[安全](SECURITY.md)、[AI 使用](AI-USE.md)、[查重边界](docs/competition/duplicate-check.md)。
