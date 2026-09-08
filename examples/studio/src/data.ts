import type { Workspace } from './types'

// 首个 Workspace：招聘政策案例（见 data/roadmap/qtcloud/product.md 验收场景）
export const seedWorkspace: Workspace = {
  name: '招聘政策修订',
  context: {
    goal: '修订招聘政策并形成可验收的交付草案',
    boundary: '仅限量潮招聘政策，不涉及其他业务线制度',
  },
  tasks: [
    {
      id: 't1',
      name: '收集现行政策条款',
      executor: '用户',
      status: '完成',
      dependsOn: [],
      deliverable: '现行政策条款清单（12 条）',
    },
    {
      id: 't2',
      name: '提取政策要点与本体',
      executor: '知识云',
      status: '执行中',
      dependsOn: ['t1'],
    },
    {
      id: 't3',
      name: '起草政策修订草案',
      executor: '写作云',
      status: '待办',
      dependsOn: ['t2'],
    },
    {
      id: 't4',
      name: '合规性校验',
      executor: '议事云',
      status: '待办',
      dependsOn: ['t3'],
    },
    {
      id: 't5',
      name: '数据合规检查',
      executor: '数据云',
      status: '待办',
      dependsOn: ['t3'],
    },
    {
      id: 't6',
      name: '汇总交付草案',
      executor: '用户',
      status: '待办',
      dependsOn: ['t4', 't5'],
    },
  ],
}
