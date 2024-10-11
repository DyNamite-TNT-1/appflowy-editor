import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/block_data/constants.dart';
import '../models/node.dart' as block;
import 'utils.dart';

extension ListUtils on Node {
  /// Determines the conversion status of a given [Node] to a list data.
  ///
  /// Returns:
  /// - -1 if the node cannot be converted to a list,
  /// - 0 if the node is a list and follows another list with the same indent,
  /// - 1 if the node is a list and does not follow another list or follows a list with a different indent.
  int get getListConversionStatus {
    if (!listTypes.contains(type)) {
      return -1; // Not a list type
    }

    final previous = this.previous;

    if (previous == null) {
      return 1; // No previous node, treat as a new list
    }

    if (previous.type != type) {
      return 1; // Previous node is a different type
    }

    if (previous.type == type) {
      if (previous.indent == indent) {
        return 0; // Same type and indent, no conversion needed
      } else {
        return 1; // Same type but different indent, conversion is possible
      }
    }

    return -1; // Default case (should not reach here)
  }

  block.BlockNode convertNearestListNodesToBlockListData() {
    assert(listTypes.contains(type));

    final List<block.BlockNode> children = [];

    Node current = this;

    while (listTypes.contains(current.type)) {
      final delta = current.delta ?? Delta();

      final currentInlineNodes = delta
          .whereType<TextInsert>()
          .map(convertTextInsertToInlineNode)
          .toList();

      final richTextSection = block.BlockNode(
        type: block.NodeTypes.richTextSection,
        children: currentInlineNodes,
      );
      children.add(richTextSection);

      final next = current.next;
      if (next == null ||
          !listTypes.contains(next.type) ||
          current.type != next.type ||
          current.indent != next.indent) {
        break;
      }

      current = next;
    }

    final listBlock = block.BlockNode(
      type: block.NodeTypes.richTextList,
      children: children,
      metaData: getMetaData,
    );

    return listBlock;
  }
}
