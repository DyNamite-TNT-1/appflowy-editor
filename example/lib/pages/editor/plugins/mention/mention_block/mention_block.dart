import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mention_user_block.dart';

class MentionBlockKeys {
  const MentionBlockKeys._();

  static const mention = "mention";
  static const userId = "user_id";
  static const userName = 'user_name';
}

Node mentionNode({
  required String userId,
  String? userName,
}) {
  return paragraphNode(
    delta: Delta(
      operations: [
        TextInsert(
          '\$',
          attributes: {
            MentionBlockKeys.mention: {
              MentionBlockKeys.userId: userId,
              MentionBlockKeys.userName: userName,
            },
          },
        ),
      ],
    ),
  );
}

class MentionBlock extends StatelessWidget {
  const MentionBlock({
    super.key,
    required this.mention,
    required this.node,
    required this.index,
    required this.textStyle,
  });

  final Map<String, dynamic> mention;
  final Node node;
  final int index;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();
    final String? userId = mention[MentionBlockKeys.userId] as String?;
    final String? userName = mention[MentionBlockKeys.userName] as String?;
    if (userId == null) {
      return const SizedBox.shrink();
    }

    return MentionUserBlock(
      key: ValueKey(userId),
      editorState: editorState,
      userId: userId,
      userName: userName,
      node: node,
      textStyle: textStyle,
      index: index,
    );
  }
}
