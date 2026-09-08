// 概念契约的最小 schema，镜像工程标准的通用语言
// （quanttide-specification-of-business-entity/work/index.md：Workspace / Task / Workflow）

export type Executor = string

export type TaskStatus = '待办' | '执行中' | '待验收' | '完成'

export interface Task {
  id: string
  name: string // 步骤名称
  executor: Executor // 执行者：云 / 人
  status: TaskStatus
  dependsOn: string[] // 上游任务 id，依赖构成流程 DAG 的边
  deliverable?: string // 交付物说明（提交验收时填写）
  review?: string // 验收意见（驳回时回传执行者）——完成判定的一部分
}

export interface Workspace {
  name: string
  context: {
    goal: string // 上下文：目标
    boundary: string // 上下文：边界
  }
  tasks: Task[]
}
