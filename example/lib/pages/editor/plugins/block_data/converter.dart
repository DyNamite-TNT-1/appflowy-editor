import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/block_data/utils/utils.dart';
import 'package:example/pages/editor/utils/node_util.dart';
import 'node.dart' as block;

List<block.Node> convertDocumentToBlockData(Document document) {
  final List<block.Node> result = [];
  final root = document.root;
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
      final updatedBlockElement = blockElement.copyWith(children: inlineNodes);
      result.add(updatedBlockElement);
    },
    -1,
  );

  final rootBlockData = block.BlockNode(
    type: block.NodeTypes.richText,
    children: result,
  );

  // for (int i = 0; i < result.length; i++) {
  //   final node = result[i];
  //   print("$i - $node");
  // }
  return result;
}
