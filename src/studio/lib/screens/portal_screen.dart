import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _Cloud {
  final String name;
  final String description;
  final String? url;

  const _Cloud(this.name, this.description, {this.url});
}

const _clouds = <_Cloud>[
  _Cloud('议事云', '决议管理，角色议事', url: 'https://delib.cloud.quanttide.com'),
  _Cloud('数据云', '数据工程平台', url: 'https://data.cloud.quanttide.com'),
  _Cloud('知识云', '语义中枢，本体建模'),
  _Cloud('写作云', '叙事秩序引擎'),
  _Cloud('执行云', '消除混乱，拿走空瓶子'),
  _Cloud('沟通云', '价值传播与责任'),
  _Cloud('智能体云', '上下文的具身化'),
  _Cloud('客服云', '无人值守与信任'),
  _Cloud('资产云', '数字资产治理'),
];

class PortalScreen extends StatelessWidget {
  const PortalScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('无法打开 $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('量潮云工作台')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('量潮云产品线', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 720 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: _clouds.length,
                itemBuilder: (context, index) =>
                    _buildCloudCard(context, _clouds[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCloudCard(BuildContext context, _Cloud cloud) {
    final colorScheme = Theme.of(context).colorScheme;
    final live = cloud.url != null;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: live ? () => _openUrl(context, cloud.url!) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      cloud.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: live
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      live ? '已上线' : '规划中',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: live
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                cloud.description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
