# Campus Hiring（v0.2）

Campus Hiring 指面向即将毕业或当届毕业 Candidate 的正式校招、应届招聘岗位。它是招聘模式，不是能力高低评价。仅在 `SKILL.md` 路由到 Campus 时加载；共享证据、缺口、匹配等级和 Formal Candidate Matching 执行规则仍由 `SKILL.md` 与 `ISOLATED-EVALUATOR-PROTOCOL.md` 决定。

## 届别与毕业窗口

- 优先使用招聘方明确给出的毕业日期窗口。Candidate 日期在窗口内则该项满足；明确在窗口外则为 qualification mismatch，不得写成能力低。
- JD 只写“2027 届”等届别而未给窗口时，不得自行发明起止日期。Candidate 明确提供届别才按届别对照；否则标记待确认。
- 不推断社保、择业期或“毕业两年内仍算应届”等政策身份。

## 学历、专业、院校类别

- JD 未限制学历或专业时，不创建门槛，也不因 Candidate 专业扣分。明确、客观且不可放宽的学历或专业限制才是 Hard Qualification；“相关专业优先”等只属 Preferred / Bonus。
- 明确专业硬限制且 Candidate 明确不符合时，报告 qualification mismatch；仍独立分析可证明的能力。Candidate 未提供专业则是信息缺口，不是失败。
- JD 未限制院校类别时，不主动评价 985、211、双一流、海外院校层级或排名。只有 JD 明确且 mandatory 地限定院校类别或范围，才进入资格判断；明确不满足则为 qualification mismatch。
- 985、211、双一流不能自行视为等价。Candidate 未给所需分类且无可靠权威映射时，标记 `SCHOOL_CATEGORY_UNVERIFIED` 与 Information Gap，不凭记忆猜测，也不维护学校名单。

## 正式入职日期

JD 提及的 full-time start date 可作为注意事项展示；本版本不建立独立入职日期匹配模型。Candidate 未提供未来正式入职时间，不因此降低 match level、阻断分析或判资格失败。

## 输出边界

毕业窗口、专业或院校类别不确定时，在正式匹配结论前简洁提示核验事项。Candidate 信息缺失不等于不符合；明确的资格冲突不等于能力缺口。项目、实习、课程等证据依照全局证据链判断，不因 Campus 模式自动提高门槛或降低匹配等级。
