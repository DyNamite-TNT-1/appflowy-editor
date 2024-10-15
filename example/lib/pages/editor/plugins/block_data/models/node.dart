import 'meta_data.dart';
import 'style.dart';

class NodeTypes {
  static const richText = 'rich_text';
  static const richTextSection = 'rich_text_section';
  static const richTextList = 'rich_text_list';
  static const richTextPreformatted = 'rich_text_preformatted';
  static const richTextQuote = 'rich_text_quote';
  static const link = 'link';
  static const user = 'user';
  static const channel = 'channel';
  static const text = 'text';
  static const emoji = 'emoji';
  static const reference = 'reference';

  static Set<String> blockElements = {
    NodeTypes.richText,
    NodeTypes.richTextSection,
    NodeTypes.richTextList,
    NodeTypes.richTextPreformatted,
    NodeTypes.richTextQuote,
  };

  static Set<String> inlineElements = {
    NodeTypes.link,
    NodeTypes.user,
    NodeTypes.channel,
    NodeTypes.text,
    NodeTypes.emoji,
    NodeTypes.reference,
  };
}

class Node {
  Node({
    required this.type,
    MetaData metaData = const {},
  }) : _metaData = metaData;

  /// The type of the node.
  final String type;

  /// The meta data of the node.
  final MetaData _metaData;
  MetaData get metaData => {..._metaData};

  Node copyWith({
    String? type,
    MetaData? metaData,
  }) {
    final node = Node(
      type: type ?? this.type,
      metaData: metaData ?? {...this.metaData},
    );

    return node;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
    };

    if (metaData.isNotEmpty) {
      map.addAll(metaData.map((key, value) => MapEntry(key, value)));
    }

    return map;
  }

  factory Node.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;

    if (NodeTypes.blockElements.contains(type)) {
      return BlockNode.fromJson(json);
    }

    if (NodeTypes.inlineElements.contains(type)) {
      return InlineNode.fromJson(json);
    }

    // Extract the metaData
    final metaDataJson = Map<String, dynamic>.from(json)..remove('type');

    return Node(
      type: type,
      metaData: metaDataJson,
    );
  }
}

class BlockNode extends Node {
  BlockNode({
    required super.type,
    super.metaData,
    List<Node> children = const [],
  }) : _children = children;

  final List<Node> _children;

  List<Node> get children {
    return _children;
  }

  @override
  BlockNode copyWith({
    String? type,
    MetaData? metaData,
    List<Node>? children,
  }) {
    return BlockNode(
      type: type ?? this.type,
      metaData: metaData ?? {...this.metaData},
      children: children ?? List.from(_children),
    );
  }

  @override
  String toString() {
    return 'BlockNode(type: $type, metaData: $metaData, children: $children)';
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();

    map['elements'] = _children.map((child) => child.toJson()).toList();

    return map;
  }

  factory BlockNode.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    // Extract the metaData
    final metaDataJson = Map<String, dynamic>.from(json)
      ..remove('type')
      ..remove('elements');

    // Extract children
    final childrenJson = json['elements'] as List<dynamic>?;
    final children = childrenJson
            ?.map(
              (childJson) => Node.fromJson(childJson as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return BlockNode(
      type: type,
      metaData: metaDataJson,
      children: children,
    );
  }
}

class InlineNode extends Node {
  InlineNode({
    required super.type,
    this.text = "",
    super.metaData,
    Style style = const {},
  }) : _style = style;

  final String text;
  final Style _style;
  Style get style => {..._style};

  @override
  String toString() {
    return 'InlineNode(type: $type, text: $text, metaData: $metaData, style: $style)';
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();

    if (type != NodeTypes.user) {
      map['text'] = text;
      if (style.isNotEmpty) {
        map['style'] = style;
      }
    }

    return map;
  }

  factory InlineNode.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    // Extracting other properties
    final text = json['text'] as String? ?? "";
    final style =
        Map<String, dynamic>.from(json['style'] as Map<String, dynamic>? ?? {});

    // Extract the metaData
    final metaDataJson = Map<String, dynamic>.from(json)
      ..remove('type')
      ..remove('text')
      ..remove('style');

    return InlineNode(
      type: type,
      text: text,
      metaData: metaDataJson,
      style: style,
    );
  }

  static InlineNode breakNewLine() {
    return InlineNode(type: NodeTypes.text, text: "\n");
  }
}
