# lite 门户静态托管桶（IaC）
#
# 桶 qtcloud-lite：命名对齐站点规范 {repo}-{type}（如 qtcloud-site）。
# 产物：Taro h5（npm run build:h5，dist-h5/）。
# 静态网站托管：index.html 为入口（hash 路由，深链接回退首页）。
# 部署流水线：.github/workflows/deploy-lite.yml 的 deploy-web job（lite/* tag 触发）。
# 域名：lite.cloud.quanttide.com，CDN 与 DNS 见 scripts/configure-lite-cdn.sh（本仓惯例：
# 桶进 terraform，CDN/证书走脚本，对齐 configure-cloud-cdn.sh）。

resource "alicloud_oss_bucket" "lite" {
  bucket = "qtcloud-lite"

  # 静态网站托管（h5 入口 index.html）
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# 2023 后新桶默认开启"阻止公共访问"，会使 public-read 失效（AccessDenied），
# 需显式关闭（qtcloud-studio 桶踩过此坑，见 README）
resource "alicloud_oss_bucket_public_access_block" "lite" {
  bucket              = alicloud_oss_bucket.lite.bucket
  block_public_access = false
}

# 公共读：站点静态资源分发；如后续接入 CDN 回源鉴权可改回 private
resource "alicloud_oss_bucket_acl" "lite" {
  bucket = alicloud_oss_bucket.lite.bucket
  acl    = "public-read"
}
