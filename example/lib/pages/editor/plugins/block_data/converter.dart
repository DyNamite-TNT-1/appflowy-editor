import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/utils/node_util.dart';
import 'node.dart' as block;

List<String> listType = [
  BulletedListBlockKeys.type,
  NumberedListBlockKeys.type,
  TodoListBlockKeys.type,
];

List<block.Node> convertDocumentToBlockData(Document document) {
  final List<block.Node> result = [];
  final root = document.root;
  root.visitAllDescendants(
    root,
    (current, _) {
      final blockElement = convertToBlockNode(current);
      final delta = current.delta ?? Delta();
      final inlineNodes = delta
          .whereType<TextInsert>()
          .map(
            (textInsert) =>
                convertTextInsertToInlineNodes(textInsert, blockElement.id),
          )
          .toList();
      final updatedBlockElement = blockElement.copyWith(children: inlineNodes);
      result.add(updatedBlockElement);
    },
    -1,
  );

  for (int i = 0; i < result.length; i++) {
    final node = result[i];
    print("$i - $node");
  }
  return result;
}

block.BlockNode convertToBlockNode(Node node) {
  final parentId = node.parent?.id;
  final nodeId = node.id;

  if (node.type == NumberedListBlockKeys.type) {
    return block.BlockNode(
      id: nodeId,
      type: block.NodeTypes.richTextList,
      parent: parentId,
      children: [],
      metaData: {
        "indent": node.indent,
        "style": "ordered",
      },
    );
  }

  if (node.type == BulletedListBlockKeys.type) {
    return block.BlockNode(
      id: nodeId,
      type: block.NodeTypes.richTextList,
      parent: parentId,
      children: [],
      metaData: {
        "indent": node.indent,
        "style": "bullet",
      },
    );
  }

  if (node.type == TodoListBlockKeys.type) {
    return block.BlockNode(
      id: nodeId,
      type: block.NodeTypes.richTextList,
      parent: parentId,
      children: [],
      metaData: {
        "indent": node.indent,
        "style": "todo",
        "value": node.attributes[TodoListBlockKeys.checked],
      },
    );
  }

  if (node.type == ParagraphBlockKeys.type) {
    return block.BlockNode(
      id: nodeId,
      type: block.NodeTypes.richTextSection,
      parent: parentId,
      children: [],
      metaData: {
        "indent": node.indent,
      },
    );
  }

  return block.BlockNode(
    id: nodeId,
    type: block.NodeTypes.richTextSection,
    parent: parentId,
    children: [],
  );
}

block.InlineNode convertTextInsertToInlineNodes(
  TextInsert textInsert,
  String parent,
) {
  final text = textInsert.text;
  final attributes = textInsert.attributes;

  if (attributes == null) {
    return block.InlineNode(type: block.NodeTypes.text, text: text);
  }

  return block.InlineNode(
    parent: parent,
    type: block.NodeTypes.text,
    text: text,
    style: convertAttributesToCssStyle(attributes),
  );
}

Map<String, dynamic> convertAttributesToCssStyle(
  Map<String, dynamic> attributes,
) {
  final cssMap = <String, dynamic>{};

  if (attributes.bold) {
    cssMap['bold'] = true;
  }
  if (attributes.underline) {
    cssMap['underline'] = true;
  }

  if (attributes.strikethrough) {
    cssMap['strikethrough'] = true;
  }

  if (attributes.italic) {
    cssMap['italic'] = true;
  }

  final backgroundColor = attributes.backgroundColor;
  if (backgroundColor != null) {
    cssMap['background-color'] = backgroundColor.toRgbaString();
  }

  final color = attributes.color;
  if (color != null) {
    cssMap['color'] = color.toRgbaString();
  }

  return cssMap;
}
