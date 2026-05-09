import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/contract_cubit.dart';
import '../models/contract.dart';
import '../constants.dart';

class ContractScreen extends StatefulWidget {
  final String eventId;

  const ContractScreen({super.key, required this.eventId});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ContractCubit>().loadContracts().then((_) {
      if (!mounted) return;
      context.read<ContractCubit>().selectContract(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('契约管理')),
      body: BlocBuilder<ContractCubit, ContractState>(
        builder: (context, state) {
          switch (state.status) {
            case ContractStatus.initial:
            case ContractStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ContractStatus.error:
              return Center(child: Text('加载失败: ${state.errorMessage}'));
            case ContractStatus.loaded:
              if (state.selectedContracts.isEmpty) {
                return const Center(child: Text('无契约信息'));
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final contract in state.selectedContracts)
                    _ContractSection(contract: contract),
                ],
              );
          }
        },
      ),
    );
  }
}

class _ContractSection extends StatelessWidget {
  final Contract contract;

  const _ContractSection({required this.contract});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Schema', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('事件ID: ${contract.eventId}'),
                Text('订阅域: ${domainLabel(contract.subscriberDomain)}'),
                Text('状态: ${contractStatusLabel(contract.status)}'),
                const SizedBox(height: 12),
                Text('字段列表', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                ...contract.versions.isNotEmpty
                    ? _parseFields(contract.versions.last.schemaJson).map(
                        (f) => Text('• ${f['name']} (${f['type']})${f['required'] == 'true' ? ' *' : ''}'),
                      )
                    : [const Text('无字段信息')],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('订阅方', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Chip(label: Text(domainLabel(contract.subscriberDomain))),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('订阅此事件'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('版本变更', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...contract.versions.map((v) => ListTile(
                      leading: Icon(
                        v.status == 'active'
                            ? Icons.check_circle
                            : v.status == 'pending'
                                ? Icons.pending
                                : Icons.cancel,
                        color: contractStatusColor(v.status),
                      ),
                      title: Text(v.changeLog),
                      subtitle: Text('v${v.id} · ${contractStatusLabel(v.status)}'),
                    )),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('提交流变更'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _parseFields(String schemaJson) {
    try {
      final json = jsonDecode(schemaJson) as Map<String, dynamic>;
      final fields = json['fields'] as List<dynamic>;
      return fields.map((f) => {
            'name': f['name'].toString(),
            'type': f['type'].toString(),
            'required': f['required'].toString(),
          }).toList();
    } catch (_) {
      return [];
    }
  }
}
