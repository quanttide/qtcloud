# 事件详情页

## 组件设计

```
EventDetailScreen
└── ScrollView (主容器)
    ├── Section (基本信息)
    │   ├── Label (事件名称：deal.closed)
    │   ├── Label (来源域：销售云)
    │   ├── Label (方向：发布)
    │   ├── Label (状态：活跃)
    │   └── Label (描述：商机成交时触发，含金额和客户信息)
    ├── Section (Schema)
    │   ├── Label (版本：v2.1)
    │   ├── FieldRow (字段：dealId, String, 必填)
    │   ├── FieldRow (字段：amount, Number, 必填)
    │   ├── FieldRow (字段：customerId, String, 必填)
    │   └── FieldRow (字段：remark, String, 可选)
    ├── Section (示例负载)
    │   └── CodeBlock (JSON 示例)
    ├── Section (订阅方)
    │   ├── SubscriberRow (商务云 - contract.signed)
    │   └── SubscriberRow (资产云 - delivery.prepared)
    ├── Section (版本历史)
    │   ├── VersionRow (v2.1 - 当前)
    │   ├── VersionRow (v2.0 - 添加 remark 字段)
    │   └── VersionRow (v1.0 - 初始版本)
    └── ButtonBar (底部操作栏)
        ├── Button (订阅此事件)
        └── Button (提交流变更)
```

## 交互说明

- Schema 版本切换：点击版本历史中的版本，Schema 区域切换显示对应版本
- 订阅按钮：点击后当前用户所在域订阅此事件，需确认数据映射
- 提交流变更：只有事件所属域的团队可操作，跳转至契约变更页
