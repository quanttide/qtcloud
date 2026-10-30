# Changelog

本文件仅记录 **cli（量潮云 CLI，Rust）** 的版本变更。

## [Unreleased]

## [0.1.0-alpha.1] - 2026-10-30

首个版本：命令面为 `skills`（内置 agent skills 管理），退出码契约冻结。

### Added

- `skills list` / `skills install`：内置 agent skills 的列出与安装（agent-skills-rs，canonical 目录 `.agents/skills/`，符号链接失败回落复制）
- 内置 skill `qtcloud-devops-release`：本仓发布流程（`qtcloud-devops release audit` → `publish`），源文件 `skills/qtcloud-devops-release/SKILL.md` 编译期嵌入
- 退出码契约 `src/core/exit.rs`：四码 0/1/2/3（OK / FINDINGS / USAGE / NOT_FOUND），冻结锚点测试钉住
- 发布脚本 `scripts/validate-version.sh`、`scripts/validate-changelog.sh`（对齐 qtcloud-work / qtcloud-devops）
