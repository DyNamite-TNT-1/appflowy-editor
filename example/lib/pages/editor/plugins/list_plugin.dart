import 'package:appflowy_editor/appflowy_editor.dart';

extension ListTransforms on EditorState {
  /// format the node as given listType at the given selection.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  Future<void> formatList(
    Selection? selection,
    String listType, {
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
            type: listType,
            children: [],
            attributes: {
              ParagraphBlockKeys.delta: (node.delta ?? Delta()).toJson(),
              blockComponentBackgroundColor:
                  node.attributes[blockComponentBackgroundColor],
              if (listType == TodoListBlockKeys.type)
                TodoListBlockKeys.checked: false,
            },
          ),
        )
        ..deleteNode(node)
        ..afterSelection = transaction.beforeSelection
        ..selectionExtraInfo = selectionExtraInfo;
    }

    return apply(transaction);
  }
}
