# qtcloud-site

量潮云门户网站，基于 React + TypeScript + Vite 构建。承载 cloud.quanttide.com 主域：产品理念、产品矩阵（各云上线状态）与工作台入口。门户职责自 Studio 迁入，Studio 专注 CoWork 工作台形态。

## 开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览生产版本
npm run preview
```

## 技术栈

- React 19
- TypeScript
- Vite
- React Router（预留，多页面后引入）

## 项目结构

```
src/
├── App.tsx              # 主应用组件（门户首页：理念 + 产品矩阵 + 工作台入口）
├── App.css              # 应用样式
├── index.css            # 全局样式
├── main.tsx             # 入口文件
└── vite-env.d.ts        # Vite 类型声明
```
