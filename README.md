# CN_job-requirement-fit-analysis

一个面向中国大陆校招与实习场景的中文 Skill。

它用于：

- 解读招聘岗位实际在做什么；
- 拆解岗位职责、任职要求和资格条件；
- 在用户提供候选人背景后，基于真实经历进行岗位匹配；
- 区分真实能力缺口、简历表达缺口和信息缺口；
- 针对当前岗位给出简历表达与能力补强方向。

## 当前版本

- Baseline：`v0.1.0`
- 当前发布版本：`v0.2.1`（Campus / Internship split、v0.2 规则澄清及隔离 / Request Control 修复）

当前发布版本已通过 Phase B Validation & Acceptance。

## 当前适用范围

v0.2 主要面向两个独立招聘模式：

- 校招：校园/应届生招聘；
- 实习：寒/暑期实习、日常实习；
- 主要面向**大一到大三/研一到研二的在校学生**和**近期毕业的高校学生**的求职场景。

当前版本不实现 Experienced Hiring 社会招聘；其规则留待 v0.3。

## 仓库结构

```text
CN_job-requirement-fit-analysis/
├── SKILL.md
├── AGENTS.md
├── README.md
├── LICENSE
├── .gitignore
├── references/
│   ├── CAMPUS-HIRING.md
│   ├── INTERNSHIP-HIRING.md
│   └── ISOLATED-EVALUATOR-PROTOCOL.md
└── docs/
    ├── SPECIFICATION.md
    ├── DEVELOPMENT.md
    └── RECRUITMENT-MODE-RULES.md
```

- `SKILL.md`：Skill 的实际运行规则。
- `AGENTS.md`：供 Codex / Agent 在开发和修改本项目时读取的工作规则。
- `docs/SPECIFICATION.md`：产品目标、功能范围和核心判断规则。
- `docs/DEVELOPMENT.md`：版本、Branch、Commit、Batch 和开发流程规范。
- `references/`：两个独立招聘模式的资格/条件规则，以及正式 Candidate Matching 的隔离协议。
- `docs/RECRUITMENT-MODE-RULES.md`：人类可读的模式路由与规则说明。

真实简历、真实 JD、私人测试输出和其他 Evaluation 数据不存放在本仓库中。

## License

本项目采用 **PolyForm Noncommercial License 1.0.0**。

允许个人学习、研究、实验、测试、兴趣项目等非商业用途。

**禁止商业使用。**

详见仓库中的 `LICENSE` 文件。
