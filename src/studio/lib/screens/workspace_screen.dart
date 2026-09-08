import 'package:flutter/material.dart';

/// 工作台占位骨架：门户已迁移至 Site（cloud.quanttide.com）。
/// 核心模型：Workspace × 流程 DAG × 单上下文——先跑通量潮自己的工作流，
/// Workspace 之间保持独立（见 ROADMAP.md）。
class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('量潮云工作台')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('任务工作台规划中', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Workspace · 流程 DAG · 单上下文',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
