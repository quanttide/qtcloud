import 'package:flutter_test/flutter_test.dart';

import 'package:qtcloud_studio/journal/journal.dart';
import 'package:qtcloud_studio/journal/redline.dart';

void main() {
  group('红线自检', () {
    test('命中飞书 ID（oc_ / ou_）', () {
      final checker = RedLineChecker();
      final hits = checker.check('群 id 是 oc_c99c2f2d13a2e8b7，负责人 ou_8f3a92b1c4d5e6f7');
      expect(hits.map((h) => h.rule), everyElement('真实 ID'));
      expect(hits, hasLength(2));
    });

    test('命中飞书内部链接', () {
      final checker = RedLineChecker();
      final hits = checker.check('详见 https://example.feishu.cn/docs/docxtokentokentoken 了吗');
      expect(hits.map((h) => h.rule), contains('内部链接'));
    });

    test('命中平台注入的真实姓名', () {
      final checker = RedLineChecker(realNames: ['张三']);
      expect(checker.check('张三说今天上线').map((h) => h.rule), contains('真实姓名'));
      expect(checker.check('创始人说今天上线'), isEmpty);
    });

    test('命中经营敏感词，且清单可覆盖', () {
      final checker = RedLineChecker();
      expect(checker.check('这个月回款到账').map((h) => h.rule), contains('经营敏感'));

      final custom = RedLineChecker(sensitiveWords: ['报价底价']);
      expect(custom.check('报价底价是 30 万'), hasLength(1));
      expect(custom.check('这个月回款到账'), isEmpty);
    });

    test('干净文本通过', () {
      final checker = RedLineChecker(realNames: ['张三']);
      expect(
        checker.check('「按周清洗比按月更稳。」（量潮实训基地 18:44 ~ 18:45）'),
        isEmpty,
      );
    });
  });

  group('分流', () {
    test('登记群映射到业务线', () {
      expect(journalLineFor('量潮实训基地'), 'qtclass');
    });

    test('闲聊水库按内容判断，返回 null 交调用方', () {
      expect(journalLineFor('闲聊水库'), isNull);
    });

    test('未登记群兜底 default', () {
      expect(journalLineFor('随便一个群'), 'default');
    });
  });

  group('同日合并', () {
    final first = JournalSection(
      group: '闲聊水库群',
      start: DateTime(2026, 9, 9, 18, 44),
      end: DateTime(2026, 9, 9, 18, 45),
      text: '「方案先出一版。」',
      topic: '方案节奏',
    );
    final second = JournalSection(
      group: '闲聊水库群',
      start: DateTime(2026, 9, 9, 20, 10),
      end: DateTime(2026, 9, 9, 20, 12),
      text: '「明天review。」',
    );

    test('新来源群另起一段', () {
      final merged = mergeJournalSection([], second);
      expect(merged, hasLength(1));
      expect(merged.single.id, '闲聊水库群');
    });

    test('同一来源群追加段落并延长时段，不新建段落', () {
      final merged = mergeJournalSection([first], second);
      expect(merged, hasLength(1));
      expect(merged.single.end, second.end);
      expect(merged.single.text, contains('方案先出一版'));
      expect(merged.single.text, contains('明天review'));
      expect(merged.single.topic, '方案节奏');
    });
  });

  group('写回序列化', () {
    test('格式对齐技能第 4 步：来源行 + 章节标题带群名与时间', () {
      final md = serializeJournal(
        date: '2026-09-09',
        sections: [
          JournalSection(
            group: '闲聊水库群',
            start: DateTime(2026, 9, 9, 18, 44),
            end: DateTime(2026, 9, 9, 18, 45),
            text: '「方案先出一版。」\n> 复盘：节奏比完备优先。',
            topic: '方案节奏',
          ),
          JournalSection(
            group: '量潮实训基地',
            start: DateTime(2026, 9, 9, 9, 5),
            end: DateTime(2026, 9, 9, 9, 20),
            text: '「设备到位了。」',
          ),
        ],
      );

      expect(md, startsWith('# 2026-09-09\n\n来源：闲聊水库群、量潮实训基地\n'));
      expect(md, contains('## 方案节奏（闲聊水库群 18:44 ~ 18:45）'));
      expect(md, contains('## 量潮实训基地 09:05 ~ 09:20'));
      expect(md, contains('> 复盘：节奏比完备优先。'));
    });
  });
}
