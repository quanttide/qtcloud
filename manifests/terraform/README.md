# qtcloud 部署选型（IaC）

对齐 qtclass 与 qtdata 的部署模式，作为 Terraform 基础设施代码的设计依据。

## 部署选型

| 维度 | 选型 | 说明 |
|------|------|------|
| 门户（Site） | React 静态站（`src/site`，`npm run build`） | 承载 cloud.quanttide.com 主域：产品矩阵 + 工作台入口（门户职责自 Studio 迁入） |
| 工作台（Studio） | Flutter Web（`src/studio`，`flutter build web --release`） | CoWork 形态客户端，规划部署 cowork.cloud.quanttide.com |
| 发布分发 | 阿里云 OSS 桶 `qtcloud-site` / `qtcloud-studio` | 均静态网站托管（index.html 默认页）+ 公共读 |
| CDN | 阿里云 CDN `cloud.quanttide.com`（回源 qtcloud-site）、`cowork.cloud.quanttide.com`（回源 qtcloud-studio，待配置） | 泛域名证书 `*.quanttide.com`（acme.sh 签发，续期后重跑 `scripts/configure-cloud-cdn.sh`） |
| 服务端 | **不适用** | 门户与工作台均为纯客户端（协作目录由 qtcloud-meta 承担，另行规划） |

## 本 IaC 范围

- **应用级**（`qtcloud-<env>` 命名）：
  - `site.tf`：OSS 桶 `qtcloud-site`（桶 + 静态网站托管 + 公共读 + 关闭阻止公共访问）
  - `studio.tf`：OSS 桶 `qtcloud-studio`（同上）
- **不含** 服务计算、数据库、API 网关（客户端无服务端）；CDN / DNS / 证书无组织级 IaC 先例（对齐 qtclass），在控制台配置并记录于本文件

## site 门户发布

- 基础设施：`terraform apply`（`site.tf`）
- 构建上传：`.github/workflows/deploy-site.yml`（推送 tag `site/*` 触发 → vite build → ossutil cp → 刷新 CDN）
- **待执行**（控制台）：cloud.quanttide.com CDN 回源从 `qtcloud-studio.oss-cn-hangzhou.aliyuncs.com` 切至 `qtcloud-site.oss-cn-hangzhou.aliyuncs.com`，切换后刷新缓存验证门户可达

## studio 客户端发布

- 基础设施：`terraform apply`（`studio.tf`）
- 构建上传：`.github/workflows/deploy-studio.yml`（推送 tag `studio/*` 触发 → flutter build web → ossutil cp → 刷新 CDN）
- **待执行**（控制台）：新增 CDN 域名 `cowork.cloud.quanttide.com`，源站 OSS `qtcloud-studio.oss-cn-hangzhou.aliyuncs.com`（type=oss, port=443），挂泛域名证书；DNS CNAME 指向 CDN 生效地址。配置前 studio 工作流的 CDN 刷新步骤会报错（域名不存在），属预期

## 关键操作记录（手动部署踩坑，参考 qtclass）

1. **阻止公共访问**：2023 后新 OSS 桶默认开启"阻止公共访问"，即使 ACL=public-read 匿名访问也返回 `AccessDenied`。已通过 `PutBucketPublicAccessBlock`（`BlockPublicAccess=false`）关闭，并在 `site.tf` / `studio.tf` 固化；如重建桶需注意。
2. **静态网站托管**：桶需配置 `website`（index.html 默认页），否则 CDN 根路径 403。
3. **CDN 配置**（控制台/CLI 完成，`scripts/configure-cloud-cdn.sh` 固化证书与 DNS）：
   - `AddCdnDomain`：`cloud.quanttide.com`，源站 OSS（**已由 qtcloud-studio 切换为 qtcloud-site**，见上方待执行记录）
   - `AddCdnDomain`（待配置）：`cowork.cloud.quanttide.com`，源站 OSS `qtcloud-studio.oss-cn-hangzhou.aliyuncs.com`
   - HTTPS：上传 `*.quanttide.com` 证书（`SetCdnDomainSSLCertificate`，acme.sh 3 个月续期）
   - DNS：对应子域 CNAME → CDN 生效地址（如 `cloud.quanttide.com.w.kunlunaq.com`）

## 使用

```sh
terraform init \
  -backend-config="bucket=quanttide-terraform-state" \
  -backend-config="key=qtcloud/terraform.tfstate" \
  -backend-config="region=cn-hangzhou"
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```
