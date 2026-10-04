# v0.2 招聘模式规则

本文件供开发、规则维护和项目复盘使用。运行时由 `SKILL.md` 路由；细节以两个 Mode Reference 和隔离协议为准。Campus Hiring、Internship Hiring、Experienced Hiring 是三个独立概念；v0.2 只实现前两者，Experienced 留待 v0.3。

## 检测顺序

1. 用户明确求职目标优先：校招/应届正式工作为 Campus；日常/暑期/寒假实习为 Internship。
2. 未声明时按 JD 明示招聘类型：校招、应届、graduate/new graduate/campus recruitment；或实习、internship、summer/winter/off-cycle internship。Candidate 是学生不能覆盖 JD 明示模式。
3. 两者均未说明时，才依据中国大陆普通本科/硕士阶段推断：四年制本科大一至大三为 Internship、大四为 Campus；三年制硕士研一研二为 Internship、研三为 Campus。Candidate 直接说的年级优先；日期仅在可明确计算时使用。
4. 仍无法确定则为 `UNKNOWN / INFORMATION_INSUFFICIENT`。特殊学制为 `OUTSIDE_CURRENT_STAGE_INFERENCE_SCOPE`，博士为 `OUT_OF_CURRENT_MODE_INFERENCE_SCOPE`，不硬套规则。

## 冲突与未知

用户明确目标与 JD 明示模式相反时，先报告 `MODE_CONFLICT`、双方模式和当前 JD 不符合目标；首轮停止正式完整匹配，不给 overall match level 或模式资格结论。后续用户明确坚持时，允许 `CAPABILITY_ONLY_OVERRIDE`，只比职责、技能、证据和能力/证据缺口，明确这不是正式招聘资格判断；届别、学生身份和实习可用时间等模式资格不参与。

执行层将该后续明确授权作为无自由文本的 request-scoped `request_control` 传入 fresh Runner：`analysis_scope: capability_only_override`、`override_source: explicit_user_followup`。它不属于 Candidate Snapshot，不能改变 Candidate 哈希，也不能携带用户原文、前轮对话、此前 Result 或 Parent summary。

未知模式时，在分析前提示模式和专属资格无法确认；继续共享证据分析。模式专属项记 `NOT DETERMINABLE / INFORMATION GAP`，不能因未知直接判低匹配或不合格。JD 本身的模式、身份或时间表述互相冲突时，独立标记 JD 内部不一致、待招聘方确认。

## Campus

- 以招聘方定义的毕业窗口为准；窗口内满足，明确在窗口外为资格冲突。只写届别时不自创起止日期；可用 Candidate 明确届别判断，否则待确认。不建社保或两年应届政策身份模型。
- 学历、专业、院校类别仅在 JD 有明确要求时判断。客观且不可放宽的 mandatory 限制才是 Hard Qualification；“相关专业优先”等保持 Preferred。专业或院校类别冲突不是能力低。
- 985、211、双一流互不自动等价。无可靠权威映射时标记 `SCHOOL_CATEGORY_UNVERIFIED`，不猜学校类别。
- 正式入职日期可提示，但 Candidate 未提供未来入职日期不扣等级、不阻断。

## Internship

- Daily/off-cycle 与 summer/winter seasonal 是理解时间条件的 subtype，不改变能力匹配阈值。
- JD 明确要求在校而 Candidate 明确已毕业：`Qualification Not Met`，停止完整正式 match level；后续可在明确请求下做 capability-only。JD 没写学生身份时不自创硬门槛，前置提示需核验并继续分析。Candidate 身份/年级缺失时标记 `STUDENT_STATUS / STAGE INFORMATION GAP`。
- 每周天数、连续时长、开始时间与指定假期时段按 JD 的 Hard、Strong、Preferred、Flexible wording 判断。双方信息齐全且明确冲突于 mandatory 要求时是资格/条件冲突，不是能力冲突。Candidate 未给安排时只列 Information Gap 和核验事项，不扣总体等级或中断。

## 共享判断

Candidate 信息缺失 ≠ 不符合；No Evidence ≠ Cannot。核心/强能力无可核验证据时不给筛选信用，但不推断真实能力不存在。真实能力缺口、简历/证据缺口、信息缺口分开。以 Relevance、Directness、Depth、Verifiability 检查实习、项目、课程、科研、社团等实际内容，建立 Experience → Capability → JD Requirement；不按证据类型、JD bullet 数或模式设置机械权重。

两种模式共用高匹配、部分匹配、低匹配、信息不足四档。资格冲突单列，不能自动变为能力低匹配。Quick Summary 与详细分析保持一致。模式路由与执行隔离路由独立组合：Candidate 正式匹配都遵守 `ISOLATED-EVALUATOR-PROTOCOL.md`；JD-only 不产生个人 match level。

## 范围边界和扩展点

不实施特殊学制、博士阶段推断、社招工作年限等值、seniority、职业成熟度、管理幅度、近期经历衰减或面试难度评分。将来的 Experienced Hiring 应新增独立模式及 Reference，并保留现有全局证据语义与隔离协议；本版本不定义其规则。
