import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/block_data/utils/utils.dart';
import 'models/node.dart' as block;

const _isLog = false;

class DocumentBlockEncoder extends Converter<Document, Map<String, dynamic>> {
  DocumentBlockEncoder();

  @override
  Map<String, dynamic> convert(Document input) {
    final rootBlockData = _createRootBlockData(input.root);
    return rootBlockData.toJson();
  }

  block.BlockNode _createRootBlockData(Node root) {
    final blockDataChildren = _collectBlockDataChildren(root);
    return block.BlockNode(
      type: block.NodeTypes.richText,
      children: blockDataChildren,
    );
  }

  List<block.Node> _collectBlockDataChildren(Node root) {
    final List<block.Node> result = [];
    _visitTree(
      root,
      (current) {
        _processCurrentNode(current, result);
      },
    );

    if (_isLog) {
      for (int i = 0; i < result.length; i++) {
        final node = result[i];
        print("$i - $node");
      }
    }

    return result;
  }

  void _processCurrentNode(Node current, List<block.Node> result) {
    final quoteStatus = current.getBlockQuoteConversionStatus;
    if (quoteStatus == 1) {
      result.add(current.convertNearestBlockQuoteNodesToBlockQuoteData());
      return;
    } else if (quoteStatus == 0) {
      return;
    }

    final listStatus = current.getListConversionStatus;
    if (listStatus == 1) {
      result.add(current.convertNearestListNodesToBlockListData());
      return;
    } else if (listStatus == 0) {
      return;
    }

    _addBlockElement(current, result);
  }

  void _addBlockElement(Node current, List<block.Node> result) {
    final blockElement = current.convertToBlockData();
    final delta = current.delta ?? Delta();
    final inlineNodes = _convertDeltaToInlineNodes(delta);
    final updatedBlockElement = blockElement.copyWith(children: inlineNodes);
    result.add(updatedBlockElement);
  }

  List<block.InlineNode> _convertDeltaToInlineNodes(Delta delta) {
    return delta
        .whereType<TextInsert>()
        .map(
          (textInsert) => convertTextInsertToInlineNode(textInsert),
        )
        .toList();
  }

  void _visitTree(Node node, void Function(Node) visitor) {
    for (var child in node.children) {
      visitor(child);
      if (child.children.isNotEmpty) {
        _visitTree(child, visitor);
      }
    }
  }
}
