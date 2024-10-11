import 'package:appflowy_editor/appflowy_editor.dart';
import '../models/node.dart' as block;
import 'utils.dart';

extension QuoteUtils on Node {
  /// Determines the conversion status of a given [Node] to a block quote data.
  ///
  /// Returns:
  /// - -1 if the node cannot be converted to a block quote data,
  /// - 0 if the node is a block quote and follows another block quote,
  /// - 1 if the node is a block quote and does not follow another block quote.
  int get getBlockQuoteConversionStatus {
    // Check if the node's type is not a block quote
    if (type != QuoteBlockKeys.type) {
      return -1; // Cannot convert if it's not a block quote
    }

    final previous = this.previous;

    // If there's no previous node, conversion is possible
    if (previous == null) {
      return 1;
    }

    // If the previous node is not a block quote, conversion is possible
    if (previous.type != QuoteBlockKeys.type) {
      return 1;
    }

    // If the previous node is also a block quote, no conversion needed
    if (previous.type == QuoteBlockKeys.type) {
      return 0;
    }

    return -1; // Default case (should not reach here)
  }

  block.BlockNode convertNearestBlockQuoteNodesToBlockQuoteData() {
    assert(type == QuoteBlockKeys.type);

    final List<block.InlineNode> inlineNodes = [];

    Node current = this;
    while (current.type == QuoteBlockKeys.type) {
      final delta = current.delta ?? Delta();

      final currentInlineNodes = delta
          .whereType<TextInsert>()
          .map(convertTextInsertToInlineNode)
          .toList();
      inlineNodes.addAll(currentInlineNodes);

      final next = current.next;
      if (next == null || (next.type != QuoteBlockKeys.type)) {
        break;
      }

      current = next;
      inlineNodes.add(block.InlineNode.breakNewLine());
    }

    final quoteBlock = block.BlockNode(
      type: block.NodeTypes.richTextQuote,
      children: inlineNodes,
    );

    return quoteBlock;
  }
}
