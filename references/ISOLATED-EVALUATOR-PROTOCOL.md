# 隔离匹配评估协议

本协议定义 v0.2.0 中候选人与 JD 的正式匹配如何执行。它只约束执行边界、记录和汇总；`SKILL.md` 中的全部业务匹配规则、匹配等级阈值和三个调试规则继续适用，不能由本协议改写。

## 1. 适用范围与运行状态

只有同时具备原始 Candidate 和当前 JD，且用户要求个人匹配、资格判断、能力/信息缺口或简历诊断时，才启动正式匹配。JD-only 分析仍按 `SKILL.md` 执行，不产生个人 `match_level`。

每次 Match Request 开始时，编排器必须先且只创建一次 **immutable Candidate Snapshot**。Snapshot 是用户本次提交的完整原始 Candidate payload，不得总结、压缩、重写、补充或解释；创建时立即记录 `candidate_source`，并从 Snapshot 的实际字节序列计算 `candidate_snapshot_sha256`。若运行环境支持所有 Runner 稳定读取同一不可变 Candidate artifact，可传递该 artifact 引用；否则必须向每个 Runner 传递完整 Snapshot。真实性和隔离优先于节省 token。

正式匹配的唯一计算单元为：

```text
match(当前唯一一个 atomic JD, immutable Candidate Snapshot) -> Result
```

每个计算单元必须由一个新建且上下文隔离的 Match Runner 执行。开始前，编排器必须能实际验证以下运行时能力：可新建 Runner、Runner 不继承父聊天或任何其他 Runner 的历史、并且只能接收本协议允许的显式输入。

若任一能力不能真正实现或不能验证，必须停止正式匹配，不得生成、猜测或沿用个人匹配等级，并以中文向用户报告：`BLOCKED_RUNTIME_CAPABILITY`。报告应说明无法满足的是“新建隔离 Runner”还是“输入限制”，并可继续提供不含个人匹配结论的 JD-only 解读。禁止以“请忽略此前历史/结果”的提示词代替真实隔离。

面向用户的状态使用以下中文语义：`正在拆分岗位`、`正在进行独立匹配`、`个案重试中`、`已完成独立匹配`、`个案评估错误，已保留 ERROR 并继续`、`正在汇总独立结果`，以及上述 `BLOCKED_RUNTIME_CAPABILITY`。这些状态不得泄露其他岗位或候选人的内容。

## 2. 角色和不可越界的职责

### JD Normalizer

JD Normalizer 先处理原始招聘页面。**Atomic JD** 是用户可以独立选择或投递、并拥有独立职责或任职要求的一个岗位方向。若页面只包含一个岗位方向，则原样形成一个 atomic JD；若页面包含方向 A、方向 B、方向 C，则必须形成 JD-A、JD-B、JD-C，不能把三个方向交给同一个 Match Runner。

页面共同要求必须完整复制到每个 atomic JD；方向特有职责与要求只进入对应 atomic JD。每个 atomic JD 都应保留原始页面及方向的来源元数据。Normalizer 只判断投递边界并忠实重组原文，不得读取、总结、压缩或重写 Candidate，不得结合 Candidate 替用户选择方向，不得做证据映射、比较、排序或预判匹配等级。

### Job Splitter

Job Splitter 对 normalization 产生的 atomic JD 只做边界工作：识别开始与结束、分配稳定的 `JD_ID`、保留每个 atomic JD 的完整内容和源元数据。源元数据可包含原始提交中的位置、批次序号、来源标识、方向标识和时间标识。它不得解释 JD、提取能力、推断公司/岗位、比较岗位、形成候选人结论或预判匹配等级。

单一 atomic JD 产生一个条目；同一聊天中连续出现的 JD 也逐个产生独立条目；多 JD batch 必须按 atomic 边界拆为多个条目。拆分后的 atomic JD 内容不得被概述、删节、改写或与其他 JD 合并后再交给 Runner。

### Match Runner

每个 `JD_ID` 必须启动一个新的 Match Runner。Runner 使用必要的 Skill instructions 中既有业务规则，独立执行该 JD 与该 Candidate 的匹配，并且只输出一个符合第 4 节 schema 的 `Result`，随后结束。Runner 不负责保存 Registry、与其他 Runner 通讯、重试其他个案、比较职位或向用户输出批次摘要。

Runner 的完整允许输入清单仅为：

1. 必要的 Skill instructions；
2. 本次 Match Request 唯一的 immutable Candidate Snapshot，或能解析为其完整原始 payload 的不可变 artifact 引用；
3. 当前唯一一个由 normalization 形成、未经概述或删节的 atomic JD；
4. 固定的 Result schema；
5. 为创建、隔离、结束 Runner 所必需的系统级运行指令。

Runner 的禁止输入包括但不限于：父聊天全文或摘要；此前轮次上下文；其他 JD 或其片段/摘要/元数据；此前 Result、`match_level`、`qualification_status`、Registry 内容或错误记录；Candidate summary；Parent interpretation；前一个 Runner 的 Candidate 摘要；Aggregator summary；按岗位重新改写的 Candidate；为节省 token 自动压缩后的 Candidate；父编排器、Job Splitter、Aggregator 或用户对先前结论的总结、偏好、猜测、排序或目标等级；其他 Runner 的输出；批次排名、比较标准或 Canary 的预期答案。不得将任何禁止项隐藏在系统级运行指令、例子、变量名、引用文本或工具返回中。

Runner 开始匹配前，必须从其实际读取的 Candidate payload 计算 `candidate_sha256`，从其实际读取的当前 atomic JD 计算 `jd_sha256`。`candidate_sha256` 必须等于 Registry 中本次 Match Request 的 `candidate_snapshot_sha256`；不相等时不得执行或保留正式匹配结论，必须返回输入审计并记录 `input_contract_status: INVALID`、`result_status: INVALID_INPUT`。

Runner 不得从 Registry 读取信息，不得请求或接受“参考前一个岗位/结果”的补充材料。若用户后来补充 Candidate，补充内容应作为新的原始 Candidate 输入触发新的独立运行，不得把旧 Result 作为依据修订。

### 编排器

编排器只负责能力预检、在每个 Match Request 开始时创建一次 immutable Candidate Snapshot、调用 JD Normalizer 与 Job Splitter、为每个 `JD_ID` 创建隔离 Runner、把同一 Snapshot 与当前 atomic JD 交给 Runner、执行一次受限重试、验证输入哈希、写入 Registry，以及在全部结果结束后调用 Aggregator。编排器不得为不同 JD 生成 Candidate 变体。编排器可以整理展示格式和保存结果，但不得重判证据、推导新的个人结论，或改写任一 Result 的 `match_level`。

个案发生执行错误时，编排器仅对该 `JD_ID` 使用相同的允许输入新建一次 fresh Runner 重试。第二次失败后记录 `ERROR` 并继续处理其他 JD；不得把错误个案的内容提供给其他 Runner。重试也必须满足所有隔离和输入限制。

### Aggregator

Aggregator 只能在全部独立 Match Result 已记录后读取 Result Registry，且正式比较只能读取 `input_contract_status: VALID` 且 `result_status: VALID` 的 Result。`INVALID_INPUT` 与 `ERROR` 可以在运行状态中报告，但不得进入正式汇总、比较或排序。Aggregator 可以汇总、比较、排序和识别有效 Result 的共性缺口，但不能启动或重跑匹配，不能新增或重判单个岗位的证据，不能改写任何 individual `match_level`、`qualification_status` 或 Result 正文。

汇总报告必须明显分为两类：

- **绝对匹配（ABSOLUTE MATCH）**：逐个 JD 原样引用 Registry 中对应 Result 的独立 `match_level` 与资格状态；
- **相对比较（RELATIVE COMPARISON）**：仅说明多个已完成 Result 之间的比较、排序或共同模式；它不是新的个人匹配等级，也不能替代、抬高或降低绝对匹配。

## 3. 执行编排

1. 编排器先完成运行时能力预检；失败即按第 1 节停止。
2. 编排器从用户本次提供的完整原始 Candidate 创建一次 immutable Candidate Snapshot，记录来源并计算 `candidate_snapshot_sha256`。
3. JD Normalizer 仅将原始招聘页面规范化为一个或多个 atomic JD，复制共同要求并保留方向特有要求，不读取 Candidate。
4. Job Splitter 为每个 atomic JD 固定 `JD_ID`，保留内容和源元数据。
5. 每个 `JD_ID` 启动一个 fresh Match Runner，并读取同一 Snapshot 与当前唯一 atomic JD。可并发或分批运行，但每个 Runner 的输入边界完全相同且彼此隔离。
6. Runner 对实际 Candidate payload 与 atomic JD 计算 SHA-256；编排器验证 Candidate 哈希等于 Snapshot 哈希，并验证同一 Match Request 的所有 Runner 使用相同 `candidate_sha256`。
7. 输入契约通过时记录 `input_contract_status: VALID`、`result_status: VALID`；Candidate 哈希不一致时记录 `input_contract_status: INVALID`、`result_status: INVALID_INPUT`，丢弃正式匹配正文。
8. 单个 Runner 的首次执行错误只重试一次；第二次错误以 `result_status: ERROR` 写入 Registry，之后继续其他条目。重试仍使用同一 Snapshot。
9. 当且仅当每个 `JD_ID` 都有 `VALID`、`INVALID_INPUT` 或 `ERROR` Registry 条目时，Aggregator 才可读取 Registry，且只聚合 `VALID` Result。

同聊连续单 JD 不是同一 Runner 的连续任务。即使 Candidate 未变，每个新 JD 也必须获得一个新的 Runner。多 JD batch 与逐次提交同一组 JD 应遵循相同的单 JD 隔离规则；可改变并发度，不可改变任一 Runner 的输入集合。

## 4. 固定 Result schema 与 Registry

成功 Result 必须仅包含下列字段；字段值使用中文分析内容，枚举值按下列约定执行：

```text
Result {
  JD_ID: string,
  company: string | "未提供",
  title: string | "未提供",
  match_level: "高匹配" | "部分匹配" | "低匹配" | "信息不足" | "部分匹配偏低（当前材料下）" | "低匹配（当前材料下）",
  qualification_status: string,
  direct_evidence: array,
  transferable_evidence: array,
  information_gaps: array,
  resume_evidence_gaps: array,
  confirmed_gaps: array,
  resume_diagnosis: string | array,
  full_analysis: string,
  run_id: string
}
```

Result 中的 `match_level` 必须保留现有业务规则的四种基础等级（高匹配、部分匹配、低匹配、信息不足），并允许使用 `SKILL.md` 已定义、用于保守校准的合规限定表达，尤其是“部分匹配偏低（当前材料下）”与“低匹配（当前材料下）”。限定表达不是新的匹配等级，也不得改变既有阈值、证据要求或等级校准。资格状态与能力匹配必须保持分离。`direct_evidence`、`transferable_evidence`、`information_gaps`、`resume_evidence_gaps` 和 `confirmed_gaps` 必须遵守现有证据与缺口规则，不能因隔离架构而改变阈值。`resume_evidence_gaps` 记录当前简历对核心能力或强要求没有可核验证据的筛选缺口：该字段不等于候选人不会，也不得写入 `confirmed_gaps`；但必须使该要求在当前材料下不获得筛选信用，并按 `SKILL.md` 影响 `match_level`。优先项缺失以及未提供的地点、到岗或实习周期不得作为该字段的负面核心证据。

Result Registry 至少保存上述每个字段，并为运行控制额外保存：

```text
runner_id: string | null
candidate_source: string
candidate_snapshot_sha256: string
candidate_sha256: string
jd_sha256: string
input_contract_status: VALID | INVALID
result_status: VALID | INVALID_INPUT | ERROR
attempt_count: 1 | 2
error_code: string | null
input_audit_id: string
```

其中 `candidate_sha256` 必须从真正传入并由该 Runner 读取的 Candidate payload 计算，`jd_sha256` 必须从该 Runner 实际读取的当前 atomic JD 计算；不同 atomic JD 应具有各自对应的 `jd_sha256`。同一个 Match Request 的所有 Runner 必须具有完全相同的 `candidate_sha256`，并与 `candidate_snapshot_sha256` 相等。`runner_id` 仅在 runtime 可获得时记录，否则为 `null`。

`INVALID_INPUT` 条目仍保留全部输入审计字段，但业务结果字段和 `match_level` 使用 `null`，不得进入 Aggregator 的正式比较。`ERROR` 条目仍保留 `JD_ID`、`run_id`、`runner_id`、`result_status`、`attempt_count`、`error_code` 和输入审计关联；无法产生的业务字段使用 `null`，不得编造分析或匹配等级。Registry 是单向记录：它绝不可反向传给新的 Runner，也不得成为 Candidate、JD 或系统指令的一部分。

## 5. 输入审计

每次 Runner 调用都必须产生一个不可变的输入审计记录，至少包含：`input_audit_id`、`run_id`、`JD_ID`、`runner_id`（如可获得）、尝试次数、`candidate_source`、`candidate_snapshot_sha256`、从 Runner 实际 Candidate payload 计算的 `candidate_sha256`、从 Runner 实际 atomic JD 计算的 `jd_sha256`、`input_contract_status`、`result_status`、原始招聘页面与方向的来源标识、允许输入清单、隔离能力验证结果和创建时间标识。

审计记录用于验证输入边界，不得把 Candidate 或 JD 的内容改写成结论后传入 Runner，也不得以审计为名让其他 Runner 获取原始材料。若需要保留原文，应只按既有隐私与保存边界保存原始输入；审计本身优先记录来源标识和完整性校验值，而不是复制不必要的个人内容。

## 6. Canary 验证性质

Canary 测试必须使用合规的测试材料，并在不修改业务规则的前提下验证下列可观察性质：

1. **同聊隔离**：在同一聊天先运行一个无关 JD 后，再运行目标 JD；目标 Runner 的审计输入中不得出现前一 JD、前一 Result 或等级。
2. **batch 与 single 一致性**：同一原始 Candidate 和同一组原始 JD 分别以 batch 与逐个 single 提交；每个相同 `JD_ID` 的独立结论和关键证据分类应一致，或将运行不可控差异明确标为待调查，不能由 Aggregator 补正。
3. **顺序不变性**：调换 batch 中 JD 的排列后，以内容对应的 `JD_ID` 比较，任何单个 Runner 的输入集合和独立结论不应因排列顺序改变。
4. **聚合器分离**：在 Registry 未完成前 Aggregator 不得运行；完成后 Aggregator 的输出必须可追溯到 Registry，且不得产生新的单 JD `match_level` 或改写已有等级。
5. **错误隔离**：人为使一个 JD 运行失败时，只允许该 JD 重试一次；其余 JD 继续完成，第二次失败记录 `ERROR`，不污染其他 Runner。
6. **上下文 Canary token**：将仅存在于父聊天、其他 JD 或先前 Result 中的唯一测试 token 作为污染标记；目标 Runner 的输入审计中不得出现该 token，目标 Runner 不应得知该 token，且其 Result/输出中不得泄漏该 token。输入审计或 Runner 输出任一处命中该 token，即验证失败，不得把该 Result 标记为正式匹配。

Canary 的通过依据是输入审计、Registry 和聚合输出的可追溯性，不得用“模型声称忽略历史”作为证据。若 Canary 显示隔离或输入限制不成立，应报告 `BLOCKED_RUNTIME_CAPABILITY` 或相应验证失败，不得把结果标记为正式匹配。
