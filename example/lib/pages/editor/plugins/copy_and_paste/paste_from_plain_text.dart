import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/shared/patterns/common_patterns.dart';

extension PasteFromPlainText on EditorState {
  Future<void> pastePlainText(String plainText) async {
    if (await pasteHtmlIfAvailable(plainText)) {
      return;
    }

    await deleteSelectionIfNeeded();

    final nodes = plainText
        .split('\n')
        .map(
          (e) => e
            ..replaceAll(r'\r', '')
            ..trimRight(),
        )
        .map((e) {
          // parse the url content
          final Attributes attributes = {};
          if (hrefRegex.hasMatch(e)) {
            attributes[AppFlowyRichTextKeys.href] = e;
          }
          return Delta()..insert(e, attributes: attributes);
        })
        .map((e) => paragraphNode(delta: e))
        .toList();
    if (nodes.isEmpty) {
      return;
    }
    if (nodes.length == 1) {
      await pasteSingleLineNode(nodes.first);
    } else {
      await pasteMultiLineNodes(nodes.toList());
    }
  }

  Future<bool> pasteHtmlIfAvailable(String plainText) async {
    final selection = this.selection;
    if (selection == null ||
        !selection.isSingle ||
        selection.isCollapsed ||
        !hrefRegex.hasMatch(plainText)) {
      return false;
    }

    final node = getNodeAtPath(selection.start.path);
    if (node == null) {
      return false;
    }

    final transaction = this.transaction;
    transaction.formatText(node, selection.startIndex, selection.length, {
      AppFlowyRichTextKeys.href: plainText,
    });
    await apply(transaction);
    return true;
  }
}
