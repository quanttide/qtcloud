import 'document.dart';
import 'task.dart';

/// 一次验收合入的版本记录
class HistoryEntry {
  HistoryEntry({
    required this.version,
    required this.taskName,
    required this.executor,
    required this.time,
  });

  int version;
  String taskName;
  String executor;
  String time;
}

/// Workspace：围绕一个上下文组织工作的容器（demo 硬编码单空间，空间之间保持独立）
class WorkspaceState {
  WorkspaceState({
    required this.name,
    required this.goal,
    required this.boundary,
    required this.doc,
    required this.tasks,
    this.history = const [],
  });

  String name;
  String goal;
  String boundary;
  Doc doc;
  List<Task> tasks;
  List<HistoryEntry> history;

  Task? byId(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// 就绪 = 待办且上游全部验收通过（河床规则的调度语义）
  bool isReady(Task t) =>
      t.status == TaskStatus.pending &&
      t.dependsOn.every((d) => byId(d)?.status == TaskStatus.done);

  /// 首个 Workspace：招聘政策案例同源的数据业务场景（见 docs/dev-guide/studio.md）
  static WorkspaceState seed() {
    return WorkspaceState(
      name: 'A 校数据治理项目',
      goal: '完成项目方案与报价，形成可发给客户的定稿',
      boundary: '仅限本项目方案文档，不含合同与后续交付物',
      doc: Doc(
        title: 'A 校数据治理项目方案',
        version: 1,
        sections: [
          DocSection(
            id: 's1',
            title: '背景与目标',
            text:
                'A 校经济学院累积了近十年的科研调查数据，格式分散、口径不一，'
                '需要建立统一的数据治理流程，支撑后续的课题申报与数据共享。',
          ),
          DocSection(
            id: 's2',
            title: '数据范围',
            text:
                '覆盖 5 个课题组的调查数据（约 12 万条记录）与 3 类仪器采集数据，'
                '不含人事与学生个人信息。',
          ),
          DocSection(
            id: 's3',
            title: '处理流程',
            text: '数据按月集中清洗，由学院管理员统一提交；清洗结果次月中旬以邮件形式反馈。',
          ),
          DocSection(
            id: 's4',
            title: '报价',
            text: '数据清洗与治理服务按人天计费，预估 60 人天，单价按量潮数据标准价目执行。',
          ),
          DocSection(
            id: 's5',
            title: '交付计划',
            text: '项目周期 30 天：第 1 周数据盘点，第 2-3 周清洗治理，第 4 周验收交接。',
          ),
        ],
      ),
      tasks: [
        Task(
          id: 't1',
          name: '数据可行性评估',
          executor: '数据云',
          status: TaskStatus.running,
          dependsOn: [],
          deliverable: '评估了客户数据源的更新频率与清洗窗口',
          output: [
            Change(
              sectionId: 's3',
              before: '数据按月集中清洗，由学院管理员统一提交；清洗结果次月中旬以邮件形式反馈。',
              after:
                  '数据按周清洗：客户数据源每周更新一次，按月集中会造成积压；'
                  '清洗结果当周内通过共享看板反馈。',
            ),
          ],
        ),
        Task(
          id: 't2',
          name: '报价核算',
          executor: '执行云',
          status: TaskStatus.pending,
          dependsOn: ['t1'],
          deliverable: '按周清洗节奏重估了工时',
          output: [
            Change(
              sectionId: 's4',
              before: '预估 60 人天，单价按量潮数据标准价目执行。',
              after:
                  '改为按周迭代交付，预估 45 人天（减少月末集中返工）；'
                  '单价按量潮数据标准价目执行，总价对应下浮。',
            ),
          ],
        ),
        Task(
          id: 't3',
          name: '交付条款检查',
          executor: '议事云',
          status: TaskStatus.pending,
          dependsOn: ['t2'],
          deliverable: '检查了交付周期承诺与数据源更新频率的匹配',
          output: [
            Change(
              sectionId: 's5',
              before: '项目周期 30 天：第 1 周数据盘点，第 2-3 周清洗治理，第 4 周验收交接。',
              after:
                  '项目周期 6 周：第 1 周数据盘点，第 2-5 周按周迭代清洗治理'
                  '（每周五向客户同步进展），第 6 周验收交接。',
            ),
          ],
        ),
        Task(
          id: 't4',
          name: '方案定稿检查',
          executor: '用户',
          status: TaskStatus.pending,
          dependsOn: ['t1', 't2', 't3'],
        ),
      ],
    );
  }
}
