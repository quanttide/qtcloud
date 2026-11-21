#!/bin/bash
# 为 lite.cloud.quanttide.com 配置 CDN（源站 OSS 桶 qtcloud-lite）+ HTTPS 证书 + DNS CNAME。
#
# 桶见 manifests/terraform/lite.tf（由 deploy-lite.yml 的 terraform job 创建）；
# 发布见 .github/workflows/deploy-lite.yml 的 deploy-web job。
# 证书为 acme.sh 单域名（*.quanttide.com 不覆盖二级子域），续期 reloadcmd 自动重绑：
#   ~/.acme.sh/deploy-cdn-cert-qtcloud-lite.sh
#
# 本仓惯例：桶进 terraform，CDN 与证书走脚本（对齐 configure-cloud-cdn.sh）。
#
# 前置：本机已登录 aliyun CLI（AK 模式）；acme.sh 已签发该域名证书。
set -euo pipefail

DOMAIN='lite.cloud.quanttide.com'
BUCKET='qtcloud-lite'
ALIYUN="$HOME/.local/bin/aliyun"
CERT_DIR="$HOME/.acme.sh/${DOMAIN}_ecc"

[ -f "$CERT_DIR/fullchain.cer" ] || { echo "证书不存在：$CERT_DIR（先 acme.sh --issue）" >&2; exit 1; }

echo "=== 1. 建 CDN 域名（已存在则跳过）==="
if "$ALIYUN" cdn DescribeCdnDomainDetail --DomainName "$DOMAIN" >/dev/null 2>&1; then
  echo "CDN 域名已存在，跳过"
else
  "$ALIYUN" cdn AddCdnDomain \
    --DomainName "$DOMAIN" \
    --CdnType web \
    --Sources "[{\"content\":\"${BUCKET}.oss-cn-hangzhou.aliyuncs.com\",\"type\":\"oss\",\"port\":80,\"priority\":20}]"
fi

echo "=== 2. 绑定 HTTPS 证书（CDN）==="
# PEM 保留换行（压成单行会报 InvalidSSLPub）
"$ALIYUN" cdn SetCdnDomainSSLCertificate \
  --DomainName "$DOMAIN" \
  --CertType upload \
  --SSLProtocol on \
  --SSLPub "$(cat "$CERT_DIR/fullchain.cer")" \
  --SSLPri "$(cat "$CERT_DIR/${DOMAIN}.key")"
echo "证书已绑定"

echo "=== 3. DNS CNAME（已存在则跳过）==="
# RRKeyWord 会误匹配前缀，需在结果里精确过滤 RR=lite.cloud 且 Type=CNAME
EXISTING=$("$ALIYUN" alidns DescribeDomainRecords --DomainName quanttide.com --RRKeyWord lite.cloud 2>/dev/null | python3 -c "
import sys, json
try:
    recs = json.load(sys.stdin).get('DomainRecords', {}).get('Record', [])
    print(len([r for r in recs if r.get('RR') == 'lite.cloud' and r.get('Type') == 'CNAME']))
except Exception:
    print(0)
")
if [ "$EXISTING" -gt 0 ]; then
  echo "CNAME 记录已存在，跳过"
else
  "$ALIYUN" alidns AddDomainRecord \
    --DomainName quanttide.com \
    --RR lite.cloud \
    --Type CNAME \
    --Value "${DOMAIN}.w.kunlunaq.com"
fi

echo "=== 完成：https://${DOMAIN}/ ===="
