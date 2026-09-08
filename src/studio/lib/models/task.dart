import 'document.dart';

/// 工作的执行者：云 / 人。人机同构——同一套任务协议。
typedef Executor = String;

/// 任务状态：待办 → 执行中 → 待验收 → 完成（驳回回到执行中）
enum TaskStatus {
  pending('待办'),
  running('执行中'),
  reviewing('待验收'),
  done('完成');

  const TaskStatus(this.label);

  final String label;
}

class Task {
  Task({
    required this.id,
    required this.name,
    required this.executor,
    required this.status,
    required this.dependsOn,
    this.deliverable,
    this.review,
    this.output,
  });

  String id;
  String name;
  Executor executor;
  TaskStatus status;
  List<String> dependsOn;
  String? deliverable;
  String? review;

  /// 任务产出：对文档的修订提案，验收通过即合入
  List<Change>? output;
}
