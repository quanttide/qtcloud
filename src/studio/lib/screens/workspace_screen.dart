import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/artifact.dart';
import '../models/document.dart';
import '../models/task.dart';
import '../models/workflow.dart';
import '../models/workspace.dart';

/// 工作台首屏：方案工作物居中，任务、验收、版本围绕它转。
/// 河床规则：状态由规则推进（上游验收通过 → 下游云任务自动开工交付），
/// 人只在闸门（验收）出现；每个自动衔接都标注「原为人工搬运」。
/// 交互对齐 examples/studio/index.html v3，设计见 docs/dev-guide/studio.md。
class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late Workspace ws;
  bool _loaded = false;
  String? _error;
  final _timers = <Timer>[];
  final _autoScheduled = <String>{};
  final _sectionKeys = <String, GlobalKey>{};
  final _deliverableControllers = <String, TextEditingController>{};
  final _rejectController = TextEditingController();
  final _intentController = TextEditingController();
  String? _rejectingId;
  bool _narrowShowDoc = true;

  bool get _allDone =>
      ws.workflow.tasks.isNotEmpty &&
      ws.workflow.tasks.every((t) => t.status == TaskStatus.done);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/workspace_seed.json');
      final loaded = _workspaceFromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (!mounted) return;
      setState(() {
        ws = loaded;
        _loaded = true;
      });
      // 已在河中的云任务（首次装载、刷新恢复）补上交付节奏
      for (final t in List<Task>.of(ws.workflow.tasks)) {
        if (t.status == TaskStatus.running && t.executor != '用户') {
          _scheduleDelivery(t);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '契约数据加载失败：$e');
    }
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _rejectController.dispose();
    _intentController.dispose();
    for (final controller in _deliverableControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _schedule(Duration duration, void Function() fn) {
    _timers.add(
      Timer(duration, () {
        if (mounted) fn();
      }),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // 河床规则：就绪的云任务自动开工、交付，人不搬运状态。
  // 回调里先校验最新状态，被驳回/重置后的旧定时器自动失效。
  void _flowCheck() {
    for (final t in ws.workflow.readyCloudTasks()) {
      if (_autoScheduled.contains(t.id)) continue;
      _autoScheduled.add(t.id);
      _schedule(const Duration(milliseconds: 700), () {
        final cur = ws.workflow.byId(t.id);
        if (cur == null || cur.status != TaskStatus.pending) return;
        if (!cur.start()) return;
        setState(() {});
        _toast('自动衔接 · ${t.executor} 开工（原为人工派单）');
        _scheduleDelivery(cur);
      });
    }
  }

  void _scheduleDelivery(Task t) {
    _schedule(const Duration(milliseconds: 1800), () {
      final cur = ws.workflow.byId(t.id);
      if (cur == null || cur.status != TaskStatus.running) return;
      if (!cur.deliver()) return;
      setState(() {});
      _toast('自动衔接 · ${t.executor} 交付了修改，等你拍板');
    });
  }

  void _start(Task t) {
    if (!t.start()) return;
    setState(() {});
    _toast('已开始：${t.name}');
  }

  void _submit(Task t) {
    if (!t.deliver()) {
      _toast('先填写交付说明，再提交验收');
      return;
    }
    setState(() {});
    _toast('已提交验收：${t.name}');
  }

  void _approve(Task t) {
    final hadChanges = (t.output ?? []).isNotEmpty;
    if (!ws.workflow.approve(t)) return;
    setState(() {});
    _toast(hadChanges ? '已验收 ✓ 方案更新至 v${ws.doc.version}' : '已验收 ✓ ${t.name}');
    _flowCheck();
  }

  void _startReject(Task t) {
    setState(() {
      _rejectingId = t.id;
      _rejectController.clear();
    });
  }

  void _confirmReject(Task t) {
    final note = _rejectController.text.trim().isEmpty
        ? '未通过，请按意见修改后重新提交'
        : _rejectController.text.trim();
    if (!t.reject(note)) return;
    setState(() {
      _rejectingId = null;
      _rejectController.clear();
    });
    _toast('已驳回：${t.name}');
    if (t.executor != '用户') {
      _schedule(const Duration(milliseconds: 2400), () {
        final cur = ws.workflow.byId(t.id);
        if (cur == null || cur.status != TaskStatus.running) return;
        if (!cur.deliver()) return;
        setState(() {});
        _toast('自动衔接 · ${t.executor} 按意见修改后重新交付');
      });
    }
  }

  // 派活：意图库匹配（demo 为预排剧本），听不懂就直说
  void _dispatch() {
    final created = ws.workflow.dispatchIntent(_intentController.text);
    if (created == null) {
      _toast('这句我还不会拆（demo 只听得懂「增加客户确认环节」这类意图）');
      return;
    }
    _intentController.clear();
    setState(() {});
    _toast('已派活 · 拆解为 1 步');
    _narrowShowDoc = false;
    _flowCheck();
  }

  Future<void> _reset() async {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    _autoScheduled.clear();
    _rejectingId = null;
    try {
      final raw = await rootBundle.loadString('assets/workspace_seed.json');
      final loaded = _workspaceFromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (!mounted) return;
      setState(() => ws = loaded);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '契约数据加载失败：$e');
      return;
    }
    _toast('已重置为初始案例');
    for (final t in List<Task>.of(ws.workflow.tasks)) {
      if (t.status == TaskStatus.running && t.executor != '用户') {
        _scheduleDelivery(t);
      }
    }
  }

  String _fmtTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  /// Workspace 契约解析：数据在 assets/workspace_seed.json，
  /// 代码读契约不读硬编码（数据驱动的产品研发）。
  /// 云的修订提案为预排剧本；正式实现由协作目录 + LLM 承担。
  Workspace _workspaceFromJson(Map<String, dynamic> json) {
    final docJson = json['doc'] as Map<String, dynamic>;
    final doc = Doc(
      title: docJson['title'] as String,
      version: docJson['version'] as int,
      sections: (docJson['sections'] as List)
          .map(
            (s) => DocSection(
              id: s['id'] as String,
              title: s['title'] as String,
              text: s['text'] as String,
            ),
          )
          .toList(),
    );

    final tasks = (json['tasks'] as List)
        .map(
          (t) => Task(
            id: t['id'] as String,
            name: t['name'] as String,
            executor: t['executor'] as String,
            status: TaskStatus.values.byName(t['status'] as String),
            dependsOn: (t['dependsOn'] as List).cast<String>(),
            deliverable: t['deliverable'] as String?,
            output: (t['output'] as List?)
                ?.map(
                  (c) => Change(
                    target: c['target'] as String,
                    before: c['before'] as String,
                    after: c['after'] as String,
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    final workflow = Workflow(tasks: tasks, artifact: doc);

    return Workspace(
      name: json['name'] as String,
      goal: json['goal'] as String,
      boundary: json['boundary'] as String,
      doc: doc,
      workflow: workflow,
    );
  }

  String _depsLabel(Task t) => t.dependsOn.isEmpty
      ? '无'
      : t.dependsOn.map((d) => ws.workflow.byId(d)?.name ?? d).join('、');

  String _sectionTitle(String id) => ws.doc.sections
      .firstWhere(
        (s) => s.id == id,
        orElse: () => DocSection(id: id, title: id, text: ''),
      )
      .title;

  void _gotoSection(String sectionId) {
    setState(() => _narrowShowDoc = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _sectionKeys[sectionId];
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.25,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('量潮云工作台')),
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFF9A2B20)),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('重试')),
                  ],
                ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ws.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: '重置为初始案例',
            icon: const Icon(Icons.restart_alt),
            onPressed: _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [_chip('目标 ${ws.goal}'), _chip('边界 ${ws.boundary}')],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _intentController,
                      onSubmitted: (_) => _dispatch(),
                      decoration: const InputDecoration(
                        hintText: '说要什么，比如：增加客户确认环节',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _dispatch, child: const Text('派活')),
                ],
              ),
            ),
            if (_allDone)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F2E8),
                  border: Border.all(color: const Color(0xFF9FD0B1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🎉 方案定稿——全部任务验收通过',
                  style: TextStyle(
                    color: Color(0xFF2C7A4B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  if (wide) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _docPanel()),
                          const SizedBox(width: 16),
                          SizedBox(width: 320, child: _rail()),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: ToggleButtons(
                          isSelected: [_narrowShowDoc, !_narrowShowDoc],
                          onPressed: (i) =>
                              setState(() => _narrowShowDoc = i == 0),
                          borderRadius: BorderRadius.circular(8),
                          constraints: const BoxConstraints(
                            minHeight: 36,
                            minWidth: 90,
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('方案'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('任务'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _narrowShowDoc ? _docPanel() : _rail()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docPanel() {
    final awaiting = ws.workflow.tasks
        .where((t) => t.status == TaskStatus.reviewing)
        .toList();
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E3EE)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    ws.doc.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EBFA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'v${ws.doc.version}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (final sec in ws.doc.sections) _section(sec, awaiting),
            if (ws.doc.revisions.isNotEmpty) ...[
              const Divider(),
              const Text(
                '版本记录',
                style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
              ),
              for (final r in ws.doc.revisions)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'v${r.version} · ${r.taskName} · ${r.executor} · ${_fmtTime(r.time)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _section(DocSection sec, List<Task> awaiting) {
    final key = _sectionKeys.putIfAbsent(sec.id, () => GlobalKey());
    final pendings = awaiting
        .where((t) => (t.output ?? []).any((c) => c.target == sec.id))
        .toList();
    return KeyedSubtree(
      key: key,
      child: Container(
        padding: const EdgeInsets.only(top: 14, bottom: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEF0F6))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  sec.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (pendings.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAEEDA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '有修改待验收',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB06E10)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sec.text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
            for (final t in pendings)
              for (final c in (t.output ?? []).where((c) => c.target == sec.id))
                _diffBlock(t, c),
          ],
        ),
      ),
    );
  }

  Widget _diffBlock(Task t, Change c) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF4),
        border: Border.all(color: const Color(0xFFE8D9B8)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${t.executor} 提议修改 · 来自「${t.name}」',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A6D1F)),
          ),
          const SizedBox(height: 6),
          if (c.before.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEEED),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                c.before,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9A2B20),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0x889A2B20),
                ),
              ),
            )
          else
            const Text(
              '在章节末尾追加：',
              style: TextStyle(fontSize: 12, color: Color(0xFF8A6D1F)),
            ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F5EC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              c.after,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E6B3C)),
            ),
          ),
          if (t.review != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '上轮意见：${t.review}',
                style: const TextStyle(fontSize: 12, color: Color(0xFFB06E10)),
              ),
            ),
          if (_rejectingId == t.id)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: _rejectController,
                    onSubmitted: (_) => _confirmReject(t),
                    decoration: const InputDecoration(
                      hintText: '驳回意见（回传给执行者）',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _confirmReject(t),
                  child: const Text('确认驳回'),
                ),
                TextButton(onPressed: _cancelReject, child: const Text('取消')),
              ],
            )
          else
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C7A4B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _approve(t),
                  child: const Text('通过 ✓'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _startReject(t),
                  child: const Text('驳回'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _cancelReject() {
    setState(() {
      _rejectingId = null;
      _rejectController.clear();
    });
  }

  Widget _rail() {
    final awaiting = ws.workflow.tasks
        .where((t) => t.status == TaskStatus.reviewing)
        .toList();
    final running = ws.workflow.tasks
        .where((t) => t.status == TaskStatus.running)
        .toList();
    final ready = ws.workflow.tasks.where(ws.workflow.isReady).toList();
    final blocked = ws.workflow.tasks
        .where((t) => t.status == TaskStatus.pending && !ws.workflow.isReady(t))
        .toList();
    final done = ws.workflow.tasks
        .where((t) => t.status == TaskStatus.done)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _zone(
            '等你拍板',
            count: awaiting.length,
            hot: true,
            child: awaiting.isEmpty
                ? const _Empty('没有等你拍板的事 ✓')
                : Column(children: [for (final t in awaiting) _verdictCard(t)]),
          ),
          _zone(
            '正在干',
            count: running.length,
            child: running.isEmpty
                ? const _Empty('暂时没有')
                : Column(
                    children: [
                      for (final t in running)
                        t.executor != '用户'
                            ? _card(
                                title: t.name,
                                metaSpan: [
                                  TextSpan(text: '${t.executor} 正在整理修改…'),
                                  _autoChipSpan(),
                                ],
                                extra: t.review == null
                                    ? null
                                    : Text(
                                        '按意见改：${t.review}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFB06E10),
                                        ),
                                      ),
                              )
                            : _card(
                                title: t.name,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: _deliverableController(t),
                                      onChanged: (v) => t.deliverable = v,
                                      decoration: const InputDecoration(
                                        hintText: '交付说明',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    FilledButton(
                                      onPressed: () => _submit(t),
                                      child: const Text('提交验收'),
                                    ),
                                  ],
                                ),
                              ),
                    ],
                  ),
          ),
          _zone(
            '可以开始',
            count: ready.length,
            child: Column(
              children: [
                if (ready.isEmpty) const _Empty('暂无可开工的任务'),
                for (final t in ready)
                  t.executor == '用户'
                      ? _rowCard(
                          t,
                          '用户 · 上游 ${_depsLabel(t)}',
                          FilledButton(
                            onPressed: () => _start(t),
                            child: const Text('开始执行'),
                          ),
                        )
                      : _card(title: t.name, meta: '就绪 · ${t.executor} 即将自动开工'),
                for (final t in blocked)
                  _card(
                    title: t.name,
                    meta: '还没轮到 · 等 ${_depsLabel(t)}',
                    muted: true,
                  ),
              ],
            ),
          ),
          if (done.isNotEmpty)
            _zone(
              '已完成 ${done.length}',
              child: _Empty(done.map((t) => t.name).join(' · ')),
            ),
        ],
      ),
    );
  }

  TextEditingController _deliverableController(Task t) {
    return _deliverableControllers.putIfAbsent(
      t.id,
      () => TextEditingController(text: t.deliverable ?? ''),
    );
  }

  Widget _verdictCard(Task t) {
    final hasDiff = (t.output ?? []).isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        border: const Border(
          left: BorderSide(color: Color(0xFFE8A13D), width: 3),
          top: BorderSide(color: Color(0xFFE2E3EE)),
          right: BorderSide(color: Color(0xFFE2E3EE)),
          bottom: BorderSide(color: Color(0xFFE2E3EE)),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            hasDiff
                ? '${t.executor} 交付了修改 · 涉及「${(t.output ?? []).map((c) => _sectionTitle(c.target)).join('、')}」'
                : '${t.executor} 提交了交付说明，等你拍板',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
          ),
          if (t.deliverable != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                t.deliverable!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
              ),
            ),
          if (hasDiff)
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: FilledButton(
                  onPressed: () => _gotoSection(t.output![0].target),
                  child: const Text('在方案中查看修改 →'),
                ),
              ),
            )
          else
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C7A4B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _approve(t),
                  child: const Text('通过 ✓'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _startReject(t),
                  child: const Text('驳回'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    String? meta,
    List<InlineSpan>? metaSpan,
    Widget? child,
    Widget? extra,
    bool muted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E3EE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          if (meta != null)
            Text(
              meta,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
            ),
          if (metaSpan != null)
            Text.rich(
              TextSpan(children: metaSpan),
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
            ),
          if (extra != null)
            Padding(padding: const EdgeInsets.only(top: 4), child: extra),
          if (child != null)
            Padding(padding: const EdgeInsets.only(top: 6), child: child),
        ],
      ),
    );
  }

  Widget _rowCard(Task t, String meta, Widget action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E3EE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name, style: const TextStyle(fontSize: 14)),
                Text(
                  meta,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }

  Widget _zone(
    String title, {
    required Widget child,
    int count = 0,
    bool hot = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: hot
                        ? const Color(0xFFFAEEDA)
                        : const Color(0xFFE3EBFA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      color: hot
                          ? const Color(0xFFB06E10)
                          : const Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
      ),
    );
  }

  InlineSpan _autoChipSpan() {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEAF7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          '自动衔接 · 原为人工搬运',
          style: TextStyle(fontSize: 12, color: Color(0xFF6B5B8A)),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFFA5A5B5)),
      ),
    );
  }
}
