# Development Guide

## 1. Repository Role

本仓库保存：

> CN_job-requirement-fit-analysis 的唯一正式源码。

本仓库未来可以公开。

因此禁止提交：

- 真实姓名；
- 电话；
- 邮箱；
- 学号；
- 私人简历；
- 未公开的个人求职材料；
- 私人 Evaluation 数据。

真实测试数据存放在独立 Private Evaluation Repository。

---

# 2. Source of Truth

本仓库中的：

> SKILL.md

是正式 Skill 实现。

docs/SPECIFICATION.md 定义产品要求。

如果两者出现冲突：

不得自行猜测。

应记录冲突并等待人工判断，或者根据明确的开发任务修改对应文件。

---

# 3. Versioning

使用：

> Semantic Versioning 风格的 0.x.y 版本。

例如：

- v0.1.0
- v0.1.1
- v0.1.2
- v0.2.0

当前：

> v0.1.0 = baseline。

---

# 4. Branch Strategy

main 只保存已经人工确认的稳定版本。

开发新版本时使用：

> iteration/<version>

例如：

> iteration/v0.1.1

自动 Agent 不应直接修改 main。

---

# 5. Commit Strategy

Commit 对应：

> 有意义的稳定开发状态。

不要求：

- 每次文件修改 commit；
- 每个 batch commit；
- 每次模型调用 commit。

可以在以下情况 commit：

- baseline 建立；
- 一个完整修复阶段完成；
- 自动 Evaluation 完成；
- 一个版本达到人工可审核状态。

如果长任务需要安全回滚，可以创建 checkpoint commit。

最终版本合并到 main 时，可以使用 squash merge 保持历史整洁。

---

# 6. Development Cycle

标准迭代：

1. 从 main 创建 iteration branch；
2. Builder 阅读 Specification；
3. Builder 阅读 Evaluation findings；
4. 修改 SKILL.md；
5. Runner 在 fresh context 中执行测试；
6. Judge 独立评估输出；
7. 如有必要，Builder 根据 Judge report 修复；
8. 重新执行 Regression Test；
9. 达到停止条件后等待人工审核；
10. 人工确认后合并 main；
11. 创建版本 tag。

---

# 7. Fresh Context Rule

正式 Evaluation 中：

Builder、Runner 和 Judge 应尽量使用独立上下文。

尤其禁止：

> Builder 修改完 Skill 后，直接依赖同一聊天上下文判断自己的修改是否成功。

Runner 应从：

- 当前 Skill；
- Test Case；
- 必要执行说明；

重新开始。

Judge 应主要读取：

- Test Input；
- Actual Output；
- Expected Behavior；
- Rubric。

---

# 8. Batch

长任务可以拆成多个 Batch。

Batch 是：

> 一个独立处理阶段。

例如：

- Batch 1：修改；
- Batch 2：执行测试；
- Batch 3：评估；
- Batch 4：修复；
- Batch 5：回归测试。

Batch 不等于 Git Branch。

多个 Batch 可以在同一个 iteration branch 中执行。

---

# 9. Automated Repair Limit

默认自动修复循环最多进行：

> 2～3 个 repair cycles。

禁止无限自动迭代。

出现以下情况应停止：

- Specification 冲突；
- Test Case 本身可能错误；
- 连续两轮没有明显改善；
- 新修改造成严重 regression；
- 需要产品方向决策；
- 无法可靠运行 fresh-context Evaluation；
- 涉及可能破坏 baseline 的操作。

停止后生成报告并等待人工决策。

---

# 10. Privacy Boundary

Public Skill Repository：

不得读取后把私人内容复制进入源码或公共文档。

Private Evaluation Repository：

可以包含脱敏后的真实：

- JD；
- 候选人背景；
- 项目经历；
- 实习经历；
- 测试输出；
- 人工审查结果。

即使 Evaluation repo 为 Private，仍建议移除：

- 电话；
- 邮箱；
- 学号；
- 精确住址；
- 无分析价值的直接身份信息。

---

# 11. Refactoring

在业务规则仍不稳定时：

优先修复业务逻辑。

不要同时进行大规模文件结构重构。

推荐：

1. 修复 Skill 行为；
2. Regression Test；
3. 确认逻辑稳定；
4. 再拆分 references 或其他文件；
5. 再次 Regression Test。

避免同时修改：

> 行为逻辑 + 文件结构

导致无法判断 regression 来源。

---

# 12. Public Release

GitHub Remote 和 Public Release 不属于开发前置条件。

可以先：

- 本地 Git；
- branch；
- Evaluation；
- version iteration。

待以下条件满足后再公开：

- Skill 基本稳定；
- 私人数据确认清除；
- README 完成；
- License 确认；
- 文件结构整理完成；
- 至少一组公开可用的 synthetic Evaluation example 准备完成。