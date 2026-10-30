# qtcloud_studio

量潮云工作台（Flutter 客户端）。

**当前状态：仅保留入口壳。** CoWork 工作台功能（方案工作物、内联 diff 验收、河床自动流转、意图派活）、CoWork 模型层、journal 日志模块与 seed 数据均已移除，只余可启动的 `lib/main.dart` + `lib/theme.dart`。设计与评判原则见主仓 `data/intention/qtfounder/studio.md` 与仓库根 `AGENTS.md`。

## 开发

```bash
flutter pub get
flutter run -d chrome
flutter build web --release
```

## 部署

推送 `studio/*` tag 触发 `.github/workflows/deploy-studio.yml`：Flutter Web 构建 → OSS 桶 `qtcloud-studio` → CDN（cowork.cloud.quanttide.com，待控制台配置）。
