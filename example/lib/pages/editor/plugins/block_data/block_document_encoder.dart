import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/block_data/utils/utils.dart';
import 'package:example/pages/editor/utils/node_util.dart';
import 'node.dart' as block;

const _isLog = false;

class DocumentBlockEncoder extends Converter<Document, Map<String, dynamic>> {
  DocumentBlockEncoder();

  @override
  Map<String, dynamic> convert(Document input) {
    final root = input.root;
    final blockDataChildren = collectBlockDataChildren(root);

    final rootBlockData = block.BlockNode(
      type: block.NodeTypes.richText,
      children: blockDataChildren,
    );

    return rootBlockData.toJson();
  }

  List<block.Node> collectBlockDataChildren(Node root) {
    final List<block.Node> result = [];
    root.visitAllDescendants(
      root,
      (current, _) {
        final quoteConversionStatus = current.getBlockQuoteConversionStatus;
        if (quoteConversionStatus == 1) {
          final quoteData =
              current.convertNearestBlockQuoteNodesToBlockQuoteData();
          result.add(quoteData);
          return;
        } else if (quoteConversionStatus == 0) {
          return;
        }

        final listConversionStatus = current.getListConversionStatus;
        if (listConversionStatus == 1) {
          final listData = current.convertNearestListNodesToBlockListData();
          result.add(listData);
          return;
        } else if (listConversionStatus == 0) {
          return;
        }

        // current is neither quote nor list
        final blockElement = current.convertToBlockData();
        final delta = current.delta ?? Delta();
        final inlineNodes = delta
            .whereType<TextInsert>()
            .map(
              (textInsert) => convertTextInsertToInlineNode(textInsert),
            )
            .toList();
        final updatedBlockElement =
            blockElement.copyWith(children: inlineNodes);
        result.add(updatedBlockElement);
      },
      -1,
    );

    if (_isLog) {
      for (int i = 0; i < result.length; i++) {
        final node = result[i];
        print("$i - $node");
      }
    }

    return result;
  }
}
