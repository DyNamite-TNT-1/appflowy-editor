import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MentionUserBlock extends StatefulWidget {
  const MentionUserBlock({
    super.key,
    required this.editorState,
    required this.index,
    required this.node,
    required this.userId,
    this.userName,
    this.textStyle,
  });

  final EditorState editorState;
  final int index;
  final Node node;
  final String userId;
  final String? userName;
  final TextStyle? textStyle;

  @override
  State<MentionUserBlock> createState() => _MentionUserBlockState();
}

class _MentionUserBlockState extends State<MentionUserBlock> {
  String get userId => widget.userId;

  String? get userName => widget.userName;

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.textStyle?.copyWith(
      color: const Color.fromRGBO(18, 100, 163, 1),
      backgroundColor: const Color.fromRGBO(29, 155, 209, 0.1),
      leadingDistribution: TextLeadingDistribution.even,
    );

    return Text(
      "@${userName ?? userId}",
      style: textStyle,
    );
  }
}
