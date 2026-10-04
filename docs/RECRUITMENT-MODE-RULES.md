# v0.3 招聘模式规则

本文件供开发、规则维护和项目复盘使用。运行时由 `SKILL.md` 路由；模式专属细节以 Campus、Internship、Experienced 三份 Reference 为准，正式 Candidate Matching 还须遵守隔离协议。

## 检测顺序

1. 用户明确目标优先：校招/应届正式工作为 Campus；日常/暑期/寒假实习为 Internship；社招、社会招聘、有经验跳槽或“按社招分析”为 Experienced。
2. 用户未声明时，按 JD 明示招聘类型：校招、应届、graduate/new graduate/campus recruitment 为 Campus；实习、internship、summer/winter/off-cycle internship 为 Internship；社招、社会招聘、Experienced Hire、experienced recruitment 为 Experienced。
3. 仍未明确时，JD 中“X 年以上相关工作经验”、正式工作经验或相关工作经验优先等职业经验信号，在没有 Campus 或 Internship 信号时，为 Experienced。工作经验优先是模式信号，不自动成为 Hard Qualification。
4. 仍无法确定时为 `UNKNOWN_REQUIRES_USER_CONFIRMATION`。JD-only 可继续岗位解读；Formal Candidate Matching 停止，并询问用户希望按实习、校招还是社招分析。不得按 Candidate 年级、学历或学制自动推断模式。

JD 内的模式、身份或时间表述相互冲突时，标记 JD 内部不一致并等待招聘方确认，不得强行选边。

## 冲突、Request Control 与隔离

用户明确目标与 JD 明示模式相反时，先报告 `MODE_CONFLICT`、双方模式和当前 JD 不符合目标；首轮停止正式完整匹配，不给 overall match level 或模式资格结论。

后续用户明确坚持比较能力或岗位内容时，Parent / Orchestrator 才可传入 request-scoped `request_control`：`analysis_scope: capability_only_override`、`override_source: explicit_user_followup`。Fresh Runner 只比较职责、技能、Candidate 证据和能力/证据缺口，明确这不是正式招聘资格判断；不执行模式专属资格，也不输出正式 overall match level。

该控制不属于 Candidate Snapshot，不能改变 Candidate 哈希，也不能携带用户原文、前轮对话、此前 Result 或 Parent summary。没有明确 follow-up 时保持 `formal_match` 或停在 `MODE_CONFLICT`。

## Campus 与 Internship

- Campus 以 JD 定义的毕业窗口、学历、专业和院校类别限制为准；“相关专业优先”等保持 Preferred，资格冲突不等于能力低。
- Internship 按 JD 明示的学生身份和 availability 判断。Candidate 未提供安排时是 Information Gap；双方信息齐全且与 mandatory 条件冲突时是资格/条件冲突，不是能力冲突。
- Daily、seasonal、Campus 的招聘形式不改变能力匹配阈值。

## Experienced Hiring

- 以近期、可核验的专业经历作为主要证据；区分 direct、adjacent、transferable 与 unrelated，不能把年限、职位名称或关键词自动等同于 seniority。
- 分别计算累计、相关及直接经验，并明确重叠经历不得重复累计。JD 的 mandatory 年限与 preferred 年限分开；能力交集仍单独分析。较大的职业阶段差距应明确呈现，不得被技术关键词掩盖。
- 对职责深度看候选人实际承担的范围、决策、端到端交付、跨团队协作、人员管理和可验证结果。仅写“参与”不能推断拥有 E2E、跨团队或管理责任。
- 校园课程、比赛和项目可支持能力解释，但不能替代核心专业经验；旧技术经历不是当前主要证据。近期实质性个人项目可以支持当前技能，不可计作生产工作年限。
- 职业空档本身不自动降低 match level。存在空档前后相关证据时，应按实际责任和证据评估。

## 共享判断与边界

Candidate 信息缺失不等于不符合；No Evidence 不等于 Cannot。资格、能力、用户偏好和信息缺口保持分开。所有模式以 Relevance、Directness、Depth、Verifiability 建立 Experience → Capability → JD Requirement 证据链，不用机械分数、JD bullet 数或模式设置阈值。

正式匹配只使用高匹配、部分匹配、低匹配、信息不足四档。JD-only 不产生个人 match level。模式路由与执行隔离路由独立组合；Candidate 正式匹配都遵守 `ISOLATED-EVALUATOR-PROTOCOL.md`。
