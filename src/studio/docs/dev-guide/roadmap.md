# ROADMAP — qtcloud_studio

## 日志更新平台化

把 `data/journal/.agents/skills/fetch-chat-logs` 技能升级为平台特性：更新工作日志不再依赖手动触发 agent，而是 studio 内置能力。

- 数据源：飞书群消息（lark-cli 拉取，按群名解析，chat_id 不落库）
- 分流：来源群 → journal 业务线目录，同日已有文件则合并
- 红线：脱敏规则（真实 ID、姓名、经营敏感信息不入公开仓库）从 agent 自律变为平台强制检查
- 产出：写入 journal 仓库，主仓库指针同步

流程已由该技能验证，平台化只做收编，不改写法。

### 复用说明

全部落在 studio 现有模型上，`Artifact`/`Task`/`Workflow` 零改动：

- **工作物 = `Doc`**：journal 日志文件（`YYYY-MM-DD.md`）天然是章节文档，一个 `DocSection` 对应一个来源群段落；「同日已有文件则合并」就是向同一 Doc 追加 Change，不新建工作物
- **产出 = `Change`**：群消息成稿为「事实+原话」段落，`target` 指向目标章节，`before` 空 = 章节末尾追加；分流规则只决定 `Change.target` 寻址，不产生新类型
- **脱敏红线 = 验收闸门**：agent 自律改为 `reviewing` 人工拍板，Change 以内联 diff 呈现，对照红线检查；驳回走 `Task.reject(note)` 现成链路；代称映射表不入仓库，配置在平台侧
- **流程 = Workflow DAG**：拉取（日志云）→ 分流成稿（日志云）→ 脱敏验收（人）→ 写入 journal + 指针同步（日志云），云任务自动衔接，人只拍板一次
- **派活**：`dispatchIntent` 意图库加「更新今天的日志」分支

真正新写的只有三块：飞书连接器（lark-cli 能力收编）、红线自检（`oc_`/`ou_` 模式检测，闸门人工兜底）、Doc→Markdown 序列化写回。
