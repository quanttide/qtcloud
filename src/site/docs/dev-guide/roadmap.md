# ROADMAP

门户职责自 Studio 迁入：cloud.quanttide.com 主域由 Site 承载（产品矩阵 + 工作台入口），Studio 专注 CoWork 工作台形态（见 `../studio/ROADMAP.md`）。部署形态对齐 qtclass-site（静态构建 + OSS 托管 + CDN）。

## v0.1.0

- [x] 工程初始化：React 19 + TypeScript + Vite，对齐 qtclass-site 技术栈
- [x] 门户首页：产品理念 + 产品矩阵（9 云卡片，含上线状态）+ 工作台入口
- [x] 部署链路：`deploy-site.yml`（site/* tag → vite build → OSS 桶 qtcloud-site → CDN 刷新）
- [ ] 域名切换：cloud.quanttide.com CDN 回源从 qtcloud-studio 切至 qtcloud-site 桶（控制台操作），工作台迁至 cowork.cloud.quanttide.com

## v0.2.0

- [ ] 各云子页：接入各云的对外介绍内容（来源：`data/intention`、档案库）
- [ ] 产品矩阵数据契约化：卡片数据从本地 JSON 契约读取，对齐数据驱动的产品研发方法
