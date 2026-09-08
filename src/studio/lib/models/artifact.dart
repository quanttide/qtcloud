// 工作物：可被修订合入的工作对象，及其修订提案。
// 工作物归属于空间，被工作流引用——工作流通过此接口向工作物交付产出。

/// 修订提案：对工作物内某个可寻址对象的修改，验收通过即合入。
/// target 是寻址键（当前为章节 id；before 为空表示在章节末尾追加）
class Change {
  Change({required this.target, required this.before, required this.after});

  String target;
  String before;
  String after;
}

/// 工作物接口：能吸收修订提案并推进自身版本的对象。
/// 工作流只依赖此抽象——工作物可以是文档、数据集、代码仓等任何成果形态。
abstract class Artifact {
  /// 合入修订，版本 +1 并在版本轴留痕
  void apply(
    List<Change> changes, {
    required String taskId,
    required String taskName,
    required String executor,
    DateTime? time,
  });
}
