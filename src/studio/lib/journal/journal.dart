// journal 日志工作物：一个来源群一个段落，同日已有文件则合并进同一份。
// 结构与序列化约定来自 fetch-chat-logs 技能第 3、4 步；成稿正文由日志云交付，
// 此处只承载分流、合并语义与 Doc→Markdown 写回格式。

import '../models/document.dart';

/// journal 的一段：一个来源群在一个时段的消息成稿。
/// 寻址键为来源群名（同一群同日合并 = 向同一段落追加）。
class JournalSection {
  JournalSection({
    required this.group,
    required this.start,
    required this.end,
    required this.text,
    this.topic,
  });

  /// 来源群名（允许出现；群内身份与 chat_id 不在此层）
  final String group;

  final DateTime start;
  final DateTime end;

  /// 已成稿正文：事实 + 原话引述，复盘用引用块
  final String text;

  /// 内容主题（由成稿方给出，可空）
  final String? topic;

  /// 寻址键：即 DocSection.id
  String get id => group;

  /// 标题格式对齐技能约定：`主题（群名 HH:mm ~ HH:mm）`
  String get title {
    final span = '${_hhmm(start)} ~ ${_hhmm(end)}';
    return topic == null || topic!.isEmpty ? '$group $span' : '$topic（$group $span）';
  }

  /// 映射为章节文档的一段（工作物 = Doc 的落点）
  DocSection get section => DocSection(id: id, title: title, text: text);
}

/// 来源群 → 业务线目录（技能第 3 步分流表）。
/// 「闲聊水库」按内容判断，返回 null 由调用方决定；未登记的群兜底 default。
const journalLineByGroup = {'量潮实训基地': 'qtclass'};

String? journalLineFor(String group) {
  final line = journalLineByGroup[group];
  if (line != null) return line;
  if (group == '闲聊水库') return null;
  return 'default';
}

/// 同日合并（Change 语义：before 为空，段落末尾追加）：
/// 同一来源群的新成稿追加到既有段落并延长时段；新来源群另起一段。
List<JournalSection> mergeJournalSection(
  List<JournalSection> existing,
  JournalSection incoming,
) {
  final idx = existing.indexWhere((s) => s.group == incoming.group);
  if (idx < 0) return [...existing, incoming];
  final s = existing[idx];
  final merged = JournalSection(
    group: s.group,
    start: s.start,
    end: incoming.end,
    text: '${s.text}\n${incoming.text}',
    topic: s.topic,
  );
  return [...existing]..[idx] = merged;
}

/// Doc → Markdown 写回序列化（技能第 4 步格式）：
/// 文件顶部写「来源：…群」，章节标题标注来源群与时间。
String serializeJournal({
  required String date,
  required List<JournalSection> sections,
}) {
  final groups = sections.map((s) => s.group).toSet().toList();
  final buffer = StringBuffer('# $date\n\n来源：${groups.join('、')}\n');
  for (final s in sections) {
    buffer
      ..writeln()
      ..writeln('## ${s.title}')
      ..writeln()
      ..writeln(s.text);
  }
  return buffer.toString();
}

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
