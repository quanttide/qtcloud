# Changelog

## [0.1.0-alpha.1] - 2026-11-21

### Added

- 功能列表：首页列出可用功能，当前只放一个入口——课程云 Lite（课程清单，通识与领域课程的上线状态）→ `lite.course.cloud.quanttide.com`
- h5 构建：`npm run build:h5`（`@tarojs/plugin-platform-h5`，产物 `dist-h5/`，hash 路由），小程序构建不受影响
- 部署链路：`lite/*` tag → `.github/workflows/deploy-lite.yml` 的 `deploy-web` job（Terraform 建桶 → h5 构建 → 上传 OSS → 刷 CDN），域名 `lite.cloud.quanttide.com`
- IaC：`manifests/terraform/lite.tf`（桶 `qtcloud-lite`，静态网站托管 + 关闭阻止公共访问 + 公共读）
- CDN 脚本：`scripts/configure-lite-cdn.sh`（CDN 域名 + acme.sh 单域名证书 + DNS CNAME，对齐 `configure-cloud-cdn.sh` 惯例）
