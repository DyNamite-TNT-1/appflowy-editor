import 'package:appflowy_editor/appflowy_editor.dart';

extension ParagraphTransforms on EditorState {
  /// format the node at the given selection.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  Future<void> formatParagraph(
    Selection? selection, {
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

    final firstNode = nodes.first;
    final pathOfFirst = firstNode.path;
    final anchor =
        pathOfFirst.length == 1 ? pathOfFirst.first : pathOfFirst.first + 1;

    for (final node in nodes) {
      final newPath = [anchor + nodes.indexOf(node)];

      final afterSelection = Selection(
        start: selection.start.copyWith(path: [anchor]),
        end: selection.end.copyWith(path: newPath),
      );

      transaction
        ..insertNode(
          // node.path,
          newPath,
          node.copyWith(
            type: ParagraphBlockKeys.type,
            indent: node.path.length - 1,
            children: [],
          ),
        )
        ..deleteNode(node)
        ..afterSelection = afterSelection
        ..selectionExtraInfo = selectionExtraInfo;
    }

    return apply(transaction);
  }
}
