import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'node.dart' as block;
import 'utils/common_utils.dart';

class DocumentBlockDecoder extends Converter<Map<String, dynamic>, Document> {
  @override
  Document convert(Map<String, dynamic> input) {
    final node = block.Node.fromJson(input);
    // print("node ${node.toString()}");

    if (node is block.BlockNode) {
      final List<Node> nodes = _parse(node);
      return Document.blank(withInitialText: false)
        ..insert(
          [0],
          nodes,
        );
    }

    return Document.blank(withInitialText: false);
  }

  List<Node> _parse(
    block.BlockNode rootNode,
  ) {
    final List<Node> result = [];

    visitBlockTree(
      rootNode,
      (current) {
        print(current);

        if (current is block.InlineNode) {
          return;
        }

        if (current is block.BlockNode) {
          if (current.type == block.NodeTypes.richTextList) {
            return;
          }

          final List<TextInsert> textInserts = [];
          for (final child in current.children) {
            if (child is block.InlineNode) {
              textInserts.add(convertInlineNodeToTextInsert(child));
            }
          }

          final delta = Delta()..addAll(textInserts);
          final parentNode = convertToNode(current, delta);

          result.add(parentNode);
        }
      },
    );
    return result;
  }

  void visitBlockTree(
    block.BlockNode node,
    void Function(block.Node) visitor,
  ) {
    final children = node.children;

    for (var child in children) {
      if (child is block.BlockNode) {
        visitor(child);
        visitBlockTree(child, visitor);
      }
    }
  }
}

Node convertToNode(block.BlockNode blockNode, Delta delta) {
  if (blockNode.type == block.NodeTypes.richTextPreformatted) {
    return codeBlockNode(delta: delta);
  }

  if (blockNode.type == block.NodeTypes.richTextQuote) {
    return quoteNode(delta: delta);
  }

  return paragraphNode(delta: delta);
}
