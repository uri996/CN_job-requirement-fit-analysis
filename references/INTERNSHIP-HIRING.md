# Internship Hiring（v0.2）

Internship Hiring 是独立招聘模式，包括日常/off-cycle 实习，以及暑期、寒假等 seasonal 实习。Subtype 用于理解时段、持续时间和每周天数，不自动改变能力匹配阈值。仅在 `SKILL.md` 路由到 Internship 时加载；共享规则与隔离执行仍由主文件和 Protocol 决定。

## 学生身份

- JD 明确要求在校、保持学生身份或满足某毕业届别，而 Candidate 明确已毕业或明确不满足时，报告 `Qualification Not Met`，直接说明不满足该实习资格，停止完整正式 match level。用户后续明确要求时，可以按主文件进入 capability-only comparison，忽略该资格。
- JD 未说明学生身份要求时，不创造“所有实习必须在校”的硬规则。继续能力与 JD 匹配，并在开头提示该项无法从 JD 确认，需用户核验实际招聘资格；不扣 match level、不判失败。
- Candidate 未提供在校/毕业、年级或足够推断阶段的信息时，在开头标记 `STUDENT_STATUS / STAGE INFORMATION GAP`；继续分析其他可判断内容，不把缺失当作不符合。

## Availability 与时段

Availability 包括每周天数、连续时长、最早开始时间、指定假期时段，以及 JD 明示的其他可用时间条件。按 JD wording 区分 Hard、Strong、Preferred、Flexible，不建立新 match level。

- JD 与 Candidate 都提供时逐项比较。若 Candidate 明确不能满足 JD mandatory 条件，报告 qualification / condition mismatch；它不是 capability mismatch。
- JD 有要求但 Candidate 未提供相应安排时，列为 `Information Gap / User Attention Item`，说明 JD 要求、缺失信息及需自行核验；不据此判不符合、扣总体 match level 或停止分析。
- JD 未给条件时，不按行业惯例补充。Candidate 的个人时间偏好与招聘方资格保持区分。

## 输出边界

学生身份、时长、天数等未确认事项应在正式分析前简洁提示。明确相反事实才构成不符合；缺失信息属于待核验。按真实工作内容和可核验证据评估项目、课程、科研、社团及实习经历，不因 daily、seasonal subtype 自动升降匹配等级。
