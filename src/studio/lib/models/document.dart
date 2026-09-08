import 'artifact.dart';

/// 文档的一个章节
class DocSection {
  DocSection({required this.id, required this.title, required this.text});

  String id;
  String title;
  String text;
}

/// 版本轴上的一个刻度：一次验收合入形成的版本——哪次任务、谁执行、何时。
/// 归属于文档（它的职责就是记录「当前有效口径」是怎么一步步来的）。
class Revision {
  Revision({
    required this.version,
    required this.taskId,
    required this.taskName,
    required this.executor,
    required this.time,
  });

  int version;
  String taskId;
  String taskName;
  String executor;
  DateTime time;
}

/// 工作物本体：正在被编写的文档。
/// 版本随修订合入递增——它是「当前有效口径」的唯一载体。
class Doc implements Artifact {
  Doc({
    required this.title,
    required this.version,
    required this.sections,
    List<Revision> revisions = const [],
  }) : revisions = List.of(revisions);

  String title;
  int version;
  List<DocSection> sections;

  /// 版本轴（最新在前）：每次合入形成一个刻度
  final List<Revision> revisions;

  /// 合入修订：修改章节正文（before 为空 = 章节末尾追加），版本 +1 并在版本轴留痕。
  /// change.target 当前解析为章节 id
  @override
  void apply(
    List<Change> changes, {
    required String taskId,
    required String taskName,
    required String executor,
    DateTime? time,
  }) {
    for (final c in changes) {
      final idx = sections.indexWhere((s) => s.id == c.target);
      if (idx < 0) continue;
      final sec = sections[idx];
      sec.text = c.before.isEmpty ? '${sec.text}\n${c.after}' : c.after;
    }
    version += 1;
    revisions.insert(
      0,
      Revision(
        version: version,
        taskId: taskId,
        taskName: taskName,
        executor: executor,
        time: time ?? DateTime.now(),
      ),
    );
  }
}
