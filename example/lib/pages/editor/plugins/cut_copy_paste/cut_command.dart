import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/plugins/cut_copy_paste/copy_command.dart';
import 'package:flutter/material.dart';

final CommandShortcutEvent $cutCommand = CommandShortcutEvent(
  key: 'cut the selected content',
  getDescription: () => AppFlowyEditorL10n.current.cmdCutSelection,
  command: 'ctrl+x',
  macOSCommand: 'cmd+x',
  handler: _cutCommandHandler,
);

CommandShortcutEventHandler _cutCommandHandler = (editorState) {
  $copyCommand.execute(editorState);
  editorState.deleteSelectionIfNeeded();
  return KeyEventResult.handled;
};
