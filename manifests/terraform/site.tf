# site 门户静态托管桶（IaC）
#
# 桶 qtcloud-site：命名对齐站点规范 {repo}-{type}（如 qtclass-site）。
# 产物：React 门户（vite build，index.html + assets/）。
# 静态网站托管：门户作为默认首页（cloud.quanttide.com 根路径）。
# 部署流水线：.github/workflows/deploy-site.yml（site/* tag 触发 → vite build → ossutil cp → 刷新 CDN）。
# 域名切换：cloud.quanttide.com CDN 回源从 qtcloud-studio 切至本桶（控制台操作，记录于 README）。

resource "alicloud_oss_bucket" "site" {
  bucket = "qtcloud-site"

  # 静态网站托管（门户入口 index.html）
  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

# 2023 后新桶默认开启"阻止公共访问"，会使 public-read 失效（AccessDenied），
# 需显式关闭（qtcloud-studio 桶踩过此坑，见 README）
resource "alicloud_oss_bucket_public_access_block" "site" {
  bucket              = alicloud_oss_bucket.site.bucket
  block_public_access = false
}

# 公共读：门户静态资源分发；如后续接入 CDN 回源鉴权可改回 private
resource "alicloud_oss_bucket_acl" "site" {
  bucket = alicloud_oss_bucket.site.bucket
  acl    = "public-read"
}
