import 'package:appflowy_editor/appflowy_editor.dart';

final listTypes = {
  BulletedListBlockKeys.type,
  NumberedListBlockKeys.type,
  TodoListBlockKeys.type,
};

extension ListTransforms on EditorState {
  /// format the node at the given selection.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  Future<void> formatList(
    Selection? selection,
    String listType, {
    Map? selectionExtraInfo,
  }) async {
    print("formatNode");
    selection ??= this.selection;
    selection = selection?.normalized;

    if (selection == null) {
      return;
    }

    final nodes = getNodesInSelection(selection);

    print("=============${nodes.length}=============");
    for (var node in nodes) {
      print(node.toJson());
    }
    print("=================================");

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
          ),
        )
        ..deleteNode(node)
        ..afterSelection = transaction.beforeSelection
        ..selectionExtraInfo = selectionExtraInfo;
    }

    return apply(transaction);
  }
}
