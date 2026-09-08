import 'document.dart';
import 'workflow.dart';

/// Workspace：围绕一个上下文组织工作的容器（demo 硬编码单空间，空间之间保持独立）。
/// 拥有工作物（Doc）与工作流（Workflow）；工作流引用工作物完成编排，
/// 空间本身不搬运状态——调度在工作流上，闸门也在工作流上。
class Workspace {
  Workspace({
    required this.name,
    required this.goal,
    required this.boundary,
    required this.doc,
    required this.workflow,
  });

  String name;
  String goal;
  String boundary;
  Doc doc;
  Workflow workflow;
}
