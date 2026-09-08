# ROADMAP — Provider

> Provider 定位：量潮云门户（Studio / Site）的服务端。当前为骨架占位——门户为纯客户端形态（Flutter Web + OSS 静态托管，见 `../../manifests/terraform/README.md`），无服务端部署；本目录按仓库惯例预留 Go 服务骨架，待门户出现真实服务端需求后立项。

## 背景

Studio ROADMAP 规划「数据源：本地 assets JSON 起步，预留服务端接口」。协作目录的元模型由 qtcloud-meta 重新规划，服务端形态待其落地后再定。在此之前，本服务只维持骨架与部署就绪状态，不做超前建设——对齐产品纪律：先有真实痛点再立项。

## 版本规划

### v0.1（当前）— 服务骨架

- [x] Go 标准库 + `/healthz`（技术栈对齐 qtclass-provider）
- [x] 环境变量配置（`LISTEN_ADDR`）
- [ ] FC 部署 manifests 与发布管道（出现服务端接口需求时补齐，对齐 qtclass 的 deploy-provider 模式）

### v0.2（待立项）— 门户服务端接口

方向候选（以 qtcloud-meta 落地与 studio 闭环进度为准）：

- 门户数据接口：产品矩阵、各云卡片数据的契约下发（替代本地 assets JSON）
- 协作目录服务端：事件、契约、工作流的读写通道
