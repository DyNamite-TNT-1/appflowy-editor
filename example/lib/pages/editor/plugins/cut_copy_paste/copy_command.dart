import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/cut_copy_paste/clipboard_service/clipboard_service.dart';
import 'package:example/pages/editor/plugins/cut_copy_paste/clipboard_service/clipboard_service_provider.dart';
import 'package:flutter/material.dart';

final CommandShortcutEvent $copyCommand = CommandShortcutEvent(
  key: 'copy the selected content',
  getDescription: () => AppFlowyEditorL10n.current.cmdCopySelection,
  command: 'ctrl+c',
  macOSCommand: 'cmd+c',
  handler: _copyCommandHandler,
);

CommandShortcutEventHandler _copyCommandHandler = (editorState) {
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  // plain text.
  final text = editorState.getTextInSelection(selection).join('\n');

  final nodes = editorState.getSelectedNodes(selection: selection);
  final document = Document.blank()..insert([0], nodes);

  // in app json
  final inAppJson = jsonEncode(document.toJson());

  () async {
    await ClipboardServiceProvider.instance.setData(
      ClipboardServiceData(
        plainText: text,
        inAppJson: inAppJson,
      ),
    );
  }();

  return KeyEventResult.handled;
};
