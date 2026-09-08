import 'artifact.dart';

/// 工作的执行者：云 / 人。人机同构——同一套任务协议。
typedef Executor = String;

/// 任务状态机：待办 → 执行中 → 待验收 → 完成；驳回（待验收 → 执行中）是唯一的回流。
/// 任何其他迁移都不合法。
enum TaskStatus {
  pending('待办'),
  running('执行中'),
  reviewing('待验收'),
  done('完成');

  const TaskStatus(this.label);

  final String label;

  /// 合法的状态迁移
  bool canGoTo(TaskStatus next) => switch (this) {
    TaskStatus.pending => next == TaskStatus.running,
    TaskStatus.running => next == TaskStatus.reviewing,
    TaskStatus.reviewing =>
      next == TaskStatus.done || next == TaskStatus.running,
    TaskStatus.done => false,
  };
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

  /// 开始：待办 → 执行中
  bool start() => _transitionTo(TaskStatus.running);

  /// 交付 / 提交验收：执行 → 待验收。人的任务必须填写交付说明
  bool deliver() {
    if (executor == '用户' && (deliverable ?? '').trim().isEmpty) return false;
    return _transitionTo(TaskStatus.reviewing);
  }

  /// 验收通过：待验收 → 完成
  bool approve() => _transitionTo(TaskStatus.done);

  /// 驳回：待验收 → 执行中，意见回传
  bool reject(String note) {
    if (!_transitionTo(TaskStatus.running)) return false;
    review = note;
    deliverable = '已按意见修改：$note';
    return true;
  }

  bool _transitionTo(TaskStatus to) {
    if (!status.canGoTo(to)) return false;
    status = to;
    return true;
  }
}
