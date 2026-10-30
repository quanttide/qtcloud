---
name: qtcloud-devops-release
description: 发布 Git 仓库 Release。必须先写 CHANGELOG 再打 tag，禁止跳步。基于 qtcloud-devops CLI，支持 scope 级（lite/cli/studio/provider/site）与根级发布。
---

# qtcloud-devops-release

> **⚠ 硬约束：不执行预检查 → 禁止发布**
> 加载此 Skill 后，必须按下方工作流从头到尾逐行执行命令。
> 标有"必须执行，不可跳过"的步骤是强制性的，AI 不得合并、跳过或提前执行后续步骤。

发布 qtcloud 的版本，经由 `qtcloud-devops` CLI 完成：审计 → 打 tag → 推送 → 创建 GitHub Release。

## 版本号格式

`scope/vX.Y.Z`（如 `cli/v0.1.0`、`lite/v1.0.0`），根级发布用 `vX.Y.Z`。tag 同时是部署触发器：

| tag 形式 | 触发 |
|----------|------|
| `lite/v*` | deploy-lite.yml：构建 Taro 并上传小程序体验版 |
| `studio/**` | deploy-studio.yml：构建上传 OSS 并刷新 CDN |
| `site/**` | deploy-site.yml：门户部署 |

发布这些 scope 前确认对应部署是本次想要的结果。

## 规则

- **必须先更新 CHANGELOG.md（在 scope 子目录，如 `src/lite/CHANGELOG.md`），提交推送，再执行发布**
- 发布前工作区干净（`git status` 无未提交变更）
- 版本号以 CHANGELOG 条目为准；CLI 只自动同步 Cargo.toml / pyproject.toml，package.json / pubspec.yaml 需手动对齐
- scope 子目录没有 CHANGELOG.md 的，先创建并写入 `## [X.Y.Z]` 条目再发布
- GitHub Release 正文取自**根目录** CHANGELOG.md（CLI 0.11 行为）；scope 发布若希望 Release 带说明，根 CHANGELOG 也需有对应 `## [X.Y.Z]` 条目，否则 notes 为空

## 工作流

### 1. 预检查

**必须执行，不可跳过**

```bash
# 单 scope 审计（7 项：版本号格式、配置文件一致性、CHANGELOG、工作区、标签冲突、远程可达性、GitHub Release）
qtcloud-devops release audit --scope <scope>

# 根级发布或查看全局
qtcloud-devops release audit
```

全部通过才继续。常见失败项：

- **CHANGELOG 不存在/缺条目**：到 `src/<scope>/CHANGELOG.md` 补写 `## [X.Y.Z]` 段落，提交推送后重审
- **配置文件版本不一致**：审计检查全部配置文件（含 package.json / pubspec.yaml），但 CLI 只自动改 Cargo.toml / pyproject.toml，其余先手动对齐并提交

### 2. 发布前确认

**向用户展示以下信息并请求确认**

```
发布版本: <scope>/vX.Y.Z

审计结果: 7/7 项通过
部署影响: 推送 tag 将触发 <deploy-lite.yml / 无 / ...>

待执行命令:
qtcloud-devops release publish -v <scope>/vX.Y.Z

确认发布? (y/n)
```

### 3. 发布

```bash
# 预览，不执行任何操作
qtcloud-devops release publish -v <scope>/vX.Y.Z --dry-run

# 正式发布（交互确认；-y 跳过确认）
qtcloud-devops release publish -v <scope>/vX.Y.Z
```

CLI（0.11，Plan → Confirm → Execute 三段）内部流程：Plan 只读计算配置更新与 CHANGELOG 内容（LLM 生成，失败不阻断）→ 用户确认 → Execute 写入 Cargo.toml / pyproject.toml / Cargo.lock / CHANGELOG 并自动 git commit（`chore: prepare release …`）→ 创建 tag → 推送 tag → 创建 GitHub Release（自动识别 origin 仓库，Release 已存在视为成功）。推送或 Release 失败时 CLI 自动回滚本地 tag。

注意：**CLI 只推送 tag，不推送分支**——自动产生的版本提交在本地分支上，需另行 `git push` 同步，否则下次拉取会出现分叉。

省略 `-v` 时 CLI 用 LLM 依据提交记录建议版本号；正式发布建议显式指定。

### 4. 发布后核对

```bash
# 确认 Release 已创建
gh release view <scope>/vX.Y.Z --repo quanttide/qtcloud

# CLI 自动提交的版本变更只随 tag 推送，分支需手动同步
git status   # 若有 "chore: prepare release" 之类的新提交，git push 同步分支
```

若需强制重新发布（删除旧 tag 与 Release 后重建）：`qtcloud-devops release publish -v <scope>/vX.Y.Z -f`。

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| CHANGELOG.md 不存在 | scope 子目录没有 CHANGELOG | 创建并写入版本条目后再发布 |
| CHANGELOG.md 未找到版本记录 | 忘记写条目或版本号不匹配 | 补 `## [X.Y.Z]` 条目（去 v 前缀） |
| 配置文件版本不一致 | package.json/pubspec.yaml 与目标版本不符 | 手动对齐版本号并提交 |
| 标签已存在 | 重复发布 | audit 会判不通过；publish 不阻断会复用旧 tag，确认后可用 `-f` 强制重建（删除旧 tag 与 Release 后重发） |
| Release notes 为空 | GitHub Release 正文取自根目录 CHANGELOG.md，scope 发布时根 CHANGELOG 无对应条目 | 需要带说明时在根 CHANGELOG 补 `## [X.Y.Z]` 条目 |
| LLM 未配置提示 | `LLM_API_KEY` 未设置时 CLI 无法自动生成 CHANGELOG / 建议版本号 | 按规则先手写 CHANGELOG，不依赖自动生成 |

## 预发布检查清单

- [ ] 预检查（release audit）全部通过
- [ ] CHANGELOG 条目已提交推送
- [ ] 工作区干净
- [ ] 已确认该 tag 触发的部署行为符合预期
- [ ] 已向用户确认发布
