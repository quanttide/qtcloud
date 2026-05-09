# qtcloud 工作文档

## 定位

qtcloud 承担双重角色：

- **产品组合器**：组合 7 个领域子平台为完整产品线
- **协作层**：提供跨域协作机制，让子平台之间高效互通（详见主仓库 `docs/prd/qtcloud.md`）

## 产品组合

| 子仓库 | 说明 |
|--------|------|
| qtcloud-business | 商务云 - 报价与合同 |
| qtcloud-sales | 销售云 - 获客与客户管理 |
| qtcloud-think | 思考云 - 思维收集与澄清 |
| qtcloud-write | 写作云 - 写作辅助 |
| qtcloud-health | 健康云 - CBT 工具 |
| qtcloud-asset | 数字资产云 - 资产管理 |
| qtcloud-connect | 连接云 - 智能体协作 |

→ [查看产品边界](docs/prd/relations/index.md)

## 协作目录

协作目录是 qtcloud 作为协作层的产品落地，解决跨域业务流程的平台断裂问题：

- **事件目录**：每个域声明自己发布/订阅的事件
- **契约版本管理**：事件 schema 版本化，变更通知所有订阅方
- **跨域流程模板**：预定义业务流程（如 deal.closed → 创建合同 → 准备交付）
- **兼容性检测**：Consumer-Driven Contract 自动化验证

架构上采用事件驱动协作，域之间通过 CloudEvents 标准化事件和 AsyncAPI 契约耦合（参见主仓库 `docs/add/intro/domain_events.md`）。