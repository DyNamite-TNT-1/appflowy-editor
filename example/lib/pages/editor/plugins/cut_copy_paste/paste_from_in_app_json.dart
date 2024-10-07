import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';

extension PasteFromInAppJson on EditorState {
  Future<bool> pasteInAppJson(String inAppJson) async {
    try {
      final nodes = Document.fromJson(jsonDecode(inAppJson)).root.children;
      if (nodes.isEmpty) {
        return false;
      }
      if (nodes.length == 1) {
        await pasteSingleLineNode(nodes.first);
      } else {
        await pasteMultiLineNodes(nodes.toList());
      }
      return true;
    } catch (e) {
      print(
        'Failed to paste in app json: $inAppJson, error: $e',
      );
    }
    return false;
  }
}
