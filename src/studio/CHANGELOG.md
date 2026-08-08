# CHANGELOG

## [0.1.0-alpha.1] - 2026-08-08

**Added**
- 新增量潮云系列产品定义与 PRD，涵盖知识云、写作云、沟通云、量潮云、智能体云、执行云和财务云
- 新增协作目录相关文档（PRD、交互设计、架构设计）及产品组合与边界说明
- 新增量潮云工作室 Flutter 客户端（qtcloud_studio）及编辑器示例
- 新增 qtcloud-cli 命令行工具基础工程、依赖锁文件与 gitignore 配置
- 新增 Apache 2.0 协议、README 及 devops-release 技能

**Changed**
- 将 studio 库迁移至 qtcloud-meta，并更新应用名为量潮云
- 重构量潮云工作台为门户化，协作目录代码与数据迁移至 qtcloud-meta
- 重写产品介绍和协作目录 PRD，采用面向场景的叙述方式
- 简化交互设计页面，围绕事件-契约-工作流概念重新组织
- 对齐 qtclass/qtdata 模式，新增 IaC 与部署 CI 配置

**Fixed**
- 重新设计页面，修复 GoRouter、TabBar、EventCard 溢出、ContractScreen 模型与导航问题
- 恢复之前误删的协作目录 ADD 文档

**Removed**
- 移除重复的 devops-release 技能
