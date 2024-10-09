import 'package:nanoid/non_secure.dart';

typedef MetaData = Map<String, dynamic>;
typedef Style = Map<String, dynamic>;

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

  static List<String> blockElements = [
    NodeTypes.richText,
    NodeTypes.richTextSection,
    NodeTypes.richTextList,
    NodeTypes.richTextPreformatted,
    NodeTypes.richTextQuote,
  ];

  static List<String> inlineElements = [
    NodeTypes.link,
    NodeTypes.user,
    NodeTypes.channel,
    NodeTypes.text,
    NodeTypes.emoji,
    NodeTypes.reference,
  ];
}

class Node {
  Node({
    required this.type,
    String? id,
    this.parent,
    MetaData metaData = const {},
  })  : id = id ?? nanoid(5),
        _metaData = metaData;

  /// The id of the node.
  final String id;

  /// The type of the node.
  final String type;

  /// The parent of the node.
  String? parent;

  /// The meta data of the node.
  final MetaData _metaData;
  MetaData get metaData => {..._metaData};

  Node copyWith({
    String? type,
    String? id,
    String? parent,
    MetaData? metaData,
  }) {
    final node = Node(
      type: type ?? this.type,
      id: id ?? this.id,
      metaData: metaData ?? {...this.metaData},
      parent: parent ?? this.parent,
    );

    return node;
  }
}

class BlockNode extends Node {
  BlockNode({
    required super.type,
    super.id,
    String? parent,
    super.metaData,
    List<Node> children = const [],
  }) : _children = children {
    super.parent = parent;
    for (final child in children) {
      child.parent = id;
    }
  }

  final List<Node> _children;

  List<Node> get children {
    return _children;
  }

  @override
  Node copyWith({
    String? type,
    String? id,
    String? parent,
    MetaData? metaData,
    List<Node>? children,
  }) {
    // Create a new BlockNode with the updated values
    return BlockNode(
      type: type ?? this.type,
      id: id ?? this.id,
      parent: parent ?? this.parent,
      metaData: metaData ?? {...this.metaData},
      children: children ?? List.from(_children),
    );
  }


  @override
  String toString() {
    return 'Node(id: $id, type: $type, parent: $parent, metaData: $metaData, children: $children)';
  }
}

class InlineNode extends Node {
  InlineNode({
    required super.type,
    super.id,
    this.text = "",
    MetaData style = const {},
    String? parent,
  }) : _style = style {
    super.parent = parent;
  }

  final String text;
  final Style _style;
  Style get style => {..._style};

   @override
  String toString() {
    return 'Node(id: $id, type: $type, parent: $parent, text: $text, metaData: $metaData, style: $style)';
  }
}
