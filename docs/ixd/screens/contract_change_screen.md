# 契约变更页

## 组件设计

```
ContractChangeScreen
└── Vertical (主容器)
    ├── Section (变更概览)
    │   ├── Label (事件：deal.closed)
    │   ├── Label (来源域：销售云)
    │   ├── Label (变更人：张三)
    │   ├── Label (提交时间：2026-05-09 14:00)
    │   └── Label (状态：等待确认)
    ├── Section (变更内容 - Diff 视图)
    │   ├── DiffRow (+ 字段：discountRate, Number, 可选)
    │   └── DiffRow (~ 字段：amount, 描述更新)
    ├── Section (影响范围)
    │   ├── SubscriberRow (商务云 - 已确认)
    │   │   ├── StatusIcon (绿色 ✓)
    │   │   └── ConfirmTime (2026-05-09 15:30)
    │   ├── SubscriberRow (资产云 - 待确认)
    │   │   ├── StatusIcon (黄色 ⏳)
    │   │   └── Deadline (2026-05-16 14:00)
    │   └── SubscriberRow (财务云 - 拒绝)
    │       ├── StatusIcon (红色 ✗)
    │       └── Reason (需要调整 discountRate 默认值)
    └── ButtonBar (底部操作栏 - 仅变更发起人可见)
        ├── Button (撤回变更)
        └── Button (确认发布 - 全部确认后可用)
```

## 交互说明

- Diff 视图只展示变更部分，未变字段折叠
- 订阅方可操作：确认 / 拒绝（带原因）/ 提议修改
- 全部确认后"确认发布"按钮亮起，点击后新版本上线
- 任一订阅方拒绝后，变更发起人需协调解决
- 超时未确认自动视为拒绝（deadline = 提交后 7 天）
