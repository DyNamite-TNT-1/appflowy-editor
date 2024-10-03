import 'package:appflowy_editor/appflowy_editor.dart';

extension ParagraphTransforms on EditorState {
  /// format the node at the given selection.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  Future<void> formatParagraph(
    Selection? selection, {
    Map? selectionExtraInfo,
  }) async {
    selection ??= this.selection;
    selection = selection?.normalized;

    if (selection == null) {
      return;
    }

    final nodes = getNodesInSelection(selection);

    if (nodes.isEmpty) {
      return;
    }

    final transaction = this.transaction;

    for (final node in nodes) {
      transaction
        ..insertNode(
          node.path,
          node.copyWith(
            type: ParagraphBlockKeys.type,
            children: [],
          ),
        )
        ..deleteNode(node)
        ..afterSelection = transaction.beforeSelection
        ..selectionExtraInfo = selectionExtraInfo;
    }

    return apply(transaction);
  }
}
