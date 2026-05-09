# 事件目录页

## 组件设计

```
EventCatalogScreen
└── Vertical (主容器)
    ├── SearchBar (搜索框，按事件名、域、关键字搜索)
    ├── FilterRow (筛选行)
    │   ├── Chip (域筛选：全部/销售云/商务云/资产云/...)
    │   ├── Chip (方向筛选：全部/发布/订阅)
    │   └── Chip (状态筛选：全部/活跃/已弃用)
    └── ScrollView (事件列表)
        ├── EventCard (事件卡片 1)
        ├── EventCard (事件卡片 2)
        └── EventCard (事件卡片 3, ... etc.)
```

## 交互说明

- 默认按域分组展示，每个域为一个分区
- 搜索时实时过滤，高亮匹配关键字
- 点击 EventCard 进入事件详情页
