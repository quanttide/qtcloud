// 工作物本体：正在被编写的文档，及其修订提案。

/// 文档的一个章节
class DocSection {
  DocSection({required this.id, required this.title, required this.text});

  String id;
  String title;
  String text;
}

/// 工作物本体：正在被编写的文档
class Doc {
  Doc({required this.title, required this.version, required this.sections});

  String title;
  int version;
  List<DocSection> sections;
}

/// 修订提案：对文档某章节的修改，验收通过即合入。before 为空表示在章节末尾追加
class Change {
  Change({required this.sectionId, required this.before, required this.after});

  String sectionId;
  String before;
  String after;
}
