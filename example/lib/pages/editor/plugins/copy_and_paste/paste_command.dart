import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/copy_and_paste/clipboard_service.dart';
import 'package:example/pages/editor/plugins/copy_and_paste/paste_from_html.dart';
import 'package:example/pages/editor/plugins/copy_and_paste/paste_from_in_app_json.dart';
import 'package:example/pages/editor/plugins/copy_and_paste/paste_from_plain_text.dart';
import 'package:flutter/material.dart';

final CommandShortcutEvent $pasteCommand = CommandShortcutEvent(
  key: 'paste the content',
  getDescription: () => AppFlowyEditorL10n.current.cmdPasteContent,
  command: 'ctrl+v',
  macOSCommand: 'cmd+v',
  handler: _pasteCommandHandler,
);

CommandShortcutEventHandler _pasteCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  () async {
    final data = await ClipboardService().getData();
    final inAppJson = data.inAppJson;
    final html = data.html;
    final plainText = data.plainText;

    // Order:
    // 1. in app json format
    // 2. html
    // 3. plain text

    // try to paste the content in order, if any of them is failed, then try the next one
    if (inAppJson != null && inAppJson.isNotEmpty) {
      await editorState.deleteSelectionIfNeeded();
      if (await editorState.pasteInAppJson(inAppJson)) {
        print('Pasted in app json');
        return;
      }
    }

    if (html != null && html.isNotEmpty) {
      await editorState.deleteSelectionIfNeeded();
      if (await editorState.pasteHtml(html)) {
        print('Pasted html');
        return;
      }
    }

    if (plainText != null && plainText.isNotEmpty) {
      print('Pasted plain text');
      await editorState.pastePlainText(plainText);
    }
  }();

  return KeyEventResult.handled;
};
