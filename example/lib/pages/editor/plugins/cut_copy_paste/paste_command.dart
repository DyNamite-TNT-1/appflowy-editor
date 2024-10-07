import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/cut_copy_paste/clipboard_service/clipboard_service_provider.dart';
import 'package:example/pages/editor/plugins/cut_copy_paste/paste_from_in_app_json.dart';
import 'package:example/pages/editor/plugins/cut_copy_paste/paste_from_plain_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final clipboardService = ClipboardServiceProvider.instance;
    // Try to paste the content in order, if any of them is failed, then try the next one
    // Order:
    // 1. in app json format
    // 2. plain text

    Future<String?> getInAppJson() async {
      if (await clipboardService.canProvideInAppJson()) {
        return await clipboardService.getInAppJson();
      }
      return null;
    }

    final inAppJson = await getInAppJson();

    if (inAppJson != null && inAppJson.isNotEmpty) {
      await editorState.deleteSelectionIfNeeded();
      if (await editorState.pasteInAppJson(inAppJson)) {
        return;
      }
    }

    Future<String?> getPlainTextFromClipboard() async {
      final plainText = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      return plainText;
    }

    Future<String?> getPlainText() async {
      String? plainText;
      if (await clipboardService.canProvidePlainText()) {
        try {
          plainText = await clipboardService.getPlainText();
        } catch (e) {
          // Sometimes, getPlainText throws error. If that, will retrieve plain text from clipboard.
          // https://github.com/superlistapp/super_native_extensions/issues/396
          plainText = await getPlainTextFromClipboard();
        }
      } else {
        plainText = await getPlainTextFromClipboard();
      }
      return plainText;
    }

    final plainText = await getPlainText();
    if (plainText != null && plainText.isNotEmpty) {
      await editorState.pastePlainText(plainText);
    }
  }();

  return KeyEventResult.handled;
};
