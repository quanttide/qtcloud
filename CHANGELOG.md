# Changelog

## [Unreleased]

### Changed

- 定位明文：职能执行仓（execute / connect）——README 与 AGENTS 补定位节；journal / profile 禁止移入本仓（住主仓库 `data/` 数据层）

## [0.1.0-alpha.1] - 2026-08-08

### Added

- 门户首页：量潮云产品线矩阵（九云卡片，已上线云跳转对应子域）
- 应用标识：量潮云 / 量潮云工作台（web/index.html 与 manifest.json）
- 部署 CI：`.github/workflows/deploy-studio.yml`（tag `studio/*` 触发，构建上传 OSS 并刷新 CDN）
- IaC：`manifests/terraform`（OSS 桶 `qtcloud-studio`，静态网站托管 + 公共读）
- CDN 配置脚本：`scripts/configure-cloud-cdn.sh`（cloud.quanttide.com）

### Changed

- 门户化：协作目录代码、数据资产与测试迁移至 qtcloud-meta，qtcloud 专注门户
- pubspec 精简依赖，版本基线 0.1.0
