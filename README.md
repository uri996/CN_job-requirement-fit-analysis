# CN_job-requirement-fit-analysis

一个面向中国大陆校招、实习与社招场景的中文 Skill。

它用于：

- 解读招聘岗位实际在做什么；
- 拆解岗位职责、任职要求和资格条件；
- 在用户提供候选人背景后，基于真实经历进行岗位匹配；
- 区分真实能力缺口、简历表达缺口和信息缺口；
- 针对当前岗位给出简历表达与能力补强方向。

## 当前版本

- Baseline：`v0.1.0`
- 发布基线：`v0.2.1`
- 当前发布版本：`v0.3.0`（Experienced Hiring 独立模式）

`v0.2.1` 已通过 Phase B Validation & Acceptance；`v0.3.0` 是当前正式发布版本。

## 当前适用范围

v0.3.0 支持三个并列招聘模式：

- 校园招聘；
- 应届生招聘；
- 暑期实习；
- 日常实习；
- 在校生和近期毕业生的中国大陆求职场景。
- 社会招聘、具备工作经验的岗位分析。

Campus、Internship 与 Experienced 使用各自的资格和证据规则，同时共享全局证据链、四档匹配等级与隔离执行协议。

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
│   ├── EXPERIENCED-HIRING.md
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
- `references/`：三个独立招聘模式的资格/条件规则，以及正式 Candidate Matching 的隔离协议。
- `docs/RECRUITMENT-MODE-RULES.md`：人类可读的模式路由与规则说明。

真实简历、真实 JD、私人测试输出和其他 Evaluation 数据不存放在本仓库中。

## License

本项目采用 **PolyForm Noncommercial License 1.0.0**。

允许个人学习、研究、实验、测试、兴趣项目等非商业用途。

**禁止商业使用。**

详见仓库中的 `LICENSE` 文件。
