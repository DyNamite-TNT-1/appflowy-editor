import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'models/node.dart' as block;
import 'utils/common_utils.dart';

class DocumentBlockDecoder extends Converter<Map<String, dynamic>, Document> {
  @override
  Document convert(Map<String, dynamic> input) {
    final node = block.Node.fromJson(input);

    if (node is block.BlockNode) {
      final List<Node> nodes = _parseBlockNode(node);
      return Document.blank(withInitialText: false)
        ..insert(
          [0],
          nodes,
        );
    }

    return Document.blank(withInitialText: false);
  }

  List<Node> _parseBlockNode(
    block.BlockNode rootNode,
  ) {
    final List<Node> result = [];
    _visitBlockTree(
      rootNode,
      (current, parent) {
        if (parent.type != block.NodeTypes.richTextList) {
          _handleNode(current, result);
        }
      },
    );
    return result;
  }

  void _handleNode(block.BlockNode current, List<Node> result) {
    if (current.type == block.NodeTypes.richTextList) {
      final listNodes = _convertRichTextList(current);
      result.addAll(listNodes);
    } else {
      final node = _convertToNode(current);
      result.add(node);
    }
  }

  Node _convertToNode(block.BlockNode blockNode) {
    final delta = _createDeltaFromChildren(blockNode);

    switch (blockNode.type) {
      case block.NodeTypes.richTextPreformatted:
        return codeBlockNode(delta: delta);
      case block.NodeTypes.richTextQuote:
        return quoteNode(delta: delta);
      default:
        return paragraphNode(delta: delta);
    }
  }

  Delta _createDeltaFromChildren(block.BlockNode blockNode) {
    final List<TextInsert> textInserts = [];
    for (final child in blockNode.children) {
      if (child is block.InlineNode) {
        textInserts.add(convertInlineNodeToTextInsert(child));
      }
    }
    return Delta(operations: textInserts);
  }

  List<Node> _convertRichTextList(block.BlockNode blockNode) {
    assert(blockNode.type == block.NodeTypes.richTextList);

    final List<Node> listNodes = [];

    for (final child in blockNode.children) {
      if (child is block.BlockNode &&
          child.type == block.NodeTypes.richTextSection) {
        final node = _createListNodeFromSection(child, blockNode);
        listNodes.add(node);
      }
    }

    return listNodes;
  }

  Node _createListNodeFromSection(
    block.BlockNode child,
    block.BlockNode parent,
  ) {
    final delta = _createDeltaFromChildren(child);
    final style = parent.metaData["style"] as String? ?? "";
    final indent = parent.metaData["indent"] as int? ?? 0;

    if (style == "ordered") {
      return numberedListNode(delta: delta).copyWith(indent: indent);
    } else if (style == "bullet") {
      return bulletedListNode(delta: delta).copyWith(indent: indent);
    } else if (style == "todo") {
      final checked = parent.metaData["checked"] as bool? ?? false;
      return todoListNode(checked: checked, delta: delta).copyWith(
        indent: indent,
      );
    }

    return bulletedListNode(delta: delta).copyWith(indent: indent);
  }

  void _visitBlockTree(
    block.BlockNode node,
    void Function(block.BlockNode, block.BlockNode) visitor,
  ) {
    for (var child in node.children) {
      if (child is block.BlockNode) {
        visitor(child, node);
        _visitBlockTree(child, visitor);
      }
    }
  }
}