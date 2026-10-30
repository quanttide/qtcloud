# qtcloud-cli

量潮云命令行工具。

## 命令

### skills

内置 agent skills 管理：skill 源文件在 `skills/`（`qtcloud-` 前缀命名），编译期嵌入二进制，运行时安装到目标仓的 `.agents/skills/`。

```bash
qtcloud skills list                                      # 列出内置 skills
qtcloud skills install                                   # 安装全部到当前目录
qtcloud skills install --skill qtcloud-devops-release    # 只装指定的
qtcloud skills install --dir /path/to/repo               # 装到指定仓
```

## 退出码

语义单点定义在 `src/core/exit.rs`，各命令只消费，不自带字面量：

| 码 | 常量 | 含义 |
|:--:|------|------|
| 0 | OK | 跑通，无命中 |
| 1 | FINDINGS | 跑通，有命中 |
| 2 | USAGE | 用法或环境错 |
| 3 | NOT_FOUND | 目标缺席（输入写法没错，对象不在） |

## 开发

```bash
cargo build        # 构建
cargo test         # 测试（含退出码冻结锚点）
cargo clippy       # lint
```
