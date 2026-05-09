# 流程模板页

## 组件设计

```
WorkflowTemplateScreen
└── Vertical (主容器)
    ├── Section (预置模板)
    │   ├── TemplateCard (成交转化)
    │   │   ├── WorkflowChain (销售云 deal.closed → 商务云 创建合同)
    │   │   ├── Badge (已启用) / Button (启用)
    │   │   └── Meta (启用时间 / 启用者)
    │   ├── TemplateCard (订单交付)
    │   │   ├── WorkflowChain (商务云 contract.signed → 资产云 准备交付)
    │   │   └── Button (启用)
    │   └── TemplateCard (开票收款)
    │       ├── WorkflowChain (商务云 contract.invoiced → 财务云 创建应收)
    │       └── Button (启用)
    └── Section (自定义流程)
        ├── Composer (拖拽区域：从左侧事件列表拖入)
        │   ├── EventNode (源事件)
        │   ├── Arrow (连接线)
        │   └── ActionNode (目标动作)
        ├── Button (保存为模板)
        └── Button (启用流程)
```

## 交互说明

- 预置模板可直接启用，启用后显示状态和操作人
- 自定义流程支持拖拽：从事件目录拖事件到编排区，在事件之间画连线
- 每个事件节点可配置数据映射：源字段 → 目标字段
- 保存为模板后可在自定义列表中复用
