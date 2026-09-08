# qtcloud_studio

量潮云工作台（Flutter 客户端），按 CoWork 形态规划：自然语言派活 → 任务拆解 → 各云执行 → 交付验收。门户已迁移至 qtcloud-site（cloud.quanttide.com），规划见 `ROADMAP.md`。

首屏已从 `examples/studio` v3 移植：方案工作物居中、内联 diff 验收、河床自动流转（就绪云任务自动开工，人只在闸门出现）。设计与评判原则见 `docs/dev-guide/studio.md` 与仓库根 `AGENTS.md`。

## 开发

```bash
flutter pub get
flutter run -d chrome
flutter build web --release
```

## 部署

推送 `studio/*` tag 触发 `.github/workflows/deploy-studio.yml`：Flutter Web 构建 → OSS 桶 `qtcloud-studio` → CDN（cowork.cloud.quanttide.com，待控制台配置）。
