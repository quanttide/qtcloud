import 'artifact.dart';
import 'task.dart';

/// 工作流：任务按依赖编排成的 DAG。
/// 河床的调度语义在这里：就绪判定、自动衔接的对象筛选、派活；
/// 验收闸门也在这里——任务闭环，产出经 Artifact 接口合入工作物。
/// 工作物被引用而不被拥有（归属空间），因此工作流不依赖任何具体工作物类型。
class Workflow {
  Workflow({required this.tasks, required this.artifact});

  List<Task> tasks;

  /// 工作物引用：任务产出的修订合入到这里
  final Artifact artifact;

  Task? byId(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// 就绪 = 待办且上游全部验收通过
  bool isReady(Task t) =>
      t.status == TaskStatus.pending &&
      t.dependsOn.every((d) => byId(d)?.status == TaskStatus.done);

  /// 就绪且等待开工的云任务——自动衔接的对象
  List<Task> readyCloudTasks() =>
      tasks.where((t) => t.executor != '用户' && isReady(t)).toList();

  /// 验收闸门：任务闭环，修订合入工作物。
  /// 无修订提案的任务（如定稿检查）只记完成，工作物版本不动——版本号不撒谎。
  bool approve(Task t) {
    if (!t.approve()) return false;
    final changes = t.output ?? const <Change>[];
    if (changes.isNotEmpty) {
      artifact.apply(
        changes,
        taskId: t.id,
        taskName: t.name,
        executor: t.executor,
      );
    }
    return true;
  }

  /// 派活：意图库匹配（demo 为预排剧本；正式实现由协作目录 + LLM 承担）。
  /// 听不懂返回 null，不塞假任务。
  Task? dispatchIntent(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return null;
    Task? created;
    if (RegExp(r'确认').hasMatch(clean)) {
      created = Task(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        name: '增加客户确认环节',
        executor: '用户',
        status: TaskStatus.pending,
        dependsOn: [],
        output: [
          Change(target: 's5', before: '', after: '各阶段交付后需客户书面确认，方可进入下一阶段。'),
        ],
      );
    } else if (RegExp(r'英文|摘要').hasMatch(clean)) {
      created = Task(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        name: '补充英文摘要',
        executor: '写作云',
        status: TaskStatus.pending,
        dependsOn: [],
        output: [
          Change(
            target: 's1',
            before: '',
            after:
                'Abstract: Data governance for 5 research groups at A University — weekly cleansing, 45 person-days, 6-week delivery.',
          ),
        ],
      );
    }
    if (created != null) tasks.add(created);
    return created;
  }
}
