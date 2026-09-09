// 红线自检：journal 是公开仓库，敏感信息在进入验收闸门之前由平台强制检查。
// 规则来自 data/journal/.agents/skills/fetch-chat-logs——把 agent 自律收编为平台检查；
// 自检不通过拦在闸门之前，人工兜底仍在验收闸门（reviewing 拍板）。

/// 一次命中：哪条红线、命中了什么
class RedLineHit {
  RedLineHit({required this.rule, required this.snippet});

  final String rule;
  final String snippet;

  @override
  String toString() => '[$rule] $snippet';
}

/// 红线自检器。
/// 真实姓名清单由平台侧注入（代称映射表不入仓库）；敏感词可按需覆盖默认清单。
class RedLineChecker {
  RedLineChecker({
    List<String> realNames = const [],
    this.sensitiveWords = defaultSensitiveWords,
  }) : _realNames = realNames;

  /// 经营敏感默认清单（技能红线：请假/病假、工作交接、回款、薪资、内部数据）
  static const defaultSensitiveWords = [
    '回款',
    '薪资',
    '病假',
    '请假',
    '工作交接',
    '内部数据',
  ];

  static final _feishuId = RegExp(r'\bo[cknu]_[0-9a-zA-Z]{8,}');
  static final _internalLink = RegExp(
    r'https?://[^\s）)]*feishu\.cn/\S+',
  );

  final List<String> _realNames;
  final List<String> sensitiveWords;

  /// 检查一段成稿文本，返回全部命中（空列表 = 通过）
  List<RedLineHit> check(String text) {
    final hits = <RedLineHit>[];
    for (final m in _feishuId.allMatches(text)) {
      hits.add(RedLineHit(rule: '真实 ID', snippet: m.group(0)!));
    }
    for (final m in _internalLink.allMatches(text)) {
      hits.add(RedLineHit(rule: '内部链接', snippet: m.group(0)!));
    }
    for (final name in _realNames) {
      if (name.isNotEmpty && text.contains(name)) {
        hits.add(RedLineHit(rule: '真实姓名', snippet: name));
      }
    }
    for (final word in sensitiveWords) {
      if (text.contains(word)) {
        hits.add(RedLineHit(rule: '经营敏感', snippet: word));
      }
    }
    return hits;
  }
}
