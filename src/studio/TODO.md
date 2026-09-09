# TODO — qtcloud_studio

来自 [ROADMAP.md](./ROADMAP.md)「日志更新平台化」。流程基准：`data/journal/.agents/skills/fetch-chat-logs` 技能（已验证，只收编不改写法）。

约束：`Doc` / `Change` / `Task` / `Workflow` 零改动，新写的只有三块——飞书连接器、红线自检、Doc→Markdown 序列化写回。

## 1 飞书连接器（新写）

- [ ] 按群名检索解析 chat_id（lark-cli `+chat-search`），本次运行内使用，不落库
- [ ] 拉取指定日期时段消息（`+chat-messages-list`）：ISO 8601 带时区、按时间正序、`page_token` 翻页到 `has_more` 为 false
- [ ] 消息结构化输出：时间、发送者代称（系统消息记 system）、消息类型、内容

## 2 分流与工作物映射（复用 Doc）

- [ ] 来源群 → 业务线目录映射表（量潮实训基地→qtclass、闲聊水库→按内容判断、兜底 default），配置在平台侧
- [ ] 目标工作物 = `<业务线>/YYYY-MM-DD.md` 的 Doc，一个来源群对应一个 DocSection
- [ ] 同日已有文件 = 向同一 Doc 追加 Change（`before` 为空，章节末尾追加），不新建工作物

## 3 红线自检（新写）

- [ ] `oc_` / `ou_` 等 ID 模式检测
- [ ] 真实姓名、经营敏感信息、内部链接检测规则
- [ ] 代称映射表配置在平台侧，不入仓库
- [ ] 自检不通过的段落拦在闸门之前，人工兜底

## 4 流程编排（复用 Workflow）

- [ ] DAG：拉取（日志云）→ 分流成稿（日志云）→ 脱敏验收（用户）→ 写回 + 指针同步（日志云）；云任务自动衔接，人只拍板一次
- [ ] `dispatchIntent` 意图库增加「更新今天的日志」分支（`lib/models/workflow.dart`）
- [ ] 验收闸门：Change 以内联 diff 呈现，对照红线检查；通过合入，驳回走 `Task.reject(note)`

## 5 写回（新写）

- [ ] Doc → Markdown 序列化：文件顶部写「来源：…群」，章节标题标注来源群与时间，事实 + 原话写法，复盘用引用块
- [ ] 写入 journal 仓库并提交（Conventional Commits），主仓库指针同步

## 6 验收

- [ ] 端到端走一遍：一次派活产生当日日志，验收通过后 journal 出现新段落，驳回则 journal 不动
- [ ] 按 AGENTS.md 交互设计评判原则走查并自评分
- [ ] 更新 CHANGELOG.md

## 待明确

- 连接器与写回的运行位置：studio 是内存态 Web 客户端，lark-cli 收编到 provider 服务端还是本地 agent 进程，实现前先定。
