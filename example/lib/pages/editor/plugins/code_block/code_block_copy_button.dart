import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'package:example/pages/editor/plugins/cut_copy_paste/clipboard_service/clipboard_service.dart';
import 'package:flutter/material.dart';

CodeBlockCopyBuilder codeBlockCopyBuilder =
    (_, node) => _CopyButton(node: node);

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.node});

  final Node node;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final delta = node.delta;
        if (delta == null) {
          return;
        }

        final document = Document.blank()
          ..insert([0], [node.copyWith()])
          ..toJson();

        await ClipboardServiceProvider.instance.setData(
          ClipboardServiceData(
            plainText: delta.toPlainText(),
            inAppJson: jsonEncode(document.toJson()),
          ),
        );
      },
      icon: Icon(
        Icons.copy,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        size: 16,
      ),
    );
  }
}
