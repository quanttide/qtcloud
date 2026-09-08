# ROADMAP — Studio（量潮云工作台）

> 定位变更：门户职责移交 Site（cloud.quanttide.com，React 门户），协作目录元模型继续在 qtcloud-meta 规划。Studio 参考 CoWork 形态重新规划——用户自然语言派活，各云作为领域专家被任务调度，系统交付可验收成果，用户从执行者变成验收者。

## 背景

- 门户（产品矩阵导航）已迁至 Site：cloud.quanttide.com 主域由 React 门户承载，工作台入口保留在门户卡片
- 协作目录（事件目录、契约管理、流程编排）核心代码此前已迁 qtcloud-meta 重新规划
- 路线图改为一次性建成：CoWork 完整形态 + 招聘政策案例闭环，对应发布 studio/v1.0.0（见 `data/roadmap/qtcloud/product.md`）；本 ROADMAP 的 v0.1.0 清单即 Studio 侧的交付范围
- 端到端练兵场景不变：以招聘政策案例为起点，逼出任务拆解、契约校验、验收机制三块能力

## 核心模型 — Workspace × 流程 DAG × 上下文

Studio 的核心是提供 Workspace。当前不依赖下级、与各保持独立，先把量潮自己的工作流跑通：

1. **一个 Workspace 一个上下文** — Workspace 围绕唯一上下文工作（如一次招聘政策修订），上下文是记忆与信息的边界；智能体云「上下文的具身化」落在 Workspace 层
2. **Workspace 内部是流程 DAG** — 内部组织的是工作流程：节点是步骤（谁做什么），边是流程依赖（上游交付物即下游输入），与信息结构同构
3. **Workspace 之间保持独立** — 跨 Workspace 任务委派（上级向下级发任务，与组织架构同构）是远期形态，待量潮自身工作流验证后再引入

## 版本规划

### studio/v0.1.0（重新规划中）— CoWork 骨架

最小闭环优先，「0.1 的最小可用比想象中小」：

- [x] 首屏交互移植：examples/studio v3 的 Workspace 首屏（方案工作物 + 内联 diff 验收 + 河床自动流转，2026-09-08）
- [ ] Workspace 创建：绑定一个上下文（名称、目标、边界）
- [ ] 任务拆解为流程 DAG：自然语言输入拆成步骤节点与依赖边，可人工调整（对接 qtcloud-meta 事件契约模型）
- [ ] 节点派活：步骤绑定执行者（云 / 人）
- [ ] 执行与验收：节点状态流转（待办 → 执行中 → 待验收 → 完成），用户按节点判定通过 / 驳回
- [ ] 部署上线 cowork.cloud.quanttide.com（Flutter Web + OSS 桶 qtcloud-studio + CDN，`deploy-studio.yml` 已对齐）

### studio/v0.2.0（远期）— 多专家接力

- [ ] 数据云、课程云执行端点接入，模块接力产品化
- [ ] 信任机制落地：假设前置化、考核刚性化、反馈制度化
- [ ] 流程记忆沉淀：拆解方案复用，成熟流程成模板

## 就绪条件

- CoWork 骨架部署上线 cowork.cloud.quanttide.com
- 招聘政策案例端到端闭环跑通（任务输入 → 拆解 → 接力 → 交付草案 → 验收）
- CHANGELOG 补条目

## 决策日志

| 日期 | 决策 | 理由 |
|:-----|:-----|:-----|
| 2026-09-08 | 门户移交 Site，Studio 参考 CoWork 重新规划 | 门户是静态展示，React Site 承载成本更低；Studio 聚焦派活—执行—验收的工作台形态，避免在展示层重复投入 |
| 2026-09-08 | 核心对象定为 Workspace：流程 DAG + 单上下文 | 内部 DAG 组织工作流程对齐信息结构；一 Workspace 一上下文，与智能体云「上下文的具身化」呼应 |
| 2026-09-08 | 当前不依赖下级、与各保持独立，先跑通量潮自己的工作流 | 对齐「云从业务中长出来，先跑通闭环再横向复制」：内部先用起来验证工作流模型，跨 Workspace 委派（外层 DAG）推迟到自身工作流验证后再引入 |

发布命令：`qtcloud-devops release publish -v studio/v0.1.0`
